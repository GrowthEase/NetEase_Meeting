// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

//
//import 'package:flutter/cupertino.dart';
//import 'package:nemeeting/global.dart';
//import 'package:nemeeting/model/account.dart';
//
//class AccountChangeNotifier extends ChangeNotifier{
//  AccountInfo get _accountInfo => Global.accountInfo;
//  set accountInfo(AccountInfo accountInfo) {
//    _accountInfo = accountInfo;
//  }
//  @override
//  void notifyListeners() {
//    Global.saveProfile();
//    super.notifyListeners();
//  }
//}
//
//class AccountInfoModel extends AccountChangeNotifier{
//
//  AccountInfo get accountInfo => _accountInfo;
//  bool get isLogin => _accountInfo.userId != null && _accountInfo.userId.length > 0;
//
//  set accountInfo(AccountInfo accountInfo){
//
//    _accountInfo = accountInfo;
//    notifyListeners();
//  }
//
//}