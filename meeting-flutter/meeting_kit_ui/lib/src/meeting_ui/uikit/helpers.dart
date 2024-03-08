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

extension MaterialStateSetExt on Set<MaterialState> {
  bool get hasDisabled => contains(MaterialState.disabled);
  bool get hasFocused => contains(MaterialState.focused);
  bool get hasHovered => contains(MaterialState.hovered);
  bool get hasSelected => contains(MaterialState.selected);
  bool get hasPressed => contains(MaterialState.pressed);
}

extension MaterialStateExt on MaterialState {
  bool get isDisabled => this == MaterialState.disabled;
  bool get isFocused => this == MaterialState.focused;
  bool get isHovered => this == MaterialState.hovered;
  bool get isSelected => this == MaterialState.selected;
  bool get isPressed => this == MaterialState.pressed;
}
