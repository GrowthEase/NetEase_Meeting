/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Ported by Wang Rongtao <rtwang@corp.netease.com>
// Date: 2013/01/25

#ifndef COMMON_NENGINE_RAW_SCOPED_REFPTR_MISMATCH_CHECKER_H_
#define COMMON_NENGINE_RAW_SCOPED_REFPTR_MISMATCH_CHECKER_H_
#pragma once

#include "base/memory/ref_count.h"
#include "template_util.h"
#include "tuple.h"

// It is dangerous to post a task with a T* argument where T is a subtype of
// RefCounted(Base|ThreadSafeBase), since by the time the parameter is used, the
// object may already have been deleted since it was not held with a
// scoped_refptr. Example: http://crbug.com/27191
// The following set of traits are designed to generate a compile error
// whenever this antipattern is attempted.

namespace nbase {

// This is a base internal implementation file used by task.h and callback.h.
// Not for public consumption, so we wrap it in namespace internal.
namespace internal {

template <typename T>
struct NeedsScopedRefptrButGetsRawPtr {
#if defined(_WIN32)
  enum {
    value = nbase::false_type::value
  };
#else
  enum {
    // Human readable translation: you needed to be a scoped_refptr if you are a
    // raw pointer type and are convertible to a RefCounted(Base|ThreadSafeBase)
    // type.
    value = (is_pointer<T>::value &&
             (is_convertible<T, RefCount*>::value ||
              is_convertible<T, RefCountThreadSafe*>::value))
  };
#endif
};

template <typename Params>
struct ParamsUseScopedRefptrCorrectly {
  enum { value = 0 };
};

template <>
struct ParamsUseScopedRefptrCorrectly<std::tuple<>> {
  enum { value = 1 };
};

template <typename A>
struct ParamsUseScopedRefptrCorrectly<std::tuple<A> > {
  enum { value = !NeedsScopedRefptrButGetsRawPtr<A>::value };
};

template <typename A, typename B>
struct ParamsUseScopedRefptrCorrectly<std::tuple<A, B> > {
  enum { value = !(NeedsScopedRefptrButGetsRawPtr<A>::value ||
                   NeedsScopedRefptrButGetsRawPtr<B>::value) };
};

template <typename A, typename B, typename C>
struct ParamsUseScopedRefptrCorrectly<std::tuple<A, B, C> > {
  enum { value = !(NeedsScopedRefptrButGetsRawPtr<A>::value ||
                   NeedsScopedRefptrButGetsRawPtr<B>::value ||
                   NeedsScopedRefptrButGetsRawPtr<C>::value) };
};

template <typename A, typename B, typename C, typename D>
struct ParamsUseScopedRefptrCorrectly<std::tuple<A, B, C, D> > {
  enum { value = !(NeedsScopedRefptrButGetsRawPtr<A>::value ||
                   NeedsScopedRefptrButGetsRawPtr<B>::value ||
                   NeedsScopedRefptrButGetsRawPtr<C>::value ||
                   NeedsScopedRefptrButGetsRawPtr<D>::value) };
};

template <typename A, typename B, typename C, typename D, typename E>
struct ParamsUseScopedRefptrCorrectly<std::tuple<A, B, C, D, E> > {
  enum { value = !(NeedsScopedRefptrButGetsRawPtr<A>::value ||
                   NeedsScopedRefptrButGetsRawPtr<B>::value ||
                   NeedsScopedRefptrButGetsRawPtr<C>::value ||
                   NeedsScopedRefptrButGetsRawPtr<D>::value ||
                   NeedsScopedRefptrButGetsRawPtr<E>::value) };
};

template <typename A, typename B, typename C, typename D, typename E,
          typename F>
struct ParamsUseScopedRefptrCorrectly<std::tuple<A, B, C, D, E, F> > {
  enum { value = !(NeedsScopedRefptrButGetsRawPtr<A>::value ||
                   NeedsScopedRefptrButGetsRawPtr<B>::value ||
                   NeedsScopedRefptrButGetsRawPtr<C>::value ||
                   NeedsScopedRefptrButGetsRawPtr<D>::value ||
                   NeedsScopedRefptrButGetsRawPtr<E>::value ||
                   NeedsScopedRefptrButGetsRawPtr<F>::value) };
};

template <typename A, typename B, typename C, typename D, typename E,
          typename F, typename G>
struct ParamsUseScopedRefptrCorrectly<std::tuple<A, B, C, D, E, F, G> > {
  enum { value = !(NeedsScopedRefptrButGetsRawPtr<A>::value ||
                   NeedsScopedRefptrButGetsRawPtr<B>::value ||
                   NeedsScopedRefptrButGetsRawPtr<C>::value ||
                   NeedsScopedRefptrButGetsRawPtr<D>::value ||
                   NeedsScopedRefptrButGetsRawPtr<E>::value ||
                   NeedsScopedRefptrButGetsRawPtr<F>::value ||
                   NeedsScopedRefptrButGetsRawPtr<G>::value) };
};

template <typename A, typename B, typename C, typename D, typename E,
          typename F, typename G, typename H>
struct ParamsUseScopedRefptrCorrectly<std::tuple<A, B, C, D, E, F, G, H> > {
  enum { value = !(NeedsScopedRefptrButGetsRawPtr<A>::value ||
                   NeedsScopedRefptrButGetsRawPtr<B>::value ||
                   NeedsScopedRefptrButGetsRawPtr<C>::value ||
                   NeedsScopedRefptrButGetsRawPtr<D>::value ||
                   NeedsScopedRefptrButGetsRawPtr<E>::value ||
                   NeedsScopedRefptrButGetsRawPtr<F>::value ||
                   NeedsScopedRefptrButGetsRawPtr<G>::value ||
                   NeedsScopedRefptrButGetsRawPtr<H>::value) };
};

}  // namespace internal

}  // namespace nbase

#endif  // COMMON_NENGINE_RAW_SCOPED_REFPTR_MISMATCH_CHECKER_H_
