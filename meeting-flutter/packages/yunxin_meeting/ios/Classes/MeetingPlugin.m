#import "MeetingPlugin.h"
#import "FLTImageUtil.h"

@implementation MeetingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"meeting_plugin"
                                     binaryMessenger:[registrar messenger]];
    MeetingPlugin* instance = [[MeetingPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    //获取模块id
    id modelName = nil;
    NSDictionary *arguments = call.arguments;
    modelName = arguments[@"module"];
    //模块校验
    if (!modelName || ![modelName isKindOfClass:[NSString class]]) {
        result(@(-1001));
        return;
    }
    //转发
    NSLog(@"[iOS] Call Model:%@ Menthod:%@ argument:%@", modelName, call.method, call.arguments);
    if ([modelName isEqualToString:@"NEAssetService"]&&[call.method isEqualToString:@"loadCustomServer"]) {
        NSDictionary *nimServerDic = [self dictionaryFromFile:@"nim_server"];
        NSString *meetingStr;
        if (nimServerDic) {
            NSDictionary *meetingDic = [nimServerDic objectForKey:@"meeting"];
            NSError *parseError;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:meetingDic options:NSJSONWritingPrettyPrinted error:&parseError];
            if (!parseError) {
                meetingStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }else {
                NSLog(@"parseError:%@",parseError);
            }
        }
        NSLog(@"[iOS] customServerUrl:%@",meetingStr);
        result(meetingStr);
    } else if ([modelName isEqualToString:@"ImageLoader"] && [call.method isEqualToString:@"loadImage"]) {
        NSString* name = [arguments objectForKey:@"key"];
        //NSNumber* maxWidth = [arguments objectForKey:@"maxWidth"];
        //NSNumber* maxHeight = [arguments objectForKey:@"maxHeight"];
        //NSNumber* imageQuality = [arguments objectForKey:@"imageQuality"];
        
        //        for (int screenScale = [UIScreen mainScreen].scale; screenScale > 1; --screenScale) {
        //            NSString* key = [FlutterDartProject
        //                lookupKeyForAsset:[NSString stringWithFormat:@"%@/%d.0x/%@", @"", 1, @""]];
        //            UIImage* image = [UIImage imageNamed:@""
        //                                        inBundle:[NSBundle mainBundle]
        //                   compatibleWithTraitCollection:nil];
        //            if (image) {
        //              return image;
        //            }
        //          }
        
        UIImage* image = [UIImage imageNamed:name];
        if (!image) {
            result(nil);
            return;
        }
        
        NSLog(@"[iOS] loadImage:%@x%@@%@", @(image.size.width), @(image.size.height), @(image.scale));
        
        //image = [FLTImageUtil scaledImage:image maxWidth:maxWidth maxHeight:maxHeight];
        NSData* data = UIImagePNGRepresentation(image);
        if (data) {
            NSLog(@"[iOS] loadImage: len=%@", @(data.length));
            result(@{
                @"scale" : @(image.scale),
                @"data" : [FlutterStandardTypedData typedDataWithBytes:data],
                   });
        } else {
            result(nil);
        }
        return;
    } else {
        result(FlutterMethodNotImplemented);
    }
}


- (NSDictionary *)dictionaryFromFile:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"conf"];
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || isDir) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data
                                             options:0
                                               error:&error];
    
    if (!obj || error || ![obj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return obj;
}

@end
