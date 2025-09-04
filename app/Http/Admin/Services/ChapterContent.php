<?php
/**
 * @copyright Copyright (c) 2021 深圳市酷瓜软件有限公司
 * @license https://opensource.org/licenses/GPL-2.0
 * @link https://www.koogua.com
 */

namespace App\Http\Admin\Services;

use App\Caches\CourseChapterList as CatalogCache;
use App\Library\Utils\Word as WordUtil;
use App\Models\Chapter as ChapterModel;
use App\Models\Course as CourseModel;
use App\Repos\Chapter as ChapterRepo;
use App\Repos\Course as CourseRepo;
use App\Services\ChapterVod as ChapterVodService;
use App\Services\CourseStat as CourseStatService;
use App\Validators\ChapterLive as ChapterLiveValidator;
use App\Validators\ChapterOffline as ChapterOfflineValidator;
use App\Validators\ChapterRead as ChapterReadValidator;
use App\Validators\ChapterVod as ChapterVodValidator;

class ChapterContent extends Service
{

    public function getChapterVod($chapterId)
    {
        $chapterRepo = new ChapterRepo();

        return $chapterRepo->findChapterVod($chapterId);
    }

    public function getChapterLive($chapterId)
    {
        $chapterRepo = new ChapterRepo();

        return $chapterRepo->findChapterLive($chapterId);
    }

    public function getChapterRead($chapterId)
    {
        $chapterRepo = new ChapterRepo();

        return $chapterRepo->findChapterRead($chapterId);
    }

    public function getChapterOffline($chapterId)
    {
        $chapterRepo = new ChapterRepo();

        return $chapterRepo->findChapterOffline($chapterId);
    }

    public function getCosPlayUrls($chapterId)
    {
        $service = new ChapterVodService();

        return $service->getCosPlayUrls($chapterId);
    }

    public function getRemotePlayUrls($chapterId)
    {
        $service = new ChapterVodService();

        return $service->getRemotePlayUrls($chapterId);
    }

    public function getRemoteDuration($chapterId)
    {
        $chapterRepo = new ChapterRepo();

        $chapter = $chapterRepo->findById($chapterId);

        $duration = $chapter->attrs['duration'] ?? 0;

        $result = ['hours' => 0, 'minutes' => 0, 'seconds' => 0];

        if ($duration == 0) return $result;

        $result['hours'] = floor($duration / 3600);
        $result['minutes'] = floor(($duration - $result['hours'] * 3600) / 60);
        $result['seconds'] = $duration % 60;

        return $result;
    }

    public function updateChapterContent($chapterId)
    {
        $chapterRepo = new ChapterRepo();
        $chapter = $chapterRepo->findById($chapterId);

        $courseRepo = new CourseRepo();
        $course = $courseRepo->findById($chapter->course_id);

        switch ($course->model) {
            case CourseModel::MODEL_VOD:
                $this->updateChapterVod($chapter);
                break;
            case CourseModel::MODEL_LIVE:
                $this->updateChapterLive($chapter);
                break;
            case CourseModel::MODEL_READ:
                $this->updateChapterRead($chapter);
                break;
            case CourseModel::MODEL_OFFLINE:
                $this->updateChapterOffline($chapter);
                break;
        }

        $this->rebuildCatalogCache($chapter);
    }

    protected function updateChapterVod(ChapterModel $chapter)
    {
        $post = $this->request->getPost();

        if (isset($post['file_id'])) {
            $this->updateCosChapterVod($chapter);
        } elseif (isset($post['file_remote'])) {
            $this->updateRemoteChapterVod($chapter);
        }
    }

    protected function updateCosChapterVod(ChapterModel $chapter)
    {
        $post = $this->request->getPost();

        $validator = new ChapterVodValidator();

        $fileId = $validator->checkFileId($post['file_id']);

        $chapterRepo = new ChapterRepo();

        $vod = $chapterRepo->findChapterVod($chapter->id);

        $attrs = $chapter->attrs;

        if ($fileId != $vod->file_id) {
            $vod->file_id = $fileId;
            $vod->file_transcode = [];
            $vod->update();

            $attrs['file']['status'] = ChapterModel::FS_UPLOADED;
            $attrs['duration'] = 0;
        }

        $chapter->attrs = $attrs;

        $chapter->update();

        $this->updateCourseVodAttrs($vod->course_id);
    }

    protected function updateRemoteChapterVod(ChapterModel $chapter)
    {
        $post = $this->request->getPost();

        $validator = new ChapterVodValidator();

        $hours = $post['file_remote']['duration']['hours'] ?? 0;
        $minutes = $post['file_remote']['duration']['minutes'] ?? 0;
        $seconds = $post['file_remote']['duration']['seconds'] ?? 0;

        $duration = 3600 * $hours + 60 * $minutes + $seconds;

        $validator->checkDuration($duration);

        $hdUrl = $post['file_remote']['hd']['url'] ?? '';
        $sdUrl = $post['file_remote']['sd']['url'] ?? '';
        $fdUrl = $post['file_remote']['fd']['url'] ?? '';

        $fileRemote = [
            'hd' => ['url' => ''],
            'sd' => ['url' => ''],
            'fd' => ['url' => ''],
        ];

        if (!empty($hdUrl)) {
            $fileRemote['hd']['url'] = $validator->checkFileUrl($hdUrl);
        }

        if (!empty($sdUrl)) {
            $fileRemote['sd']['url'] = $validator->checkFileUrl($sdUrl);
        }

        if (!empty($fdUrl)) {
            $fileRemote['fd']['url'] = $validator->checkFileUrl($fdUrl);
        }

        $validator->checkRemoteFile($hdUrl, $sdUrl, $fdUrl);

        $chapterRepo = new ChapterRepo();

        $vod = $chapterRepo->findChapterVod($chapter->id);

        $vod->file_remote = $fileRemote;

        $vod->update();

        $attrs = $chapter->attrs;

        $attrs['file']['status'] = ChapterModel::FS_UPLOADED;
        $attrs['duration'] = $duration;

        $chapter->attrs = $attrs;

        $chapter->update();

        $this->updateCourseVodAttrs($vod->course_id);
    }

    protected function updateChapterLive(ChapterModel $chapter)
    {
        $post = $this->request->getPost();

        $chapterRepo = new ChapterRepo();

        $live = $chapterRepo->findChapterLive($chapter->id);

        $validator = new ChapterLiveValidator();

        $startTime = $validator->checkStartTime($post['start_time']);
        $endTime = $validator->checkEndTime($post['end_time']);

        $validator->checkTimeRange($startTime, $endTime);

        $live->start_time = $startTime;
        $live->end_time = $endTime;

        $live->update();

        $attrs = $chapter->attrs;
        $attrs['start_time'] = $startTime;
        $attrs['end_time'] = $endTime;
        $chapter->attrs = $attrs;

        $chapter->update();

        $this->updateCourseLiveAttrs($live->course_id);
    }

    protected function updateChapterRead(ChapterModel $chapter)
    {
        $post = $this->request->getPost();

        $chapterRepo = new ChapterRepo();

        $read = $chapterRepo->findChapterRead($chapter->id);

        $validator = new ChapterReadValidator();

        $content = $validator->checkContent($post['content']);

        $read->content = $content;

        $read->update();

        $attrs = $chapter->attrs;
        $attrs['word_count'] = WordUtil::getWordCount($content);
        $attrs['duration'] = WordUtil::getWordDuration($content);
        $chapter->attrs = $attrs;

        $chapter->update();

        $this->updateCourseReadAttrs($read->course_id);
    }

    protected function updateChapterOffline(ChapterModel $chapter)
    {
        $post = $this->request->getPost();

        $chapterRepo = new ChapterRepo();

        $offline = $chapterRepo->findChapterOffline($chapter->id);

        $validator = new ChapterOfflineValidator();

        $startTime = $validator->checkStartTime($post['start_time']);
        $endTime = $validator->checkEndTime($post['end_time']);

        $validator->checkTimeRange($startTime, $endTime);

        $offline->start_time = $startTime;
        $offline->end_time = $endTime;

        $offline->update();

        $attrs = $chapter->attrs;
        $attrs['start_time'] = $startTime;
        $attrs['end_time'] = $endTime;
        $chapter->attrs = $attrs;

        $chapter->update();

        $this->updateCourseOfflineAttrs($offline->course_id);
    }

    protected function updateCourseVodAttrs($courseId)
    {
        $statService = new CourseStatService();

        $statService->updateVodAttrs($courseId);
    }

    protected function updateCourseLiveAttrs($courseId)
    {
        $statService = new CourseStatService();

        $statService->updateLiveAttrs($courseId);
    }

    protected function updateCourseReadAttrs($courseId)
    {
        $statService = new CourseStatService();

        $statService->updateReadAttrs($courseId);
    }

    protected function updateCourseOfflineAttrs($courseId)
    {
        $statService = new CourseStatService();

        $statService->updateOfflineAttrs($courseId);
    }

    protected function rebuildCatalogCache(ChapterModel $chapter)
    {
        $cache = new CatalogCache();

        $cache->rebuild($chapter->course_id);
    }

    /**
     * 验证章节文件类型，确保只能上传一种类型的课时
     */
    protected function validateChapterFileTypes($post)
    {
        if (!isset($post['chapter_files']) || !is_array($post['chapter_files'])) {
            return; // 如果没有文件数据，跳过验证
        }

        $filledTypes = [];
        
        // 检查哪些类型的课时信息被填写了
        foreach ($post['chapter_files'] as $type => $fileData) {
            if (!empty($fileData['url'])) {
                $filledTypes[] = $type;
            }
        }

        // 如果填写了超过一种类型的课时信息，抛出异常
        if (count($filledTypes) > 1) {
            $typeNames = [
                'document' => 'PDF文档',
                'exam' => '考试链接',
                'video' => '视频文件'
            ];
            
            $filledTypeNames = array_map(function($type) use ($typeNames) {
                return $typeNames[$type] ?? $type;
            }, $filledTypes);
            
            throw new \RuntimeException(
                '课时信息类型冲突：您同时填写了 ' . implode(' 和 ', $filledTypeNames) . '。' .
                '系统只能处理一种类型的课时信息，请选择其中一种进行上传。'
            );
        }

        // 检查是否同时填写了视频相关信息和文件信息
        $hasVideoInfo = !empty($post['file_remote']['hd']['url']) || 
                       !empty($post['file_remote']['sd']['url']) || 
                       !empty($post['file_remote']['fd']['url']);
        
        $hasFileInfo = count($filledTypes) > 0;
        
        if ($hasVideoInfo && $hasFileInfo) {
            throw new \RuntimeException(
                '课时信息类型冲突：您同时填写了视频信息和文件信息。' .
                '系统只能处理一种类型的课时信息，请选择其中一种进行上传。' .
                '（视频信息：腾讯云视频文件；文件信息：PDF文档或考试链接）'
            );
        }
    }






// 在现有的 ChapterContent 类中添加新方法（不要修改现有方法）

/**
 * 更新章节文件
 */
public function updateChapterFiles($chapterId)
{
    $post = $this->request->getPost();
    
    // 添加调试日志
    error_log('ChapterContent::updateChapterFiles - chapterId: ' . $chapterId);
    error_log('ChapterContent::updateChapterFiles - post data: ' . json_encode($post));
    
    // 验证课时信息类型，确保只能上传一种类型的课时
    $this->validateChapterFileTypes($post);
    
    // 特别检查exam_required_duration字段
    if (isset($post['exam_required_duration'])) {
        error_log('ChapterContent::updateChapterFiles - exam_required_duration found: ' . $post['exam_required_duration']);
    } else {
        error_log('ChapterContent::updateChapterFiles - exam_required_duration NOT found in post data');
    }
    
    // 验证POST数据结构
    if (!is_array($post)) {
        error_log('ChapterContent::updateChapterFiles - post is not array');
        return;
    }
    
    if (!isset($post['chapter_files'])) {
        error_log('ChapterContent::updateChapterFiles - no chapter_files in post');
        return;
    }
    
    if (!is_array($post['chapter_files'])) {
        error_log('ChapterContent::updateChapterFiles - chapter_files is not array');
        return;
    }

    $chapterRepo = new ChapterRepo();
    $chapter = $chapterRepo->findById($chapterId);
    
    if (!$chapter) {
        throw new \RuntimeException('Chapter not found');
    }
    
    $vod = $chapterRepo->findChapterVod($chapter->id);
    
    if (!$vod) {
        throw new \RuntimeException('ChapterVod not found');
    }
    
    $validator = new ChapterVodValidator();
    
    $files = [];
    
    foreach ($post['chapter_files'] as $type => $fileData) {
        error_log('ChapterContent::updateChapterFiles - processing type: ' . $type . ', data: ' . json_encode($fileData));
        
        // 确保 $fileData 是数组
        if (!is_array($fileData)) {
            error_log('ChapterContent::updateChapterFiles - fileData is not array for type: ' . $type);
            continue;
        }
        
        // 设置默认值，确保即使某些字段为空也能正常工作
        $fileData = array_merge([
            'name' => '',
            'description' => '',
            'sort_order' => 0,
            'status' => 1
        ], $fileData);
        
        if (!empty($fileData['url'])) {
            // 验证文件类型
            $validator->checkFileType($type);
            
            // 处理document类型（PDF文档）和exam类型（考试链接）
            if ($type === 'document') {
                $files[$type] = [
                    'url' => $validator->checkPdfFileUrl($fileData['url']), // 使用PDF专用验证
                    'name' => $validator->checkFileName($fileData['name']),
                    'description' => $this->filter->sanitize($fileData['description'], ['trim', 'string']),
                    'sort_order' => intval($fileData['sort_order'])
                ];
            } elseif ($type === 'exam') {
                $files[$type] = [
                    'url' => $validator->checkExamUrl($fileData['url']), // 使用考试链接验证
                    'name' => $validator->checkFileName($fileData['name']),
                    'description' => $this->filter->sanitize($fileData['description'], ['trim', 'string']),
                    'sort_order' => intval($fileData['sort_order']),
                    'status' => $validator->checkExamStatus($fileData['status']), // 验证考试状态
                    // 添加考试时间限制字段
                    'time_limit_hours' => intval($fileData['time_limit_hours'] ?? 0),
                    'time_limit_minutes' => intval($fileData['time_limit_minutes'] ?? 30),
                    'time_limit_seconds' => intval($fileData['time_limit_seconds'] ?? 0)
                ];
            }
            
            error_log('ChapterContent::updateChapterFiles - processed file: ' . json_encode($files[$type]));
        } else {
            error_log('ChapterContent::updateChapterFiles - skipping type ' . $type . ' due to empty URL');
        }
    }
    
    error_log('ChapterContent::updateChapterFiles - final files array: ' . json_encode($files));
    
    // 重要：当保存课程文件时，清空视频相关数据，确保二选一逻辑
    $vod->file_id = '';  // 清空腾讯云视频文件ID
    $vod->file_transcode = [];  // 清空转码信息
    $vod->file_remote = $files;  // 保存课程文件到file_remote字段
    
    if ($vod->update() === false) {
        throw new \RuntimeException('Update ChapterVod failed');
    }
    
    // 更新章节属性（合并文件信息）
    $attrs = $chapter->attrs ?? [];
    
    // 确保attrs是数组格式
    if (is_string($attrs)) {
        $attrs = json_decode($attrs, true) ?: [];
    }
    
    error_log('ChapterContent::updateChapterFiles - original attrs: ' . json_encode($attrs));
    
    // 设置文件相关属性
    $attrs['files'] = $files;
    
    // 确保file属性存在
    if (!isset($attrs['file']) || !is_array($attrs['file'])) {
        $attrs['file'] = [];
        error_log('ChapterContent::updateChapterFiles - created new file array');
    }
    
    error_log('ChapterContent::updateChapterFiles - file array before: ' . json_encode($attrs['file']));
    $attrs['file']['status'] = ChapterModel::FS_UPLOADED;  // 设置文件状态
    error_log('ChapterContent::updateChapterFiles - file array after: ' . json_encode($attrs['file']));
    
    $attrs['duration'] = 0;  // 清空视频时长
    
    // 设置attrs属性
    $chapter->attrs = $attrs;
    
    error_log('ChapterContent::updateChapterFiles - final attrs: ' . json_encode($attrs));
    
    if ($chapter->update() === false) {
        throw new \RuntimeException('Update Chapter failed');
    }
    
    $this->rebuildCatalogCache($chapter);
    
    error_log('ChapterContent::updateChapterFiles - completed successfully');
}

/**
 * 获取章节文件列表
 */
public function getChapterFiles($chapterId)
{
    $chapterRepo = new ChapterRepo();
    $vod = $chapterRepo->findChapterVod($chapterId);
    
    if (!$vod || empty($vod->file_remote)) {
        return [];
    }
    
    return $vod->file_remote;
}





}


