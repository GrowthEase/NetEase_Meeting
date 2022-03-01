/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/10/16
//
// http Unittest

#if defined(WITH_UNITTEST)

#include "base/network/http.h"
#include "gtest/gtest.h"

TEST(HttpTest, basic)
{
	nbase::Http http;

	EXPECT_EQ(CURLE_OK, http.last_error());
	EXPECT_TRUE(http.IsValid());
}

TEST(HttpTest, HttpGet)
{
	nbase::Http http;
	http.SetTimeout(nbase::TimeDelta::FromSeconds(20));
	nbase::HttpString content;
	nbase::HttpError error = http.HttpGet("http://res.popo.163.com/lbs/link.jsp?net=t", content);
	EXPECT_EQ(CURLE_OK, error);
	EXPECT_TRUE(content.size() > 0);
	EXPECT_TRUE(content.find(':') > 0);
}

TEST(HttpTest, HttpPost)
{
	nbase::Http http;
	nbase::HttpString content;
	http.SetHeaderField("Content-Type", "application/x-www-form-urlencoded");
	http.SetHeaderField("User-Agent", "POPO");
	nbase::HttpError error = http.HttpPost(
		"http://reg.163.com/services/userlogin", 
		"username=po_mail_test&password=d078f151fdcf4415082b68887d3cb1d0&type=1&product=popomail",
		content);
	EXPECT_EQ(CURLE_OK, error);
	EXPECT_TRUE(content.size() > 0);
	EXPECT_TRUE(content.find("Ok") > 0);
}

TEST(HttpTest, HttpsGet)
{
	nbase::Http https;
    https.SetTimeout(nbase::TimeDelta::FromSeconds(6));
	nbase::HttpString content, ca_path;
	nbase::HttpError error = https.HttpsGet("https://www.163.com", false, ca_path, content);
	EXPECT_EQ(CURLE_OK, error);
	EXPECT_TRUE(content.size() > 0);
}

#endif  // WITH_UNITTEST