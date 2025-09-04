{% extends 'templates/main.volt' %}

{% block head %}
{% endblock %}

{% block scripts %}
{% endblock %}

{% block content %}

    {% set share_url = share_url('chapter',chapter.id,auth_user.id) %}
    {% set qrcode_url = url({'for':'home.qrcode'},{'text':share_url}) %}
    {% set course_url = url({'for':'home.course.show','id':chapter.course.id}) %}
    {% set learning_url = url({'for':'home.chapter.learning','id':chapter.id}) %}

    <div class="breadcrumb">
        <span class="layui-breadcrumb">
            <a href="{{ course_url }}"><i class="layui-icon layui-icon-return"></i> 返回课程</a>
            <a><cite>{{ chapter.title }}</cite></a>
        </span>
        <span class="share">
            <a class="share-wechat" href="javascript:" title="分享到微信"><i class="layui-icon layui-icon-login-wechat"></i></a>
            <a class="share-qq" href="javascript:" title="分享到QQ空间"><i class="layui-icon layui-icon-login-qq"></i></a>
            <a class="share-weibo" href="javascript:" title="分享到微博"><i class="layui-icon layui-icon-login-weibo"></i></a>
            <a class="share-link kg-copy" href="javascript:" title="复制链接" data-clipboard-text="{{ share_url }}"><i class="layui-icon layui-icon-share"></i></a>
        </span>
    </div>

    <div class="layout-main">
        <div class="layout-content">
            <!-- 二选一显示逻辑：视频章节显示播放器，文件章节显示文件 -->
            {% if chapter.files is defined and chapter.files and (chapter.files.document.url|default('') != '' or chapter.files.exam.url|default('') != '') %}
                <!-- 有文件时，只显示文件内容 -->
                <div class="file-display wrap">
                    <div class="file-container">
                        {% for type, file in chapter.files %}
                            {% if file.url != '' %}
                                <div class="file-viewer">
                                    <div class="file-header">
                                        <h3>{{ file.name }}</h3>
                                        {% if file.description %}
                                            <p class="file-desc">{{ file.description }}</p>
                                        {% endif %}
                                    </div>
                                    <div class="file-content">
                                        {% if type == 'document' %}
                                            <!-- PDF文档直接嵌入显示 -->
                                            <iframe src="{{ file.url }}" width="100%" height="800" frameborder="0"></iframe>
                                        {% elseif type == 'exam' %}
                                            <div class="exam-content-display">
                                                <!-- 考试按钮 - 根据学习时长和时间限制判断 -->
                                                {% if file.status == 1 %}
                                                    {% set time_limit_hours = file.time_limit_hours is defined ? file.time_limit_hours : 0 %}
                                                    {% set time_limit_minutes = file.time_limit_minutes is defined ? file.time_limit_minutes : 0 %}
                                                    {% set time_limit_seconds = file.time_limit_seconds is defined ? file.time_limit_seconds : 0 %}
                                                    {% set time_limit_total = (time_limit_hours * 3600) + (time_limit_minutes * 60) + time_limit_seconds %}
                                                    {% set user_study_time = chapter.course.me.duration is defined ? chapter.course.me.duration : 0 %}
                                                    
                                                    {% if time_limit_total == 0 or user_study_time >= time_limit_total %}
                                                        <!-- 无时间限制或已达到学习时长要求 -->
                                                        <div class="exam-progress-section exam-completed">
                                                            <div class="progress-label">
                                                                <h4>{% if file.name %}{{ file.name }}{% else %}在线考试{% endif %}</h4>
                                                                {% if file.description %}
                                                                    <p class="exam-desc">{{ file.description }}</p>
                                                                {% endif %}
                                                                <span class="status-badge status-enabled">启用</span>
                                                            </div>
                                                            <div class="progress-container">
                                                                <div class="layui-progress layui-progress-big" lay-showpercent="true">
                                                                    <div class="layui-progress-bar" lay-percent="100%" style="width: 100%;"></div>
                                                                </div>
                                                            </div>
                                                            <div class="exam-actions">
                                                                <a href="{{ file.url }}" class="layui-btn layui-btn-normal exam-btn" target="_blank">
                                                                    <i class="layui-icon layui-icon-link"></i> 进入考试
                                                                </a>
                                                                {% if time_limit_total > 0 %}
                                                                    <div class="exam-status-info">
                                                                        <i class="layui-icon layui-icon-ok-circle"></i>
                                                                        已满足学习时长要求
                                                                    </div>
                                                                {% endif %}
                                                            </div>
                                                        </div>
                                                    {% else %}
                                                        <!-- 未达到学习时长要求 -->
                                                        <div class="exam-progress-section exam-incomplete">
                                                            <div class="progress-label">
                                                                <h4>{% if file.name %}{{ file.name }}{% else %}在线考试{% endif %}</h4>
                                                                {% if file.description %}
                                                                    <p class="exam-desc">{{ file.description }}</p>
                                                                {% endif %}
                                                                <span class="status-badge status-enabled">启用</span>
                                                            </div>
                                                            <div class="progress-container">
                                                                <div class="layui-progress layui-progress-big" lay-showpercent="true">
                                                                    <div class="layui-progress-bar" lay-percent="0%" id="progress-bar-{{ chapter.id }}"></div>
                                                                </div>
                                                            </div>
                                                            <div class="remaining-time">
                                                                还需学习 <span id="remaining-minutes-{{ chapter.id }}">0</span> 分钟
                                                            </div>
                                                            <div class="exam-actions">
                                                                <button class="layui-btn layui-btn-disabled" disabled="disabled">
                                                                    <i class="layui-icon layui-icon-time"></i> 学习时长不足
                                                                </button>
                                                            </div>
                                                        </div>
                                                    {% endif %}
                                                {% else %}
                                                    <div class="exam-progress-section exam-disabled">
                                                        <div class="progress-label">
                                                            <h4>{% if file.name %}{{ file.name }}{% else %}在线考试{% endif %}</h4>
                                                            {% if file.description %}
                                                                <p class="exam-desc">{{ file.description }}</p>
                                                            {% endif %}
                                                            <span class="status-badge status-disabled">禁用</span>
                                                        </div>
                                                        <div class="exam-actions">
                                                            <div class="exam-locked">
                                                                <i class="layui-icon layui-icon-close"></i>
                                                                <span>考试已禁用</span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                {% endif %}
                                            </div>
                                        {% else %}
                                            <!-- 其他类型文件显示下载链接 -->
                                            <div class="file-content-display">
                                                <div class="file-icon">
                                                    <i class="layui-icon layui-icon-file"></i>
                                                </div>
                                                <div class="file-text">
                                                    <h4>{{ file.name }}</h4>
                                                    <p>此文件类型无法直接预览，请下载后查看</p>
                                                    <a href="{{ file.url }}" class="layui-btn layui-btn-primary" target="_blank">
                                                        <i class="layui-icon layui-icon-download-circle"></i> 下载文件
                                                    </a>
                                                </div>
                                            </div>
                                        {% endif %}
                                    </div>
                                </div>
                            {% endif %}
                        {% endfor %}
                    </div>
                </div>
            {% elseif chapter.play_urls is defined and chapter.play_urls %}
                <!-- 视频播放器 -->
                <div class="video-player-container">
                    <div id="player" class="dplayer"></div>
                    <div id="play-mask" class="play-mask">
                        <i class="layui-icon layui-icon-play"></i>
                    </div>
                </div>
            {% else %}
                <!-- 既没有文件也没有视频时，显示提示 -->
                <div class="empty-content wrap">
                    <div class="layui-text" style="text-align: center; padding: 40px 20px; color: #999;">
                        <i class="layui-icon layui-icon-face-cry" style="font-size: 48px; margin-bottom: 20px;"></i>
                        <p>该章节暂无内容</p>
                    </div>
                </div>
            {% endif %}

            <div id="comment-anchor"></div>
            <div class="vod-comment wrap">
                {{ partial('chapter/comment') }}
            </div>
        </div>
        <div class="layout-sidebar">
            {{ partial('chapter/catalog') }}
        </div>
    </div>

    <div class="layout-sticky">
        {{ partial('chapter/sticky') }}
    </div>

    <div class="layui-hide">
        <input type="hidden" name="chapter.id" value="{{ chapter.id }}">
        <input type="hidden" name="chapter.cover" value="{{ chapter.course.cover }}">
        <input type="hidden" name="chapter.learning_url" value="{{ learning_url }}">
        {% if chapter.play_urls is defined %}
            <input type="hidden" name="chapter.play_urls" value='{{ chapter.play_urls|json_encode }}'>
        {% endif %}
        <input type="hidden" name="chapter.me.position" value="{{ chapter.me.position }}">
        <input type="hidden" name="chapter.me.plan_id" value="{{ chapter.me.plan_id }}">
    </div>

    <div class="layui-hide">
        <input type="hidden" name="share.title" value="{{ chapter.course.title }}">
        <input type="hidden" name="share.pic" value="{{ chapter.course.cover }}">
        <input type="hidden" name="share.url" value="{{ share_url }}">
        <input type="hidden" name="share.qrcode" value="{{ qrcode_url }}">
    </div>

{% endblock %}

{% block include_js %}

    {{ js_include('lib/clipboard.min.js') }}
    {{ js_include('lib/dplayer/hls.min.js') }}
    {{ js_include('lib/dplayer/DPlayer.min.js') }}
    {{ js_include('home/js/course.share.js') }}
    {{ js_include('home/js/chapter.show.js') }}
    {{ js_include('home/js/chapter.vod.player.js?v=' ~ timestamp) }}
    {{ js_include('home/js/comment.js') }}
    {{ js_include('home/js/copy.js') }}

    <script>
        // 初始化Layui进度条
        layui.use(['element'], function(){
            var element = layui.element;
            

            
            // 处理所有考试文件的进度条
            var chapterId = {{ chapter.id }};
            var progressBar = document.getElementById('progress-bar-' + chapterId);
            var remainingSpan = document.getElementById('remaining-minutes-' + chapterId);
            
            if (progressBar && remainingSpan) {
                // 获取当前考试章节的时间限制（每个考试章节不同）
                var examData = {
                    time_limit_hours: {{ file.time_limit_hours is defined ? file.time_limit_hours : 0 }},
                    time_limit_minutes: {{ file.time_limit_minutes is defined ? file.time_limit_minutes : 0 }},
                    time_limit_seconds: {{ file.time_limit_seconds is defined ? file.time_limit_seconds : 0 }}
                };
                
                // 获取整个课程的学习时长（从课程用户记录获取，与个人主页一致）
                var courseStudyTime = {{ chapter.course.me.duration is defined ? chapter.course.me.duration : 0 }};
                
                // 调试信息
                console.log('Chapter ID:', chapterId);
                console.log('Course Study Time:', courseStudyTime);
                console.log('Exam Time Limit:', examData);
                
                // 计算总时间限制（秒）
                var totalTimeLimit = (examData.time_limit_hours * 3600) + (examData.time_limit_minutes * 60) + examData.time_limit_seconds;
                
                if (totalTimeLimit > 0) {
                    // 计算进度百分比（使用课程学习时长）
                    var progressPercent = Math.min(100, Math.round((courseStudyTime / totalTimeLimit) * 100));
                    
                    console.log('Total Time Limit (seconds):', totalTimeLimit);
                    console.log('Progress Percent:', progressPercent);
                    
                    // 更新进度条
                    progressBar.setAttribute('lay-percent', progressPercent + '%');
                    progressBar.style.width = progressPercent + '%';
                    
                    // 计算剩余时间（使用课程学习时长）
                    var remainingTime = Math.max(0, totalTimeLimit - courseStudyTime);
                    var remainingMinutes = Math.ceil(remainingTime / 60);
                    
                    // 更新剩余时间显示
                    remainingSpan.textContent = remainingMinutes;
                } else {
                    // 无时间限制
                    progressBar.setAttribute('lay-percent', '100%');
                    progressBar.style.width = '100%';
                    remainingSpan.textContent = '0';
                }
            }
            
            // 重新渲染进度条
            element.render('progress');
        });
    </script>

{% endblock %}

{% block inline_css %}
<style>
/* 文件显示区域样式优化 */
.file-display {
    margin: 20px 0;
}

.file-container {
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    overflow: hidden;
}

.file-viewer {
    margin-bottom: 0;
}

.file-header {
    background: #f8f9fa;
    padding: 15px 20px;
    border-bottom: 1px solid #e9ecef;
}

.file-header h3 {
    margin: 0;
    color: #333;
    font-size: 18px;
    font-weight: 600;
}

.file-desc {
    margin: 8px 0 0 0;
    color: #666;
    font-size: 14px;
}

.file-content {
    padding: 0;
    background: #fff;
}

.file-content iframe {
    border: none;
    width: 100%;
    height: 800px; /* 增加高度 */
    min-height: 600px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

/* 考试相关样式美化 */
.exam-content-display {
    padding: 25px;
    text-align: center;
}

/* 状态标签样式 - 不像按钮 */
.status-badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 500;
    text-align: center;
    min-width: 40px;
}

.status-enabled {
    background: #f0f9ff;
    color: #1E9FFF;
    border: 1px solid #b3d8ff;
}

.status-disabled {
    background: #f5f5f5;
    color: #999;
    border: 1px solid #e0e0e0;
}

/* 考试按钮样式 */
.exam-btn {
    margin: 15px 0;
    padding: 12px 30px;
    font-size: 16px;
    border-radius: 6px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
    height: auto;
    min-height: 44px;
}

.exam-btn i {
    margin-right: 8px;
    font-size: 16px;
    line-height: 1;
}

.exam-btn span {
    line-height: 1;
    vertical-align: middle;
}

/* 考试状态信息 */
.exam-status-info {
    margin-top: 15px;
    padding: 12px 20px;
    background: #f6ffed;
    border: 1px solid #b7eb8f;
    border-radius: 6px;
    color: #52c41a;
    font-size: 14px;
}

.exam-status-info i {
    margin-right: 8px;
    color: #52c41a;
}

/* 进度条区域 - 现在占据整个宽度 */
.exam-progress-section {
    width: 100%;
    padding: 30px;
    background: #fafafa;
    border-radius: 8px;
    border: 1px solid #f0f0f0;
    text-align: center;
    margin-top: 20px;
}

/* 已完成状态 */
.exam-completed {
    background: #f6ffed;
    border-color: #b7eb8f;
}

/* 未完成状态 */
.exam-incomplete {
    background: #fafafa;
    border-color: #f0f0f0;
}

/* 禁用状态 */
.exam-disabled {
    background: #f5f5f5;
    border-color: #e0e0e0;
}

.progress-label {
    text-align: center;
    margin-bottom: 25px;
}

.progress-label h4 {
    margin: 0 0 10px 0;
    color: #333;
    font-size: 20px;
    font-weight: 600;
}

.exam-desc {
    margin: 0 0 15px 0;
    color: #666;
    font-size: 14px;
    line-height: 1.5;
}

.progress-container {
    margin-bottom: 20px;
}

/* 拉长进度条 */
.layui-progress {
    height: 16px;
    border-radius: 8px;
    background: #f0f0f0;
    overflow: hidden;
}

.layui-progress-bar {
    height: 16px;
    border-radius: 8px;
    background: linear-gradient(90deg, #1E9FFF, #5FB878);
    transition: width 0.3s ease;
}

.remaining-time {
    font-size: 14px;
    color: #666;
    text-align: center;
    padding: 10px;
    background: #fff;
    border-radius: 6px;
    border: 1px solid #e8e8e8;
    margin-bottom: 20px;
}

.remaining-time span {
    color: #1E9FFF;
    font-weight: 600;
    font-size: 16px;
}

/* 考试操作区域 */
.exam-actions {
    text-align: center;
    margin-top: 20px;
}

/* 考试锁定状态 */
.exam-locked {
    display: inline-flex;
    align-items: center;
    padding: 15px 25px;
    background: #fff2e8;
    border: 1px solid #ffbb96;
    border-radius: 6px;
    color: #fa8c16;
    font-size: 14px;
}

.exam-locked i {
    margin-right: 8px;
    font-size: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
    .file-content iframe {
        height: 600px;
        min-height: 400px;
    }
    
    .exam-content-display {
        padding: 20px 15px;
    }
    
    .exam-progress-section {
        padding: 15px;
    }
}

@media (max-width: 480px) {
    .file-content iframe {
        height: 500px;
        min-height: 300px;
    }
    
    .exam-content-display {
        padding: 15px 10px;
    }
    
    .exam-progress-section {
        padding: 12px;
    }
}
</style>
{% endblock %}


