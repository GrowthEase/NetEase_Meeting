/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

//
//  lunch_mac.h
//  nem_ipc_module
//
//  Created by 邓佳佳 on 2020/7/22.
//

#ifndef LUNCH_MAC_H
#define LUNCH_MAC_H
#include <string>

bool lunchProcess(const std::string& sdkpath, int& process_id, int port, int old_process_id = 0);

#endif /* LUNCH_MAC_H */
