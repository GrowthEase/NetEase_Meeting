/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2013, NetEase Inc. All rights reserved.
//
// Wang Rongtao <rtwang@corp.netease.com>
// 2013/9/17
//
// Log helpers for simpler use

#ifndef BASE_LOG_LOG_HELPER_H_
#define BASE_LOG_LOG_HELPER_H_

class BASE_EXPORT LogMessage
{
public:
	LogMessage(LogInterface::Level level, const char *file, int line);
	void operator() (const char *format, ...);
	void operator() (const wchar_t* format, ...);

private:
	LogInterface::Level level_;
	int line_;
	const char *file_;
};

BASE_EXPORT void DebugCheck(const char *expression,
							const char *file,
							int line,
							bool condition);

#define LOG_IS_ON(level) DEFLOGALLOW(nbase::LogInterface:: ## level)
#define LAZY_LOG(condition,msg) (!condition) ? (void)0 : msg
#define LOG_MSG(level) nbase::LogMessage( \
	nbase::LogInterface:: ## level, __FILE__, __LINE__)
#define LOG(level) LAZY_LOG(LOG_IS_ON(level),LOG_MSG(level))
#define LOG_KER LOG(LV_KER)
#define LOG_ASS LOG(LV_ASS)
#define LOG_ERR LOG(LV_ERR)
#define LOG_WAR LOG(LV_WAR)
#define LOG_INT LOG(LV_INT)
#define LOG_APP LOG(LV_APP)
#define LOG_PRO LOG(LV_PRO)

#ifndef NDEBUG
#define DCHECK(x) \
	nbase::DebugCheck(#x, __FILE__, __LINE__, !!(x));
#else
#define DCHECK(x) true? (void)0 : \
	nbase::DebugCheck(#x, __FILE__, __LINE__, !!(x));
#endif // NDEBUG

/*
#ifndef NDEBUG
#define DLOG_KER LOG_KER
#define DLOG_ASS LOG_ASS
#define DLOG_ERR LOG_ERR
#define DLOG_WAR LOG_WAR
#define DLOG_INT LOG_INT
#define DLOG_APP LOG_APP
#define DLOG_PRO LOG_PRO
#define DCHECK(x) \
	nbase::DebugCheck(#x, __FILE__, __LINE__, !!(x));
#else
#define DLOG_KER true? (void)0 : LOG_KER
#define DLOG_ASS true? (void)0 : LOG_ASS
#define DLOG_ERR true? (void)0 : LOG_ERR
#define DLOG_WAR true? (void)0 : LOG_WAR
#define DLOG_INT true? (void)0 : LOG_INT
#define DLOG_APP true? (void)0 : LOG_APP
#define DLOG_PRO true? (void)0 : LOG_PRO
#define DCHECK(x) true? (void)0 : \
	nbase::DebugCheck(#x, __FILE__, __LINE__, !!(x));
#endif // NDEBUG
*/

#endif // BASE_LOG_LOG_HELPER_H_
