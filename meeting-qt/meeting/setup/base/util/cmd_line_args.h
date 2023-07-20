// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/*
 *
 *	Author		Wang Rongtao <rtwang@corp.netease.com>
 *	Date		2010-09-01
 *	Copyright	Hangzhou, Netease Inc.
 *	Brief		a Windows command line parser
 *
 */

#ifndef BASE_UTIL_CMD_LINE_ARGS_H_
#define BASE_UTIL_CMD_LINE_ARGS_H_

#include <ctype.h>
#include <vector>
#include "base/base_export.h"

namespace nbase {

class BASE_EXPORT CmdLineArgs : public std::vector<wchar_t*> {
public:
    CmdLineArgs(const wchar_t* command_line = 0);
    virtual ~CmdLineArgs();

private:
    bool ParseCommandLine();

    wchar_t* buffer_;
};

}  // namespace nbase

#endif  // BASE_UTIL_CMD_LINE_ARGS_H_
