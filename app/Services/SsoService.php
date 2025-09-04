<?php
/**
 * @copyright Copyright (c) 2021 深圳市酷瓜软件有限公司
 * @license https://opensource.org/licenses/GPL-2.0
 * @link https://www.koogua.com
 */

namespace App\Services;

use App\Models\User as UserModel;
use App\Models\Account as AccountModel;

class SsoService extends Service
{
    /**
     * 考试系统SSO基础URL
     */
    const EXAM_SYSTEM_SSO_URL = 'http://surveyking:8080/api/sso/auto-login';
    
    /**
     * SSO密钥（与考试系统保持一致）
     */
    const SSO_SECRET_KEY = 'SECRET_KEY';
    
    /**
     * 生成考试系统的SSO跳转URL
     *
     * @param int $userId 用户ID
     * @param string $examUrl 原始考试URL
     * @return string SSO跳转URL
     */
    public function generateExamSsoUrl($userId, $examUrl = '')
    {
        try {
            // 调试信息
            error_log("SSO Debug: userId = {$userId}, examUrl = {$examUrl}");
            
            // 检查用户ID是否有效
            if (empty($userId) || $userId == 0) {
                error_log("SSO Error: Invalid userId = {$userId}");
                return $examUrl;
            }
            
            // 获取用户信息
            $user = UserModel::findFirst($userId);
            if (!$user) {
                error_log("SSO Error: User not found for userId = {$userId}");
                return $examUrl;
            }
            
            // 获取用户邮箱
            $account = AccountModel::findFirst($userId);
            $userEmail = $account ? $account->email : '';
            
            // 生成SSO参数
            $timestamp = time();
            $userName = $user->name;
            $token = $this->generateSsoToken($userId, $userName, $timestamp);
            
            // 构建SSO跳转URL
            $ssoParams = [
                'userId' => $userId,
                'userName' => $userName,
                'userEmail' => $userEmail,
                'timestamp' => $timestamp,
                'token' => $token
            ];
            
            // 如果有原始考试URL，添加到重定向参数中
            if (!empty($examUrl)) {
                $ssoParams['redirect'] = $examUrl;
            }
            
            $ssoUrl = self::EXAM_SYSTEM_SSO_URL . '?' . http_build_query($ssoParams);
            
            error_log("SSO Debug: Generated URL = {$ssoUrl}");
            
            return $ssoUrl;
        } catch (\Exception $e) {
            // 如果出现异常，记录日志并返回原始URL
            error_log('SSO Error: ' . $e->getMessage());
            error_log('SSO Error Stack: ' . $e->getTraceAsString());
            return $examUrl;
        }
    }
    
    /**
     * 生成SSO Token
     *
     * @param int $userId 用户ID
     * @param string $userName 用户名
     * @param int $timestamp 时间戳
     * @return string SSO Token
     */
    public function generateSsoToken($userId, $userName, $timestamp)
    {
        $tokenData = $userId . $userName . $timestamp . self::SSO_SECRET_KEY;
        return base64_encode($tokenData);
    }
}
