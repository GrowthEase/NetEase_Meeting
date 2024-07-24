// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of feedback;

class FeedbackRepository with _AloggerMixin {
  static const _tag = 'FeedbackRepository';
  FeedbackRepository._internal();

  static final FeedbackRepository _singleton = FeedbackRepository._internal();

  factory FeedbackRepository() => _singleton;

  String? get feedbackServer => CoreRepository().feedbackServer;

  static const audioDumpDurationInSeconds = 60;

  NEFeedback? feedbackPending;
  Timer? currentTimer;

  Future<NEResult<void>> _feedback(NEFeedback feedback) async {
    /// 如果没有配置反馈服务器地址，则直接返回
    if (feedbackServer == null || feedbackServer.isEmpty) {
      apiLogger.e('feed url is null, please check the config');
      return NEResult(code: -1);
    }

    /// 复制图片到日志目录
    final copyImages = await copyImageToLogDir(feedback);

    /// 上传日志到nos平台并返回下载路径
    final result = await NERoomKit.instance.uploadLog();
    apiLogger.d('uploadLog result = ${result.data}');

    /// 删除日志中复制的照片
    for (final image in copyImages) {
      final file = File(image);
      try {
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        apiLogger.e('delete image error: $e, $image');
      }
    }
    final roomContext = MeetingRepository().currentRoomContext;
    final accountInfo = AccountRepository().getAccountInfo();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    var response = await HttpApiHelper.feedback(
      feedbackServer!,
      feedback,
      accountInfo?.phoneNumber,
      accountInfo?.nickname,
      roomContext?.meetingInfo.meetingId.toString(),
      0,
      result.data,
      appVersion,
    );
    return NEResult(code: response.code, msg: response.msg);
  }

  Future<List<String>> copyImageToLogDir(NEFeedback feedback) async {
    final copyImages = <String>[];
    if (feedback.imageList != null) {
      apiLogger.i('images=${feedback.imageList?.join(',')}');
      final logDirectoryPath = await _getImageLogDirectoryPath();
      if (logDirectoryPath != null) {
        for (final image in feedback.imageList!) {
          try {
            final file = File(image);
            if (!file.existsSync()) continue;
            final fileName = file.path.split('/').last;
            final newPath = logDirectoryPath + fileName;
            await File(newPath).create(recursive: true);
            await file.copy(newPath);
            copyImages.add(newPath);
          } catch (e) {
            apiLogger.e('copy image error: $e, $image');
          }
        }
      }
    }
    return copyImages;
  }

  Future<String?> _getImageLogDirectoryPath() async {
    final path = await NERoomKit.instance.logPath;
    return '$path${path?.endsWith('/') == true ? '' : '/'}images/';
  }

  Future<NEResult<void>> addFeedbackTask(NEFeedback feedback) async {
    print('$_tag addFeedbackTask');
    if (feedbackPending != null) {
      await commitFeedbackTask();
    }
    feedbackPending = feedback;
    final roomContext = MeetingRepository().currentRoomContext;
    if (feedbackPending?.needAudioDump == true && roomContext != null) {
      await roomContext.rtcController.startAudioDump(NEAudioDumpType.kPCM);
      currentTimer = Timer(Duration(seconds: audioDumpDurationInSeconds), () {
        apiLogger.i('$_tag timeout to commit');
        commitFeedbackTask();
      });
      return NEResult.success();
    } else {
      return commitFeedbackTask();
    }
  }

  Future<NEResult<void>> commitFeedbackTask() async {
    print('$_tag commitFeedbackTask');
    final pending = feedbackPending;
    var result = NEResult.success();
    if (pending != null) {
      if (pending.needAudioDump == true) {
        final roomContext = MeetingRepository().currentRoomContext;
        await roomContext?.rtcController.stopAudioDump();
      }
      result = await _commitFeedbackTaskInner(pending);
      currentTimer?.cancel();
      currentTimer = null;
      feedbackPending = null;
    }
    return result;
  }

  Future<NEResult<void>> _commitFeedbackTaskInner(NEFeedback fb) async {
    await ConnectivityManager().awaitUntilConnected();
    return _feedback(fb);
  }
}
