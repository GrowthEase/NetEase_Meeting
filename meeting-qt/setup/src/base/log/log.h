/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/12
//
// Modified by Wang Rongtao <rtwang@corp.netease.com>
// Date: 2013/9/5
//
// Log interface

#ifndef BASE_LOG_LOG_H_
#define BASE_LOG_LOG_H_

#include "base/base_types.h"
#include "base/base_export.h"
#include "base/file/file_path.h"

namespace nbase
{

class BASE_EXPORT LogInterface
{
public:
	// Flag: Determine the log header style
	enum Flag
	{
		LOG_DATE=0x01,              // "MM-DD-YYYY"
		LOG_TIME=0x02,              // "hh:mm:ss"
		LOG_TIMESTAMP=0x04,         // "MM-DD-YYYY hh:mm:ss:MsMsMs"
		LOG_FILE=0x08,              // source file
		LOG_LINE=0X10,              // line number
		LOG_SYS_CODE=0x20,          // system error code
		LOG_SYS_MSG=0x40,           // system error info
		LOG_OTYPE_DESCRIPTOR=0x100, // the output type, decide by you self
		LOG_FTYPE_ONLYONE=0x200,    // only one output file
		LOG_ONLY_LEVEL=0x400,       // only output the level_ level log
		LOG_OUT_DEBUGINFO=0x800,    // output debug info to the debugger [Win]
	};
	// some log level define
	enum Level
	{
#ifndef LOG_LEVEL
#define LOG_LEVEL(m,v) m=v,
#include "base/log/log_level.h"
#undef LOG_LEVEL
#endif
	};

public:
	virtual const char * Version() const = 0;
	virtual void         SetFlag(Flag flag) = 0;
	virtual void         RemoveFlag(Flag flag) = 0;
	virtual void         SetLevel(uint32_t level) = 0;
	virtual uint32_t     GetLevel() const = 0;
	virtual void         SetSuffix(const PathChar *suffix) = 0;
	virtual const PathChar* GetOutPath() const = 0;
	virtual void         SetOutPath(const PathChar *path) = 0;
	virtual void         SetOutDesc(int fd) = 0;
	virtual int          GetOutDesc() const = 0;

	virtual void         Log(uint32_t level, const char *file, uint32_t line, const char *format,...) = 0;
	virtual void         VLog(uint32_t level, const char *file, uint32_t line, const char *format, va_list args) = 0;
	virtual void         VLog(uint32_t level, const char *file, uint32_t line, const wchar_t* format, va_list args) = 0;
};

BASE_EXPORT nbase::LogInterface * Log_Creater();

BASE_EXPORT void DefLogSetLevel(int level);
BASE_EXPORT void DefLogSetFlag(nbase::LogInterface::Flag flag);
BASE_EXPORT void DefLogRemoveFlag(nbase::LogInterface::Flag flag);
BASE_EXPORT void DefLogSetSuffix(const PathChar *suffix);
BASE_EXPORT void DefLogSetOutPath(const PathChar *path);
BASE_EXPORT void DefLogSetOutDesc(int desc);
BASE_EXPORT void DefLog(uint32_t level, const char *file, uint32_t line, const char *format,...);
BASE_EXPORT void DefHalfLog(const PathChar *path, ULONGLONG limit_max, ULONGLONG limit_to);

#define DEFLOGALLOW(lv)  (lv <= nbase::Log_Creater()->GetLevel())
#define DEFLOG           DefLog

#include "base/log/log_helper.h"

}  // namespace nbase

#endif  // BASE_LOG_LOG_H_