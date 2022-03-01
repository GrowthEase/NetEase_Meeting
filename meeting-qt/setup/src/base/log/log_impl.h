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
// Log implementation

#ifndef BASE_LOG_LOG_IMPL_H_
#define BASE_LOG_LOG_IMPL_H_

#include "base/log/log.h"
#include "base/synchronization/lock.h"
#include <string>

namespace nbase
{
class Log_Impl : public nbase::LogInterface
{
public:
	Log_Impl();
	Log_Impl(int fd);
	Log_Impl(const PathChar *path);
	virtual ~Log_Impl() {}

	static Log_Impl* GetInstance();

	const char * Version() const
	{
		return (const char *)"NLOGv1.0";
	}

	void SetFlag(Flag flag)
	{
		if (flag & LOG_OTYPE_DESCRIPTOR)
			return;
		flags_ |= flag;
	}

	void RemoveFlag(Flag flag)
	{
		if (flag & LOG_OTYPE_DESCRIPTOR)
			return;
		flags_ &= flag ^ 0xffffffff;
	}

	inline void SetLevel(uint32_t level)
	{
		level_ = level;
	}

	inline uint32_t GetLevel() const
	{
		return level_;
	}

	inline void SetSuffix(const PathChar *suffix)
	{
		if (suffix)
			suffix_ = suffix;
	}

	inline const PathChar* GetOutPath() const
	{
		if (flags_ & LOG_OTYPE_DESCRIPTOR)
			return 0;
		return out_path_.c_str();
	}

	inline void SetOutPath(const PathChar *path)
	{
		if (path)
		{
			out_path_ = path;
			flags_ &= LOG_OTYPE_DESCRIPTOR ^ 0xffffffff;
		}
	}

	inline void SetOutDesc(int fd)
	{
		if (fd>=0)
		{
			//if ( out_fd_ >=0 && out_fd_!=fd )
			//    close(out_fd_);
			flags_ |= LOG_OTYPE_DESCRIPTOR;
			out_path_.clear();
			suffix_.clear();
			out_fd_ = fd;
		}
	}

	inline int GetOutDesc() const
	{
		if (flags_ & LOG_OTYPE_DESCRIPTOR)
			return out_fd_;
		return -1;
	}

	void Log(uint32_t level,
			 const char *file,
			 uint32_t line,
			 const char *format,...);

	void HalfLog(PathString log, ULONGLONG limit_max, ULONGLONG limit_to);

	void VLog(uint32_t level,
			  const char *file,
			  uint32_t line,
			  const char *format,
			  va_list args);

	void VLog(uint32_t level, const char* file, uint32_t line, const wchar_t* format, va_list args);

protected:
	uint32_t          flags_;           // format flags

private:
	bool LogFile(PathString &filepath);
	void CreateLineSuffix(const char *file,
						  int32_t line,
						  int32_t level,
						  std::string &header);

	int out_fd_; // output descriptor
	uint32_t level_; // debug level
	NLock vlog_lock_; // vlog lock
	PathString out_path_; // output path
	PathString suffix_; // output file's suffix
};

}  // namespace nbase

#endif  // BASE_LOG_LOG_IMPL_H_

