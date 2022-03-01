// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NTESLinkStreamHandler.h"

@interface NTESLinkStreamHandler ()

@property (nonatomic,strong)FlutterEventSink  eventSink;

@property (nonatomic,strong) NSMutableArray * queuedLinks;

@end

@implementation NTESLinkStreamHandler

- (BOOL)handleLink:(NSString *)link {
    if (!self.eventSink) {
        [self.queuedLinks addObject:link];
        return NO;
    }
    
    self.eventSink(link);
    return YES;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError *)onListenWithArguments:(id)arguments
                              eventSink:(FlutterEventSink)events {
    
    self.eventSink = events;
    for (NSString * link in self.queuedLinks) {
        events(link);
    }
    return nil;
}

- (NSMutableArray *)queuedLinks {
    if (!_queuedLinks) {
        _queuedLinks = [NSMutableArray array];
    }
    return _queuedLinks;
}

@end
