<?php

namespace App\Services\Logic\Chapter;

use App\Services\Logic\Service as LogicService;
use App\Services\Logic\UserTrait;

class ExamUserSync extends LogicService
{
    use UserTrait;

    /**
     * 生成考试系统登录信息
     * 不直接操作数据库，只生成登录提示信息
     */
    public function generateLoginInfo($user)
    {
        // 获取用户邮箱
        $email = $this->getUserEmail($user->id);
        
        return [
            'username' => $email,
            'password' => $email, // 默认密码就是邮箱
            'display_name' => $user->name,
            'hint' => '密码就是您的邮箱地址'
        ];
    }

    /**
     * 生成考试系统认证URL
     * 通过URL参数传递用户信息，实现SSO
     */
    public function generateAuthUrl($examUrl, $user)
    {
        $timestamp = time();
        
        // 获取用户邮箱
        $email = $this->getUserEmail($user->id);
        
        // 生成认证Token（包含用户信息）
        $token = base64_encode(json_encode([
            'user_id' => $user->id,
            'user_name' => $user->name,
            'user_email' => $email,
            'timestamp' => $timestamp,
            'expire' => $timestamp + 300 // 5分钟有效期
        ]));
        
        // 构建带认证的考试URL
        $separator = strpos($examUrl, '?') !== false ? '&' : '?';
        
        return $examUrl . $separator . http_build_query([
            'token' => $token,
            'user_id' => $user->id,
            'user_name' => urlencode($user->name),
            'user_email' => urlencode($email),
            'timestamp' => $timestamp,
            'auto_login' => 'true',
            'login_hint' => base64_encode(json_encode([
                'username' => $email,
                'password' => $email,
                'display_name' => $user->name,
                'hint' => '密码就是您的邮箱地址'
            ]))
        ]);
    }

    /**
     * 获取用户邮箱
     */
    private function getUserEmail($userId)
    {
        try {
            $account = \App\Models\Account::findFirst([
                'conditions' => 'id = :id: AND deleted = 0',
                'bind' => ['id' => $userId]
            ]);
            
            return $account ? $account->email : '';
        } catch (Exception $e) {
            error_log('获取用户邮箱失败: ' . $e->getMessage());
            return '';
        }
    }

    /**
     * 验证Token是否有效
     */
    public function validateToken($token)
    {
        try {
            $tokenData = json_decode(base64_decode($token), true);
            
            if (!$tokenData) {
                return false;
            }
            
            $currentTime = time();
            $expireTime = $tokenData['expire'] ?? 0;
            
            // 检查Token是否过期
            if ($currentTime > $expireTime) {
                return false;
            }
            
            return $tokenData;
        } catch (Exception $e) {
            return false;
        }
    }
}
