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

#include "base/log/log_impl.h"

#include "base/file/file_util.h"
#include "base/memory/singleton.h"
#include "base/time/time.h"
#include "base/util/string_util.h"

#if defined(OS_WIN)
#include <io.h>
#else
#include <unistd.h>
#include <string.h>
#endif  // OS_WIN

#include <assert.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <stdarg.h>
//#include "shared/tool.h"
#include "../win32/platform_string_util.h"
#include "../memory/scoped_std_handle.h"

namespace nbase
{

const char kFileLineBreak[] = "\r\n";

LogInterface* Log_Creater()
{
	return Log_Impl::GetInstance();
}

void DefLogSetLevel(int level)
{
	Log_Creater()->SetLevel(level);
}

void DefLogSetFlag(LogInterface::Flag flag)
{
	Log_Creater()->SetFlag(flag);
}

void DefLogRemoveFlag(LogInterface::Flag flag)
{
	Log_Creater()->RemoveFlag(flag);
}

void DefLogSetSuffix(const PathChar *suffix)
{
	Log_Creater()->SetSuffix(suffix);
}

void DefLogSetOutPath(const PathChar *path)
{
	Log_Creater()->SetOutPath(path);
}

void DefLogSetOutDesc(int desc)
{
	Log_Creater()->SetOutDesc(desc);
}

void DefLog(uint32_t level, const char *file, uint32_t line, const char *format,...)
{
	if (level <= Log_Creater()->GetLevel())
	{
		va_list args;
		va_start(args, format);
		Log_Creater()->VLog(level, file, line, format ,args);
		va_end(args);
	}
}
void DefHalfLog(const PathChar *path, ULONGLONG limit_max, ULONGLONG limit_to)
{
	if (path)
	{
		PathString log = path;
		Log_Impl::GetInstance()->HalfLog(log, limit_max, limit_to);
	}
}

// Log_Impl ------------------------------------------------------
Log_Impl::Log_Impl()
	: flags_(LogInterface::LOG_DATE |
             LogInterface::LOG_TIME |
             LogInterface::LOG_FILE |
             LogInterface::LOG_LINE |
#if defined(DEBUG) || defined(_DEBUG)
			 LogInterface::LOG_OUT_DEBUGINFO
#else
			 0
#endif
			 ),
      out_fd_(-1)
{
      level_ = 0;
}

Log_Impl::Log_Impl(const PathChar* path) : out_fd_(-1)
{
      level_ = 0;
      flags_=  LogInterface::LOG_DATE |
               LogInterface::LOG_TIME |
               LogInterface::LOG_FILE |
               LogInterface::LOG_LINE;
      if (path)
          out_path_ = path;
}

Log_Impl::Log_Impl(int outfd)
{
      level_ = 0;
      flags_=  LogInterface::LOG_DATE |
               LogInterface::LOG_TIME |
               LogInterface::LOG_FILE |
               LogInterface::LOG_LINE |
               LogInterface::LOG_OTYPE_DESCRIPTOR;
      out_fd_   = outfd;
}

Log_Impl* Log_Impl::GetInstance()
{
	return Singleton<Log_Impl>::get();
}

void Log_Impl::VLog( uint32_t level, const char *file, uint32_t line, const char *format, va_list args )
{
	if (level > level_)
		return;

	PathString log_file;

	int32_t flags = flags_;
	if (flags & LogInterface::LOG_OTYPE_DESCRIPTOR)
	{
		if (out_fd_ < 0)
			return;
	}
	else
	{
		if (!LogFile(log_file))
			return;
	}

	std::string msg;
	CreateLineSuffix(file, line, level, msg);
	StringAppendV(msg, format, args);
	msg.append(kFileLineBreak);

	if (flags & LogInterface::LOG_OTYPE_DESCRIPTOR)
	{
		NAutoLock guard(&vlog_lock_);
#if defined(OS_WIN)
		_write(out_fd_, msg.c_str(), (unsigned int)msg.length());
#else
		write(out_fd_, msg.c_str(), (unsigned int)msg.length());
#endif
	}
	else
	{
		int fd;
#if defined(OS_WIN)
		bool exist = nbase::FilePathIsExist( log_file, false );

		fd = _wsopen( log_file.c_str(), O_CREAT | O_RDWR | O_APPEND, _SH_DENYNO, _S_IREAD | _S_IWRITE );
		if( fd < 0 )
			return;

		NAutoLock guard(&vlog_lock_);

		if( !exist )
		{
			const char utf8[3] = { (char) 0xEF, (char) 0xBB, (char) 0xBF };
			_write( fd, utf8, 3 );
		}

		_write(fd, msg.c_str(), (unsigned int)msg.length());
		_close(fd);
#else
		// 非win下遇到再加
		if ((fd = open(log_file.c_str(), O_CREAT|O_RDWR|O_APPEND, 0660)) < 0)
			return;
		write(fd, msg.c_str(), (unsigned int)msg.length());
		close(fd);
#endif  // OS_WIN
	}

	// If debug mode, output the log to console    
#if defined(DEBUG) || defined(_DEBUG)
	fprintf(stdout, "%s", msg.c_str());
#endif // DEBUG

#if defined(OS_WIN)
	if (flags & LOG_OUT_DEBUGINFO)
		OutputDebugStringA(msg.c_str());
#endif // OS_WIN
}

void Log_Impl::VLog( uint32_t level, const char* file, uint32_t line, const wchar_t* format, va_list args )
{
	if (level > level_)
		return;
//实在很遗憾，yixin.log是utf8编码，中文写入可以看到，但是在控制台就会乱码；如果用多字节，控制台不会乱，但log会乱
#if defined(DEBUG) || defined(_DEBUG)
	std::string ascii;
#endif // DEBUG

	PathString log_file;

	int32_t flags = flags_;
	if (flags & LogInterface::LOG_OTYPE_DESCRIPTOR)
	{
		if (out_fd_ < 0)
			return;
	}
	else
	{
		if (!LogFile(log_file))
			return;
	}

	std::string msg;
	CreateLineSuffix(file, line, level, msg);

	std::wstring info;
	StringAppendV(info, format, args);

#if defined(DEBUG) || defined(_DEBUG)
	ascii = msg;

	std::string str;
	nbase::win32::UnicodeToMBCS(info, str);
	ascii.append(str);
	ascii.append(kFileLineBreak);
#endif 

	UTF8String utf;
	nbase::UTF16ToUTF8(info, utf);
	msg.append(utf);
	msg.append(kFileLineBreak);

	if (flags & LogInterface::LOG_OTYPE_DESCRIPTOR)
	{
		NAutoLock guard(&vlog_lock_);
#if defined(OS_WIN)
		_write(out_fd_, msg.c_str(), (unsigned int)msg.length());
#else
		write(out_fd_, msg.c_str(), (unsigned int)msg.length());
#endif
	}
	else
	{
		int fd;
#if defined(OS_WIN)
		bool exist = nbase::FilePathIsExist( log_file, false );

		fd = _wsopen( log_file.c_str(), O_CREAT | O_RDWR | O_APPEND, _SH_DENYNO, _S_IREAD | _S_IWRITE );
		if( fd < 0 )
			return;

		NAutoLock guard(&vlog_lock_);

		if( !exist )
		{
			const char utf8[3] = { (char) 0xEF, (char) 0xBB, (char) 0xBF };
			_write( fd, utf8, 3 );
		}

		_write( fd, msg.c_str(), (unsigned int) msg.length() );
		_close( fd );
#else
		if ((fd = open(log_file.c_str(), O_CREAT|O_RDWR|O_APPEND, 0660)) < 0)
			return;
		write(fd, msg.c_str(), (unsigned int)msg.length());
		close(fd);
#endif  // OS_WIN
	}
  
#if defined(DEBUG) || defined(_DEBUG)
	fprintf(stdout, "%s", ascii.c_str());
#endif 

#if defined(OS_WIN) 
	if (flags & LOG_OUT_DEBUGINFO)
	{
#if defined(DEBUG) || defined(_DEBUG)
		OutputDebugStringA(ascii.c_str());
#else
		OutputDebugStringA(msg.c_str());
#endif 
	}
#endif // OS_WIN
}

void Log_Impl::Log(uint32_t level,
				   const char * file,
				   uint32_t line,
				   const char * format,...)
{
	va_list args;
	va_start(args, format);
	VLog(level, file, line, format, args);
	va_end(args);
}

//  Format : "[MM-DD-YYYY hh:mm:ss:msec file:line level]<SYS_ERRNO:SYS_ERRMSG>"
void Log_Impl::CreateLineSuffix(const char *file,
								int32_t line,
								int32_t level,
								std::string &header)
{
	header.clear();

    if (file == 0)
        return;

    uint32_t    flags = flags_;
    //    Time and Date
    if (flags & (LogInterface::LOG_DATE|LogInterface::LOG_TIME|LogInterface::LOG_TIMESTAMP))
    {
		Time::TimeStruct ts = Time::Now().ToTimeStruct(true);
        if (flags & LogInterface::LOG_TIMESTAMP)
        {
#if defined(OS_WIN)
			StringAppendF(header, "[%04d-%02d-%02d %02d:%02d:%02d:%03d %u/%u",
				ts.year(), ts.month(), ts.day_of_month(),
				ts.hour(), ts.minute(), ts.second(), ts.millisecond(),
				GetCurrentProcessId(), GetCurrentThreadId());
#else
			StringAppendF(header, "[%04d-%02d-%02d %02d:%02d:%02d:%03d",
				                ts.year(), ts.month(), ts.day_of_month(),
								ts.hour(), ts.minute(), ts.second(), ts.millisecond());
#endif //
        }
        else
        {
			header.append("[");
			if (flags & LogInterface::LOG_DATE)
			{
				StringAppendF(header, "%04d-%02d-%02d",
					ts.year(), ts.month(), ts.day_of_month());
			}
			if (flags & LogInterface::LOG_TIME)
			{
				if (flags & Log_Impl::LOG_DATE)
					header.append(" ");
				StringAppendF(header, "%02d:%02d:%02d",
					ts.hour(), ts.minute(), ts.second());
			}
#if defined(OS_WIN)
			StringAppendF(header, " %u/%u",
				GetCurrentProcessId(), GetCurrentThreadId());
#endif //
        }
    }
    //    filename and line number
    if (file)
	{
        if (flags & LogInterface::LOG_FILE)
        {
			header.append(" ");
			size_t length = strlen(file);
			for (; length > 0; length--) {
#if defined(OS_WIN)
				if (file[length-1] == '\\') {
#else
				if (file[length-1] == '/') {
#endif
					header.append(file+length);
					break;
				}
			}
			if (length == 0)
				header.append(file);
        }
        if (flags & LogInterface::LOG_LINE)
        {
			StringAppendF(header, ":%d", line);
        }
    }

#undef LOG_LEVEL
#define LOG_LEVEL(m,v) case v: level_string = #m; break;
	const char *level_string = "NONE";
	switch (level) {
#include "base/log/log_level.h"
	}
	StringAppendF(header, " %s] ", level_string);

    //System errno and errmsg
    if (flags & ( LogInterface::LOG_SYS_CODE | LogInterface::LOG_SYS_MSG ))
    {
		if (flags & LogInterface::LOG_SYS_MSG)
#if defined(OS_WIN) && defined(COMPILER_MSVC)
        {
			char errbuf[256];
			strerror_s(errbuf, 256, errno);
			StringAppendF(header, " {%d:%s}%s", errno, errbuf, kFileLineBreak);
		}
#else
			StringAppendF(header, " {%d:%s}%s", errno, strerror(errno), kFileLineBreak);
#endif
        else
			StringAppendF(header, " {%d}%s", errno, kFileLineBreak);
    }
}

// create log file name
bool Log_Impl::LogFile(PathString &filepath)
{
	std::string time_prefix;
	Time::TimeStruct ts = Time::Now().ToTimeStruct(true);
	StringPrintf(time_prefix, "%04d%02d%02d_", ts.year(), ts.month(), ts.day_of_month());
	
	 uint32_t flags = flags_;
#if defined(OS_WIN)
	PathString filename;
    if (flags & LogInterface::LOG_FTYPE_ONLYONE)
		StringPrintf(filename, L"%s.txt", suffix_.c_str());
    else
		StringPrintf(filename, L"%s%s.txt", time_prefix.c_str(), suffix_.c_str());
#else
	 std::string filename;
	 if (flags & LogInterface::LOG_FTYPE_ONLYONE)
		 StringPrintf(filename, "%s.txt", suffix_.c_str());
	 else
		 StringPrintf(filename, "%s%s.txt", time_prefix.c_str(), suffix_.c_str());
#endif
    return FilePathCompose(out_path_, filename, filepath);
}
void Log_Impl::HalfLog(PathString log, ULONGLONG limit_max, ULONGLONG limit_to)
{
	//获取路径
	//PathString log = shared::tools::GetLogFilePath();

	//打开文件
	nbase::ScopedStdHandle fp;
	_wfopen_s(fp, log.c_str(), L"r");
	if (!fp.Valid())
	{
		_wfopen_s(fp, log.c_str(), L"w");
		fp.Reset(NULL);
		return;
	}

	//获取长度
	int ret = fseek(fp, 0L, SEEK_END);
	if (ret != 0)
	{
		return;
	}

	//小于limit_max则直接返回
	long len = ftell(fp);
	if (len < limit_max)
	{
		return;
	}

	//大于limit_max，只留下最后limit_to
	len = limit_to * (-1);
	ret = fseek(fp, len, SEEK_END);
	if (ret != 0)
	{
		return;
	}

	//创建新文件
	PathString new_file = log + L".old";
	nbase::ScopedStdHandle fp2;
	_wfopen_s(fp2, new_file.c_str(), L"w");
	if (!fp2.Valid())
		return;

	//写入新文件
	char cbuf[12 * 1024];
	int cn = sizeof(cbuf), n = 0;
	while (!feof(fp))
	{
		n = fread_s(cbuf, cn, sizeof(char), cn, fp);
		if (n > 0)
		{
			fwrite(cbuf, sizeof(char), n, fp2);
		}
		else
			break;
	}

	fp.Reset(NULL);
	fp2.Reset(NULL);
	//文件替换
	NAutoLock guard(&vlog_lock_);
	bool del = nbase::DeleteFileW(log);
	if (del)
	{
		::_wrename(new_file.c_str(), log.c_str());
	}
	else
	{
		nbase::DeleteFileW(new_file.c_str());
	}
}

}  // namespace nbase
