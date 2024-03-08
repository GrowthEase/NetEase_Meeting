// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingConfig {
  // static final int _focusSwitchInterval = 6;

  /// audio low threshold
  static const int volumeLowThreshold = 10;

  /// join time out
  static const int joinTimeOutInterval = 45;

  static const int _defaultGridSide = 2;

  static int get defaultGridSide => _defaultGridSide;

  /// gridSide * gridSide
  /// /*/*/
  /// /*/*/
  // static final int _gridSize = _defaultGridSide * _defaultGridSide;

  /// min show grid size  must bigger than 2, because every page show self
  static const minGridSize = 2;

  /// gallery self render size
  static const int selfRenderSize = 2;

  factory MeetingConfig() =>
      _instance ??= (_instance = MeetingConfig._internal());

  static MeetingConfig? _instance;

  MeetingConfig._internal();
}

///
/// 聊天室配置
///
class NEMeetingChatroomConfig {
  ///
  /// 是否允许发送/接收文件消息，默认打开。
  ///
  final bool enableFileMessage;

  ///
  /// 是否允许发送/接收图片消息，默认打开。
  ///
  final bool enableImageMessage;

  NEMeetingChatroomConfig({
    this.enableFileMessage = true,
    this.enableImageMessage = true,
  });

  factory NEMeetingChatroomConfig.fromJson(Map? json) {
    return NEMeetingChatroomConfig(
      enableFileMessage: json.getOrDefault('enableFileMessage', true) ?? true,
      enableImageMessage: json.getOrDefault('enableImageMessage', true) ?? true,
    );
  }
}

abstract base class MeetingGridLayout {
  int get rows;

  int get columns;

  int get pageSize => rows * columns;

  double get itemW;

  double get itemH;

  bool portrait = true;

  void ensureLayoutParams(Size size, EdgeInsets paddings);
}

final class MeetingVideoGridLayout extends MeetingGridLayout {
  static const int _maxRows = 2;
  static const int _maxColumns = 2;
  MeetingVideoGridLayout();

  Size _size = Size.zero;
  late double _itemWPortrait, _itemHPortrait;
  late int _rowsPortrait, _columnsPortrait;
  late double _itemWLandscape, _itemHLandscape;
  late int _rowsLandscape, _columnsLandscape;

  @override
  int get rows => portrait ? _rowsPortrait : _rowsLandscape;

  @override
  int get columns => portrait ? _columnsPortrait : _columnsLandscape;

  @override
  double get itemW => portrait ? _itemWPortrait : _itemWLandscape;

  @override
  double get itemH => portrait ? _itemHPortrait : _itemHLandscape;

  @override
  void ensureLayoutParams(Size size, EdgeInsets paddings) {
    final width = size.shortestSide;
    final height = size.longestSide;
    final fixSize = Size(width, height);
    if (fixSize == _size) return;
    _size = fixSize;
    final w = width - paddings.left - paddings.right;
    final h = height - paddings.top - paddings.bottom;

    /// 计算竖屏布局参数
    final portraitParams =
        _calculateLayoutParams(w, h, _maxRows, _maxColumns, 9 / 16);
    _itemWPortrait = portraitParams.width;
    _itemHPortrait = portraitParams.height;
    _rowsPortrait = portraitParams.row;
    _columnsPortrait = portraitParams.column;

    /// 计算横屏布局参数
    final landscapeParams =
        _calculateLayoutParams(h, w, _maxRows, _maxColumns, 16 / 9);
    _itemWLandscape = landscapeParams.width;
    _itemHLandscape = landscapeParams.height;
    _rowsLandscape = landscapeParams.row;
    _columnsLandscape = landscapeParams.column;

    debugPrint(
        'MeetingVideoGridLayout: $fixSize, $paddings, $portraitParams, $landscapeParams');
  }

  static ({
    double width,
    double height,
    int row,
    int column,
  }) _calculateLayoutParams(
      double width, double height, int row, int columns, double aspectRatio) {
    var _row = row;
    var w = width / columns;
    var h = w / aspectRatio;
    if (h * row > height) {
      h = height / row;
      w = h * aspectRatio;
      if (w * columns > width) {
        w = width / columns;
        h = w / aspectRatio;
        _row = (height / h).floor();
      }
    }
    return (width: w, height: h, row: _row, column: columns);
  }
}

final class MeetingAudioGridLayout extends MeetingGridLayout {
  /// 语音模式的 item 宽高
  static const Size _itemSize = Size(100, 128);

  /// 竖屏、语音模式下的 grid 行数
  static const int _maxRowsPortrait = 4;

  /// 竖屏、语音模式下的 grid 列数
  static const int _maxColumnsPortrait = 3;

  /// 横屏、语音模式下的 grid 行数
  static const int _maxRowsLandscape = 2;

  /// 横屏、语音模式下的 grid 列数
  static const int _maxColumnsLandscape = 6;

  MeetingAudioGridLayout();

  Size _size = Size.zero;
  late int _rowsPortrait, _columnsPortrait;
  late int _rowsLandscape, _columnsLandscape;

  @override
  int get rows => portrait ? _rowsPortrait : _rowsLandscape;

  @override
  int get columns => portrait ? _columnsPortrait : _columnsLandscape;

  @override
  final double itemW = _itemSize.width;

  @override
  final double itemH = _itemSize.height;

  @override
  void ensureLayoutParams(Size size, EdgeInsets paddings) {
    final width = size.shortestSide;
    final height = size.longestSide;
    final fixSize = Size(width, height);
    if (fixSize == _size) return;
    _size = fixSize;
    final w = width - paddings.left - paddings.right;
    final h = height - paddings.top - paddings.bottom;

    /// 计算竖屏布局参数
    final portraitParams =
        _calculateLayoutParams(w, h, _maxRowsPortrait, _maxColumnsPortrait);
    _rowsPortrait = portraitParams.row;
    _columnsPortrait = portraitParams.col;

    /// 计算横屏布局参数
    final landscapeParams =
        _calculateLayoutParams(h, w, _maxRowsLandscape, _maxColumnsLandscape);
    _rowsLandscape = landscapeParams.row;
    _columnsLandscape = landscapeParams.col;

    debugPrint(
        'MeetingAudioGridLayout: $fixSize, $paddings, $portraitParams, $landscapeParams');
  }

  static ({int row, int col}) _calculateLayoutParams(
      double w, double h, int maxRows, int maxColumns) {
    final itemW = _itemSize.width;
    final itemH = _itemSize.height;
    final rows = h ~/ itemH;
    final columns = w ~/ itemW;
    return (row: min(rows, maxRows), col: min(columns, maxColumns));
  }
}
