/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/8
//
// RefCount is a reference counted base class, not thread safe.
// ThreadSafeRefCount is a reference counted base class, thread safe.
// scoped_refptr is a reference counted class template.

#ifndef BASE_MEMORY_REF_COUNT_H__
#define BASE_MEMORY_REF_COUNT_H__

#include <assert.h>
#include "base/base_types.h"
#include "base/base_export.h"
#include "base/third_party/chrome/atomicops.h"

namespace nbase
{
/*
 *	purpose		Reference counted class. Not thread safe.
 */
class BASE_EXPORT RefCount
{
public:
	// default constructor function
	RefCount() : ref_(0) {}

	// destructor function
	virtual ~RefCount()
	{
		assert(ref_ == 0);
	}

    // Get the current count of the object reference
    inline int32_t ref() const
    {
        return ref_;
    }

    // Set the current count of the object reference
    inline void set_ref(int32_t ref)
    {
        ref_ = ref;
        assert(ref_ >= 0);
    }

    // increase the count of the object reference
    inline int32_t AddRef()
    {
        ++ref_;
		return ref_;
    }

    //decrease the count of the object reference
    inline int32_t Release()
    {
		assert(ref_ >= 0);
		int32_t r = --ref_;
        if (ref_ == 0)
            delete this;
		return r;
    }

private:
	// forbid copy and assignment of the RefCount object
	RefCount(const RefCount&);
	void operator=(const RefCount&);

	int32_t     ref_;
};

/*
 *	purpose		Reference counted class. Not thread safe.
 */
class BASE_EXPORT ThreadSafeRefCountBase
{
public:
	// default constructor function
	ThreadSafeRefCountBase() : ref_(0) {}

	// destructor function
	virtual ~ThreadSafeRefCountBase()
	{
		assert(ref_ == 0);
	}

    // Get the current count of the object reference
    inline base::subtle::Atomic32 ref() const
    {
        return base::subtle::Acquire_Load(&ref_);
    }

    // Set the current count of the object reference
    inline void set_ref(base::subtle::Atomic32 ref)
    {
		base::subtle::NoBarrier_AtomicExchange(&ref_, ref);
        assert(ref_ >= 0);
    }

    // increase the count of the object reference
    inline base::subtle::Atomic32 AddRef() const
    {
		return base::subtle::NoBarrier_AtomicIncrement(&ref_, 1);
    }

    //decrease the count of the object reference
    inline base::subtle::Atomic32 Release() const
    {
        assert(ref_ > 0);
        return base::subtle::Barrier_AtomicIncrement(&ref_, -1);
    }

private:
	// forbid copy and assignment of the RefCount object
	explicit ThreadSafeRefCountBase(const ThreadSafeRefCountBase&);
	void operator=(const ThreadSafeRefCountBase&);

	mutable base::subtle::Atomic32 ref_;
};

// Forward declaration.
template <typename T, typename Traits> class ThreadSafeRefCountT;

template<typename T>
struct DefaultRefCountedThreadSafeTraits {
	static void Destruct(const T* x) {
		// Delete through RefCountedThreadSafe to make child classes only need to be
		// friend with RefCountedThreadSafe instead of this struct, which is an
		// implementation detail.
		ThreadSafeRefCountT<T,
			DefaultRefCountedThreadSafeTraits>::DeleteInternal(x);
	}
};

template <class T, typename Traits = DefaultRefCountedThreadSafeTraits<T> >
class ThreadSafeRefCountT : public ThreadSafeRefCountBase
{
public:
	ThreadSafeRefCountT() { }
	~ThreadSafeRefCountT() { }

	base::subtle::Atomic32 Release() const
	{
		base::subtle::Atomic32 r = ThreadSafeRefCountBase::Release();
		if (r == 0)
			Traits::Destruct(static_cast<const T*>(this));
		return r;
	}

private:
	friend struct DefaultRefCountedThreadSafeTraits<T>;
	static void DeleteInternal(const T* x) { delete x; }

	DISALLOW_COPY_AND_ASSIGN(ThreadSafeRefCountT);
};

class BASE_EXPORT ThreadSafeRefCount :
	public ThreadSafeRefCountT<ThreadSafeRefCount>
{
public:

};

template <class T>
class scoped_refptr
{
public:
	scoped_refptr() : ptr_(NULL)
	{

	}

	scoped_refptr(T *p) : ptr_(p)
	{
		if (ptr_)
			ptr_->AddRef();
	}

	scoped_refptr(const scoped_refptr<T> &r) : ptr_(r.ptr_)
	{
		if (ptr_)
			ptr_->AddRef();
	}

	template <typename U>
	scoped_refptr(const scoped_refptr<U> &r) : ptr_(r.get())
	{
		if (ptr_)
			ptr_->AddRef();
	}

	~scoped_refptr()
	{
		if (ptr_)
			ptr_->Release();
	}

	T* get() const { return ptr_; }
	operator T*() const { return ptr_; }
	T* operator->() const { return ptr_; }

	inline bool is_nil() const
	{
		return (ptr_ == NULL);
	}

	// Release a pointer.
	// The return value is the current pointer held by this object.
	// If this object holds a NULL pointer, the return value is NULL.
	// After this operation, this object will hold a NULL pointer,
	// and will not own the object any more.
	T* release()
	{
		T* retVal = ptr_;
		ptr_ = NULL;
		return retVal;
	}

	scoped_refptr<T>& operator=(T *p)
	{
		// AddRef first so that self assignment should work
		if (p)
			p->AddRef();
		if (ptr_)
			ptr_->Release();
		ptr_ = p;
		return *this;
	}

	scoped_refptr<T>& operator=(const scoped_refptr<T> &r)
	{
		return *this = r.ptr_;
	}

	template <typename U>
	scoped_refptr<T>& operator=(const scoped_refptr<U> &r)
	{
		return *this = r.get();
	}

	void swap(T **pp)
	{
		T* p = ptr_;
		ptr_ = *pp;
		*pp = p;
	}

	void swap(scoped_refptr<T> &r)
	{
		swap(&r.ptr_);
	}

protected:
	T* ptr_;
};

// Handy utility for creating a scoped_refptr<T> out of a T* explicitly without
// having to retype all the template arguments
template <typename T>
scoped_refptr<T> make_scoped_refptr(T *t)
{
	return scoped_refptr<T>(t);
}

}

#endif  // BASE_MEMORY_REF_COUNT_H__


