// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

///
/// 会议功能配置开关
///
class NEMeetingKitFeatureConfig extends StatefulWidget {
  final Widget child;
  const NEMeetingKitFeatureConfig({
    super.key,
    required this.child,
  });

  @override
  State<NEMeetingKitFeatureConfig> createState() =>
      _NEMeetingKitFeatureConfigState();
}

class _NEMeetingKitFeatureConfigState extends State<NEMeetingKitFeatureConfig> {
  final configChangeNotifier = SDKConfig.configChangeNotifier;
  late SDKConfig config;
  StreamSubscription? subscription;
  int version = 0;

  @override
  void initState() {
    super.initState();
    config = configChangeNotifier.value;
    configChangeNotifier.addListener(onConfigChange);
  }

  @override
  void dispose() {
    configChangeNotifier.removeListener(onConfigChange);
    subscription?.cancel();
    super.dispose();
  }

  void onConfigChange() {
    subscription?.cancel();
    config = configChangeNotifier.value;
    subscription = config.onConfigUpdated.listen((event) {
      if (mounted)
        setState(() {
          version++;
        });
    });
    setState(() {
      version++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SDKConfigScope(
      config: config,
      version: version,
      child: Builder(
        builder: (context) {
          return widget.child;
        },
      ),
    );
  }
}

class _SDKConfigScope extends InheritedWidget {
  final SDKConfig config;
  final int version;

  const _SDKConfigScope({
    required this.config,
    required this.version,
    required Widget child,
  }) : super(child: child);

  static _SDKConfigScope of(BuildContext context) {
    final _SDKConfigScope? result =
        context.dependOnInheritedWidgetOfExactType<_SDKConfigScope>();
    assert(result != null, 'No _SDKConfigScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_SDKConfigScope old) {
    return old.version != version;
  }
}

extension NEMeetingKitConfigExtension on BuildContext {
  SDKConfig get _sdkConfig => _SDKConfigScope.of(this).config;

  bool get isBeautyFaceEnabled => _sdkConfig.isBeautyFaceSupported;

  bool get isMeetingLiveEnabled => _sdkConfig.isLiveSupported;

  bool get isWaitingRoomEnabled => _sdkConfig.isWaitingRoomSupported;

  bool get isGuestJoinEnabled => _sdkConfig.isGuestJoinSupported;

  bool get isVirtualBackgroundEnabled =>
      _sdkConfig.isVirtualBackgroundSupported;
}
