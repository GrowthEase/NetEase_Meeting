/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */


#ifndef NIPCLIB_EXPORT_H_
#define NIPCLIB_EXPORT_H_

#if defined(COMPONENT_BUILD)
    #if defined(WIN32)
        #if defined(NIPCLIB_IMPLEMENTATION)
        #define NIPCLIB_EXPORT __declspec(dllexport)
        #define NIPCLIB_EXPORT_PRIVATE __declspec(dllexport)
        #else
        #define NIPCLIB_EXPORT __declspec(dllimport)
        #define NIPCLIB_EXPORT_PRIVATE __declspec(dllimport)
        #endif  // defined(NIPCLIB_IMPLEMENTATION)
    #else  // defined(WIN32)
        #if defined(NIPCLIB_IMPLEMENTATION)
            #define NIPCLIB_EXPORT __attribute__((visibility("default")))
            #define NIPCLIB_EXPORT_PRIVATE __attribute__((visibility("default")))
        #else
            #define NIPCLIB_EXPORT
            #define NIPCLIB_EXPORT_PRIVATE
        #endif  // defined(NIPCLIB_IMPLEMENTATION)
    #endif
#else  // defined(COMPONENT_BUILD)
    #define NIPCLIB_EXPORT
    #define NIPCLIB_EXPORT_PRIVATE
#endif

#endif  // NIPCLIB_EXPORT_H_
