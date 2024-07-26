// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 非管理员自动关闭页面组件
class AutoPopIfNotManager extends StatefulWidget {
  const AutoPopIfNotManager({
    super.key,
    this.child,
    this.builder,
    required this.roomContext,
  }) : assert(child != null || builder != null);

  final NERoomContext roomContext;
  final Widget? child;
  final TransitionBuilder? builder;

  @override
  State<AutoPopIfNotManager> createState() => _AutoPopIfNotManagerState();
}

class _AutoPopIfNotManagerState extends State<AutoPopIfNotManager> {
  late final _eventCallback =
      NERoomEventCallback(memberRoleChanged: (member, _, __) {
    if (member.uuid == widget.roomContext.myUuid) {
      isMySelfNotManager.value = !widget.roomContext.isMySelfHostOrCoHost();
    }
  });

  late ValueNotifier<bool> isMySelfNotManager;

  @override
  void initState() {
    super.initState();
    widget.roomContext.addEventCallback(_eventCallback);
    isMySelfNotManager =
        ValueNotifier(!widget.roomContext.isMySelfHostOrCoHost());
  }

  @override
  void dispose() {
    widget.roomContext.removeEventCallback(_eventCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoPopScope(
      listenable: isMySelfNotManager,
      builder: widget.builder,
      child: widget.child,
    );
  }
}

typedef MemberRoleBuilder = Widget Function(
    BuildContext context, bool isHost, bool isCohost, Widget? child);

/// 根据成员角色构建不同的组件
class MemberRoleChangedBuilder extends StatefulWidget {
  final String? userUuid;
  final NERoomContext roomContext;
  final MemberRoleBuilder? builder;
  final Widget? child;

  const MemberRoleChangedBuilder({
    super.key,
    required this.roomContext,
    this.userUuid,
    this.builder,
    this.child,
  }) : assert(builder != null || child != null);

  MemberRoleChangedBuilder.ifManager({
    Key? key,
    required NERoomContext roomContext,
    String? userUuid,
    Widget? child,
    required TransitionBuilder builder,
  }) : this(
          key: key,
          roomContext: roomContext,
          userUuid: userUuid,
          builder: (context, isHost, isCohost, child) {
            if (isHost || isCohost) {
              return builder.call(context, child);
            }
            return const SizedBox.shrink();
          },
          child: child,
        );

  @override
  State<MemberRoleChangedBuilder> createState() =>
      _MemberRoleChangedBuilderState();
}

class _MemberRoleChangedBuilderState extends State<MemberRoleChangedBuilder> {
  late final _eventCallback = NERoomEventCallback(
    memberRoleChanged: (member, _, __) {
      if (member.uuid == widget.userUuid ||
          (widget.userUuid == null &&
              member.uuid == widget.roomContext.myUuid)) {
        if (mounted) setState(() {});
      }
    },
  );

  @override
  void initState() {
    super.initState();
    widget.roomContext.addEventCallback(_eventCallback);
  }

  @override
  void dispose() {
    widget.roomContext.removeEventCallback(_eventCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.userUuid == null
        ? widget.roomContext.localMember
        : widget.roomContext.getMember(widget.userUuid);
    final isHost = member?.isHost ?? false;
    final isCohost = member?.isCohost ?? false;
    return widget.builder!.call(context, isHost, isCohost, widget.child);
  }
}

/// 通用按钮组件
class MeetingTextButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final Color? borderColor;

  const MeetingTextButton({
    super.key,
    required this.text,
    this.textColor,
    this.backgroundColor,
    this.onPressed,
    this.borderColor,
  });

  MeetingTextButton.fill({
    super.key,
    required this.text,
    this.textColor = _UIColors.white,
    this.backgroundColor = _UIColors.color_337eff,
    this.onPressed,
    this.borderColor,
  });

  MeetingTextButton.outlined({
    super.key,
    required this.text,
    this.textColor = _UIColors.color1E1F27,
    this.backgroundColor = Colors.white,
    this.onPressed,
    this.borderColor = _UIColors.colorCDCFD7,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(const Size.fromHeight(44)),
        textStyle: WidgetStateProperty.all(
            TextStyle(fontSize: 16, color: _UIColors.color1E1F27)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        )),
        backgroundColor: backgroundColor != null
            ? WidgetStateProperty.all(
                backgroundColor!.withOpacity(onPressed != null ? 1 : 0.6))
            : null,
        foregroundColor:
            textColor != null ? WidgetStateProperty.all(textColor!) : null,
      ),
    );
  }
}

/// 账号信息组件。账号信息变更时，自动刷新
class NEAccountInfoBuilder extends StatefulWidget {
  const NEAccountInfoBuilder({
    super.key,
    this.child,
    this.nullBuilder,
    this.builder,
  }) : assert(child != null || builder != null);

  final Widget? child;
  final TransitionBuilder? nullBuilder;
  final ValueWidgetBuilder<NEAccountInfo>? builder;

  @override
  State<NEAccountInfoBuilder> createState() => _NEAccountInfoBuilderState();
}

class _NEAccountInfoBuilderState extends State<NEAccountInfoBuilder>
    with NEAccountServiceListener {
  late final accountRepo = AccountRepository();

  @override
  void initState() {
    super.initState();
    accountRepo.addListener(this);
  }

  @override
  void dispose() {
    accountRepo.removeListener(this);
    super.dispose();
  }

  void onAccountInfoUpdated(NEAccountInfo? accountInfo) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final accountInfo = accountRepo.getAccountInfo();
    if (accountInfo == null) {
      return widget.nullBuilder?.call(context, widget.child) ??
          SizedBox.shrink();
    }
    return widget.builder?.call(
          context,
          accountInfo,
          widget.child,
        ) ??
        widget.child!;
  }
}

/// 会议水印配置管理
class NEWatermarkConfigurationManager extends StatefulWidget {
  final NERoomContext roomContext;
  final NEWatermarkConfig? watermarkConfig;
  final Widget child;

  const NEWatermarkConfigurationManager({
    super.key,
    required this.child,
    required this.roomContext,
    this.watermarkConfig,
  });

  @override
  State<NEWatermarkConfigurationManager> createState() =>
      _NEWatermarkConfigurationManagerState();

  static TextWatermarkConfiguration? of(BuildContext context) {
    return _WatermarkConfigurationScope.of(context)?.textWatermarkConfiguration;
  }
}

class _NEWatermarkConfigurationManagerState
    extends State<NEWatermarkConfigurationManager> {
  NERoomContext? roomContext;
  NEMeetingWatermark? watermark;

  late final NERoomEventCallback callback = NERoomEventCallback(
    memberScreenShareStateChanged: (_, __, ___) => updateWatermarkInfo(),
    roomPropertiesChanged: (_) => updateWatermarkInfo(),
    roomPropertiesDeleted: (_) => updateWatermarkInfo(),
  );

  @override
  void initState() {
    super.initState();
    setup(widget.roomContext);
  }

  @override
  void didUpdateWidget(covariant NEWatermarkConfigurationManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    setup(widget.roomContext);
  }

  void setup(NERoomContext newRoomContext) {
    if (roomContext != newRoomContext) {
      roomContext?.removeEventCallback(callback);
      newRoomContext.addEventCallback(callback);
      roomContext = newRoomContext;
      updateWatermarkInfo();
    }
  }

  void updateWatermarkInfo() {
    var newWatermark = roomContext?.watermark;
    if (roomContext?.localMember.isSharingScreen == true) {
      newWatermark = null;
    }
    if (newWatermark != watermark) {
      setState(() {
        watermark = newWatermark;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextWatermarkConfiguration? _config = null;
    final _watermark = watermark;
    if (_watermark != null && _watermark.isEnable()) {
      _config = TextWatermarkConfiguration(
        offset: Offset(0, MediaQuery.of(context).padding.top),
        singleRow: _watermark.isSingleRow(),
        text: _watermark.replaceFormatText(widget.watermarkConfig),
        maxWidth: _watermark.isSingleRow() ? 184 : 138,
      );
    }

    return _WatermarkConfigurationScope(
      textWatermarkConfiguration: _config,
      child: widget.child,
    );
  }
}

class _WatermarkConfigurationScope extends InheritedWidget {
  const _WatermarkConfigurationScope({
    required Widget child,
    required this.textWatermarkConfiguration,
  }) : super(child: child);

  final TextWatermarkConfiguration? textWatermarkConfiguration;

  static _WatermarkConfigurationScope? of(BuildContext context) {
    final _WatermarkConfigurationScope? result = context
        .dependOnInheritedWidgetOfExactType<_WatermarkConfigurationScope>();
    return result;
  }

  @override
  bool updateShouldNotify(_WatermarkConfigurationScope old) {
    return textWatermarkConfiguration != old.textWatermarkConfiguration;
  }
}

class MeetingWatermark extends StatelessWidget {
  final Widget child;

  const MeetingWatermark({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TextWatermark(
      configuration: NEWatermarkConfigurationManager.of(context),
      child: child,
    );
  }
}
