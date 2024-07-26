// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class NEEncryptionConfig {
  /// 加密类型
  final NEEncryptionMode encryptionMode;

  /// 加密秘钥
  final String encryptKey;

  NEEncryptionConfig({
    required this.encryptionMode,
    required this.encryptKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'encryptionMode': encryptionMode.index,
      'encryptKey': encryptKey,
    };
  }

  static NEEncryptionConfig? fromJson(Map<String, dynamic>? map) {
    if (map == null) return null;
    return NEEncryptionConfig(
      encryptionMode: NEEncryptionMode.values[map['encryptionMode']],
      encryptKey: map['encryptKey'] ?? '',
    );
  }

  @override
  String toString() {
    return 'NEEncryptionConfig{encryptionMode: $encryptionMode, encryptKey: $encryptKey}';
  }
}
