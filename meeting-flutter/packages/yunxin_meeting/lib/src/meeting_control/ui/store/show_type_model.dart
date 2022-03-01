// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ShowTypeInfo {
  int? showType;
  bool? clickable;

  ShowTypeInfo({this.showType, this.clickable});
}

class ShowTypeModel extends ShowTypeInfo with ChangeNotifier {
  final ShowTypeInfo _showTypeInfo = ShowTypeInfo(showType: showTypePresenter, clickable: false);

  @override
  int? get showType => _showTypeInfo.showType;

  @override
  bool? get clickable => _showTypeInfo.clickable;

  void changeShowType(int showType) {
    _showTypeInfo.showType = showType;
    notifyListeners();
  }

  void changeClickable(bool clickable) {
    _showTypeInfo.clickable = clickable;
    notifyListeners();
  }

  void reset(int showType, bool clickable, {bool notify = false}) {
    _showTypeInfo.showType = showType;
    _showTypeInfo.clickable = clickable;
    if (notify) {
      notifyListeners();
    }
  }
}
