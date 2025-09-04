{% set action_url = url({'for':'admin.chapter.content','id':chapter.id}) %}

{% if vod.file_id is defined %}
    {% set file_id = vod.file_id %}
{% else %}
    {% set file_id = '' %}
{% endif %}

<!-- 重要提示 -->
<div class="layui-alert layui-alert-warning" style="margin-bottom: 20px;">
    <i class="layui-icon layui-icon-tips"></i>
    <strong>重要提示：</strong>课时信息只能选择一种类型进行上传，不能同时上传多种类型。
    <br><br>
    <strong>可选择的类型：</strong>
    <ul style="margin: 10px 0; padding-left: 20px;">
        <li><strong>视频内容：</strong>腾讯云视频文件或外链视频（支持多清晰度）</li>
        <li><strong>课程文件：</strong>PDF文档文件</li>
        <li><strong>考试链接：</strong>在线考试平台链接</li>
    </ul>
</div>

<div class="layui-tab layui-tab-brief">
    <ul class="layui-tab-title kg-tab-title">
        <li class="layui-this">视频内容</li>
        <li>课程文件</li>
        <li>考试链接</li>
    </ul>
    <div class="layui-tab-content">
        <!-- 视频内容标签页 -->
        <div class="layui-tab-item layui-show">
            <!-- 腾讯云点播 -->
            <div class="layui-tab layui-tab-brief" style="margin-top: 0;">
                <ul class="layui-tab-title">
                    <li class="layui-this">腾讯云点播</li>
                    <li>外链云点播</li>
                </ul>
                <div class="layui-tab-content">
                    <div class="layui-tab-item layui-show">
                        {% if cos_play_urls %}
                            <fieldset class="layui-elem-field layui-field-title">
                                <legend>视频信息</legend>
                            </fieldset>
                            <table class="kg-table layui-table">
                                <tr>
                                    <th>格式</th>
                                    <th>时长</th>
                                    <th>分辨率</th>
                                    <th>码率</th>
                                    <th>大小</th>
                                    <th width="16%">操作</th>
                                </tr>
                                {% for item in cos_play_urls %}
                                    <tr>
                                        <td>{{ item.format }}</td>
                                        <td>{{ item.duration|duration }}</td>
                                        <td>{{ item.width }} x {{ item.height }}</td>
                                        <td>{{ item.rate }}kbps</td>
                                        <td>{{ item.size }}M</td>
                                        <td>
                                            <span class="layui-btn kg-preview" data-chapter-id="{{ chapter.id }}" data-play-url="{{ item.url|url_encode }}">预览</span>
                                            <span class="layui-btn layui-btn-primary kg-copy" data-clipboard-text="{{ item.url }}">复制</span>
                                        </td>
                                    </tr>
                                {% endfor %}
                            </table>
                            <br>
                        {% endif %}
                        <form class="layui-form kg-form" id="vod-form" method="POST" action="{{ action_url }}">
                            <fieldset class="layui-elem-field layui-field-title">
                                <legend>上传视频</legend>
                            </fieldset>
                            <div class="layui-form-item" id="upload-block">
                                <label class="layui-form-label">视频文件</label>
                                <div class="layui-input-inline">
                                    <input class="layui-input" type="text" name="file_id" value="{{ file_id }}" readonly="readonly" lay-verify="required">
                                </div>
                                <div class="layui-inline">
                                    {% if vod.file_id > 0 %}
                                        <span class="layui-btn" id="upload-btn">重新上传</span>
                                    {% else %}
                                        <span class="layui-btn" id="upload-btn">选择视频</span>
                                    {% endif %}
                                    <input class="layui-hide" type="file" name="file" accept="video/*,audio/*">
                                </div>
                            </div>
                            <div class="layui-form-item layui-hide" id="upload-progress-block">
                                <label class="layui-form-label">上传进度</label>
                                <div class="layui-input-block">
                                    <div class="layui-progress layui-progress-big" lay-showpercent="yes" lay-filter="upload-progress" style="top:10px;">
                                        <div class="layui-progress-bar" lay-percent="0%"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="layui-form-item">
                                <label class="layui-form-label"></label>
                                <div class="layui-input-block">
                                    <button id="vod-submit" class="layui-btn layui-btn-disabled" disabled="disabled" lay-submit="true" lay-filter="go">提交</button>
                                    <button type="button" class="kg-back layui-btn layui-btn-primary">返回</button>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="layui-tab-item">
                        <form class="layui-form kg-form" method="POST" action="{{ action_url }}">
                            <fieldset class="layui-elem-field layui-field-title">
                                <legend>外链视频</legend>
                            </fieldset>
                            <div class="layui-form-item">
                                <label class="layui-form-label">视频时长</label>
                                <div class="layui-input-block">
                                    <div class="layui-inline">
                                        <select name="file_remote[duration][hours]">
                                            {% for value in 0..10 %}
                                                {% set selected = value == remote_duration.hours ? 'selected="selected"' : '' %}
                                                <option value="{{ value }}" {{ selected }}>{{ value }}小时</option>
                                            {% endfor %}
                                        </select>
                                    </div>
                                    <div class="layui-inline">
                                        <select name="file_remote[duration][minutes]">
                                            {% for value in 0..59 %}
                                                {% set selected = value == remote_duration.minutes ? 'selected="selected"' : '' %}
                                                <option value="{{ value }}" {{ selected }}>{{ value }}分钟</option>
                                            {% endfor %}
                                        </select>
                                    </div>
                                    <div class="layui-inline">
                                        <select name="file_remote[duration][seconds]">
                                            {% for value in 0..59 %}
                                                {% set selected = value == remote_duration.seconds ? 'selected="selected"' : '' %}
                                                <option value="{{ value }}" {{ selected }}>{{ value }}秒</option>
                                            {% endfor %}
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="layui-form-item">
                                <label class="layui-form-label">高清地址</label>
                                {% if remote_play_urls.hd.url %}
                                    <div class="layui-inline" style="width:55%;">
                                        <input id="tc-hd-url" class="layui-input" type="text" name="file_remote[hd][url]" value="{{ remote_play_urls.hd.url }}">
                                    </div>
                                    <div class="layui-inline">
                                        <span class="layui-btn kg-preview" data-chapter-id="{{ chapter.id }}" data-play-url="{{ remote_play_urls.hd.url }}">预览</span>
                                        <span class="layui-btn layui-btn-primary kg-copy" data-clipboard-target="#tc-hd-url">复制</span>
                                    </div>
                                {% else %}
                                    <div class="layui-inline" style="width:55%;">
                                        <input id="tc-hd-url" class="layui-input" type="text" name="file_remote[hd][url]" value="">
                                    </div>
                                    <div class="layui-inline">
                                        <span class="layui-btn layui-btn-disabled">预览</span>
                                        <span class="layui-btn layui-btn-disabled">复制</span>
                                    </div>
                                {% endif %}
                            </div>
                            <div class="layui-form-item">
                                <label class="layui-form-label">标清地址</label>
                                {% if remote_play_urls.sd.url %}
                                    <div class="layui-inline" style="width:55%;">
                                        <input id="tc-sd-url" class="layui-input" type="text" name="file_remote[sd][url]" value="{{ remote_play_urls.sd.url }}">
                                    </div>
                                    <div class="layui-inline">
                                        <span class="layui-btn kg-preview" data-chapter-id="{{ chapter.id }}" data-play-url="{{ remote_play_urls.sd.url }}">预览</span>
                                        <span class="layui-btn layui-btn-primary kg-copy" data-clipboard-target="#tc-sd-url">复制</span>
                                    </div>
                                {% else %}
                                    <div class="layui-inline" style="width:55%;">
                                        <input id="tc-sd-url" class="layui-input" type="text" name="file_remote[sd][url]" value="">
                                    </div>
                                    <div class="layui-inline">
                                        <span class="layui-btn layui-btn-disabled">预览</span>
                                        <span class="layui-btn layui-btn-disabled">复制</span>
                                    </div>
                                {% endif %}
                            </div>
                            <div class="layui-form-item">
                                <label class="layui-form-label">极速地址</label>
                                {% if remote_play_urls.fd.url %}
                                    <div class="layui-inline" style="width:55%;">
                                        <input id="tc-fd-url" class="layui-input" type="text" name="file_remote[fd][url]" value="{{ remote_play_urls.fd.url }}">
                                    </div>
                                    <div class="layui-inline">
                                        <span class="layui-btn kg-preview" data-chapter-id="{{ chapter.id }}" data-play-url="{{ remote_play_urls.hd.url }}">预览</span>
                                        <span class="layui-btn layui-btn-primary kg-copy" data-clipboard-target="#tc-fd-url">复制</span>
                                    </div>
                                {% else %}
                                    <div class="layui-inline" style="width:55%;">
                                        <input id="tc-fd-url" class="layui-input" type="text" name="file_remote[fd][url]" value="">
                                    </div>
                                    <div class="layui-inline">
                                        <span class="layui-btn layui-btn-disabled">预览</span>
                                        <span class="layui-btn layui-btn-disabled">复制</span>
                                    </div>
                                {% endif %}
                            </div>
                            <div class="layui-form-item">
                                <label class="layui-form-label"></label>
                                <div class="layui-input-block">
                                    <button class="layui-btn" lay-submit="true" lay-filter="go">提交</button>
                                    <button type="button" class="kg-back layui-btn layui-btn-primary">返回</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- 课程文件标签页 -->
        <div class="layui-tab-item">
            <div class="layui-alert layui-alert-info" style="margin-bottom: 20px;">
                <i class="layui-icon layui-icon-help"></i>
                <strong>格式要求：</strong>仅支持PDF格式文件，其他格式将无法上传。
            </div>
            
            <form class="layui-form kg-form" method="POST" action="{{ action_url }}">
                <fieldset class="layui-elem-field layui-field-title">
                    <legend>课程文件</legend>
                </fieldset>
                
                <!-- 文档文件 -->
                <div class="layui-form-item">
                    <label class="layui-form-label">PDF文档</label>
                    <div class="layui-input-block">
                        <input type="text" name="chapter_files[document][name]" class="layui-input" 
                               placeholder="文档名称（如：课程大纲.pdf）" value="{{ chapter_files.document.name|default('') }}">
                        <input type="url" name="chapter_files[document][url]" class="layui-input" 
                               placeholder="PDF文件链接，必须以.pdf结尾" 
                               value="{{ chapter_files.document.url|default('') }}">
                        <textarea name="chapter_files[document][description]" class="layui-textarea" 
                                  placeholder="文档描述（可选）">{{ chapter_files.document.description|default('') }}</textarea>
                        <input type="number" name="chapter_files[document][sort_order]" class="layui-input" 
                               placeholder="排序顺序（数字越小越靠前）" 
                               value="{{ chapter_files.document.sort_order|default(0) }}" min="0">
                        <div class="layui-form-mid layui-word-aux">
                            <i class="layui-icon layui-icon-ok-circle" style="color: #5FB878;"></i>
                            仅支持PDF格式，文件链接必须以.pdf结尾
                        </div>
                        <div class="layui-form-mid layui-word-aux">
                            <i class="layui-icon layui-icon-help" style="color: #1E9FFF;"></i>
                            排序顺序：数字越小越靠前显示，相同数字按添加时间排序
                        </div>
                    </div>
                </div>
                
                <div class="layui-form-item">
                    <div class="layui-input-block">
                        <button class="layui-btn" lay-submit="true" lay-filter="go">保存文件</button>
                        <button type="button" class="kg-back layui-btn layui-btn-primary">返回</button>
                    </div>
                </div>
            </form>
        </div>
        
        <!-- 考试链接标签页 -->
        <div class="layui-tab-item">
            <div class="layui-alert layui-alert-info" style="margin-bottom: 20px;">
                <i class="layui-icon layui-icon-help"></i>
                <strong>格式要求：</strong>支持各种在线考试平台的链接，如问卷星、腾讯问卷等。
            </div>
            
            <form class="layui-form kg-form" method="POST" action="{{ action_url }}">
                <fieldset class="layui-elem-field layui-field-title">
                    <legend>考试链接</legend>
                </fieldset>
                
                <!-- 考试链接 -->
                <div class="layui-form-item">
                    <label class="layui-form-label">考试名称</label>
                    <div class="layui-input-block">
                        <input type="text" name="chapter_files[exam][name]" class="layui-input" 
                               placeholder="考试名称（如：第一章测试）" 
                               value="{{ (chapter_files.exam is defined and chapter_files.exam.name) ? chapter_files.exam.name : '' }}">
                    </div>
                </div>
                
                <div class="layui-form-item">
                    <label class="layui-form-label">考试链接</label>
                    <div class="layui-input-block">
                        <input type="url" name="chapter_files[exam][url]" class="layui-input" 
                               placeholder="在线考试链接地址" 
                               value="{{ (chapter_files.exam is defined and chapter_files.exam.url) ? chapter_files.exam.url : '' }}">
                    </div>
                </div>
                
                <div class="layui-form-item">
                    <label class="layui-form-label">考试描述</label>
                    <div class="layui-input-block">
                        <textarea name="chapter_files[exam][description]" class="layui-textarea" 
                                  placeholder="考试说明（可选）">{{ (chapter_files.exam is defined and chapter_files.exam.description) ? chapter_files.exam.description : '' }}</textarea>
                    </div>
                </div>
                
                <div class="layui-form-item">
                    <label class="layui-form-label">考试状态</label>
                    <div class="layui-input-block">
                        <input type="radio" name="chapter_files[exam][status]" value="1" title="启用" 
                               {{ (chapter_files.exam is defined and chapter_files.exam.status == 1) ? 'checked' : '' }}>
                        <input type="radio" name="chapter_files[exam][status]" value="0" title="禁用" 
                               {{ (chapter_files.exam is defined and chapter_files.exam.status == 0) ? 'checked' : '' }}>
                    </div>
                </div>
                
                <div class="layui-form-item">
                    <label class="layui-form-label">时间限制</label>
                    <div class="layui-input-block">
                        <div class="layui-row layui-col-space10">
                            <div class="layui-col-md4">
                                <input type="number" name="chapter_files[exam][time_limit_hours]" class="layui-input" 
                                       placeholder="小时" min="0" max="99" 
                                       value="{{ (chapter_files.exam is defined and chapter_files.exam.time_limit_hours) ? chapter_files.exam.time_limit_hours : 0 }}">
                                <div class="layui-form-mid layui-word-aux">小时</div>
                            </div>
                            <div class="layui-col-md4">
                                <input type="number" name="chapter_files[exam][time_limit_minutes]" class="layui-input" 
                                       placeholder="分钟" min="0" max="59" 
                                       value="{{ (chapter_files.exam is defined and chapter_files.exam.time_limit_minutes) ? chapter_files.exam.time_limit_minutes : 30 }}">
                                <div class="layui-form-mid layui-word-aux">分钟</div>
                            </div>
                            <div class="layui-col-md4">
                                <input type="number" name="chapter_files[exam][time_limit_seconds]" class="layui-input" 
                                       placeholder="秒" min="0" max="59" 
                                       value="{{ (chapter_files.exam is defined and chapter_files.exam.time_limit_seconds) ? chapter_files.exam.time_limit_seconds : 0 }}">
                                <div class="layui-form-mid layui-word-aux">秒</div>
                            </div>
                        </div>
                        <div class="layui-form-mid layui-word-aux">
                            <i class="layui-icon layui-icon-help"></i>
                            设置用户需要学习多长时间才能参加考试，0表示无限制
                        </div>
                    </div>
                </div>
                
                <div class="layui-form-item">
                    <label class="layui-form-label">排序</label>
                    <div class="layui-input-block">
                        <input type="number" name="chapter_files[exam][sort_order]" class="layui-input" 
                               placeholder="排序值" 
                               value="{{ (chapter_files.exam is defined and chapter_files.exam.sort_order) ? chapter_files.exam.sort_order : 0 }}" min="0">
                    </div>
                </div>
                
                <div class="layui-form-item">
                    <div class="layui-input-block">
                        <button class="layui-btn" lay-submit="true" lay-filter="go">保存考试</button>
                        <button type="button" class="kg-back layui-btn layui-btn-primary">返回</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>




