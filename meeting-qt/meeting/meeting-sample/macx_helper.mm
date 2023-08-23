// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "macx_helper.h"
#import <Foundation/Foundation.h>

std::string MacxHelper::GetBundlePath() {
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString* directoryPath = [bundlePath stringByDeletingLastPathComponent];
    return [directoryPath UTF8String];
}
