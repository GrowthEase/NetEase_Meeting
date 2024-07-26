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
  late SDKConfig config;
  StreamSubscription? subscription;
  int version = 0;

  @override
  void initState() {
    super.initState();
    if (widget.config == null) {
      updateConfig(SDKConfig.global);
    } else {
      updateConfig(widget.config!);
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NEMeetingKitFeatureConfig oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      updateConfig(widget.config ?? SDKConfig.global);
    }
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

  bool get isBeautyFaceSupported => sdkConfig!.isBeautyFaceSupported;

  bool get isMeetingLiveSupported => sdkConfig!.isLiveSupported;

  bool get isWaitingRoomSupported => sdkConfig!.isWaitingRoomSupported;

  bool get isGuestJoinSupported => sdkConfig!.isGuestJoinSupported;

  bool get isCloudRecordSupported => sdkConfig!.isCloudRecordSupported;

  bool get isVirtualBackgroundEnabled =>
      sdkConfig!.isVirtualBackgroundSupported;

  NEInterpretationConfig get interpretationConfig =>
      sdkConfig!.interpretationConfig;

  bool get isCaptionsSupported => sdkConfig!.isCaptionsSupported;

  bool get isTranscriptionSupported => sdkConfig!.isTranscriptionSupported;
}
