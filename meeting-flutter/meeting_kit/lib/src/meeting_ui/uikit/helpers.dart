// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

extension MeetingNumFormatter on String {
  String toMeetingNumFormat() {
    return replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d{3,})'), (match) {
      return '${match[1]}-${match[2]}-${match[3]}';
    });
  }
}

extension MaterialStateSetExt on Set<WidgetState> {
  bool get hasDisabled => contains(WidgetState.disabled);
  bool get hasFocused => contains(WidgetState.focused);
  bool get hasHovered => contains(WidgetState.hovered);
  bool get hasSelected => contains(WidgetState.selected);
  bool get hasPressed => contains(WidgetState.pressed);
}

extension MaterialStateExt on WidgetState {
  bool get isDisabled => this == WidgetState.disabled;
  bool get isFocused => this == WidgetState.focused;
  bool get isHovered => this == WidgetState.hovered;
  bool get isSelected => this == WidgetState.selected;
  bool get isPressed => this == WidgetState.pressed;
}
