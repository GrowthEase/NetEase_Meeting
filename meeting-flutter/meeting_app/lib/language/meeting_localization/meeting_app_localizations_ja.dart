// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'meeting_app_localizations.dart';

/// The translations for Japanese (`ja`).
class MeetingAppLocalizationsJa extends MeetingAppLocalizations {
  MeetingAppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get globalAppName => '網易会議';

  @override
  String get globalSure => '確定';

  @override
  String get globalOK => '確認';

  @override
  String get globalQuit => '退出する';

  @override
  String get globalAgree => '同意する';

  @override
  String get globalDisagree => '同意しない';

  @override
  String get globalCancel => 'キャンセル';

  @override
  String get globalCopy => 'コピー';

  @override
  String get globalCopySuccess => 'コピー成功';

  @override
  String get globalApplication => 'アプリ';

  @override
  String get globalNo => 'no';

  @override
  String get globalYes => 'yes';

  @override
  String get globalComplete => '完了';

  @override
  String get globalResume => 'リカバリ';

  @override
  String get globalCopyright => 'すべての著作権1997-2024ネッ網易会社は\nすべての権利を留保する。';

  @override
  String get globalAppRegistryNO => '浙ICP17006647号-124A';

  @override
  String get globalNetworkUnavailableCheck =>
      'ネットワーク接続に失敗しました、あなたのネットワーク接続をチェックしてください!';

  @override
  String get globalNetworkNotAvailable => 'ネットワークは使用できません。ネットワーク設定を確認してください。';

  @override
  String get globalNetworkNotAvailableTitle => 'ネットワーク接続は使用できません。';

  @override
  String get globalNetworkNotAvailablePart1 => 'インターネットに接続できません。';

  @override
  String get globalNetworkNotAvailablePart2 =>
      'インターネットに接続する必要がある場合は、次の方法を参照してください：';

  @override
  String get globalNetworkNotAvailablePart3 => 'デバイスがWiFiネットワークに接続されている場合：';

  @override
  String get globalNetworkNotAvailableTip1 =>
      'お使いのデバイスがモバイルまたはwi-fiネットワークで有効になっていません';

  @override
  String get globalNetworkNotAvailableTip2 =>
      'デバイスの「設定」-「wi-fiネットワーク」の設定パネルから利用可能なwi-fiホットスポットへのアクセスを選択します。';

  @override
  String get globalNetworkNotAvailableTip3 =>
      '•機器の「設定」-「ネットワーク」の設定パネルでセルラーデータを有効にします(有効にすると事業者からデータ通信料金が請求される場合があります)。';

  @override
  String get globalNetworkNotAvailableTip4 =>
      'デバイスが接続されているwi-fiホットスポットがインターネットに接続されているかどうか、またはホットスポットがデバイスがインターネットにアクセスできるようにしているかどうかを確認します。';

  @override
  String get globalYear => '年';

  @override
  String get globalMonth => '月';

  @override
  String get globalDay => '日';

  @override
  String get globalSave => '保存';

  @override
  String get globalSunday => '日曜日';

  @override
  String get globalMonday => '月曜日';

  @override
  String get globalTuesday => '火曜日';

  @override
  String get globalWednesday => '水曜日';

  @override
  String get globalThursday => '木曜日';

  @override
  String get globalFriday => '金曜日';

  @override
  String get globalSaturday => '土曜日';

  @override
  String get globalNotify => 'お知らせ';

  @override
  String get globalSubmit => '提出';

  @override
  String get globalEdit => '編定';

  @override
  String get globalIKnow => '知っています';

  @override
  String get authImmediatelyRegister => '登録します';

  @override
  String get authLoginBySSO => 'SSO';

  @override
  String get authPrivacyCheckedTips => 'まず「プライバシーポリシー」と「サービス契約」に同意してください';

  @override
  String get authLogin => 'ログイン';

  @override
  String get authLoginToNetEase => '網易会議にログインする';

  @override
  String get authRegisterAndLogin => '登録/ログイン';

  @override
  String get authServiceAgreement => 'サービス契約';

  @override
  String get authPrivacy => 'プライバシーポリシー';

  @override
  String get authPrivacyDialogTitle => 'サービス契約とプライバシーポリシー';

  @override
  String get authUserProtocolAndPrivacy => 'サービス契約とプライバシーポリシー';

  @override
  String get authNetEaseServiceAgreement => '網易会議サービス契約';

  @override
  String get authNeteasePrivacy => '網易会議プライバシーポリシー';

  @override
  String authPrivacyDialogMessage(
      Object neteasePrivacy, Object neteaseUserProtocol) {
    return '網易会議は、網易が提供するオーディオおよびビデオ会議ソフトウェア製品です。私たちは、\"$neteaseUserProtocol\"と\"$neteasePrivacy\"を使用して、会議ソフトウェアが個人情報とお客様の権利と義務をどのように処理するかを理解します。同意する場合は、[同意する]をクリックして当社のサービスに同意します。';
  }

  @override
  String get authLoginOnOtherDevice => '同時に登録機器数が制限を超え、自動的にログアウトされました';

  @override
  String get authLoginTokenExpired => '登録期限が切れましたので,再登録してください';

  @override
  String get authInputEmailHint => '完全な電子メールアドレスを入力してください';

  @override
  String get authAndLogin => '許可しログイン';

  @override
  String get authNoAuth => '先にログインしてください';

  @override
  String authHasReadAndAgreeToPolicy(
      Object neteasePrivacy, Object neteaseUserProtocol) {
    return '網易会議$neteasePrivacyと$neteaseUserProtocolを読んで同意しました';
  }

  @override
  String get authHasReadAndAgreeMeeting => '網易会議を読み、同意しました';

  @override
  String get authAnd => 'と';

  @override
  String get authNextStep => '次のステップ';

  @override
  String get authMobileNotRegister => 'この携帯電話番号は登録されていない';

  @override
  String get authVerifyCodeErrorTip => '検証コードエラー';

  @override
  String get authEnterCheckCode => '認証コードを入力する';

  @override
  String get authEnterMobile => '電話番号を入力してください';

  @override
  String get authGetCheckCode => '取得する';

  @override
  String get authNewRegister => '新規ユーザー登録';

  @override
  String get authCheckMobile => '電話番号を確認する';

  @override
  String get authLoginByPassword => 'パスワードログイン';

  @override
  String get authLoginByMobile => '認証コードの登録';

  @override
  String get authRegister => '登録します';

  @override
  String get authEnterAccount => '勘定科目を入力します';

  @override
  String get authEnterPassword => 'パスワードを入力してください';

  @override
  String get authEnterNick => '名前を入力してください';

  @override
  String get authCompleteSelfInfo => '個人情報の充実';

  @override
  String authResendCode(Object second) {
    return '$second秒再送';
  }

  @override
  String authCheckCodeHasSendToMobile(Object mobile) {
    return '認証コードは$mobileに送られました。下に認証コードを入力してください';
  }

  @override
  String get authResend => '再送';

  @override
  String get authEnterCorpCode => '企業コードを入力してください。';

  @override
  String get authSSOTip => '関連企業はありません。';

  @override
  String get authSSONotSupport => 'シングルサインオンはサポートされていません。';

  @override
  String get authSSOLoginFail => 'SSOログインに失敗しました。';

  @override
  String get authEnterCorpMail => '企業のメールアドレスを入力してください。';

  @override
  String get authForgetPassword => 'パスワードを忘れる';

  @override
  String get authPhoneErrorTip => '電話番号が無効';

  @override
  String get authPleaseLoginFirst => 'まず 網易会議 にログインします';

  @override
  String get authResetInitialPasswordTitle => '新しいパスワードを設定する';

  @override
  String get authResetInitialPasswordDialogTitle => '新しいパスワードを設定する';

  @override
  String get authResetInitialPasswordDialogMessage =>
      'セキュリティ上の理由から、新しいパスワードを設定することをお勧めします';

  @override
  String get authResetInitialPasswordDialogCancelLabel => '設定しない';

  @override
  String get authResetInitialPasswordDialogOKLabel => '設定に移動';

  @override
  String get authMobileNum => '電話番号';

  @override
  String get authUnavailable => '無';

  @override
  String get authNoCorpCode => 'コードはありませんか？';

  @override
  String get authCreateAccountByPC => 'デスクトップへの作成';

  @override
  String get authCreateNow => '今すぐ作成';

  @override
  String get authLoginToCorpEdition => '正式版';

  @override
  String get authLoginToTrialEdition => '体験版';

  @override
  String get authCorpNotFound => 'マッチする企業はありません';

  @override
  String get authHasCorpCode => '既存のエンタープライズコード？';

  @override
  String get authLoginByCorpCode => '企業コードログイン';

  @override
  String get authLoginByCorpMail => '企業メールログイン';

  @override
  String get authOldPasswordError => 'パスワードが間違っています。再入力してください';

  @override
  String get authEnterOldPassword => '元のパスワードを入力する';

  @override
  String get authSuggestChrome => 'Chromeの使用を推奨します';

  @override
  String get authLoggingIn => '会議登録中';

  @override
  String get meetingCreate => '会議を開始';

  @override
  String get meetingNetworkAbnormalityCheckAndRejoin =>
      'ネットワークエラーです。ネットワーク接続を確認してから、再度ミーティングに参加してください';

  @override
  String get meetingRecover => '前回の例外終了が検出されました。会議を再開しますか？';

  @override
  String get meetingJoin => '会議に参加';

  @override
  String get meetingSchedule => '会議を予約';

  @override
  String get meetingScheduleListEmpty => '会議がない';

  @override
  String get meetingToday => '今日';

  @override
  String get meetingTomorrow => '明日';

  @override
  String get meetingNum => '会議 ID';

  @override
  String get meetingStatusInit => '開始待ち';

  @override
  String get meetingStatusStarted => '進行中';

  @override
  String get meetingStatusEnded => '終了';

  @override
  String get meetingStatusRecycle => '回収済み';

  @override
  String get meetingStatusCancel => 'キャンセル済み';

  @override
  String get meetingOperationNotSupportedInMeeting => '会議はこの操作をサポートしていません';

  @override
  String get meetingPersonalMeetingID => '個人会議 ID';

  @override
  String get meetingPersonalShortMeetingID => '個人会議の短縮 ID';

  @override
  String get meetingUsePersonalMeetId => '個人会議 IDを使う';

  @override
  String get meetingPassword => 'パスワード';

  @override
  String get meetingEnterSixDigitPassword => '6桁のパスワードを入力してください';

  @override
  String get meetingJoinCameraOn => 'カメラオンになっています';

  @override
  String get meetingJoinMicrophoneOn => 'マイク オンになっています';

  @override
  String get meetingJoinCloudRecordOn => '会議の録画を有効にする';

  @override
  String get meetingCreateAlreadyInTip => '会議はまだ進行中です。会議に参加しませんか。';

  @override
  String get meetingCreateFail => '会議の作成に失敗しました';

  @override
  String get meetingJoinFail => '会議参加失敗';

  @override
  String get meetingEnterId => '会議IDを入力します';

  @override
  String meetingSubject(Object userName) {
    return '$userNameの計画会議';
  }

  @override
  String get meetingScheduleNow => '予約する';

  @override
  String get meetingEnterPassword => 'ミーティングパスワードを入力してください';

  @override
  String get meetingScheduleTimeIllegal => '予約時間は現在の時間より前にしてはいけません';

  @override
  String get meetingScheduleSuccess => '予約が成功する';

  @override
  String get meetingDurationTooLong => '会議の持続時間が長すぎる';

  @override
  String get meetingInfo => '会議情報';

  @override
  String get meetingSecurity => '安全';

  @override
  String get meetingEnableWaitingRoom => '待合室できる';

  @override
  String get meetingWaitingRoomHint => '参加者は会議に参加する時にまず待合室に入る';

  @override
  String get meetingAttendeeAudioOff => '参加者が入った時にミュートする';

  @override
  String get meetingAttendeeAudioOffAllowOn =>
      '自動的にミュートし、参加者がマイクをオンにできるようにします。';

  @override
  String get meetingAttendeeAudioOffNotAllowOn =>
      '参加者がマイクをオンにすることを自動的にミュートし、禁止します。';

  @override
  String get meetingEnterTopic => '会議のテーマを入力する';

  @override
  String get meetingEndTime => '終了時間';

  @override
  String get meetingChooseDate => '選択デート';

  @override
  String get meetingLiveOn => 'ライブ配信を有効にする';

  @override
  String get meetingLiveUrl => 'ライブ アドレス';

  @override
  String get meetingLiveLevelTip => '従業員のみ視聴可能';

  @override
  String get meetingRecordOn => '参加者が会議に参加すると、記録を開始します';

  @override
  String get meetingInviteUrl => '参加リンク';

  @override
  String get meetingLiveLevel => 'ライブモード';

  @override
  String get meetingCancel => '削除';

  @override
  String get meetingCancelConfirm => '予定を削除しますか？';

  @override
  String get meetingNotCancel => '削除しない';

  @override
  String get meetingEdit => '会議を編集する';

  @override
  String get meetingScheduleEditSuccess => '修正成功';

  @override
  String get meetingInfoDialogMeetingTitle => 'タイトル';

  @override
  String get meetingDeepLinkTipAlreadyInMeeting => 'あなたは既に対応会議にいます';

  @override
  String get meetingDeepLinkTipAlreadyInDifferentMeeting =>
      'あなたは別の会議に参加しています。会議を終了して再試行してください';

  @override
  String get meetingShareScreenTips =>
      '画面上の通知を含むすべてのコンテンツが記録されます。 顧客サービス、キャンパスローン、検察庁法を模倣した詐欺に警戒し、「画面共有」時に財務振替操作を行わないでください。';

  @override
  String get meetingForegroundContentText => '網易会議は現在進行中です';

  @override
  String get meetingId => '会議 ID:';

  @override
  String get meetingShortId => '会議 ID:';

  @override
  String get meetingStartTime => '開始時間';

  @override
  String get meetingCloseByHost => '司会者は会議を終えた';

  @override
  String get meetingEndOfLife => '会議時間が上限に達しました。会議は閉会した。';

  @override
  String get meetingSwitchOtherDevice =>
      '司会者によって会議から外されたり、アカウントが他のデバイスに切り替わったりしたため、会議を退会されました';

  @override
  String get meetingSyncDataError => '会議情報の同期に失敗しました。';

  @override
  String get meetingEnd => '会議はもう終わった。';

  @override
  String get meetingMicrophone => 'マイク';

  @override
  String get meetingCamera => 'カメラ';

  @override
  String get meetingDetail => '会議詳細';

  @override
  String get meetingInfoDialogMeetingDateFormat => 'yyyy-MM-dd';

  @override
  String get meetingHasBeenCanceled => '会議が他のログインデバイスによってキャンセルされました';

  @override
  String get meetingRepeat => '周期';

  @override
  String get meetingFrequency => '繰り返し周波数';

  @override
  String get meetingNoRepeat => '重複しない';

  @override
  String get meetingRepeatEveryday => '毎日';

  @override
  String get meetingRepeatEveryWeekday => '出勤日ごと';

  @override
  String get meetingRepeatEveryWeek => '毎週';

  @override
  String get meetingRepeatEveryTwoWeek => '2週間ごとに';

  @override
  String get meetingRepeatEveryMonth => '毎月';

  @override
  String get meetingRepeatCustom => 'カスタマイズ';

  @override
  String get meetingRepeatEndAt => 'で終わる';

  @override
  String get meetingRepeatEndAtOneday => '有効期限';

  @override
  String get meetingRepeatTimes => '会議の回数を制限する';

  @override
  String get meetingRepeatStop => 'シリーズを終了する';

  @override
  String meetingDayInMonth(Object day) {
    return '$day日';
  }

  @override
  String get meetingRepeatSelectDate => '日付を選択する';

  @override
  String meetingRepeatDayInWeek(Object day, Object week) {
    return '$week週ごとの$day繰り返し';
  }

  @override
  String meetingRepeatDay(Object day) {
    return '$day日ごとに繰り返す';
  }

  @override
  String meetingRepeatDayInMonth(Object day, Object month) {
    return '$monthヶ月ごとの$day繰り返し';
  }

  @override
  String meetingRepeatDayInWeekInMonth(
      Object month, Object week, Object weekday) {
    return '$monthヶ月ごとの$week個目の$weekday繰り返し';
  }

  @override
  String get meetingRepeatDate => '日付';

  @override
  String get meetingRepeatWeekday => '週';

  @override
  String meetingRepeatOrderWeekday(Object week, Object weekday) {
    return '第$week$weekday';
  }

  @override
  String get meetingRepeatEditing => '繰り返しミーティングを編集していること。';

  @override
  String get meetingRepeatEditCurrent => '今回の会議を編集する';

  @override
  String get meetingRepeatEditAll => 'すべての会議を編集する';

  @override
  String get meetingRepeatEditTips => '以下の情報を修正すると,この週期的な会議に影響が出ます';

  @override
  String get meetingLeaveEditTips => '会議の編集からの退会を確認しますか?';

  @override
  String get meetingRepeatCancelAll => '週期的な一連の会議を廃止します';

  @override
  String get meetingCancelCancel => '削除しない';

  @override
  String get meetingCancelConfirm2 => '削除';

  @override
  String get meetingLeaveEditTips2 => '終了すると、現在のミーティングの変更は保存できません';

  @override
  String get meetingEditContinue => '編集を続けます';

  @override
  String get meetingEditLeave => '退出する';

  @override
  String get meetingRepeatUnitEvery => '';

  @override
  String get meetingRepeatUnitDay => '日';

  @override
  String get meetingRepeatUnitWeek => '週';

  @override
  String get meetingRepeatUnitMonth => '月';

  @override
  String meetingRepeatLimitTimes(Object times) {
    return '限定回数$times回です';
  }

  @override
  String get meetingJoinBeforeHost => '参加者はホストの前に参加することができます';

  @override
  String get meetingRepeatMeetings => '周期的な会議';

  @override
  String get meetingRepeatLabel => '繰り返します';

  @override
  String get meetingRepeatEnd => '終わった';

  @override
  String get meetingRepeatOneDay => 'ある日';

  @override
  String get meetingRepeatFrequency => '周波数';

  @override
  String get meetingRepeatAt => 'にあります';

  @override
  String meetingRepeatUncheckTips(Object date) {
    return '現在は$dateです。選択を解除できません';
  }

  @override
  String get meetingRepeatCancelEdit => '編集の取り消し';

  @override
  String get historyMeeting => '歴史会議';

  @override
  String get historyAllMeeting => 'すべての会議';

  @override
  String get historyCollectMeeting => 'お気に入り';

  @override
  String get historyMeetingListEmpty => '歴史会議はまだありません';

  @override
  String get historyChat => 'チャット記録';

  @override
  String get historyMeetingOwner => '設立者';

  @override
  String get historyMeetingCloudRecord => '雲記録';

  @override
  String get historyMeetingCloudRecordingFileBeingGenerated => 'クラウド記録ファイルの生成';

  @override
  String get settings => 'セット';

  @override
  String get settingDefaultCompanyName => '無所属の企業';

  @override
  String get settingInternalDedicated => '内部のみ';

  @override
  String get settingMeeting => '会議の設定';

  @override
  String get settingFeedback => 'フィードバック';

  @override
  String get settingBeauty => '美顔';

  @override
  String get settingVirtualBackground => '背景';

  @override
  String get settingAbout => 'について';

  @override
  String get settingSetMeetingNick => '名前の設定';

  @override
  String get settingSetMeetingTips => '中国語、英語、数字を入力してください';

  @override
  String get settingValidatorNickTip => '漢字、英字、数字をサポートする，最大20文字';

  @override
  String get settingModifySuccess => '修正成功';

  @override
  String get settingModifyFailed => '修正失敗';

  @override
  String get settingCheckUpdate => '更新のチェック';

  @override
  String get settingFindNewVersion => '新版本';

  @override
  String get settingAlreadyLatestVersion => '最新版';

  @override
  String get settingVersion => 'Version:';

  @override
  String get settingAccountAndSafety => 'マイアカウント';

  @override
  String get settingModifyPassword => 'パスワードの変更';

  @override
  String get settingEnterNewPasswordTips => '新しいパスワードに入る';

  @override
  String get settingEnterPasswordConfirm => '新しいパスワードを再度入力します';

  @override
  String get settingValidatorPwdTip => '6-18文字で、大文字と小文字と数字を含める必要があります';

  @override
  String get settingPasswordDifferent => '2つの新しいパスワードは違います。 再入力してください';

  @override
  String get settingPasswordSameToOld => '新しいパスワードは元のパスワードと重複しますので、入力し直してください';

  @override
  String get settingPasswordFormatError => 'パスワードの形式が間違っています。再入力してください';

  @override
  String get settingCompany => '企業';

  @override
  String get settingSwitchCompanyFail => '企業の切り替えに失敗します。ネットワークのチェックをお願いします。';

  @override
  String get settingAudioAINS => 'インテリジェント・ノイズリダクション';

  @override
  String get settingShowShareUserVideo => '共有するときは共有者のカメラをオンにします';

  @override
  String get settingEnableTransparentWhiteboard => 'ホワイトボードを透明に設定';

  @override
  String get settingEnableFrontCameraMirror => '前面カメラミラーリング';

  @override
  String get settingOpenCameraMeeting => 'デフォルトでカメラオン';

  @override
  String get settingOpenMicroMeeting => 'マイクはデフォルトでオン';

  @override
  String get settingShowMeetDuration => '会議時間の表示';

  @override
  String get settingEnableAudioDeviceSwitch => 'オーディオ機器の切り替えを許可する';

  @override
  String get settingRename => '名前の変更';

  @override
  String get settingPackageVersion => 'パッケージ版';

  @override
  String get settingNick => '名前';

  @override
  String get settingDeleteAccount => 'アカウントのキャンセル';

  @override
  String get settingEmail => '電子メール';

  @override
  String get settingLogout => 'ログアウト';

  @override
  String get settingLogoutConfirm => 'ログインをログアウトすることは確実ですか?';

  @override
  String get settingMobile => '電話';

  @override
  String get settingAvatar => 'プロフィール写真';

  @override
  String get settingAvatarUpdateSuccess => 'アイコンの修正成功です';

  @override
  String get settingAvatarUpdateFail => 'プロフィール画像の修正に失敗しました';

  @override
  String get settingAvatarTitle => 'プロフィール画像の設定です';

  @override
  String get settingTakePicture => '写真を撮ります';

  @override
  String get settingChoosePicture => '携帯のアルバムから選びます';

  @override
  String get settingPersonalCenter => '個人センター';

  @override
  String get settingVersionUpgrade => 'バージョンの更新';

  @override
  String get settingUpgradeNow => '今すぐ更新';

  @override
  String get settingUpgradeCancel => '更新しない';

  @override
  String get settingDownloadFailTryAgain => 'ダウンロードに失敗しました。再試行してください。';

  @override
  String get settingInstallFailTryAgain => 'インストールに失敗しました。再試行してください';

  @override
  String get settingModifyAndReLogin => '修正後、再度ログインする必要があります';

  @override
  String get settingServiceBundleTitle => 'サポートされる会議';

  @override
  String settingServiceBundleDetailLimitedMinutes(
      Object maxCount, Object maxMinutes) {
    return '$maxCount名の参加者、期間限定$maxMinutes分会議';
  }

  @override
  String settingServiceBundleDetailUnlimitedMinutes(Object maxCount) {
    return '$maxCount人、単場無制限時会議';
  }

  @override
  String get settingUpdateFailed => '更新に失敗しました';

  @override
  String get settingTryAgainLater => '次回';

  @override
  String get settingRetryNow => '再試行';

  @override
  String get settingUpdating => '更新中';

  @override
  String get settingCancelUpdate => '更新のキャンセル';

  @override
  String get settingExitApp => '退出する';

  @override
  String get settingNotUpdate => '更新しない';

  @override
  String get settingUPdateNow => '更新';

  @override
  String get settingComfirmExitApp => '確認してアプリを終了します';

  @override
  String get feedbackInRoom => 'フィードバック';

  @override
  String get feedbackProblemType => '問題の類型';

  @override
  String get feedbackSuccess => 'フィードバックの提出に成功しました';

  @override
  String get feedbackAudioLatency => '長時間の遅れ';

  @override
  String get feedbackAudioFreeze => '相手の話し声がひっかかる';

  @override
  String get feedbackCannotHearOthers => '相手の声が聞こえない';

  @override
  String get feedbackCannotHearMe => '他の人には聞こえない';

  @override
  String get feedbackTitleExtras => '補足情報';

  @override
  String get feedbackTitleDate => '問題の発生時期';

  @override
  String get feedbackContentEmpty => '無';

  @override
  String get feedbackTitleSelectPicture => '画像';

  @override
  String get feedbackAudioMechanicalNoise => '機械音';

  @override
  String get feedbackAudioNoise => '雑音';

  @override
  String get feedbackAudioEcho => '反響がある';

  @override
  String get feedbackAudioVolumeSmall => '音量が小さいです';

  @override
  String get feedbackVideoFreeze => 'ビデオ長時間カートンです';

  @override
  String get feedbackVideoIntermittent => 'ビデオは途切れ途切れです';

  @override
  String get feedbackVideoTearing => '画面が裂ける';

  @override
  String get feedbackVideoTooBrightOrDark => '画面が明るすぎる/暗すぎる';

  @override
  String get feedbackVideoBlurry => '画面がぼやける';

  @override
  String get feedbackVideoNoise => '画面のノイズが目立つ';

  @override
  String get feedbackAudioVideoNotSync => '音画が同期していない';

  @override
  String get feedbackUnexpectedExit => '予期せず脱退する';

  @override
  String get feedbackOthers => '他にも問題があります';

  @override
  String get feedbackTitleAudio => 'オーディオの問題';

  @override
  String get feedbackTitleVideo => 'ビデオの問題';

  @override
  String get feedbackTitleOthers => 'その他';

  @override
  String get feedbackTitleDescription => '問題の説明';

  @override
  String get feedbackOtherTip =>
      '質問を説明してください。「他に質問があります」を選択した場合、提出する前に具体的な説明を記入する必要があります';

  @override
  String get evaluationTitle => '同僚やパートナーに「網易会議」を推薦する可能性はどれくらいありますか？';

  @override
  String get evaluationCoreZero => '0-絶対にしない';

  @override
  String get evaluationCoreTen => '10-よろこんで参ります';

  @override
  String get evaluationHitTextOne => '0-6：あなたを不満にさせたり、失望させたりする点は何ですか？ (オプション)';

  @override
  String get evaluationHitTextTwo => '7-8：どのような面でもっと上手にできると思いますか？ (オプション)';

  @override
  String get evaluationHitTextThree => '9-10：最高の機能についての体験や気持ちを共有してください(オプション)';

  @override
  String get evaluationToast => '採点して提出します';

  @override
  String get evaluationThankFeedback => 'フィードバックありがとうございます';

  @override
  String get evaluationGoHome => 'トップページに戻ります';
}
