// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class NEMeetingWatermark {
  /// 水印策略，0.关闭，1.开启，2.强制开启
  late int videoStrategy;

  /// 水印风格，1.单条居中，2.全屏多条。
  late int videoStyle;

  /// 水印文字格式，{name}_{phone}
  late String videoFormat;

  NEMeetingWatermark.fromMap(Map? map) {
    videoStrategy = map?['videoStrategy'] ?? 0;
    videoStyle = map?['videoStyle'] ?? 1;
    videoFormat = map?['videoFormat'] ?? _WatermarkFormatType.name;
  }

  Map<String, dynamic> toMap() {
    return {
      'videoStrategy': videoStrategy,
      'videoStyle': videoStyle,
      'videoFormat': videoFormat,
    };
  }
}

/// 水印文本占位符类型
class _WatermarkFormatType {
  static const String name = '{name}';

  static const String phone = '{phone}';

  static const String email = '{email}';

  static const String jobNumber = '{jobNumber}';
}

extension WatermarkExtension on NEMeetingWatermark {
  bool isSingleRow() => videoStyle == 1;

  bool isForce() => videoStrategy == 2;

  bool isEnable() => videoStrategy == 1 || videoStrategy == 2;

  String replaceFormatText(NEWatermarkConfig? config) {
    String result = videoFormat;
    result = result.replaceAll(_WatermarkFormatType.name, config?.name ?? '');
    result = result.replaceAll(_WatermarkFormatType.phone, config?.phone ?? '');
    result = result.replaceAll(_WatermarkFormatType.email, config?.email ?? '');
    result = result.replaceAll(
        _WatermarkFormatType.jobNumber, config?.jobNumber ?? '');
    return result;
  }
}

class NEWatermarkConfig {
  final String? name;
  final String? phone;
  final String? email;
  final String? jobNumber;

  NEWatermarkConfig({
    this.name,
    this.phone,
    this.email,
    this.jobNumber,
  });

  static NEWatermarkConfig? fromJson(Map<String, dynamic>? map) {
    if (map == null) return null;
    return NEWatermarkConfig(
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      jobNumber: map['jobNumber'],
    );
  }

  @override
  String toString() {
    return 'NEWatermarkConfig{name: $name, phone: $phone, email: $email, jobNumber: $jobNumber}';
  }
}
