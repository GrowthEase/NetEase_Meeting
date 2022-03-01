/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#define NBASE_FORBID_COPY(FORBIDDEN_CLASS) \
	FORBIDDEN_CLASS(const FORBIDDEN_CLASS& tmp) = delete; \
	FORBIDDEN_CLASS& operator = (const FORBIDDEN_CLASS& tmp) = delete;