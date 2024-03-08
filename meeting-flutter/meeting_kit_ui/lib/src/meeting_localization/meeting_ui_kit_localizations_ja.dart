// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'meeting_ui_kit_localizations.dart';

/// The translations for Japanese (`ja`).
class NEMeetingUIKitLocalizationsJa extends NEMeetingUIKitLocalizations {
  NEMeetingUIKitLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get globalAppName => '網易会議';

  @override
  String get globalDelete => '消去';

  @override
  String get globalNothing => 'なし';

  @override
  String get globalCancel => 'キャンセル';

  @override
  String get globalAdd => '追加';

  @override
  String get globalClose => 'close';

  @override
  String get globalOpen => 'open';

  @override
  String get globalFail => '失敗';

  @override
  String get globalYes => 'yes';

  @override
  String get globalNo => 'no';

  @override
  String get globalSave => '保存';

  @override
  String get globalDone => '完成';

  @override
  String get globalNotify => 'お知らせ';

  @override
  String get globalSure => 'OK';

  @override
  String get globalIKnow => '知っています';

  @override
  String get globalCopy => 'コピー';

  @override
  String get globalCopySuccess => 'コピー成功';

  @override
  String get globalEdit => '編定';

  @override
  String get globalGotIt => 'わかりました';

  @override
  String get globalMin => '分';

  @override
  String globalNotWork(Object permissionName) {
    return '$permissionNameが使えません。';
  }

  @override
  String globalNeedPermissionTips(Object permissionName, Object title) {
    return 'この機能には$permissionNameが必要です。$titleがあなたの$permissionName権限にアクセスすることを許可してください';
  }

  @override
  String get globalToSetUp => '設置に';

  @override
  String get globalNoPermission => 'パーミッションは許可されていません';

  @override
  String get globalDays => '日';

  @override
  String get globalHours => '時間';

  @override
  String get globalMinutes => '分';

  @override
  String get globalViewMessage => '観メッセージ';

  @override
  String get globalNoLongerRemind => '注意しません';

  @override
  String get globalOperationFail => '操作に失敗しました';

  @override
  String get meetingBeauty => '美顔';

  @override
  String get meetingBeautyLevel => '美容レベル';

  @override
  String get meetingJoinTips => '会議に参加しています...';

  @override
  String get meetingQuit => '会議終了';

  @override
  String get meetingDefalutTitle => 'ビデオ会議';

  @override
  String get meetingJoinFail => 'ミーティングに参加できませんでした';

  @override
  String get meetingHostKickedYou =>
      'ホストから削除されたか、別のデバイスに切り替えられたため、ミーティングを退出しました';

  @override
  String get meetingMicphoneNotWorksDialogTitle => 'マイクを使用できません';

  @override
  String get meetingMicphoneNotWorksDialogMessage =>
      '話していることが検出されました。話す必要がある場合は、「ミュート解除」ボタンをクリックしてもう一度話してください';

  @override
  String get meetingFinish => '終了';

  @override
  String get meetingLeave => '退室';

  @override
  String get meetingLeaveFull => '退室';

  @override
  String get meetingSpeakingPrefix => 'Speaking:';

  @override
  String get meetingLockMeetingByHost => '会議はロックされています。新しい参加者は会議に参加できません';

  @override
  String get meetingLockMeetingByHostFail => '会議のロックに失敗しました';

  @override
  String get meetingUnLockMeetingByHost =>
      'ミーティングのロックが解除されました。新しい参加者はミーティングに参加できます';

  @override
  String get meetingUnLockMeetingByHostFail => 'ミーティングのロック解除に失敗しました';

  @override
  String get meetingLock => 'ミーティングをロック';

  @override
  String get meetingMore => '更に多く';

  @override
  String get meetingPassword => '会議パスワード';

  @override
  String get meetingEnterPassword => 'ミーティングパスワードを入力してください';

  @override
  String get meetingWrongPassword => 'パスワード間違い';

  @override
  String get meetingNum => '会議ID';

  @override
  String get meetingShortNum => '会議の短縮番号';

  @override
  String get meetingInfoDesc => '会議は暗号化保護されています';

  @override
  String get meetingAlreadyHandsUpTips => '手を上げました。ホストが対応するまでお待ちください';

  @override
  String get meetingHandsUpApply => '挙手のお願い';

  @override
  String get meetingCancelHandsUp => '挙手キャンセル';

  @override
  String get meetingCancelHandsUpConfirm => 'ハンドアップをキャンセルしてよろしいですか?';

  @override
  String get meetingHandsUpDown => 'ハンズダウン';

  @override
  String get meetingInHandsUp => '挙手';

  @override
  String get meetingHandsUpFail => '挙手できませんでした';

  @override
  String get meetingHandsUpSuccess => 'ハンドアップに成功しました。ホストの処理を待っています';

  @override
  String get meetingCancelHandsUpFail => '挙手失敗を取り消す';

  @override
  String get meetingHostRejectAudioHandsUp => 'ホストがあなたの手を下ろしました';

  @override
  String get meetingSip => 'SIP';

  @override
  String get meetingInviteUrl => '参加リンク';

  @override
  String get meetingInvitePageTitle => '参加者を追加';

  @override
  String get meetingSipNumber => 'SIP 電話';

  @override
  String get meetingSipHost => 'SIP アドレス';

  @override
  String get meetingInvite => '招待';

  @override
  String get meetingInviteListTitle => '招待リスト';

  @override
  String get meetingInvitationSendSuccess => '招待を発起した';

  @override
  String get meetingInvitationSendFail => '招待に失敗しました';

  @override
  String get meetingRemovedByHost => '主催者によってミーティングから削除されました';

  @override
  String get meetingCloseByHost => '会議は終了しました';

  @override
  String get meetingWasInterrupted => '会議は中断しました';

  @override
  String get meetingSyncDataError => 'ルーム情報の合わせる失敗しました';

  @override
  String get meetingLeaveMeetingBySelf => 'ミーティングを退出する';

  @override
  String get meetingClosed => '会議は終了された';

  @override
  String get meetingConnectFail => '接続に失敗しました';

  @override
  String get meetingJoinTimeout => '会議への参加がタイムアウトしました。もう一度やり直してください';

  @override
  String get meetingEndOfLife => '会議時間が上限に達したため、会議は終了しました';

  @override
  String get meetingEndTip => '会議が終了するまであと 1 つだけです';

  @override
  String get meetingReuseIMNotSupportAnonymousJoinMeeting =>
      'IM の再利用は匿名で会議への参加をサポートしていません';

  @override
  String get meetingInviteDialogTitle => '会議への招待';

  @override
  String get meetingInviteContentCopySuccess => '会議出席依頼のコンテンツがコピーされました';

  @override
  String get meetingInviteTitle => '会議に招待します';

  @override
  String get meetingSubject => '会議の件名';

  @override
  String get meetingTime => '会議時間';

  @override
  String get meetingInvitationUrl => '参加リンク';

  @override
  String get meetingCopyInvite => '招待をコピー';

  @override
  String get meetingInternalSpecial => '内部のみ';

  @override
  String get loginOnOtherDevice => '別のデバイスに切り替えました';

  @override
  String get authInfoExpired => '認可が期限切れです。もう一度ログインしてください';

  @override
  String get meetingCamera => 'カメラ';

  @override
  String get meetingMicrophone => 'マイク';

  @override
  String get meetingBluetooth => 'ブルートゥース';

  @override
  String get meetingPhoneState => '電話';

  @override
  String meetingNeedRationaleAudioPermission(Object permission) {
    return 'オーディオ会議では、オーディオ通信を行うために$permission権限を申請する必要があります。';
  }

  @override
  String meetingNeedRationaleVideoPermission(Object permission) {
    return '音声ビデオ会議では、ビデオ通信を行うために$permission権限を申請する必要があります。';
  }

  @override
  String get meetingNeedRationalePhotoPermission =>
      '会議での仮想背景(背景画像の追加・変更)機能のために、写真権限の申請が必要です。';

  @override
  String get meetingDisconnectAudio => 'オーディオの切断';

  @override
  String get meetingReconnectAudio => 'オーディオ';

  @override
  String get meetingDisconnectAudioTips =>
      '会議の音声をオフにするには、より多くの「オーディオの切断」をクリックします。';

  @override
  String get meetingNotificationContentTitle => 'ビデオ会議';

  @override
  String get meetingNotificationContentText => 'ビデオ会議が進行中';

  @override
  String get meetingNotificationContentTicker => 'ビデオ会議';

  @override
  String get meetingNotificationChannelId => 'ne_meeting_channel';

  @override
  String get meetingNotificationChannelName => 'ビデオ会議通知';

  @override
  String get meetingNotificationChannelDesc => 'ビデオ会議通知';

  @override
  String meetingUserJoin(Object userName) {
    return '$userNameは会議に参加した。';
  }

  @override
  String meetingUserLeave(Object userName) {
    return '$userName会議を離れました。';
  }

  @override
  String get meetingStartAudioShare => '共有音声をオンにする';

  @override
  String get meetingStopAudioShare => '音声の共有をやめる';

  @override
  String get meetingSwitchFcusView => '切り替える フォーカス表示';

  @override
  String get meetingSwitchGalleryView => '切り替える ギャラリービュー';

  @override
  String get meetingNoSupportSwitch => 'iPadはモード切り替えに対応していません';

  @override
  String get meetingFuncNotAvailableWhenInCallState => '通話中は本機能を使用できません';

  @override
  String get meetingRejoining => 'さいせん';

  @override
  String get meetingSecurity => '安全';

  @override
  String get meetingManagement => '会議管理';

  @override
  String get meetingWatermark => '会議の透かし';

  @override
  String get meetingBeKickedOutByHost => '司会者があなたを会議から外しました';

  @override
  String get meetingBeKickedOut => '会議からはずされる';

  @override
  String get meetingClickOkToClose => '「ok」をクリックすると自動的にページが閉じます';

  @override
  String get meetingLeaveConfirm => '会議を離れることは確実ですか?';

  @override
  String get meetingWatermarkEnabled => '透かしが開きました';

  @override
  String get meetingWatermarkDisabled => '透かしは閉じました';

  @override
  String get meetingInfo => '会議情報';

  @override
  String get meetingNickname => '名前';

  @override
  String get meetingHostChangeYourMeetingName => 'ホストが君の名前を変えた';

  @override
  String get meetingIsInCall => '現在電話対応中';

  @override
  String get screenShare => '画面共有';

  @override
  String get screenShareStop => '共有の終了';

  @override
  String get screenShareOverLimit => '誰かが既に共有しているため、共有できません';

  @override
  String get screenShareNoPermission => '画面共有権限なし';

  @override
  String get screenShareTips => '画面に表示されているすべてのスクリーンショットの撮影を開始します。';

  @override
  String get screenShareStopFail => '画面共有の停止に失敗しました';

  @override
  String get screenShareStartFail => '共有画面の開始に失敗しました';

  @override
  String screenShareLocalTips(Object userName) {
    return '$userNameは画面を共有しています';
  }

  @override
  String screenShareUser(Object userName) {
    return '$userNameの共有画面';
  }

  @override
  String get screenShareInteractionTip => '2 本の指を離すと画面が拡大されます';

  @override
  String get whiteBoardShareStopFail => 'ホワイトボードの共有を停止できませんでした';

  @override
  String get whiteBoardShareStartFail => 'ホワイトボード共有の開始に失敗しました';

  @override
  String get whiteboardShare => 'ホワイトボード';

  @override
  String get whiteBoardClose => 'ホワイトボードを終了';

  @override
  String get whiteBoardInteractionTip => 'ホワイトボード操作権限が付与されました';

  @override
  String get whiteBoardUndoInteractionTip => 'ホワイトボード操作権限が取り消されました';

  @override
  String get whiteBoardNoAuthority =>
      'ホワイトボード オーソリティはまだ有効化されていません。有効化するには営業担当者に連絡してください';

  @override
  String get whiteBoardPackUp => 'やめる';

  @override
  String get meetingHasScreenShareShare => '画面共有中のホワイトボード共有はサポートされていません';

  @override
  String get meetingHasWhiteBoardShare => 'ホワイトボード共有場合は画面共有をサポートしていません';

  @override
  String get meetingStopSharing => '共有を停止する';

  @override
  String get meetingStopSharingConfirm => '進行中の共有を停止しますか？';

  @override
  String get virtualBackground => '背景';

  @override
  String get virtualBackgroundImageNotExist => 'カスタム背景画像が存在しません';

  @override
  String get virtualBackgroundImageFormatNotSupported => 'カスタム背景画像の画像形式が無効です';

  @override
  String get virtualBackgroundImageDeviceNotSupported =>
      'このデバイスはバーチャル背景の使用をサポートしていません';

  @override
  String get virtualBackgroundImageLarge => 'カスタム背景画像が 5M サイズ制限を超えています';

  @override
  String get virtualBackgroundImageMax => 'カスタム背景画像が最大数を超えています';

  @override
  String get virtualBackgroundSelectTip => '画像選択時に有効';

  @override
  String get live => '生放送';

  @override
  String get liveMeeting => '会議の生放送';

  @override
  String get liveMeetingTitle => '生放送のテーマ';

  @override
  String get liveMeetingUrl => '生放送のURL';

  @override
  String get liveEnterLivePassword => 'ライブのパスワードを入力します';

  @override
  String get liveEnterLiveSixDigitPassword => '6桁のパスワードを入力してください';

  @override
  String get liveInteraction => 'ライブ インタラクション';

  @override
  String get liveInteractionTips => 'オンにすると、会議室とライブ ルームのメッセージが相互に表示されます';

  @override
  String get liveLevel => 'この会社の従業員のみが訪問でき';

  @override
  String get liveLevelTip => 'オープンした後、この企業の従業員以外は閲覧できません';

  @override
  String get liveViewSetting => 'ライブビュー設定';

  @override
  String get liveViewSettingChange => 'アンカー変更';

  @override
  String get liveViewPreviewTips => '現在のライブ ビュー プレビュー';

  @override
  String get liveViewPreviewDesc => '最初にライブビューを設定してください';

  @override
  String get liveStart => 'ライブを開始';

  @override
  String get liveUpdate => 'ライブ設定を更新';

  @override
  String get liveStop => 'ライブ停止';

  @override
  String get liveGalleryView => 'ギャラリー';

  @override
  String get liveFocusView => 'フォーカス';

  @override
  String get liveScreenShareView => 'スクリーン共有';

  @override
  String get liveChooseView => '表示スタイルを選択';

  @override
  String get liveChooseCountTips => '最大4人の参加者を選択';

  @override
  String get liveStartFail => 'ライブ開始に失敗しました。後でもう一度試してください';

  @override
  String get liveStartSuccess => 'ライブが正常に開始されました';

  @override
  String livePickerCount(Object length) {
    return '選択$length人';
  }

  @override
  String get liveUpdateFail => 'ライブ更新に失敗しました。後でもう一度試してください';

  @override
  String get liveUpdateSuccess => 'ライブ更新成功';

  @override
  String get liveStopFail => 'ライブ ストップに失敗しました。後でもう一度お試しください';

  @override
  String get liveStopSuccess => 'ライブは正常に停止しました';

  @override
  String get livePassword => 'ライブ パスワード';

  @override
  String get liveDisableAuthLevel => 'ライブ配信中は、ライブ配信の視聴権限を変更できません';

  @override
  String get liveStreaming => '生放送';

  @override
  String get participants => '参加者';

  @override
  String get participantsManager => '参加者の管理';

  @override
  String get participantAssignedHost => 'ホストになりました';

  @override
  String get participantAssignedCoHost => '共同ホストに設定されました';

  @override
  String get participantUnassignedCoHost => '共同主催者としてキャンセルされました';

  @override
  String get participantAssignedActiveSpeaker => 'フォーカス映像に設定されていますね';

  @override
  String get participantUnassignedActiveSpeaker => 'フォーカス映像から削除されました';

  @override
  String get participantMuteAudioAll => '全員ミュート';

  @override
  String get participantMuteAudioAllDialogTips => '全員と新しいメンバーがミュートされます';

  @override
  String get participantMuteVideoAllDialogTips => '全員と新しいメンバーはカメラをオフにします';

  @override
  String get participantUnmuteAll => '全員ミュート解除';

  @override
  String get participantMute => 'ミュート';

  @override
  String get participantUnmute => 'ミュート解除';

  @override
  String get participantTurnOffVideos => '全員ビデオ閉じ';

  @override
  String get participantTurnOnVideos => '全員ビデオを開く';

  @override
  String get participantStopVideo => 'カメラ';

  @override
  String get participantStartVideo => 'カメラ';

  @override
  String get participantTurnOffAudioAndVideo => 'オーディオとビデオをオフにする';

  @override
  String get participantTurnOnAudioAndVideo => 'オーディオとビデオを開く';

  @override
  String get participantHostStoppedShare => 'ホストが共有を終了しました';

  @override
  String get participantHostStopWhiteboard => 'ホストがホワイトボードの共有を終了しました';

  @override
  String get participantAssignActiveSpeaker => 'フォーカス ビデオとして設定';

  @override
  String get participantUnassignActiveSpeaker => 'ビデオのフォーカスを外す';

  @override
  String get participantTransferHost => 'ホストに引き渡す';

  @override
  String participantTransferHostConfirm(Object userName) {
    return '司会者の権限を$userNameに移譲しますか？';
  }

  @override
  String get participantRemove => '除去';

  @override
  String get participantRename => '名称変更';

  @override
  String get participantRenameDialogTitle => '名称変更';

  @override
  String get participantAssignCoHost => '共同ホストを設定';

  @override
  String get participantUnassignCoHost => '共同ホストをキャンセル';

  @override
  String get participantRenameTips => '新しいニックネームを入力してください';

  @override
  String get participantRenameSuccess => '名前が変更成功';

  @override
  String get participantRenameFail => '名前が変更失敗';

  @override
  String get participantRemoveConfirm => '削除の確認';

  @override
  String get participantCannotRemoveSelf => '自分自身を削除できません';

  @override
  String get participantMuteAudioFail => 'ミュート失敗';

  @override
  String get participantUnMuteAudioFail => 'ミュート解除失敗';

  @override
  String get participantMuteVideoFail => 'ビデオの停止に失敗しました';

  @override
  String get participantUnMuteVideoFail => 'ビデオオンが失敗';

  @override
  String get participantFailedToAssignActiveSpeaker => 'フォーカス ビデオの設定に失敗しました';

  @override
  String get participantFailedToUnassignActiveSpeaker => 'ビデオのフォーカス解除に失敗しました';

  @override
  String get participantFailedToLowerHand => 'メンバーの挙手を下ろすのに失敗しました';

  @override
  String get participantFailedToTransferHost => 'ホストの引き渡すことが失敗しました';

  @override
  String get participantFailedToRemove => '削除に失敗しました';

  @override
  String get participantOpenCamera => 'カメラを開く';

  @override
  String get participantOpenMicrophone => 'マイクを開く';

  @override
  String get participantHostOpenCameraTips => 'ホストがカメラを再開しました。確認しますか?';

  @override
  String get participantHostOpenMicroTips => 'ホストがマイクを再開しました。確認しますか?';

  @override
  String get participantMuteAllAudioTip => '参加者が自分自身をミュート解除できるようにする';

  @override
  String get participantMuteAllVideoTip => '参加者がビデオを開くことを許可';

  @override
  String get participantMuteAllAudioSuccess => 'すべてのオーディオをミュートしました';

  @override
  String get participantMuteAllAudioFail => 'すべてのミュートに失敗しました';

  @override
  String get participantMuteAllVideoSuccess => 'すべての動画を閉じました';

  @override
  String get participantMuteAllVideoFail => 'すべてのビデオを閉じることができませんでした';

  @override
  String get participantUnMuteAllAudioSuccess => 'すべてのミュート解除をリクエストしました';

  @override
  String get participantUnMuteAllAudioFail => '全員ミュート解除 に失敗しました';

  @override
  String get participantUnMuteAllVideoSuccess => '全員ビデオを開くように要求しました';

  @override
  String get participantUnMuteAllVideoFail => 'すべてのビデオを開くことができませんでした';

  @override
  String get participantHostMuteVideo => 'ビデオから停止されました';

  @override
  String get participantHostMuteAudio => 'ミュートされました';

  @override
  String get participantHostMuteAllAudio => '主催者が全員をミュートに設定しました';

  @override
  String get participantHostMuteAllVideo => '主催者はすべてのビデオをオフに設定しました';

  @override
  String get participantMuteAudioHandsUpOnTips =>
      '主催者があなたのミュートを解除しました。あなたは自由に話すことができます';

  @override
  String get participantOverRoleLimitCount => '割り当てられた役割が制限数を超えています';

  @override
  String get participantMe => 'わたし';

  @override
  String get participantSearchMember => '検索メンバー';

  @override
  String get participantHost => 'ホスト';

  @override
  String get participantCoHost => '共同ホスト';

  @override
  String get participantMuteAllHandsUpTips =>
      '主催者が全員をミュートしました。手を挙げてスピーチを申し込むことができます';

  @override
  String get participantTurnOffAllVideoHandsUpTips =>
      'ホストがすべてのビデオをオフにしました。ビデオを開くために手を挙げて適用できます';

  @override
  String get participantWhiteBoardInteract => 'ホワイトボード操作権限が付与されました';

  @override
  String get participantWhiteBoardInteractFail => 'ホワイトボード操作権限が付与のは失敗しました';

  @override
  String get participantUndoWhiteBoardInteract => 'ホワイトボード操作権限が撤回しました';

  @override
  String get participantUndoWhiteBoardInteractFail => 'ホワイトボード操作の取り消しに失敗しました';

  @override
  String get participantUserHasBeenAssignCoHostRole => '共同ホストとして設定されています';

  @override
  String get participantUserHasBeenRevokeCoHostRole => '共同主催者としての活動を停止されました';

  @override
  String get participantInMeeting => '会議中';

  @override
  String get participantNotJoined => '未入会';

  @override
  String get participantAttendees => '参加者';

  @override
  String get participantAdmit => '許可します';

  @override
  String get participantWaitingTimePrefix => '待ちました';

  @override
  String get participantPutInWaitingRoom => '待合室に移動';

  @override
  String get participantExpelWaitingMemberDialogTitle => '待合室メンバーの除去';

  @override
  String get participantDisallowMemberRejoinMeeting =>
      'ユーザーが会議に再参加することは許可されていません';

  @override
  String get cloudRecordingEnabledTitle => 'クラウド録画を有効にするかどうか';

  @override
  String get cloudRecordingEnabledMessage =>
      'オンにすると、会議中の音声ビデオと共有画面のコンテンツをクラウドに録画し、参加メンバー全員に通知します';

  @override
  String get cloudRecordingEnabledMessageWithoutNotice =>
      '録画が開始されると、会議の音声、ビデオ、共有画面がクラウドに記録されます';

  @override
  String get cloudRecordingTitle => '会議は録画中です';

  @override
  String get cloudRecordingMessage =>
      '司会者は会議クラウドの録画を開始し、会議の作成者はクラウドの録画ファイルを見ることができ、会議が終わったら会議の作成者に連絡して閲覧リンクを得ることができます。';

  @override
  String get cloudRecordingAgree => '会議に残っていれば、録画に同意することを示します';

  @override
  String get cloudRecordingWhetherEndedTitle => 'クラウド記録を終了するかどうか';

  @override
  String get cloudRecordingEndedMessage =>
      'クラウド録画ファイルを終了するかどうかは、会議の終了後に履歴会議-会議の詳細に同期されます。クラウド録画ファイルを終了するかどうかは、会議の終了後に履歴会議-会議の詳細に同期されます。';

  @override
  String get cloudRecordingEndedTitle => 'クラウドレコーディングが終了しました';

  @override
  String get cloudRecordingEndedAndGetUrl =>
      '会議終了後に会議作成者に連絡して閲覧リンクを取得することができます';

  @override
  String get cloudRecordingStart => 'クラウドレコーディング';

  @override
  String get cloudRecordingStop => '記録の停止';

  @override
  String get cloudRecording => '録画中';

  @override
  String get cloudRecordingStartFail => 'クラウド録画に失敗しました';

  @override
  String get cloudRecordingStopFail => 'クラウド録画の停止に失敗しました';

  @override
  String get cloudRecordingStarting => '録画を開始する...';

  @override
  String get chat => 'チャート';

  @override
  String get chatInputMessageHint => '入力メッセージ...';

  @override
  String get chatCannotSendBlankLetter => '空のメッセージの送信はサポートされていません';

  @override
  String get chatJoinFail => 'チャット ルームへのエントリに失敗しました!';

  @override
  String get chatNewMessage => '新しいメッセージ';

  @override
  String get chatUnsupportedFileExtension => 'このタイプのファイルは現在サポートされていません';

  @override
  String get chatFileSizeExceedTheLimit => 'ファイル サイズは 200MB を超えることはできません';

  @override
  String get chatImageSizeExceedTheLimit => '画像サイズは 20MB を超えることはできません';

  @override
  String get chatImageMessageTip => '[画像]';

  @override
  String get chatFileMessageTip => '[ファイル]';

  @override
  String get chatSaveToGallerySuccess => 'システム アルバムに保存しました';

  @override
  String get chatOperationFailNoPermission => '操作権限なし';

  @override
  String get chatOpenFileFail => 'ファイルを開くことができませんでした';

  @override
  String get chatOpenFileFailNoPermission => 'ファイルを開くことができませんでした: 権限がありません';

  @override
  String get chatOpenFileFailFileNotFound => 'ファイルを開くことができませんでした: ファイルが存在しません';

  @override
  String get chatOpenFileFailAppNotFound =>
      'ファイルを開けませんでした: このファイルを開くアプリケーションが見つかりません';

  @override
  String get chatRecall => '撤回';

  @override
  String get chatAboveIsHistoryMessage => '以上が履歴チャットメッセージです';

  @override
  String get chatYou => 'あなた';

  @override
  String get chatRecallAMessage => 'はメッセージを撤回した';

  @override
  String get chatMessageRecalled => 'メッセージは撤回されました';

  @override
  String get chatMessage => 'メッセージです';

  @override
  String get chatSendTo => '発送します';

  @override
  String get chatAllMembersInMeeting => '会議の全員です';

  @override
  String get chatAllMembersInWaitingRoom => '待合室の全員です';

  @override
  String get chatHistory => 'チャット履歴';

  @override
  String get chatMessageSendToWaitingRoom => '待合室に送る';

  @override
  String get chatNoChatHistory => 'チャット記録はありません';

  @override
  String get waitingRoomJoinMeeting => 'ミーティングに参加';

  @override
  String get waitingRoom => '待合室';

  @override
  String get waitingRoomJoinMeetingOption => '入会オプションです';

  @override
  String get waitingRoomWaitHostToInviteJoinMeeting =>
      'お待ちください,司会者が会議にご案内しますので';

  @override
  String get waitingRoomWaitMeetingToStart => 'ちょっと待ってくださいね。まもなく会議が始まります';

  @override
  String get waitingRoomTurnOnMicrophone => 'マイクをオンにします';

  @override
  String get waitingRoomTurnOnVideo => 'カメラを起動します';

  @override
  String get waitingRoomEnabledOnEntry => '待合室を有効にしています';

  @override
  String get waitingRoomDisabledOnEntry => '待合室は閉鎖しました';

  @override
  String get waitingRoomDisableDialogTitle => '待合室を閉める';

  @override
  String get waitingRoomDisableDialogMessage => '待合室が閉鎖された後、新入会員が直接会議に参加します';

  @override
  String get waitingRoomDisableDialogAdmitAll => '待合室のすべてのメンバーが会議に入ることを許可します';

  @override
  String get waitingRoomCloseRightNow => '閉じる';

  @override
  String waitingRoomCount(Object count) {
    return '待合室に$count名お待ちしております';
  }

  @override
  String get movedToWaitingRoom => 'ホストがあなたを待合室に移動させました';

  @override
  String get deviceSpeaker => 'スピーカー';

  @override
  String get deviceReceiver => 'レシーバー';

  @override
  String get deviceBluetooth => 'Bluetooth';

  @override
  String get deviceHeadphones => 'ヘッドホン';

  @override
  String get deviceOutput => 'オーディオ機器';

  @override
  String get deviceHeadsetState => 'イヤホンを使用しています';

  @override
  String get networkConnectionGood => '良好なインターネット回線';

  @override
  String get networkConnectionGeneral => '一般的なインターネット回線';

  @override
  String get networkConnectionPoor => 'インターネット接続環境の悪さ';

  @override
  String get nan => 'インターネット接続不可';

  @override
  String get networkLocalLatency => '遅延';

  @override
  String get networkPacketLossRate => 'パケット損失率';

  @override
  String get networkReconnectionSuccessful => 'ネットワーク再接続成功。';

  @override
  String get networkAbnormalityPleaseCheckYourNetwork =>
      'ネットワーク異常、あなたのネットワークを確認してください。';

  @override
  String get networkAbnormality => 'ネットワーク異常。';

  @override
  String get networkDisconnectedPleaseCheckYourNetworkStatusOrTryToRejoin =>
      'ネットワークが切断されました。ネットワーク状況を確認するか、再度参加してください。';

  @override
  String get networkNotStable => '現在のネットワーク状態は良くありません';

  @override
  String get networkUnavailableCloseFail => 'ネットワーク異常、ミーティングを終了できませんでした';

  @override
  String get networkDisconnectedTryingToReconnect =>
      'ネットワークが切断されました。再接続を試みています...';
}
