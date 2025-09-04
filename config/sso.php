<?php
/**
 * SSO配置文件
 * 用于配置与考试系统的单点登录功能
 */

return [
    /**
     * 考试系统配置
     */
    'exam_system' => [
        // 考试系统容器名称
        'host' => env('EXAM_SYSTEM_HOST', 'surveyking'),
        // 考试系统端口
        'port' => env('EXAM_SYSTEM_PORT', 8080),
        // SSO接口路径
        'sso_path' => '/api/sso/auto-login',
        // 是否启用SSO
        'enabled' => env('SSO_ENABLED', true),
    ],
    
    /**
     * SSO安全配置
     */
    'security' => [
        // SSO密钥（与考试系统保持一致）
        'secret_key' => env('SSO_SECRET_KEY', 'SECRET_KEY'),
    ],
];
