/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/8
//
// Refcount Unittest

#if defined(WITH_UNITTEST)

#include "base/memory/ref_count.h"
#include "gtest/gtest.h"

TEST(RefCount, Count)
{
	nbase::RefCount *ref = new nbase::RefCount();
	EXPECT_EQ(0, ref->ref());

	ref->AddRef();
	EXPECT_EQ(1, ref->ref());
	ref->AddRef();
	EXPECT_EQ(2, ref->ref());
	ref->AddRef();
	EXPECT_EQ(3, ref->ref());
	ref->Release();
	EXPECT_EQ(2, ref->ref());
	ref->Release();
	EXPECT_EQ(1, ref->ref());
	ref->Release();
}

TEST(RefCount, Reference)
{
	nbase::RefCount *ref = new nbase::RefCount();;
    nbase::scoped_refptr<nbase::RefCount> var(ref);
	var = var;
	EXPECT_EQ(var.get(), ref);

	nbase::scoped_refptr<nbase::RefCount> svar(ref);
	svar = svar;
	EXPECT_EQ(svar.get(), ref);
	EXPECT_EQ(svar.get(), var.get());
}

#endif  // WITH_UNITTEST