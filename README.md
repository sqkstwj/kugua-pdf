# Kugua PDF & Exam System

为开源酷瓜云增加PDF文档上传和在线考试跳转功能。

## 🚀 核心功能

### 📄 PDF文档上传与管理
- **PDF文件上传**: 支持PDF格式文档的上传和管理
- **文档预览**: 在线预览PDF文档，无需下载
- **文档分类**: 支持多种文档类型分类管理
- **权限控制**: 基于用户权限的文档访问控制

### 📝 在线考试系统
- **考试权限验证**: 基于学习时长的考试权限控制
- **SSO单点登录**: 与外部考试系统的无缝集成
- **考试配置管理**: 灵活的考试参数配置
- **学习进度跟踪**: 实时跟踪用户学习进度

## 🏗️ 技术架构

### 后端技术栈
- **框架**: Phalcon PHP Framework
- **数据库**: MySQL
- **缓存**: Redis
- **文件存储**: 支持多种存储方式

### 核心组件

#### 1. PDF上传服务 (`app/Services/MyStorage.php`)
```php
// 支持PDF文件上传和验证
protected function upload($prefix, $mimeType, $uploadType, $fileName = null)
{
    // 文件类型验证
    if (!$this->checkFile($file->getRealType(), $mimeType)) {
        throw new InvalidArgumentException('Invalid file type');
    }
    
    // 文件上传处理
    $path = $this->putFile($keyName, $file->getTempName());
    
    return $upload;
}
```

#### 2. 考试权限管理 (`app/Services/Logic/Chapter/ChapterExam.php`)
```php
// 检查用户考试权限
public function checkExamPermission($chapterId, $userId, $requiredDuration = 0)
{
    $watchedDuration = $this->getChapterWatchedDuration($chapterId, $userId);
    
    // 基于学习时长的权限验证
    $allowed = $watchedDuration >= $requiredDuration;
    
    return [
        'allowed' => $allowed,
        'watched_duration' => $watchedDuration,
        'required_duration' => $requiredDuration,
        'progress' => $progress
    ];
}
```

#### 3. SSO单点登录 (`app/Services/SsoService.php`)
```php
// 生成考试系统SSO URL
public function generateExamSsoUrl($userId, $examUrl = '')
{
    $ssoParams = [
        'userId' => $userId,
        'userName' => $userName,
        'userEmail' => $userEmail,
        'timestamp' => $timestamp,
        'token' => $token
    ];
    
    return self::EXAM_SYSTEM_SSO_URL . '?' . http_build_query($ssoParams);
}
```

## 📁 项目结构

```
kugua-pdf-core/
├── app/
│   ├── Services/
│   │   ├── Logic/Chapter/
│   │   │   ├── ChapterExam.php          # 考试权限管理
│   │   │   └── ExamUserSync.php         # 考试用户同步
│   │   └── SsoService.php               # SSO单点登录服务
│   ├── Http/
│   │   ├── Admin/
│   │   │   ├── Services/
│   │   │   │   └── ChapterContent.php   # 章节内容管理
│   │   │   └── Views/chapter/
│   │   │       └── edit_lesson_vod.volt # 管理端PDF上传界面
│   │   └── Home/
│   │       └── Views/chapter/
│   │           ├── vod.volt             # 前端PDF预览界面
│   │           └── files.volt           # 文件管理界面
│   └── ...
├── config/
│   └── sso.php                          # SSO配置文件
├── composer.json                         # 依赖管理
├── LICENSE                              # 开源协议
└── README.md                            # 项目说明
```

## 🔧 安装与配置

### 环境要求
- PHP 7.4+
- Phalcon 4.0+
- MySQL 5.7+
- Redis 5.0+

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/sqkstwj/kugua-pdf.git
cd kugua-pdf
```

2. **安装依赖**
```bash
composer install
```

3. **配置数据库**
```bash
# 复制配置文件
cp config/config.default.php config/config.php

# 编辑数据库配置
vim config/config.php
```

4. **配置SSO**
```bash
# 编辑SSO配置
vim config/sso.php
```

## 🎯 功能特性

### PDF文档功能
- ✅ PDF文件上传与验证
- ✅ 在线PDF预览
- ✅ 文档分类管理
- ✅ 权限访问控制
- ✅ 文件大小限制
- ✅ 文件类型验证

### 考试系统功能
- ✅ 学习时长验证
- ✅ 考试权限控制
- ✅ SSO单点登录
- ✅ 考试配置管理
- ✅ 用户进度跟踪
- ✅ 考试结果同步

## 🔐 安全特性

- **文件类型验证**: 严格验证上传文件类型
- **权限控制**: 基于用户角色的访问控制
- **SSO安全**: 加密的SSO Token机制
- **输入验证**: 全面的输入数据验证
- **SQL注入防护**: 使用ORM防止SQL注入

## 📊 使用示例

### PDF文档上传
```php
// 在管理端上传PDF文档
$chapterContent = new ChapterContent();
$result = $chapterContent->updateChapterFiles($chapterId, [
    'document' => [
        'name' => '课程大纲.pdf',
        'url' => 'https://example.com/course-outline.pdf',
        'description' => '本课程的学习大纲',
        'sort_order' => 1
    ]
]);
```

### 考试权限检查
```php
// 检查用户考试权限
$chapterExam = new ChapterExam();
$permission = $chapterExam->checkExamPermission($chapterId, $userId, 3600); // 要求学习1小时

if ($permission['allowed']) {
    // 允许参加考试
    $examUrl = $chapterExam->getChapterExamConfig($chapterId);
} else {
    // 显示学习进度
    echo "还需要学习 " . ($permission['required_duration'] - $permission['watched_duration']) . " 秒";
}
```

## 🤝 贡献指南

欢迎提交Issue和Pull Request来改进这个项目。

### 开发流程
1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 开源协议

本项目基于 [GPL-2.0](LICENSE) 协议开源。

## 📞 联系方式

- 项目地址: https://github.com/sqkstwj/kugua-pdf
- 问题反馈: [Issues](https://github.com/sqkstwj/kugua-pdf/issues)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者们！

---

**注意**: 这是一个精简版本，包含了PDF上传和考试功能的核心代码。完整版本包含更多功能模块。
