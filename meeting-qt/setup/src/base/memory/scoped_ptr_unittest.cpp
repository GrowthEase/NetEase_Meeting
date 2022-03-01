/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/29
//
// scoped_ptr Unittest

#if defined(WITH_UNITTEST)

#include "base/base_types.h"
#include "base/memory/scoped_ptr.h"
#include "gtest/gtest.h"

namespace
{

class ConDecLogger
{
public:
	ConDecLogger() : ptr_(NULL) { }
	explicit ConDecLogger(int *ptr) { set_ptr(ptr); }
	~ConDecLogger() { --*ptr_; }

	void set_ptr(int *ptr) { ptr_ = ptr; ++*ptr_; }

	int SomeMeth(int x) { return x; }

private:
	int *ptr_;
};

}  // namespace

TEST(ScopedPtrTest, ScopedPtr)
{
	int constructed = 0;

	{
		nbase::scoped_ptr<ConDecLogger> scoper(new ConDecLogger(&constructed));
		EXPECT_EQ(1, constructed);
		EXPECT_TRUE(scoper.get() != NULL);

		EXPECT_EQ(10, scoper->SomeMeth(10));
		EXPECT_EQ(10, scoper.get()->SomeMeth(10));
		EXPECT_EQ(10, (*scoper).SomeMeth(10));
	}
	EXPECT_EQ(0, constructed);

	// Test reset() and release()
	{
		nbase::scoped_ptr<ConDecLogger> scoper(new ConDecLogger(&constructed));
		EXPECT_EQ(1, constructed);
		EXPECT_TRUE(scoper.get() != NULL);

		scoper.reset(new ConDecLogger(&constructed));
		EXPECT_EQ(1, constructed);
		EXPECT_TRUE(scoper.get() != NULL);

		scoper.reset();
		EXPECT_EQ(0, constructed);
		EXPECT_FALSE(scoper.get() != NULL);

		scoper.reset(new ConDecLogger(&constructed));
		EXPECT_EQ(1, constructed);
		EXPECT_TRUE(scoper.get() != NULL);

		ConDecLogger *take = scoper.release();
		EXPECT_EQ(1, constructed);
		EXPECT_FALSE(scoper.get() != NULL);
		delete take;
		EXPECT_EQ(0, constructed);

		scoper.reset(new ConDecLogger(&constructed));
		EXPECT_EQ(1, constructed);
		EXPECT_TRUE(scoper.get() != NULL);
	}
	EXPECT_EQ(0, constructed);

	// Test swap(), == and !=
	{
		nbase::scoped_ptr<ConDecLogger> scoper1;
		nbase::scoped_ptr<ConDecLogger> scoper2;
		EXPECT_TRUE(scoper1 == scoper2.get());
		EXPECT_FALSE(scoper1 != scoper2.get());

		ConDecLogger *logger = new ConDecLogger(&constructed);
		scoper1.reset(logger);
		EXPECT_EQ(logger, scoper1.get());
		EXPECT_FALSE(scoper2.get());
		EXPECT_FALSE(scoper1 == scoper2.get());
		EXPECT_TRUE(scoper1 != scoper2.get());

		scoper2.swap(scoper1);
		EXPECT_EQ(logger, scoper2.get());
		EXPECT_FALSE(scoper1.get());
		EXPECT_FALSE(scoper1 == scoper2.get());
		EXPECT_TRUE(scoper1 != scoper2.get());
	}
	EXPECT_EQ(0, constructed);
}

TEST(ScopedPtrTest, ScopedArray)
{
	static const int kNumLoggers = 12;

	int constructed = 0;

	{
		nbase::scoped_array<ConDecLogger> scoper(new ConDecLogger[kNumLoggers]);
		EXPECT_TRUE(scoper.get() != NULL);
		EXPECT_EQ(&scoper[0], scoper.get());
		for (int i = 0; i < kNumLoggers; ++i)
		{
			scoper[i].set_ptr(&constructed);
		}
		EXPECT_EQ(12, constructed);

		EXPECT_EQ(10, scoper.get()->SomeMeth(10));
		EXPECT_EQ(10, scoper[2].SomeMeth(10));
	}
	EXPECT_EQ(0, constructed);

	// Test reset() and release()
	{
		nbase::scoped_array<ConDecLogger> scoper;
		EXPECT_FALSE(scoper.get());
		EXPECT_FALSE(scoper.release());
		EXPECT_FALSE(scoper.get());
		scoper.reset();
		EXPECT_FALSE(scoper.get());

		scoper.reset(new ConDecLogger[kNumLoggers]);
		for (int i = 0; i < kNumLoggers; ++i)
		{
			scoper[i].set_ptr(&constructed);
		}
		EXPECT_EQ(12, constructed);
		scoper.reset();
		EXPECT_EQ(0, constructed);

		scoper.reset(new ConDecLogger[kNumLoggers]);
		for (int i = 0; i < kNumLoggers; ++i) {
			scoper[i].set_ptr(&constructed);
		}
		EXPECT_EQ(12, constructed);
		ConDecLogger* ptr = scoper.release();
		EXPECT_EQ(12, constructed);
		delete[] ptr;
		EXPECT_EQ(0, constructed);
	}
	EXPECT_EQ(0, constructed);

	// Test swap(), == and !=
	{
		nbase::scoped_array<ConDecLogger> scoper1;
		nbase::scoped_array<ConDecLogger> scoper2;
		EXPECT_TRUE(scoper1 == scoper2.get());
		EXPECT_FALSE(scoper1 != scoper2.get());

		ConDecLogger* loggers = new ConDecLogger[kNumLoggers];
		for (int i = 0; i < kNumLoggers; ++i)
		{
			loggers[i].set_ptr(&constructed);
		}
		scoper1.reset(loggers);
		EXPECT_EQ(loggers, scoper1.get());
		EXPECT_FALSE(scoper2.get());
		EXPECT_FALSE(scoper1 == scoper2.get());
		EXPECT_TRUE(scoper1 != scoper2.get());

		scoper2.swap(scoper1);
		EXPECT_EQ(loggers, scoper2.get());
		EXPECT_FALSE(scoper1.get());
		EXPECT_FALSE(scoper1 == scoper2.get());
		EXPECT_TRUE(scoper1 != scoper2.get());
	}
	EXPECT_EQ(0, constructed);
}

#endif  // WITH_UNITTEST
