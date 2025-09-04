
{% extends 'templates/main.volt' %}

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
            <!-- 文件内容显示 -->
            <div class="file-content wrap">
                <div class="file-list">
                    <h3>课程文件</h3>
                    {% for type, file in chapter.files %}
                        <div class="file-item">
                            <div class="file-icon">
                                {% if type == 'document' %}
                                    <i class="layui-icon layui-icon-file"></i>
                                {% elseif type == 'presentation' %}
                                    <i class="layui-icon layui-icon-file"></i>
                                {% elseif type == 'spreadsheet' %}
                                    <i class="layui-icon layui-icon-file"></i>
                                {% elseif type == 'archive' %}
                                    <i class="layui-icon layui-icon-file"></i>
                                {% endif %}
                            </div>
                            <div class="file-info">
                                <div class="file-name">{{ file.name }}</div>
                                {% if file.description %}
                                    <div class="file-desc">{{ file.description }}</div>
                                {% endif %}
                            </div>
                            <div class="file-actions">
                                <a href="{{ file.url }}" target="_blank" class="layui-btn layui-btn-sm">
                                    <i class="layui-icon layui-icon-download-circle"></i> 查看
                                </a>
                            </div>
                        </div>
                    {% endfor %}
                </div>
            </div>

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
    {{ js_include('home/js/course.share.js') }}
    {{ js_include('home/js/chapter.show.js') }}
    {{ js_include('home/js/comment.js') }}
    {{ js_include('home/js/copy.js') }}
{% endblock %}
