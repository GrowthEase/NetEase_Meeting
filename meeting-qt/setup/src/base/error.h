// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/8
//
// This file defines error and exception

#ifndef BASE_ERROR_H_
#define BASE_ERROR_H_

#include <stdexcept>
#include <string>
#include "base_types.h"

#define NBASE(n) 5000 + n

namespace nbase {
typedef uint32_t RESULT;

/* define error code */
const RESULT kResultSuccess = 0;
const RESULT kResultFailed = 1;
const RESULT kResultInvalidHandle = NBASE(2);
const RESULT kResultObjectNull = NBASE(3);
const RESULT kResultIOError = NBASE(4);
const RESULT kResultMemoryError = NBASE(5);
const RESULT kResultTimeout = NBASE(6);

class BASE_EXPORT NException : public std::runtime_error {
public:
    NException(const std::string& e)
        : std::runtime_error(e)
        , error_code_(nbase::kResultFailed) {}
    NException(const char* s, uint32_t error_code = nbase::kResultFailed)
        : std::runtime_error(s)
        , error_code_(error_code) {}
    NException()
        : std::runtime_error((const char*)"Unknown error")
        , error_code_(nbase::kResultFailed) {}
    virtual ~NException() throw() {}
    uint32_t error_code() const { return error_code_; }

private:
    uint32_t error_code_;
};

}  // namespace nbase

#endif  // BASE_ERROR_H_
