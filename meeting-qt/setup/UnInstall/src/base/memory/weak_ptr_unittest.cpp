/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/10/6
//
// weak_ptr unittest

#if defined(WITH_UNITTEST)

#include "base/memory/weak_ptr.h"
#include "gtest/gtest.h"

namespace nbase
{

struct Base {};
struct Derived : Base {};

struct Producer : SupportsWeakPtr<Producer> {};
struct Consumer { WeakPtr<Producer> producer; };

TEST(WeakPtrTest, Basic)
{
	int data;
	WeakPtrFactory<int> factory(&data);
	WeakPtr<int> ptr = factory.GetWeakPtr();
	EXPECT_EQ(&data, ptr.get());
}

TEST(WeakPtrTest, Comparison)
{
	int data;
	WeakPtrFactory<int> factory(&data);
	WeakPtr<int> ptr = factory.GetWeakPtr();
	WeakPtr<int> ptr2 = ptr;
	EXPECT_TRUE(ptr == ptr2);
}

TEST(WeakPtrTest, OutOfScope)
{
	WeakPtr<int> ptr;
	EXPECT_TRUE(ptr.get() == NULL);
	{
		int data;
		WeakPtrFactory<int> factory(&data);
		ptr = factory.GetWeakPtr();
	}
	EXPECT_TRUE(ptr.get() == NULL);
}

TEST(WeakPtrTest, Multiple)
{
    WeakPtr<int> a, b;
    {
		int data;
		WeakPtrFactory<int> factory(&data);
		a = factory.GetWeakPtr();
		b = factory.GetWeakPtr();
		EXPECT_EQ(&data, a.get());
		EXPECT_EQ(&data, b.get());
    }
    EXPECT_TRUE(a.get() == NULL);
    EXPECT_TRUE(b.get() == NULL);
}

TEST(WeakPtrTest, MultipleStaged)
{
    WeakPtr<int> a;
    {
		int data;
		WeakPtrFactory<int> factory(&data);
		a = factory.GetWeakPtr();
		{
		    WeakPtr<int> b = factory.GetWeakPtr();
		}
		EXPECT_TRUE(a.get() != NULL);
	}
    EXPECT_TRUE(a.get() == NULL);
}

TEST(WeakPtrTest, UpCast)
{
	Derived data;
	WeakPtrFactory<Derived> factory(&data);
	WeakPtr<Base> ptr = factory.GetWeakPtr();
	ptr = factory.GetWeakPtr();
	EXPECT_EQ(ptr.get(), &data);
}

TEST(WeakPtrTest, SupportsWeakPtr)
{
	Producer f;
	WeakPtr<Producer> ptr = f.AsWeakPtr();
	EXPECT_EQ(&f, ptr.get());
}

TEST(WeakPtrTest, InvalidateWeakPtrs)
{
	int data;
	WeakPtrFactory<int> factory(&data);
	WeakPtr<int> ptr = factory.GetWeakPtr();
	EXPECT_EQ(&data, ptr.get());
	EXPECT_TRUE(factory.HasWeakPtrs());
	factory.InvalidateWeakPtrs();
	EXPECT_TRUE(ptr.get() == NULL);
	EXPECT_FALSE(factory.HasWeakPtrs());
}

TEST(WeakPtrTest, HasWeakPtrs)
{
	int data;
	WeakPtrFactory<int> factory(&data);
	{
		WeakPtr<int> ptr = factory.GetWeakPtr();
		EXPECT_TRUE(factory.HasWeakPtrs());
	}
	EXPECT_FALSE(factory.HasWeakPtrs());
}
}

#endif  // WITH_UNITTEST