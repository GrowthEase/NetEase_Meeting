// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class AccountSettings {
  BeautySettings? beauty;

  AccountSettings({required this.beauty});

  factory AccountSettings.fromMap(Map<String, dynamic> map) {
    return AccountSettings(
        beauty:
            BeautySettings.fromMap(map['settings'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toMap() {
    return {
      'settings': {
        if (beauty != null) beauty!.toMap(),
      }
    };
  }
}

/// beauty : {'enable':true,'level':1}

class BeautySettings {
  final Beauty beauty;

  BeautySettings({required this.beauty});

  factory BeautySettings.fromMap(Map<String, dynamic> map) {
    return BeautySettings(
        beauty: Beauty.fromMap(
            (map['beauty'] ?? <String, dynamic>{}) as Map<String, dynamic>));
  }

  Map<String, dynamic> toMap() => {
        'beauty': beauty.toMap(),
      };
}

/// enable : true
/// level : 1

class Beauty {
  final int level;

  Beauty({required this.level});

  factory Beauty.fromMap(Map<String, dynamic> map) {
    return Beauty(level: (map['level'] ?? 0) as int);
  }

  Map<String, dynamic> toMap() => {
        'level': level,
      };
}
