// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

mixin _MeetingKitLocalizationsMixin {
  NEMeetingKitLocalizations get localizations =>
      NEMeetingKit.instance.localizations;
}

abstract class NEMeetingKitLocalizations {
  static const LocalizationsDelegate<NEMeetingKitLocalizations> delegate =
      _NEMeetingKitLocalizationsDelegate();

  static NEMeetingKitLocalizations? of(BuildContext context) {
    return Localizations.of<NEMeetingKitLocalizations>(
        context, NEMeetingKitLocalizations);
  }

  static NEMeetingKitLocalizations ofLocale(Locale locale) {
    // Lookup logic when only language code is specified.
    switch (locale.languageCode) {
      case 'ja':
        return _NEMeetingKitLocalizationsJa();
      case 'zh':
        return _NEMeetingKitLocalizationsZh();
      default:
        return _NEMeetingKitLocalizationsEn();
    }
  }

  String get cancelled;

  String get meetingIsUnderGoing;

  String get unauthorized;

  String get meetingIdShouldNotBeEmpty;

  String get meetingPasswordNotValid;

  String get displayNameShouldNotBeEmpty;

  String get meetingLogPathParamsError;

  String get meetingLocked;

  String get meetingNotExist;

  String get reuseIMNotSupportAnonymousLogin;

  String get networkUnavailableCheck;
}

class _NEMeetingKitLocalizationsZh extends NEMeetingKitLocalizations {
  @override
  String get networkUnavailableCheck => '网络连接失败，请检查你的网络连接！';

  @override
  String get cancelled => '已取消';

  @override
  String get meetingIsUnderGoing => '当前会议还未结束，不能进行此类操作';

  @override
  String get unauthorized => '登录状态已过期，请重新登录';

  @override
  String get meetingIdShouldNotBeEmpty => '会议号不能为空';

  @override
  String get meetingPasswordNotValid => '会议密码不合法';

  @override
  String get displayNameShouldNotBeEmpty => '昵称不能为空';

  @override
  String get meetingLogPathParamsError => '参数错误，日志路径不合法或无创建权限';

  @override
  String get meetingLocked => '会议已锁定';

  @override
  String get meetingNotExist => '会议不存在';

  @override
  String get reuseIMNotSupportAnonymousLogin => 'IM复用不支持匿名登录';
}

class _NEMeetingKitLocalizationsEn extends NEMeetingKitLocalizations {
  @override
  String get networkUnavailableCheck =>
      'Network connection failed. Check your network connectivity.';

  @override
  String get cancelled => 'Canceled';

  @override
  String get meetingIsUnderGoing =>
      'The meeting is still ongoing. Invalid operation';

  @override
  String get unauthorized => 'Login state expired, log in again';

  @override
  String get meetingIdShouldNotBeEmpty => 'Meeting ID is required';

  @override
  String get meetingPasswordNotValid => 'Invalid meeting password';

  @override
  String get displayNameShouldNotBeEmpty => 'Nickname is required';

  @override
  String get meetingLogPathParamsError =>
      'Parameter error, invalid log path or no permission';

  @override
  String get meetingLocked => 'Meeting is locked';

  @override
  String get meetingNotExist => 'Meeting does not exist';

  @override
  String get reuseIMNotSupportAnonymousLogin =>
      'IM reuse does not support anonymous login';
}

class _NEMeetingKitLocalizationsJa extends NEMeetingKitLocalizations {
  @override
  String get networkUnavailableCheck => 'ネットワーク接続に失敗しました。ネットワーク接続を確認してください! ';

  @override
  String get cancelled => 'キャンセル';

  @override
  String get meetingIsUnderGoing => '現在の会議はまだ終わっていないため、そのような操作は実行できません';

  @override
  String get unauthorized => 'ログイン ステータスの有効期限が切れています。再度ログインしてください';

  @override
  String get meetingIdShouldNotBeEmpty => 'ミーティング ID を空にすることはできません';

  @override
  String get meetingPasswordNotValid => 'ミーティング パスワードが無効です';

  @override
  String get displayNameShouldNotBeEmpty => 'ニックネームを空にすることはできません';

  @override
  String get meetingLogPathParamsError => 'パラメータが間違っているか、ログのパスが無効か、作成権限がありません';

  @override
  String get meetingLocked => 'ミーティングはロックされています';

  @override
  String get meetingNotExist => 'ミーティングは存在しません';

  @override
  String get reuseIMNotSupportAnonymousLogin => 'IM の再利用は匿名ログインをサポートしていません';
}

class _NEMeetingKitLocalizationsDelegate
    extends LocalizationsDelegate<NEMeetingKitLocalizations> {
  const _NEMeetingKitLocalizationsDelegate();

  @override
  Future<NEMeetingKitLocalizations> load(Locale locale) {
    return SynchronousFuture<NEMeetingKitLocalizations>(
        NEMeetingKitLocalizations.ofLocale(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_NEMeetingKitLocalizationsDelegate old) => false;
}
