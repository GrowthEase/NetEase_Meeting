/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2013, NetEase Inc. All rights reserved.
//
// Wang Rongtao <rtwang@corp.netease.com>
// 2013/9/12
//
// Log helpers

#include "base/log/log.h"

namespace nbase
{

#if defined(OS_WIN)

void BreakDebugger()
{
	__debugbreak();
#if defined(NDEBUG)
	_exit(1);
#endif
}

#else // !OS_WIN

#if defined(NDEBUG) && !defined(OS_MACOSX)
#define DEBUG_BREAK() abort()
#elif defined(ARCH_CPU_ARM_FAMILY)
#define DEBUG_BREAK() asm("bkpt 0")
#else
#define DEBUG_BREAK() asm("int3")
#endif

void BreakDebugger()
{
  DEBUG_BREAK();
#if defined(NDEBUG)
  _exit(1);
#endif
}

#endif // defined(OS_WIN)

void DebugCheck(const char *expression,
				const char *file,
				int line,
				bool condition)
{
	if (!condition) {
		LogMessage message(LogInterface::LV_ASS, file, line);
		message("Assert FAILED! Expression: %s", expression);
		BreakDebugger();
	}
}

LogMessage::LogMessage(LogInterface::Level level, const char *file, int line)
	: level_(level), file_(file), line_(line)
{

}

void LogMessage::operator() (const char *format,...)
{
	va_list args;
	va_start(args, format);
	nbase::Log_Creater()->VLog(level_, file_, line_, format ,args);
	va_end(args);
}

void LogMessage::operator()( const wchar_t* format, ... )
{
	va_list args;
	va_start(args, format);
	nbase::Log_Creater()->VLog(level_, file_, line_, format ,args);
	va_end(args);
}

} // nbase
