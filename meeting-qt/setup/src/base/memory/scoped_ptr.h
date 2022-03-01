/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Ported by Wang Rongtao <rtwang@corp.netease.com>
// Date: 2013/01/25

#ifndef BASE_MEMORY_SCOPED_PTR_H_
#define BASE_MEMORY_SCOPED_PTR_H_
#pragma once

#include <assert.h>
#include <stddef.h>
#include <stdlib.h>

#include "base/util/move.h"

namespace nbase {

// This class wraps the c library function free() in a class that can be
// passed as a template argument to scoped_ptr_malloc below.
class ScopedPtrMallocFree {
 public:
  inline void operator()(void* x) const {
    free(x);
  }
};

} // namespace nbase
#endif  // BASE_MEMORY_SCOPED_PTR_H_
