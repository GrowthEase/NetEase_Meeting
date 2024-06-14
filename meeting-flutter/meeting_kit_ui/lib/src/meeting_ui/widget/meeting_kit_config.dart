// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

///
/// 会议功能配置开关
///
class NEMeetingKitFeatureConfig extends StatefulWidget {
  final Widget? child;
  final TransitionBuilder? builder;
  final SDKConfig? config;
  const NEMeetingKitFeatureConfig({
    super.key,
    this.child,
    this.builder,
    this.config,
  }) : assert(child != null || builder != null);

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
    if (widget.config == null) {
      configChangeNotifier.addListener(globalConfigChanged);
      updateConfig(configChangeNotifier.value);
    } else {
      updateConfig(widget.config!);
    }
  }

  @override
  void dispose() {
    configChangeNotifier.removeListener(globalConfigChanged);
    subscription?.cancel();
    super.dispose();
  }

  void globalConfigChanged() {
    updateConfig(configChangeNotifier.value);
  }

  void updateConfig(SDKConfig config) {
    subscription?.cancel();
    this.config = config;
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
          return widget.builder?.call(context, widget.child) ?? widget.child!;
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

  static _SDKConfigScope? of(BuildContext context) {
    final _SDKConfigScope? result =
        context.dependOnInheritedWidgetOfExactType<_SDKConfigScope>();
    return result;
  }

  @override
  bool updateShouldNotify(_SDKConfigScope old) {
    return old.config != config || old.version != version;
  }
}

extension NEMeetingKitConfigExtension on BuildContext {
  SDKConfig? get sdkConfig => _SDKConfigScope.of(this)?.config;

  bool get isBeautyFaceEnabled => sdkConfig!.isBeautyFaceSupported;

  bool get isMeetingLiveEnabled => sdkConfig!.isLiveSupported;

  bool get isWaitingRoomEnabled => sdkConfig!.isWaitingRoomSupported;

  bool get isGuestJoinEnabled => sdkConfig!.isGuestJoinSupported;

  bool get isVirtualBackgroundEnabled =>
      sdkConfig!.isVirtualBackgroundSupported;

  InterpretationConfig get interpretationConfig =>
      sdkConfig!.interpretationConfig;
}
