/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// This file defines error and exception

#ifndef NIPCLIB_BASE_NEXEPTION_ERROR_H_
#define NIPCLIB_BASE_NEXEPTION_ERROR_H_

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include <string>
#include <stdexcept>

#define          NBASE(n)          5000+n

NIPCLIB_BEGIN_DECLS

typedef uint32_t RESULT;

/* define error code */
const RESULT     kResultSuccess           = 0;
const RESULT     kResultFailed            = 1;      
const RESULT     kResultInvalidHandle     = NBASE(2);
const RESULT     kResultObjectNull        = NBASE(3);
const RESULT     kResultIOError           = NBASE(4);
const RESULT     kResultMemoryError       = NBASE(5);
const RESULT     kResultTimeout           = NBASE(6);


class NIPCLIB_EXPORT NException : public std::runtime_error
{
public:
    NException(const std::string &e) : std::runtime_error(e), error_code_(kResultFailed) {}
    NException(const char *s, uint32_t error_code = kResultFailed) 
		: std::runtime_error(s), error_code_(error_code) 
	{}
    NException() 
		: std::runtime_error((const char *)"Unknown error"), error_code_(kResultFailed)
	{}
    virtual ~NException() throw() {}
    uint32_t error_code() const{ return error_code_; }
private:
	uint32_t error_code_;
};

NIPCLIB_END_DECLS

#endif  // NIPCLIB_BASE_NEXEPTION_ERROR_H_
