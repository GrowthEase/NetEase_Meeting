// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/**
 * NEAccountService提供了与会议组件账号相关的各种服务，如登录、登出、SSO验证、账号信息查询等。
 * 通过该Service登录会议组件后才能正常使用会议组件的其他能力，如创建会议加入会议等。
 */
abstract class NEAccountService {
  ///
  /// 尝试自动登录鉴权。成功时返回 [NEAccountInfo]。
  ///
  Future<NEResult<NEAccountInfo>> tryAutoLogin();

  ///
  /// 根据用户唯一ID和Token登录鉴权。成功时返回 [NEAccountInfo]。
  ///
  /// * [userUuid] 用户唯一ID
  /// * [token] 登录令牌
  ///
  Future<NEResult<NEAccountInfo>> loginByToken(String userUuid, String token);

  /// 通过用户唯一ID和密码登录鉴权。成功时返回 [NEAccountInfo]。
  ///
  /// * [userUuid]   用户唯一ID
  /// * [password]   登录密码
  Future<NEResult<NEAccountInfo>> loginByPassword(
      String userUuid, String password);

  ///
  /// 请求登录验证码。
  ///
  /// * [phoneNumber] 电话号码
  ///
  Future<VoidResult> requestSmsCodeForLogin(String phoneNumber);

  /// 通过验证码登录鉴权。成功时返回 [NEAccountInfo]。
  ///
  /// * [phoneNumber] 电话号码
  /// * [smsCode] 验证码
  ///
  Future<NEResult<NEAccountInfo>> loginBySmsCode(
      String phoneNumber, String smsCode);

  ///
  /// 生成SSO登录链接，调用方使用该链接通过浏览器去完成SSO登录。
  ///
  Future<NEResult<String>> generateSSOLoginWebURL();

  ///
  /// 通过SSO登录结果uri完成会议组件登录鉴权。成功时返回 [NEAccountInfo]。
  ///
  /// * [ssoUri] SSO登录结果uri
  Future<NEResult<NEAccountInfo>> loginBySSOUri(String ssoUri);

  /// 通过邮箱密码登录鉴权。成功时返回 [NEAccountInfo]。
  ///
  /// * [email]      登录邮箱
  /// * [password]   登录密码
  ///
  Future<NEResult<NEAccountInfo>> loginByEmail(String email, String password);

  /// 通过电话号码密码登录鉴权。成功时返回 [NEAccountInfo]。
  ///
  /// * [phoneNumber] 电话号码
  /// * [password]    登录密码
  ///
  Future<NEResult<NEAccountInfo>> loginByPhoneNumber(
      String phoneNumber, String password);

  ///
  /// 获取当前登录账号信息。成功时返回 [NEAccountInfo]。
  ///
  NEAccountInfo? getAccountInfo();

  /// 添加账号服务监听实例
  ///
  /// * [listener] 要添加的监听实例
  ///
  void addListener(NEAccountServiceListener listener);

  /// 移除账号服务监听实例
  ///
  /// * [listener] 要移除的监听实例
  ///
  void removeListener(NEAccountServiceListener listener);

  /// 重置密码
  /// * [userUuid] 用户唯一ID
  /// * [newPassword] 新密码
  /// * [oldPassword] 旧密码
  ///
  Future<NEResult<void>> resetPassword(
      String userUuid, String newPassword, String oldPassword);

  /// 修改当前登录账号头像
  ///
  /// * [imagePath] 新头像本地图片文件路径
  ///
  Future<VoidResult> updateAvatar(String imagePath);

  /// 修改当前登录账号昵称
  ///
  /// * [nickname] 新昵称
  ///
  Future<VoidResult> updateNickname(String nickname);

  ///
  /// 登出当前已登录的账号
  ///
  Future<VoidResult> logout();
}

@Deprecated('已废弃，请使用[NEAccountServiceListener]代替')
typedef NEAuthListener = NEAccountServiceListener;

extension NEAccountServiceExtension on NEAccountService {
  bool get isAnonymous => getAccountInfo()?.isAnonymous == true;
}
