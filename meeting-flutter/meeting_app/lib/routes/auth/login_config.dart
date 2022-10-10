// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class LoginConfig {
  static String getServerConfig() {
    return serverIsOnline() ? '{\"online\":1}' : '{\"online\":0}';
  }

  static bool serverIsOnline() {
    // if (ServersConfig().baseUrl.contains("test")) return false;
    return true;
  }

  static String getAndroidConfig() {
    return '{\"product\":\"ne_meeting\",     \"accessId\":\"25c85e48901002c860eb71d4f4d156f7\"}';
  }

  static String getiosConfig() {
    return '{\"product\": \"ne_meeting\", 	'
        '\"accessId\": \"25c85e48901002c860eb71d4f4d156f7\"}';
  }
}
