// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
//
//  lunch_mac.m
//  nem_hosting_module
//
//  Created by 邓佳佳 on 2020/7/22.
//

#include "lunch_mac.h"
#include <mach-o/dyld.h>
#include <signal.h>
#include <iostream>
#include "nem_hosting_module/global/global.h"

#import <Foundation/Foundation.h>

#define MEETING_HOST_EXECUTOR "NetEaseMeetingClient"

USING_NS_NNEM_SDK_HOSTING_MODULE

bool lunchProcess(const std::string& sdkpath, int& process_id, int port, int old_process_id) {
    [[NSProcessInfo processInfo] beginActivityWithOptions:NSActivityLatencyCritical | NSActivityUserInitiated reason:@"Disable App Nap"];
    // 向进程发送 Quit 信号，让进程优雅的退出，而不是直接杀死
    if (old_process_id != 0) {
        do {
            int ret = kill(old_process_id, SIGTERM);
            std::cout << "kill(old_process_id, SIGTERM): " << ret << ", errno: " << errno << std::endl;
            std::string strTmp = "successful.";
            if (0 != ret) {
                strTmp = "unsuccessful. errno: " + std::to_string(errno) + " (" + strerror(errno) + ")";
            }
            LOG_IPCSERVICE_INFO("Latest processID " + std::to_string(old_process_id) + " is closed(SIGTERM): " + strTmp);

            if (0 != ret) {
                if (3 == errno) {
                    break;
                }

                ret = kill(old_process_id, SIGKILL);
                std::cout << "kill(old_process_id, SIGKILL): " << ret << ", errno: " << errno << std::endl;
                strTmp = "successful.";
                if (0 != ret) {
                    strTmp = "unsuccessful. errno: " + std::to_string(errno) + " (" + strerror(errno) + ")";
                }
                LOG_IPCSERVICE_INFO("Latest processID " + std::to_string(old_process_id) + " is closed(SIGKILL): " + strTmp);
            }
        } while (0);
    }

    std::string strPort = std::to_string(port);
    NSString* NSPort = [NSString stringWithCString:strPort.c_str() encoding:[NSString defaultCStringEncoding]];

    std::string fullExecutorPath;
    if (sdkpath.empty()) {
        char path[256] = {0};
        unsigned size = 256;
        _NSGetExecutablePath(path, &size);
        fullExecutorPath = path;
        fullExecutorPath.replace(fullExecutorPath.find_last_of('/'), fullExecutorPath.length(), "");
        fullExecutorPath.replace(fullExecutorPath.find_last_of('/'), fullExecutorPath.length(), "");
        fullExecutorPath.append(R"(/Frameworks/NetEaseMeetingClient.app/Contents/MacOS/NetEaseMeetingClient)");
        // NSString *NSFilePath = [NSString stringWithCString:fullExecutorPath.c_str() encoding:[NSString defaultCStringEncoding]];
    } else {
        fullExecutorPath = sdkpath;
        fullExecutorPath.replace(fullExecutorPath.find_last_of('/'), 1, "");
        fullExecutorPath.replace(fullExecutorPath.find_last_of('/'), 1, "");
        fullExecutorPath.append(R"(/NetEaseMeetingClient.app/Contents/MacOS/NetEaseMeetingClient)");
    }

    NSString* NSFilePath = [[NSString alloc] initWithBytes:fullExecutorPath.data()
                                                    length:fullExecutorPath.size() * sizeof(char)
                                                  encoding:NSUTF8StringEncoding];

    std::cout << "Launch macOS application: " << fullExecutorPath << std::endl;
    LOG_IPCSERVICE_INFO("Launch macOS application: " + fullExecutorPath + " port: " + std::to_string(port));

    NSString* NSCommandLine = [NSString stringWithFormat:@"--port=\"%@\"", NSPort];
    NSLog(@"NSString path: %@", NSFilePath);

    NSString* commandLine = [NSString stringWithFormat:@"%@ \"%@\" %@", @"/usr/bin/open", NSFilePath, NSCommandLine];

    process_id = 0;
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:NSFilePath];
    [task setArguments:[NSArray arrayWithObjects:@"--port", NSPort, nil]];
    [task launch];
    process_id = task.processIdentifier;
    LOG_IPCSERVICE_INFO("Launch macOS application successed, ProcessID: " + std::to_string(process_id) + ".");
    std::this_thread::sleep_for(std::chrono::seconds(2));
    [task release];
    [NSFilePath release];
    return true;
}
