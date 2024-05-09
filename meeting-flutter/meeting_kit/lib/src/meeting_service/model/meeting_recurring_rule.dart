// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 预约会议重复规则类型
enum NEMeetingRecurringRuleType {
  /// 未定义
  undefine,

  /// 不重复
  no,

  /// 每天
  day,

  /// 每工作日
  weekday,

  /// 每周
  week,

  /// 每两周
  twoWeeks,

  /// 每月的今天
  dayOfMonth,

  /// 自定义
  custom,
}

/// 自定义频率单位
enum NEMeetingFrequencyUnitType {
  /// 未定义
  undefine,

  /// 天
  day,

  /// 周
  weekday,

  /// 按月指定日期
  dayOfMonth,

  /// 按月固定星期
  weekdayOfMonth,
}

/// 周期性会议结束规则类型
enum NEMeetingRecurringEndRuleType {
  /// 未定义
  undefine,

  /// 指定日期
  date,

  /// 指定次数
  times,
}

/// 周期性会议重复星期
enum NEMeetingRecurringWeekday {
  /// 未定义
  undefine,

  /// 星期日
  sunday,

  /// 星期一
  monday,

  /// 星期二
  tuesday,

  /// 星期三
  wednesday,

  /// 星期四
  thursday,

  /// 星期五
  friday,

  /// 星期六
  saturday,
}

/// 周期性会议规则
class NEMeetingRecurringRule {
  DateTime? _startTime;

  /// 下一场的开始时间，用于内部联动计算[NEMeetingRecurringEndRule.times]跟[NEMeetingRecurringEndRule.date]
  DateTime? get startTime => _startTime;

  /// 当开始时间变化的时候也要刷新规则
  set startTime(DateTime? value) {
    _startTime = value;
    if (value == null) {
      return;
    }
    if (_type == NEMeetingRecurringRuleType.custom) {
      customizedFrequency?.updateStartTime();
    }
    if (endRule?.type == NEMeetingRecurringEndRuleType.times) {
      endRule?.times = endRule!.times;
    } else {
      endRule?.date = endRule?.date;
    }
  }

  NEMeetingRecurringRuleType _type = NEMeetingRecurringRuleType.no;

  /// 重复类型
  NEMeetingRecurringRuleType get type => _type;

  /// 周期性会议结束规则是否锁定，如果锁定则根据[NEMeetingRecurringEndRuleType]来计算，如果未锁定则使用默认7次
  bool isEndTypeLocked = false;

  set type(NEMeetingRecurringRuleType value) {
    _type = value;
    if (value == NEMeetingRecurringRuleType.custom &&
        customizedFrequency == null) {
      /// 默认每天
      customizedFrequency = NEMeetingCustomizedFrequency(
        stepSize: 1,
        stepUnit: NEMeetingFrequencyUnitType.day,
        recurringRule: WeakReference(this),
      );
    }
    if (value != NEMeetingRecurringRuleType.no && endRule == null) {
      /// 默认结束时间是从今天开始7天后
      endRule = NEMeetingRecurringEndRule(
        recurringRule: WeakReference(this),
        type: NEMeetingRecurringEndRuleType.date,
        times: 7,
      );
    }
    if (!isEndTypeLocked) {
      /// 如果未锁定则使用默认7次
      endRule?.times = 7;
    } else {
      if (endRule?.type == NEMeetingRecurringEndRuleType.times) {
        endRule?.times = endRule!.times;
      } else {
        endRule?.date = endRule?.date;
      }
    }
  }

  /// 自定义频率
  /// 当[type]为[NEMeetingRecurringRuleType.custom]时有效
  NEMeetingCustomizedFrequency? customizedFrequency;

  /// 周期结束配置
  NEMeetingRecurringEndRule? endRule;

  get maxRepeatTimes {
    switch (type) {
      /// 每天、每个工作日、每周、自定义，最大支持200场子会议
      case NEMeetingRecurringRuleType.day:
      case NEMeetingRecurringRuleType.weekday:
      case NEMeetingRecurringRuleType.week:
        return 200;
      case NEMeetingRecurringRuleType.custom:
        if (customizedFrequency?.stepUnit ==
                NEMeetingFrequencyUnitType.weekdayOfMonth ||
            customizedFrequency?.stepUnit ==
                NEMeetingFrequencyUnitType.dayOfMonth) {
          return 50;
        } else {
          return 200;
        }

      /// 每两周、每月，最大支持50场子会议
      case NEMeetingRecurringRuleType.twoWeeks:
      case NEMeetingRecurringRuleType.dayOfMonth:
        return 50;
      default:
        return 7;
    }
  }

  NEMeetingRecurringRule({
    required NEMeetingRecurringRuleType type,
    this.customizedFrequency,
    this.endRule,
    startTime,
  }) {
    this.type = type;
    this.startTime = startTime;
  }

  toJson() {
    return {
      'type': type.index,
      'customizedFrequency': customizedFrequency?.toJson(),
      'endRule': endRule?.toJson(),
    };
  }

  static fromJson(Map<dynamic, dynamic>? map, {DateTime? startTime}) {
    if (map != null) {
      return NEMeetingRecurringRule(
        type: NEMeetingRecurringRuleType.values[map['type']],
        customizedFrequency: map['customizedFrequency'] != null
            ? NEMeetingCustomizedFrequency.fromJson(map['customizedFrequency'])
            : null,
        endRule: map['endRule'] != null
            ? NEMeetingRecurringEndRule.fromJson(map['endRule'])
            : null,
        startTime: startTime,
      );
    } else {
      return NEMeetingRecurringRule(
          type: NEMeetingRecurringRuleType.no, startTime: startTime);
    }
  }

  // 深拷贝
  NEMeetingRecurringRule copy() {
    return NEMeetingRecurringRule(
      type: type,
      customizedFrequency: customizedFrequency,
      endRule: endRule,
      startTime: startTime,
    );
  }
}

/// 周期性会议自定义规则
class NEMeetingCustomizedFrequency {
  /// 引用结束规则的周期性会议规则，当修改结束规则的时候需要知道周期性会议的重复类型
  /// 如果是从native创建，则不维护这个逻辑，需要native自己管理[NEMeetingRecurringEndRule.times]/[NEMeetingRecurringEndRule.date]与[recurringRule]之间的关系
  WeakReference<NEMeetingRecurringRule>? recurringRule;

  int _stepSize = 1;

  /// 步长, 每隔多少个单位重复一次
  int get stepSize => _stepSize;

  set stepSize(int value) {
    _stepSize = value;
    updateTarget();
  }

  NEMeetingFrequencyUnitType _stepUnit = NEMeetingFrequencyUnitType.day;

  /// 单位
  NEMeetingFrequencyUnitType get stepUnit => _stepUnit;

  set stepUnit(NEMeetingFrequencyUnitType value) {
    _stepUnit = value;
    updateTarget();
  }

  /// 每周几
  /// 当[stepUnit]为[NEMeetingFrequencyUnit.week]时有效
  List<NEMeetingRecurringWeekday>? daysOfWeek;

  /// 每个月的多少号
  /// 当[stepUnit]为[NEMeetingFrequencyUnit.dayOfMonth]时有效
  List<int>? daysOfMonth;

  NEMeetingCustomizedFrequency({
    required int stepSize,
    required NEMeetingFrequencyUnitType stepUnit,
    this.recurringRule,
    this.daysOfWeek,
    this.daysOfMonth,
  }) {
    this.stepSize = stepSize;
    this.stepUnit = stepUnit;
  }

  updateTarget() {
    if (recurringRule?.target?.type == NEMeetingRecurringRuleType.custom) {
      if (recurringRule?.target?.isEndTypeLocked == true) {
        if (recurringRule?.target?.endRule?.type ==
            NEMeetingRecurringEndRuleType.times) {
          if (recurringRule?.target?.endRule!.times != null) {
            recurringRule?.target?.endRule?.times =
                recurringRule!.target!.endRule!.times;
          }
        } else {
          recurringRule?.target?.endRule?.date =
              recurringRule?.target?.endRule?.date;
        }
      } else {
        recurringRule?.target?.endRule?.times = 7;
      }
    }
  }

  updateStartTime() {
    var time = recurringRule?.target?.startTime;
    if (time == null) {
      return;
    }
    if (_stepUnit == NEMeetingFrequencyUnitType.dayOfMonth) {
      if (daysOfMonth != null) {
        if (!daysOfMonth!.contains(time.day)) {
          if (daysOfMonth!.length == 1) {
            daysOfMonth!.clear();
          }
          daysOfMonth!.add(time.day);
        }
      }
    } else if (_stepUnit == NEMeetingFrequencyUnitType.weekday) {
      if (daysOfWeek != null) {
        final weekday = time.weekday;
        if (weekday == DateTime.sunday) {
          if (!daysOfWeek!.contains(NEMeetingRecurringWeekday.sunday)) {
            if (daysOfWeek!.length == 1) {
              daysOfWeek!.clear();
            }
            daysOfWeek!.add(NEMeetingRecurringWeekday.sunday);
          }
        } else {
          if (!daysOfWeek!
              .contains(NEMeetingRecurringWeekday.values[time.weekday + 1])) {
            if (daysOfWeek!.length == 1) {
              daysOfWeek!.clear();
            }
            daysOfWeek!.add(NEMeetingRecurringWeekday.values[time.weekday + 1]);
          }
        }
      }
    }
  }

  toJson() {
    return {
      'stepSize': stepSize,
      'stepUnit': stepUnit.index,
      'daysOfWeek': daysOfWeek?.map((e) => e.index).toList(),
      'daysOfMonth': daysOfMonth,
    };
  }

  static fromJson(Map<dynamic, dynamic>? map) {
    if (map != null) {
      return NEMeetingCustomizedFrequency(
        stepSize: map['stepSize'],
        stepUnit: NEMeetingFrequencyUnitType.values[map['stepUnit']],
        daysOfWeek: (map['daysOfWeek'] as List?)
            ?.map((e) => NEMeetingRecurringWeekday.values[e])
            .toList(),
        daysOfMonth: map['daysOfMonth']?.cast<int>(),
      );
    } else {
      return NEMeetingCustomizedFrequency(
        stepSize: 1,
        stepUnit: NEMeetingFrequencyUnitType.day,
      );
    }
  }
}

/// 周期性会议结束规则
class NEMeetingRecurringEndRule {
  /// 引用结束规则的周期性会议规则，当修改结束规则的时候需要知道周期性会议的重复类型
  /// 如果是从native创建，则不维护这个逻辑，需要native自己管理[times]/[date]与[recurringRule]之间的关系
  WeakReference<NEMeetingRecurringRule>? recurringRule;

  /// 结束类型
  NEMeetingRecurringEndRuleType type;

  int _times = 1;

  /// 剩余次数
  /// 当[type]为[NEMeetingRecurringEndRuleType.times]时有效
  int get times => _times;

  set times(int value) {
    if (recurringRule?.target?.type == NEMeetingRecurringRuleType.no) {
      return;
    }
    if (recurringRule?.target?.maxRepeatTimes != null &&
        value > recurringRule?.target?.maxRepeatTimes) {
      _times = recurringRule?.target?.maxRepeatTimes ?? 1;
    } else {
      _times = value;
    }
    if (recurringRule?.target != null) {
      /// 下一场会议的开始时间，用于内部联动计算times跟date
      var startTime = recurringRule?.target?.startTime;
      if (startTime == null) startTime = DateTime.now();
      final endTime = calculateEndDate(startTime, _times);
      if (endTime != null) {
        _date = DateFormat('yyyy/MM/dd').format(endTime);
      }
    }
  }

  DateTime _addMonths(DateTime dt, int months) {
    int year = dt.year;
    int month = dt.month + months;
    while (month > 12) {
      year++;
      month -= 12;
    }
    while (month < 1) {
      year--;
      month += 12;
    }
    return DateTime(year, month, dt.day, dt.hour, dt.minute, dt.second,
        dt.millisecond, dt.microsecond);
  }

  DateTime? calculateEndDate(DateTime startTime, int times) {
    DateTime? endTime;
    switch (recurringRule!.target!.type) {
      case NEMeetingRecurringRuleType.day:
        endTime = startTime.add(Duration(days: times - 1));
        break;
      case NEMeetingRecurringRuleType.weekday:
        var skip = 0;
        var i = times;
        while (i > 0) {
          var next = startTime.add(Duration(days: skip));
          if (next.weekday != DateTime.saturday &&
              next.weekday != DateTime.sunday) {
            i--;
          }
          if (i > 0) {
            skip++;
          }
        }
        endTime = startTime.add(Duration(days: skip));
        break;
      case NEMeetingRecurringRuleType.week:
        endTime = startTime.add(Duration(days: (times - 1) * 7));
        break;
      case NEMeetingRecurringRuleType.twoWeeks:
        endTime = startTime.add(Duration(days: (times - 1) * 14));
        break;
      case NEMeetingRecurringRuleType.dayOfMonth:
        endTime = _addMonths(startTime, (times - 1));
        break;
      case NEMeetingRecurringRuleType.custom:
        endTime = _calculateCustomEndDate(startTime, (times - 1));
        break;
      case NEMeetingRecurringRuleType.no:
      case NEMeetingRecurringRuleType.undefine:
        break;
    }
    if (endTime != null) {
      endTime = DateTime(endTime.year, endTime.month, endTime.day, 23, 59, 59);
    }
    return endTime;
  }

  /// 根据开始时间与次数计算结束时间
  DateTime _calculateCustomEndDate(DateTime startTime, int times) {
    final customizedFrequency = recurringRule?.target?.customizedFrequency;
    if (customizedFrequency == null) {
      return DateTime.now();
    }
    switch (customizedFrequency.stepUnit) {
      case NEMeetingFrequencyUnitType.day:
        return startTime
            .add(Duration(days: times * customizedFrequency.stepSize));
      case NEMeetingFrequencyUnitType.weekday:

        /// 还能进行完整几周
        final weeks = times ~/ customizedFrequency.daysOfWeek!.length;

        /// 不完整的周
        var left = times % customizedFrequency.daysOfWeek!.length;
        var endDate = startTime
            .add(Duration(days: weeks * 7 * (customizedFrequency.stepSize)));
        while (left > 0) {
          endDate = endDate.add(Duration(days: 1));
          final weekday;
          if (endDate.weekday == DateTime.sunday) {
            weekday = NEMeetingRecurringWeekday.sunday;
          } else {
            weekday = NEMeetingRecurringWeekday.values[endDate.weekday + 1];
          }
          if (customizedFrequency.daysOfWeek!.contains(weekday)) {
            left--;
          }
        }
        return endDate;
      case NEMeetingFrequencyUnitType.dayOfMonth:

        /// 还能进行完整几个月
        final months = times ~/ customizedFrequency.daysOfMonth!.length;

        /// 不完整的月
        var left = times % customizedFrequency.daysOfMonth!.length;

        var endDate =
            _addMonths(startTime, months * (customizedFrequency.stepSize));
        while (left > 0) {
          endDate = endDate.add(Duration(days: 1));
          if (customizedFrequency.daysOfMonth!.contains(endDate.day)) {
            left--;
          }
        }
        return endDate;
      case NEMeetingFrequencyUnitType.weekdayOfMonth:
        final endDate =
            _addMonths(startTime, times * (customizedFrequency.stepSize));
        var firstDayOfMonth = DateTime(startTime.year, startTime.month, 1);
        var dayOfWeek = firstDayOfMonth.weekday;
        var currentWeekDay = startTime.weekday;
        var day = startTime.day;
        final currentWeekOfMonth;
        if (dayOfWeek <= currentWeekDay) {
          currentWeekOfMonth = (day + dayOfWeek - 2) ~/ 7 + 1;
        } else {
          currentWeekOfMonth = (day + dayOfWeek - 2) ~/ 7;
        }
        final endMonth = DateTime(endDate.year, endDate.month, 1);
        final firstDayWeekDayEnd = endMonth.weekday;

        /// 找到endMonth里对应的第currentWeekOfMonth周的weekday
        var endDay = 0;
        if (firstDayWeekDayEnd <= currentWeekDay) {
          endDay = (currentWeekOfMonth - 1) * 7 +
              currentWeekDay -
              firstDayWeekDayEnd +
              1;
        } else {
          endDay = (currentWeekOfMonth - 1) * 7 +
              7 -
              firstDayWeekDayEnd +
              currentWeekDay +
              1;
        }
        return DateTime(endDate.year, endDate.month, endDay);
      case NEMeetingFrequencyUnitType.undefine:
        return DateTime.now();
    }
  }

  /// 根据开始时间与结束时间计算次数
  int _calculateCustomEndTime(DateTime startTime, DateTime endTime) {
    final customizedFrequency = recurringRule?.target?.customizedFrequency;
    if (customizedFrequency == null) {
      return 0;
    }
    switch (customizedFrequency.stepUnit) {
      case NEMeetingFrequencyUnitType.day:

        /// 每stepSize天一次，startTime与endTime之间的次数
        return 1 +
            endTime.difference(startTime).inDays ~/
                customizedFrequency.stepSize;
      case NEMeetingFrequencyUnitType.weekday:

        /// 每stepSize周daysOfWeek次，可以包含周末，startTime与endTime之间的次数
        final weeks = endTime.difference(startTime).inDays ~/ 7;
        var times = customizedFrequency.daysOfWeek!.length *
            (weeks ~/ customizedFrequency.stepSize);
        var left = endTime.difference(startTime).inDays % 7;
        while (left > 0) {
          final weekday;
          if (endTime.weekday == DateTime.sunday) {
            weekday = NEMeetingRecurringWeekday.sunday;
          } else {
            weekday = NEMeetingRecurringWeekday.values[endTime.weekday + 1];
          }
          if (customizedFrequency.daysOfWeek!.contains(weekday)) {
            times++;
          }
          left--;
          endTime = endTime.subtract(Duration(days: 1));
        }
        return times + 1;
      case NEMeetingFrequencyUnitType.dayOfMonth:

        /// 每stepSize个月daysOfMonth次，startTime与endTime之间的次数
        var times = 0;
        if (endTime.day >= startTime.day) {
          /// 计算endTime与startTime之间的完整月份

          final months = (endTime.year - startTime.year) * 12 +
              endTime.month -
              startTime.month;
          times = customizedFrequency.daysOfMonth!.length *
              (months ~/ customizedFrequency.stepSize);
          var left = endTime.day - startTime.day;
          while (left > 0) {
            if (customizedFrequency.daysOfMonth!
                .contains(endTime.day - left + 1)) {
              times++;
            }
            left--;
          }
        } else {
          var months = (endTime.year - startTime.year) * 12 +
              endTime.month -
              startTime.month -
              1;
          if (months < 0) {
            months = 0;
          }
          times = customizedFrequency.daysOfMonth!.length *
              (months ~/ customizedFrequency.stepSize);
          var left = endTime.difference(_addMonths(startTime, months)).inDays;
          while (left > 0) {
            final day = startTime.add(Duration(days: left));
            if (customizedFrequency.daysOfMonth!.contains(day.day)) {
              times++;
            }
            left--;
          }
        }
        return 1 + times;
      case NEMeetingFrequencyUnitType.weekdayOfMonth:

        /// 开始时间位于当月的第几个周几
        var startFirstDayOfMonth = DateTime(startTime.year, startTime.month, 1);
        var startDayOfWeek = startFirstDayOfMonth.weekday;
        var startCurrentWeekDay = startTime.weekday;
        var startDay = startTime.day;
        final startCurrentWeekOfMonth;
        if (startDayOfWeek <= startCurrentWeekDay) {
          startCurrentWeekOfMonth = (startDay + startDayOfWeek - 2) ~/ 7 + 1;
        } else {
          startCurrentWeekOfMonth = (startDay + startDayOfWeek - 2) ~/ 7;
        }

        /// 结束时间位于当月的第几个周几
        var endFirstDayOfMonth = DateTime(endTime.year, endTime.month, 1);
        var endDayOfWeek = endFirstDayOfMonth.weekday;
        var endCurrentWeekDay = endTime.weekday;
        var endDay = endTime.day;
        final endCurrentWeekOfMonth;
        if (endDayOfWeek <= endCurrentWeekDay) {
          endCurrentWeekOfMonth = (endDay + endDayOfWeek - 2) ~/ 7 + 1;
        } else {
          endCurrentWeekOfMonth = (endDay + endDayOfWeek - 2) ~/ 7;
        }

        if (endCurrentWeekOfMonth >= startCurrentWeekOfMonth) {
          /// 结束时间的周次数比开始时间大
          if (endCurrentWeekDay >= startCurrentWeekDay) {
            /// 结束时间的周几比开始时间大
            return ((endTime.year - startTime.year) * 12 +
                        endTime.month -
                        startTime.month) ~/
                    customizedFrequency.stepSize +
                1;
          } else {
            /// 结束时间的周几比开始时间小
            return ((endTime.year - startTime.year) * 12 +
                    endTime.month -
                    startTime.month) ~/
                customizedFrequency.stepSize;
          }
        } else {
          /// 结束时间的周次数比开始时间小
          return ((endTime.year - startTime.year) * 12 +
                  endTime.month -
                  startTime.month) ~/
              customizedFrequency.stepSize;
        }
      case NEMeetingFrequencyUnitType.undefine:
        return 0;
    }
  }

  String? _date;

  /// 结束日期，格式：YYYY/MM/dd，如：2024/3/2
  /// 当[type]为[NEMeetingRecurringEndRuleType.date]时有效
  String? get date => _date;

  set date(String? value) {
    if (recurringRule?.target?.type == NEMeetingRecurringRuleType.no) {
      return;
    }
    _date = value;

    /// 根据最大次数判断是否超出最远时间，联动修改times
    if (recurringRule?.target != null && value != null) {
      var startTime = recurringRule?.target?.startTime;
      if (startTime == null) startTime = DateTime.now();
      var endTime = DateFormat('yyyy/MM/dd').parse(value);
      endTime = DateTime(endTime.year, endTime.month, endTime.day, 23, 59, 59);
      final times;
      switch (recurringRule!.target!.type) {
        case NEMeetingRecurringRuleType.day:
          times = endTime.difference(startTime).inDays + 1;
          break;
        case NEMeetingRecurringRuleType.weekday:

          /// startTime与endTime之间的工作日
          var skip = 0;
          var next = startTime;
          while (next.isBefore(endTime)) {
            if (next.weekday != DateTime.saturday &&
                next.weekday != DateTime.sunday) {
              skip++;
            }
            next = next.add(Duration(days: 1));
          }
          times = skip;
          break;
        case NEMeetingRecurringRuleType.week:

          /// 每周一次，startTime与endTime之间的次数
          times = 1 + endTime.difference(startTime).inDays ~/ 7;
          break;
        case NEMeetingRecurringRuleType.twoWeeks:

          /// 每两周一次，startTime与endTime之间的次数
          times = 1 + endTime.difference(startTime).inDays ~/ 14;
          break;
        case NEMeetingRecurringRuleType.dayOfMonth:

          /// 每月一次，startTime与endTime之间的次数
          if (endTime.day < startTime.day) {
            times = (endTime.year - startTime.year) * 12 +
                endTime.month -
                startTime.month;
          } else {
            times = 1 +
                (endTime.year - startTime.year) * 12 +
                endTime.month -
                startTime.month;
          }
          break;
        case NEMeetingRecurringRuleType.custom:
          times = _calculateCustomEndTime(startTime, endTime);
          break;
        case NEMeetingRecurringRuleType.no:
        case NEMeetingRecurringRuleType.undefine:
          times = 0;
          break;
      }
      if (times > recurringRule!.target!.maxRepeatTimes) {
        /// 如果通过设置的时间超过了最大时间，则使用默认次数7
        _times = 7;
        _date = _date = DateFormat('yyyy/MM/dd')
            .format(calculateEndDate(startTime, 7) ?? startTime);
      } else {
        _times = times;
      }
    }
  }

  NEMeetingRecurringEndRule({
    this.recurringRule,
    required this.type,
    required int times,
    String? date,
  }) {
    this.times = times;
    this.date = date;
  }

  toJson() {
    return {
      'type': type.index,
      'times': times,
      'date': date,
    };
  }

  static fromJson(Map<dynamic, dynamic>? map) {
    if (map != null) {
      return NEMeetingRecurringEndRule(
        type: NEMeetingRecurringEndRuleType.values[map['type']],
        times: map['times'],
        date: map['date'],
      );
    } else {
      return NEMeetingRecurringEndRule(
        type: NEMeetingRecurringEndRuleType.times,
        times: 1,
      );
    }
  }
}
