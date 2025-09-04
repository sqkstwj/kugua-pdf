<?php
/**
 * @copyright Copyright (c) 2021 深圳市酷瓜软件有限公司
 * @license https://opensource.org/licenses/GPL-2.0
 * @link https://www.koogua.com
 */

namespace App\Services\Logic\Chapter;

use App\Models\Learning as LearningModel;
use App\Repos\Learning as LearningRepo;
use App\Services\Logic\Service as LogicService;
use App\Services\Logic\UserTrait;

class ChapterExam extends LogicService
{
    use UserTrait;

    /**
     * 检查用户是否有权限参加考试
     *
     * @param int $chapterId 章节ID
     * @param int $userId 用户ID
     * @param int $requiredDuration 要求的观看时长（秒）
     * @return array
     */
    public function checkExamPermission($chapterId, $userId, $requiredDuration = 0)
    {
        $user = $this->getLoginUser(true);
        
        if ($user->id != $userId) {
            return [
                'allowed' => false,
                'message' => '用户身份验证失败',
                'watched_duration' => 0,
                'required_duration' => $requiredDuration,
                'progress' => 0
            ];
        }

        // 获取用户在该章节的总观看时长
        $watchedDuration = $this->getChapterWatchedDuration($chapterId, $userId);
        
        // 如果没有设置要求时长，默认允许参加考试
        if ($requiredDuration <= 0) {
            return [
                'allowed' => true,
                'message' => '可以参加考试',
                'watched_duration' => $watchedDuration,
                'required_duration' => $requiredDuration,
                'progress' => 100
            ];
        }

        // 检查观看时长是否达到要求
        $allowed = $watchedDuration >= $requiredDuration;
        $progress = min(100, round(($watchedDuration / $requiredDuration) * 100, 2));

        return [
            'allowed' => $allowed,
            'message' => $allowed ? '可以参加考试' : '观看时长不足，无法参加考试',
            'watched_duration' => $watchedDuration,
            'required_duration' => $requiredDuration,
            'progress' => $progress
        ];
    }

    /**
     * 获取用户在指定章节的总观看时长
     *
     * @param int $chapterId 章节ID
     * @param int $userId 用户ID
     * @return int 观看时长（秒）
     */
    public function getChapterWatchedDuration($chapterId, $userId)
    {
        $learningRepo = new LearningRepo();
        
        // 查询该用户在该章节的所有学习记录
        $learnings = LearningModel::find([
            'conditions' => 'chapter_id = :chapter_id: AND user_id = :user_id:',
            'bind' => [
                'chapter_id' => $chapterId,
                'user_id' => $userId
            ]
        ]);

        if (!$learnings) {
            return 0;
        }

        $totalDuration = 0;
        
        foreach ($learnings as $learning) {
            // 累加每次学习的时长
            $totalDuration += $learning->duration;
        }

        return $totalDuration;
    }

    /**
     * 获取章节考试配置信息
     *
     * @param int $chapterId 章节ID
     * @return array|null
     */
    public function getChapterExamConfig($chapterId)
    {
        $chapterRepo = new \App\Repos\Chapter();
        $vod = $chapterRepo->findChapterVod($chapterId);
        
        if (!$vod || empty($vod->file_remote) || !isset($vod->file_remote['exam'])) {
            return null;
        }

        $examConfig = $vod->file_remote['exam'];
        
        // 从章节属性中获取考试要求时长
        $chapter = $chapterRepo->findById($chapterId);
        $attrs = $chapter->attrs ?? [];
        $requiredDuration = $attrs['exam_required_duration'] ?? 0;

        return [
            'name' => $examConfig['name'] ?? '',
            'url' => $examConfig['url'] ?? '',
            'description' => $examConfig['description'] ?? '',
            'status' => $examConfig['status'] ?? 1,
            'required_duration' => $requiredDuration,
            'sort_order' => $examConfig['sort_order'] ?? 0
        ];
    }

    /**
     * 更新章节考试配置
     *
     * @param int $chapterId 章节ID
     * @param array $examConfig 考试配置
     * @return bool
     */
    public function updateChapterExamConfig($chapterId, $examConfig)
    {
        $chapterRepo = new \App\Repos\Chapter();
        $chapter = $chapterRepo->findById($chapterId);
        
        if (!$chapter) {
            return false;
        }

        $attrs = $chapter->attrs ?? [];
        $attrs['exam_required_duration'] = intval($examConfig['required_duration'] ?? 0);
        $chapter->attrs = $attrs;

        return $chapter->update() !== false;
    }
}

