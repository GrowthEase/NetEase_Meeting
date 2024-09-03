// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 账号信息设置
/// {
///  "beauty": {
///   "level": 1
///  },
///  "asrTranslationLanguage": 0,
///  "captionBilingual": true,
///  "transcriptionBilingual": true,
/// }
class AccountSettings {
  static const _keyAsrTranslationLanguage = 'asrTranslationLanguage';
  static const _keyCaptionBilingual = 'captionBilingual';
  static const _keyTranscriptionBilingual = 'transcriptionBilingual';

  /// 美颜级别
  final BeautySettings? beauty;

  /// ASR目标翻译语言，默认不翻译
  final String? asrTranslationLanguage;

  /// 字幕显示双语，默认不显示
  final bool? captionBilingual;

  /// 转写显示双语，默认不显示
  final bool? transcriptionBilingual;

  AccountSettings({
    this.beauty,
    this.asrTranslationLanguage,
    this.captionBilingual,
    this.transcriptionBilingual,
  });

  factory AccountSettings.fromMap(Map map) {
    return AccountSettings(
      beauty: BeautySettings.fromMap(map),
      asrTranslationLanguage: map[_keyAsrTranslationLanguage] as String?,
      captionBilingual: map[_keyCaptionBilingual] as bool?,
      transcriptionBilingual: map[_keyTranscriptionBilingual] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (beauty != null) ...beauty!.toMap(),
      if (asrTranslationLanguage != null)
        _keyAsrTranslationLanguage: asrTranslationLanguage,
      if (captionBilingual != null) _keyCaptionBilingual: captionBilingual,
      if (transcriptionBilingual != null)
        _keyTranscriptionBilingual: transcriptionBilingual,
    };
  }

  @override
  int get hashCode => Object.hash(
        beauty,
        asrTranslationLanguage,
        captionBilingual,
        transcriptionBilingual,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountSettings &&
        beauty == other.beauty &&
        asrTranslationLanguage == other.asrTranslationLanguage &&
        captionBilingual == other.captionBilingual &&
        transcriptionBilingual == other.transcriptionBilingual;
  }
}

/// beauty : {'enable':true,'level':1}
class BeautySettings {
  final Beauty beauty;

  BeautySettings({required this.beauty});

  factory BeautySettings.fromMap(Map map) {
    return BeautySettings(
        beauty: Beauty.fromMap(
            (map['beauty'] ?? <String, dynamic>{}) as Map<String, dynamic>));
  }

  Map<String, dynamic> toMap() => {
        'beauty': beauty.toMap(),
      };

  @override
  int get hashCode => beauty.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BeautySettings && beauty == other.beauty;
  }
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

  @override
  int get hashCode => level.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Beauty && level == other.level;
  }
}
