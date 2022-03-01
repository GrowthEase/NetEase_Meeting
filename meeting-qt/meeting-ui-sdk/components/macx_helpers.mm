/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "macx_helpers.h"
//#include <qcocoaintegration.h>
#import <AppKit/AppKit.h>
#include <QtMac>

bool MacXHelpers::openFolder(const QString& folder) {
    QByteArray byteFolder = folder.toUtf8();
    NSString* command = [NSString stringWithFormat:@" open %s ", byteFolder.data()];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
      NSTask* task = [[NSTask alloc] init];
      [task setLaunchPath:@"/bin/sh"];
      NSArray* arguments;
      arguments = [NSArray arrayWithObjects:@"-c", command, nil];
      [task setArguments:arguments];
      [task launch];
      [task waitUntilExit];
    });

    return true;
}

int MacXHelpers::getDisplayId(int screenIndex) {
    YXLOG(Info) << "Get display ID by screen index: " << screenIndex << YXLOGEnd;
    int nativeDisplayId = 0;
    int index = 0;

    NSArray<NSScreen*>* screens = [NSScreen screens];
    for (NSScreen* screen in screens) {
        NSDictionary* deviceDescription = [screen deviceDescription];
        id screenNumber = [deviceDescription objectForKey:@"NSScreenNumber"];
        NSString* displayId = [NSString stringWithFormat:@"%@", screenNumber];
        if (screenIndex == index) {
            nativeDisplayId = displayId.intValue;
        }
        YXLOG(Info) << "[MacXHelpers] Got NSScreen:" << displayId << YXLOGEnd;
        index += 1;
    }

    return nativeDisplayId;
}

int MacXHelpers::getWindowId(WId wid) {
    NSView* nativeView = reinterpret_cast<NSView*>(wid);
    NSWindow* nativeWindow = nativeView.window;
    if (nativeWindow) {
        return nativeWindow.windowNumber;
    }

    return 0;
}

void MacXHelpers::hideTitleBar(QQuickWindow* window) {
    NSView* nativeView = reinterpret_cast<NSView*>(window->winId());
    NSWindow* nativeWindow = nativeView.window;

    //    // Default masks
    //    nativeWindow.styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;

    //    // Content under title bar
    //    nativeWindow.styleMask |= NSWindowStyleMaskFullSizeContentView;

    //    nativeWindow.titlebarAppearsTransparent = true;
    //    //nativeWindow.movableByWindowBackground = true;
    //    nativeWindow.titleVisibility = NSWindowTitleHidden; // Hide window title name

    //设置标题文字和图标为不可见
    nativeWindow.titleVisibility = NSWindowTitleHidden;  // MAC_10_10及以上版本支持
    //设置标题栏为透明
    nativeWindow.titlebarAppearsTransparent = true;  // MAC_10_10及以上版本支持
    //设置不可由标题栏拖动,避免与自定义拖动冲突
    [nativeWindow setMovable:NO];  // MAC_10_6及以上版本支持
    // nativeWindow.movableByWindowBackground = YES;
    //设置view扩展到标题栏
    nativeWindow.styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskBorderless;
    // NSWindowStyleMaskClosable |
    // NSWindowStyleMaskMiniaturizable |
    // NSWindowStyleMaskResizable;
    nativeWindow.styleMask |= NSWindowStyleMaskFullSizeContentView;  // MAC_10_10及以上版本支持
}

void MacXHelpers::setAppPolicy() {
    // The application is an ordinary app that appears in the Dock and may
    // have a user interface.
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    // The application does not appear in the Dock and does not have a menu
    // bar, but it may be activated programmatically or by clicking on one
    // of its windows.
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    // The application does not appear in the Dock and may not create
    // windows or be activated.
    [NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];
}

bool MacXHelpers::isWindow(uint32_t winId) const {
    CFArrayRef window_array = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow | kCGWindowListExcludeDesktopElements, CGWindowID(winId));
    if (window_array) {
        CFIndex count = CFArrayGetCount(window_array);
        for (CFIndex i = 0; i < count; ++i) {
            CFDictionaryRef window = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(window_array, i));
            if (!window) {
                continue;
            }

            CFNumberRef window_id = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowNumber));
            if (!window_id) {
                continue;
            }

            NSNumber* windowId = (__bridge NSNumber*)window_id;
            uint32_t idTmp = [windowId longValue];
            if (idTmp == winId) {
                return true;
            }
        }
        CFRelease(window_array);
    }

    return false;
}

bool MacXHelpers::isMinimized(uint32_t winId) const {
    CFArrayRef window_array = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow | kCGWindowListExcludeDesktopElements, CGWindowID(winId));
    if (window_array) {
        CFIndex count = CFArrayGetCount(window_array);
        for (CFIndex i = 0; i < count; ++i) {
            CFDictionaryRef window = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(window_array, i));
            if (!window) {
                continue;
            }

            CFBooleanRef on_screen = reinterpret_cast<CFBooleanRef>(CFDictionaryGetValue(window, kCGWindowIsOnscreen));
            if (on_screen == NULL) {
                return true;
            }

            return FALSE == CFBooleanGetValue(on_screen);
        }
    }
    CFRelease(window_array);
    return true;
}

QRectF MacXHelpers::getWindowRect(uint32_t winId) const {
    QRectF rect;
    CFArrayRef window_array = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow | kCGWindowListExcludeDesktopElements, CGWindowID(winId));
    if (window_array) {
        CFIndex count = CFArrayGetCount(window_array);
        for (CFIndex i = 0; i < count; ++i) {
            CFDictionaryRef window = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(window_array, i));
            if (!window) {
                continue;
            }

            CFDictionaryRef bounds = (CFDictionaryRef)(CFDictionaryGetValue(window, kCGWindowBounds));
            if (bounds) {
                CGRect rectTmp;
                CGRectMakeWithDictionaryRepresentation(bounds, &rectTmp);
                rect = QRectF::fromCGRect(rectTmp);
                break;
            }
        }
    }
    CFRelease(window_array);
    return rect;
}

QPixmap MacXHelpers::getCapture(uint32_t winId) const {
    QPixmap pixmap;
    CGImageRef screenshot = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow | kCGWindowListExcludeDesktopElements,
                                                    (CGWindowID)winId, kCGWindowImageBoundsIgnoreFraming);
    if (screenshot) {
        pixmap = QtMac::fromCGImageRef(screenshot);
        CGImageRelease(screenshot);
    }

    return pixmap;
}

bool MacXHelpers::getCaptureWindowList(MacXHelpers::CaptureTargetInfoList* windows) const {
    bool bRet = false;
    CFArrayRef window_array = CGWindowListCopyWindowInfo(kCGWindowListOptionAll | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    if (window_array) {
        CFIndex count = CFArrayGetCount(window_array);
        for (CFIndex i = 0; i < count; ++i) {
            CFDictionaryRef window = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(window_array, i));
            if (!window) {
                continue;
            }

            int windowPid = 0;
            CFNumberRef window_pid = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowOwnerPID));
            if (window_pid) {
                CFNumberGetValue(window_pid, kCFNumberIntType, &windowPid);
            } else {
                continue;
            }
            if (qApp->applicationPid() == windowPid) {
                continue;
            }

            // Skip windows with layer!=0 (menu, dock).
            CFNumberRef window_layer = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowLayer));
            if (!window_layer) {
                continue;
            }
            int layer = 1;
            if (!CFNumberGetValue(window_layer, kCFNumberIntType, &layer)) {
                continue;
            }
            if (0 != layer) {
                continue;
            }

            CFNumberRef window_id = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowNumber));
            if (!window_id) {
                continue;
            }
            NSNumber* windowId = (__bridge NSNumber*)window_id;
            uint32_t winId = [windowId longValue];
            CGImageRef screenshot = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow | kCGWindowListExcludeDesktopElements,
                                                            (CGWindowID)winId, kCGWindowImageBoundsIgnoreFraming);
            if (!screenshot) {
                continue;
            } else {
                if (QtMac::fromCGImageRef(screenshot).size().height() < 100) {
                    CGImageRelease(screenshot);
                    continue;
                }
            }
            CGImageRelease(screenshot);

            //            CFBooleanRef on_screen = reinterpret_cast<CFBooleanRef>(CFDictionaryGetValue(window, kCGWindowIsOnscreen));
            //            if (on_screen == NULL || !CFBooleanGetValue(on_screen))
            //            {
            //                continue;
            //            }

            CFStringRef window_owner_name = reinterpret_cast<CFStringRef>(CFDictionaryGetValue(window, kCGWindowOwnerName));
            NSString* windowOwnerName = (__bridge NSString*)window_owner_name;
            if (windowOwnerName == nil || windowOwnerName == NULL || [windowOwnerName isKindOfClass:[NSNull class]] ||
                ([[windowOwnerName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)) {
                continue;
            }

            CFStringRef window_title = reinterpret_cast<CFStringRef>(CFDictionaryGetValue(window, kCGWindowName));
            if (!window_title) {
                continue;
            }

            NSString* windowTitle = (__bridge NSString*)window_title;
            if (windowTitle == nil || windowTitle == NULL || [windowTitle isKindOfClass:[NSNull class]] ||
                ([[windowTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)) {
                // continue;
            }

            NSString* winTitle = [NSString stringWithFormat:@"%@-%d-%d-%@-%d", windowOwnerName, windowPid, layer, windowTitle, winId];
            // YXLOG(Info) << "windowOwnerName, windowPid, layer, windowTitle, winId: " << [winTitle UTF8String] << YXLOGEnd;

            CaptureTargetInfo info;
            info.id = [windowId longValue];
            info.pid = windowPid;
            info.title = [windowTitle UTF8String];
            if (info.title.empty()) {
                info.title = [windowOwnerName UTF8String];
            }

            windows->push_back(info);
        }

        bRet = true;
    }
    CFRelease(window_array);
    return bRet;
}

bool MacXHelpers::getWindowInfo(uint32_t winId, bool& isWindow, bool& isMinimized, QRectF& rect) const {
    isWindow = false;
    isMinimized = true;
    CFArrayRef window_array = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
    if (window_array) {
        CFIndex count = CFArrayGetCount(window_array);
        for (CFIndex i = 0; i < count; ++i) {
            CFDictionaryRef window = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(window_array, i));
            if (!window)
            {
                YXLOG(Info) << "!window" << YXLOGEnd;
                continue;
            }

            CFNumberRef window_id = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowNumber));
            if (!window_id)
            {
                YXLOG(Info) << "!window_id" << YXLOGEnd;
                continue;
            }

            NSNumber* windowId = (__bridge NSNumber*)window_id;
            uint32_t idTmp = [windowId longValue];
            //YXLOG(Info) <<"-----------: "<< idTmp <<" " << winId << "." << YXLOGEnd;

            if (idTmp == winId)
            {
                isWindow = true;
                //YXLOG(Info) << "isWindow = true." << YXLOGEnd;
            }
            else
            {
                continue;
            }

            CFBooleanRef on_screen = reinterpret_cast<CFBooleanRef>(CFDictionaryGetValue(window, kCGWindowIsOnscreen));
            if (on_screen) {
                isMinimized = (FALSE == CFBooleanGetValue(on_screen));
            } else {
                continue;
            }

            CFDictionaryRef bounds = reinterpret_cast<CFDictionaryRef>(CFDictionaryGetValue(window, kCGWindowBounds));
            if (bounds) {
                CGRect rectTmp;
                CGRectMakeWithDictionaryRepresentation(bounds, &rectTmp);
                rect = QRectF::fromCGRect(rectTmp);
            }
        }
        CFRelease(window_array);
        return true;
    }

    return false;
}

void MacXHelpers::setForegroundWindow(uint32_t winId) const {
    CFArrayRef window_array = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow | kCGWindowListExcludeDesktopElements, CGWindowID(winId));
    if (window_array) {
        CFIndex count = CFArrayGetCount(window_array);
        for (CFIndex i = 0; i < count; ++i) {
            CFDictionaryRef window = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(window_array, i));
            if (!window) {
                continue;
            }

            int windowPid = 0;
            CFNumberRef window_pid = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowOwnerPID));
            if (window_pid) {
                CFNumberGetValue(window_pid, kCFNumberIntType, &windowPid);
                NSRunningApplication* runningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:windowPid];
                if (runningApplication) {
                    [runningApplication activateWithOptions:NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps];
                    break;
                }
            }
        }
        CFRelease(window_array);
    }

    return;
}

void MacXHelpers::setForegroundWindow(int pId) const {
    NSRunningApplication* runningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:pId];
    if (runningApplication) {
        [runningApplication activateWithOptions:NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps];
    }
}

void MacXHelpers::sharedOutsideWindow(WId wid, uint32_t winId, bool bFullScreen) {
    NSView* nativeView = reinterpret_cast<NSView*>(wid);
    NSWindow* nativeWindow = nativeView.window;
    if (nativeWindow) {
        if (bFullScreen) {
            [nativeWindow setLevel:kCGScreenSaverWindowLevel];
        } else {
            [nativeWindow setLevel:NSNormalWindowLevel];
            [nativeWindow orderWindow:NSWindowAbove relativeTo:winId];
        }
    }
}

std::string MacXHelpers::getModuleName(uint32_t& winId) {
    std::string strApp;
    CFArrayRef window_array = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    if (window_array) {
        CFIndex count = CFArrayGetCount(window_array);
        for (CFIndex i = 0; i < count; ++i) {
            CFDictionaryRef window = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(window_array, i));
            if (!window) {
                continue;
            }

            CFNumberRef window_id = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowNumber));
            if (!window_id) {
                continue;
            }

            uint32_t windowid = 0;
            if (!CFNumberGetValue(window_id, kCFNumberIntType, &windowid)) {
                continue;
            }

            if (winId != windowid) {
                continue;
            }

            CFStringRef window_owner_name = reinterpret_cast<CFStringRef>(CFDictionaryGetValue(window, kCGWindowOwnerName));
            NSString* windowOwnerName = (__bridge NSString*)window_owner_name;
            strApp = [windowOwnerName UTF8String];
            break;
        }
    }
    CFRelease(window_array);
    return strApp;
}

bool MacXHelpers::isPptPlaying(uint32_t& winId, bool& bKeynote, const QScreen* pScreen) const
{
    bKeynote = false;
    bool bRet = false;
    CFArrayRef window_array = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    if (window_array) {
        CFIndex count = CFArrayGetCount(window_array);
        for (CFIndex i = 0; i < count; ++i) {
            CFDictionaryRef window = reinterpret_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(window_array, i));
            if (!window) {
                continue;
            }

            CFBooleanRef on_screen = reinterpret_cast<CFBooleanRef>(CFDictionaryGetValue(window, kCGWindowIsOnscreen));
            if (on_screen == NULL || !CFBooleanGetValue(on_screen)) {
                // continue;
            }

            CFNumberRef window_pid = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowOwnerPID));
            if (!window_pid) {
                continue;
            }

            int windowPid = 0;
            if (!CFNumberGetValue(window_pid, kCFNumberIntType, &windowPid)) {
                continue;
            }

            CFStringRef window_owner_name = reinterpret_cast<CFStringRef>(CFDictionaryGetValue(window, kCGWindowOwnerName));
            NSString* windowOwnerName = (__bridge NSString*)window_owner_name;
            std::string strAppTmp = [windowOwnerName UTF8String];
            std::string strApp;
            std::transform(strAppTmp.begin(), strAppTmp.end(), std::back_inserter(strApp), ::tolower);
            // YXLOG(Info) <<"strApp: "<< strApp <<", strAppTmp: " << strAppTmp << YXLOGEnd;
            if (0 != strApp.rfind("keynote", 0) && 0 != strApp.rfind("wps office", 0) && 0 != strApp.rfind("wpsoffice", 0))
            {
                continue;
            }

            CFNumberRef window_layer = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowLayer));
            if (!window_layer) {
                continue;
            }

            int layer;
            if (!CFNumberGetValue(window_layer, kCFNumberIntType, &layer)) {
                continue;
            }

            // YXLOG(Info) <<"strApp: "<< strApp <<", layer: " << layer << YXLOGEnd;
            bool bFind = false;
            if (0 == strApp.rfind("keynote", 0) && layer > 0)
            {
                CFDictionaryRef bounds = reinterpret_cast<CFDictionaryRef>(CFDictionaryGetValue(window, kCGWindowBounds));
                if (bounds)
                {
                    CGRect rectTmp;
                    CGRectMakeWithDictionaryRepresentation(bounds, &rectTmp);
                    QRectF rect = QRectF::fromCGRect(rectTmp);
                    QList<QScreen*> listScreen = qApp->screens();
                    for (auto& screen : listScreen)
                    {
//                        qInfo() << "availableVirtualGeometry: "<<pScreen->availableVirtualGeometry() << screen->availableVirtualGeometry();
//                        qInfo() << "virtualGeometry: "<<pScreen->virtualGeometry() << screen->virtualGeometry();
//                        qInfo() << "name: "<<pScreen->name() << screen->name();
//                        qInfo() << "geometry: "<<pScreen->geometry() << screen->geometry();
//                        qInfo() << "screen: "<<pScreen << screen;
                        if ((pScreen != nullptr ? pScreen == screen : 1) && screen->size() == rect.size().toSize())
                        {
                            bKeynote = true;
                            bFind = true;
                        }
                    }
                }
            }
            if (!bFind && (0 == strApp.rfind("wps office", 0) || 0 == strApp.rfind("wpsoffice", 0)) && 0 == layer)
            {
                CFDictionaryRef bounds = reinterpret_cast<CFDictionaryRef>(CFDictionaryGetValue(window, kCGWindowBounds));
                if (bounds) {
                    CGRect rectTmp;
                    CGRectMakeWithDictionaryRepresentation(bounds, &rectTmp);
                    QRectF rect = QRectF::fromCGRect(rectTmp);
                    QList<QScreen*> listScreen = qApp->screens();
                    for (auto& screen : listScreen) {
                        if (screen->size() == rect.size().toSize()) {
                            bFind = true;
                            break;
                        }
                    }
                }
            }
            if (!bFind) {
                continue;
            }

            CFNumberRef window_id = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(window, kCGWindowNumber));
            if (!window_id) {
                continue;
            }

            uint32_t windowid = 0;
            if (!CFNumberGetValue(window_id, kCFNumberIntType, &windowid)) {
                continue;
            }
            winId = windowid;
            // YXLOG(Info) <<"-----------: "<< windowid <<" " << strAppTmp << " " << layer << YXLOGEnd;
            bRet = true;
            break;
        }
    }
    CFRelease(window_array);
    return bRet;
}

int MacXHelpers::getDisplayIdByWinId(uint32_t winId) const {
    QRectF rect = getWindowRect(winId);
    NSScreen* currentScreent = [NSScreen mainScreen];
    QRectF mainScreen = QRectF::fromCGRect([currentScreent frame]);
    NSArray<NSScreen*>* screens = [NSScreen screens];
    for (NSScreen* screen in screens) {
        QPointF point = rect.center();
        point.setY(mainScreen.height() + (-point.y()));
        if (QRectF::fromCGRect([screen frame]).contains(point)) {
            currentScreent = screen;
            break;
        }
    }

    NSDictionary* deviceDescription = [currentScreent deviceDescription];
    id screenNumber = [deviceDescription objectForKey:@"NSScreenNumber"];
    NSString* displayId = [NSString stringWithFormat:@"%@", screenNumber];
    return displayId.intValue;
}

bool MacXHelpers::getDisplayRect(uint32_t winId, QRectF& rect, QRectF& availableRect) const {
    QRectF rt = getWindowRect(winId);
    QRectF mainScreen = QRectF::fromCGRect([[NSScreen mainScreen] frame]);
    NSArray<NSScreen*>* screens = [NSScreen screens];
    for (NSScreen* screen in screens) {
        QPointF point = rt.center();
        point.setY(mainScreen.height() + (-point.y()));
        if (QRectF::fromCGRect([screen frame]).contains(point)) {
            availableRect = QRectF::fromCGRect([screen visibleFrame]);
            int height = 0;
            int y = availableRect.y();
            if (y > 0 && availableRect.x() == 0) {
                height = availableRect.height();
                availableRect.setY(-height);
                availableRect.setHeight(height);
            }

            if (y < 0) {
                height = availableRect.height();
                availableRect.setY(mainScreen.height() + y + height);
                availableRect.setHeight(height);
            }

            rect = QRectF::fromCGRect([screen frame]);
            y = rect.y();
            if (y > 0 && rect.x() == 0) {
                height = rect.height();
                rect.setY(-height);
                rect.setHeight(height);
            }

            if (y < 0) {
                height = rect.height();
                rect.setY(mainScreen.height() + y + height);
                rect.setHeight(height);
            }
            return true;
        }
    }

    return false;
}
