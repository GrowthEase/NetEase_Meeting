// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:uuid/uuid.dart';

/// uuid generate
class UUID {
  static final Uuid uuid = Uuid();

  String genUUID() {
    return uuid.v4();
  }
}
