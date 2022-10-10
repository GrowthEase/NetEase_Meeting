// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/proto/base_proto.dart';
import 'package:nemeeting/service/response/result.dart';

/// base service
class BaseService {
  /// execute method
  Future<Result<T>> execute<T>(BaseProto proto) {
    return proto.execute().then((result) {
      if (proto.checkLoginState() &&
          (result.code == HttpCode.verifyError ||
              result.code == HttpCode.tokenError)) {
        AuthManager().tokenIllegal(HttpCode.getMsg(result.msg, 'Token失效'));
      }
      // return Result(code: result.code, msg: result.msg, data: result.data as T);
      return result as Result<T>;
    });
  }
}
