/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/12
//
// Log Unittest

#if defined(WITH_UNITTEST)

#include "base/log/log_impl.h"
#include "base/file/file_util.h"
#include "gtest/gtest.h"

TEST(Log, Basic)
{
	nbase::LogInterface *log_test = nbase::Log_Creater();

	EXPECT_STREQ("nbase::Log_Impl::1.0", log_test->Version());

    log_test->SetLevel(nbase::LogInterface::LV_PRO);
	EXPECT_EQ(nbase::LogInterface::LV_PRO, log_test->GetLevel());
	EXPECT_LE((uint32_t)nbase::LogInterface::LV_ERR, log_test->GetLevel());

	std::wstring directory;
	nbase::FilePathCurrentDirectory(directory);
	log_test->SetOutPath(directory.c_str());
	EXPECT_STREQ(directory.c_str(), log_test->GetOutPath());

	log_test->SetSuffix(L"test");
	log_test->SetFlag(nbase::LogInterface::LOG_FTYPE_ONLYONE);
	log_test->Log(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "base_win_msvc: TEST(Log, Basic)");
}

TEST(Log, DefaultAPI)
{
	std::wstring directory;
	nbase::FilePathCurrentDirectory(directory);
	nbase::DefLogSetOutPath(directory.c_str());
	nbase::DefLogSetSuffix(L"test");
	nbase::DefLogSetFlag(nbase::LogInterface::LOG_FTYPE_ONLYONE);
	nbase::DefLogSetLevel(nbase::LogInterface::LV_APP);

	DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "base_win_msvc: TEST(Log, DefaultAPI)");
	DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "Test 1");
	DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "Test 2");
	nbase::DefLog(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "Test 3");
}

TEST(Log, Advanced)
{
	std::wstring directory;
	nbase::FilePathCurrentDirectory(directory);
	nbase::DefLogSetOutPath(directory.c_str());
	nbase::DefLogSetSuffix(L"test");
	nbase::DefLogSetFlag(nbase::LogInterface::LOG_FTYPE_ONLYONE);
	nbase::DefLogSetLevel(nbase::LogInterface::LV_APP);

	LOG_KER("KER");
	LOG_ASS("ASS");
	LOG_ERR("%s", "ERR");
	LOG_WAR("%s", "WAR");
	LOG_INT("%s-%d", "INT", 5);
	LOG_APP("%s", "APP");
	LOG_PRO("%s", "PRO");

	DLOG_KER("KER");
	DLOG_ASS("ASS");
	DLOG_ERR("%s", "ERR");
	DLOG_WAR("%s", "WAR");
	DLOG_INT("%s-%d", "INT", 5);
	DLOG_APP("%s", "APP");
	DLOG_PRO("%s", "PRO");
}

#endif