/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "macxhelper.h"
#import <AppKit/AppKit.h>

NSURL* mount(const QString &file)
{
    QByteArray mountpath =  file.toUtf8();
    NSTask       * task;
    NSPipe       * pipe;
    NSData       * data;
    NSDictionary * plist;
    NSArray      * entities;
    NSDictionary * entity;
    NSString     * path;
    NSURL        * url;
    NSString     * nspath = @(mountpath.data());

    pipe                = [NSPipe pipe ];
    task                = [NSTask new ];
    task.launchPath     = @"/usr/bin/hdiutil";
    task.arguments      = @[@"attach", @"-plist", @"-nobrowse", nspath];
    task.standardOutput = pipe;

    [ task launch ];
    [ task waitUntilExit ];

    if (task.terminationStatus != 0)
    {
        // [ self displayErrorWithMessage:@"Error mounting the DMG file."];
        return nil;
    }

    data = [pipe.fileHandleForReading readDataToEndOfFile ];
    url  = nil;

    if (data)
    {
        plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL ];
        if ([plist isKindOfClass:[NSDictionary class]])
        {
            entities = plist[@"system-entities"];
            if ([entities isKindOfClass:[NSArray class]])
            {
                for (entity in entities)
                {
                    if ([entity isKindOfClass:[NSDictionary class]] == NO)
                    {
                        continue;
                    }

                    path = entity[@"mount-point"];
                    if ([path isKindOfClass:[ NSString class]])
                    {
                        url = [NSURL fileURLWithPath:path];
                        break;
                    }
                }
            }
        }
    }

    if (url == nil)
    {
        // [ self displayErrorWithMessage: NSLocalizedString( @"Error mounting the DMG file.", @"" ) ];
        return nil;
    }

    return url;
}

void unmount(NSURL * url)
{
    NSTask    * detach;
    NSString  * nspath = url.path;

    detach            = [NSTask new];
    detach.launchPath = @"/usr/bin/hdiutil";
    detach.arguments  = @[@"detach", nspath];

    @try
    {
        [detach launch];
        [detach waitUntilExit];
    }
    @catch( NSException * e )
    {
        (void)e;
    }
}

void startupApp()
{
    if (1)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Relauncher" ofType:@""];

        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {

            [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath] options:NSWorkspaceLaunchAsync|NSWorkspaceLaunchNewInstance configuration: @{} error: NULL ];
            return ;
        }

        NSString *bundlePath = [NSBundle mainBundle ].bundlePath;

        NSTask   *task = [NSTask new];
        task.launchPath = path;
        task.arguments  = @[bundlePath];

        @try
        {
            [task launch];
        }
        @catch( NSException * e )
        {
            ( void )e;
        }

        if (NO == [[NSRunningApplication currentApplication] terminate]) {
            [[NSRunningApplication currentApplication] forceTerminate];
        }
    }
}

NSURL* findAppInDirectory(NSURL* directory)
{
    NSURL    * url;
    NSBundle * bundle;
    NSString * bundleID;
    NSString * version;

    for (url in [[NSFileManager defaultManager] contentsOfDirectoryAtURL: directory includingPropertiesForKeys: nil options: NSDirectoryEnumerationSkipsSubdirectoryDescendants error:NULL])
    {
        if ([url.pathExtension isEqualToString:@"app"] == NO)
        {
            continue;
        }

        bundle = [NSBundle bundleWithURL:url];

        if (bundle == nil)
        {
            continue;
        }

        bundleID = [ bundle objectForInfoDictionaryKey: @"CFBundleIdentifier" ];
        version  = [ bundle objectForInfoDictionaryKey: @"CFBundleShortVersionString" ];

        if (bundleID == nil || version == nil)
        {
            continue;
        }

        if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] isEqualToString:bundleID] == NO)
        {
            continue;
        }

        return url;
    }

    return nil;
}

NSURL* replacemeetingfile(NSURL* app)
{
    NSError * error;
    NSURL   * trashURL;
    BOOL      replaced;

    if ([[NSFileManager defaultManager] trashItemAtURL:[NSBundle mainBundle].bundleURL resultingItemURL:&trashURL error:&error] == NO)
    {
        //[ self displayErrorWithMessage:@"Cannot move the original application to the trash."];
        return nil;
    }


    if ([[NSFileManager defaultManager] isWritableFileAtPath:app.path])
    {
        replaced = [[NSFileManager defaultManager] moveItemAtURL:app toURL:[NSBundle mainBundle].bundleURL error: &error];
    }
    else
    {
        replaced = [[NSFileManager defaultManager] copyItemAtURL:app toURL:[NSBundle mainBundle].bundleURL error: &error];
    }

    if (replaced == NO )
    {
        if ([[NSFileManager defaultManager] moveItemAtURL:trashURL toURL:[NSBundle mainBundle].bundleURL error: &error] == NO)
        {
            // [self displayErrorWithMessage:@"Cannot move the new application. Original application is in your Trash"];
        }
        else
        {
            //[self displayErrorWithMessage:@"Cannot move the new application."];
        }

        return nil;
    }
    //NSLog(@"liangpeng -------------1: %@", [NSBundle mainBundle].bundlePath);
    //NSLog(@"liangpeng -------------2: %@", [NSBundle mainBundle].bundleURL);
    return [NSBundle mainBundle].bundleURL;
}

void removeQuarantine(NSURL* app)
{
    NSTask * task;
    task            = [ NSTask new ];
    task.launchPath = @"/usr/bin/xattr";
    task.arguments  = @[ @"-d", @"-r", @"com.apple.quarantine", app.path];

    @try
    {
        [ task launch ];
        [ task waitUntilExit ];
    }
    @catch( NSException * e )
    {
        ( void )e;
    }
}

Macxhelper::Macxhelper(const QString& dmgFile, QObject* parent)
    : QObject(parent)
    , m_strDmgFile(dmgFile)
{
}

void  Macxhelper::installFromDMG()
{
    //0.挂载dmg文件
    NSURL* mounturl = mount(m_strDmgFile);

    //1.遍历挂载目录 找到meeting文件
    NSURL* appURL = findAppInDirectory(mounturl);

    //2.替换符合要求的文件
    NSURL* newapp = replacemeetingfile(appURL);

    //3.修改属性
    removeQuarantine(newapp);

    //4.取消挂载
    unmount(mounturl);

    //5.启动新程序
    //startupApp();

    emit installFinished();
}
