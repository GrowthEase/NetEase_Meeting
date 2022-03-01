// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

class KeyboardUtils{

  static dismissKeyboard(BuildContext context){
    FocusScope.of(context).requestFocus(FocusNode());
  }

}