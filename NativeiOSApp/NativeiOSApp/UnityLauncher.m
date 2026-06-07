//
//  UnityLauncher.m
//  NativeiOSApp
//
//  Created by Kenson Tsang on 11/05/2026.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NativeiOSApp-Swift.h"

#if !TARGET_OS_SIMULATOR

#include <crt_externs.h>

@protocol UnityFrameworkListener @end

@interface UnityFramework : NSObject
+ (UnityFramework *)getInstance;
- (id)appController;
- (void)runEmbeddedWithArgc:(int)argc argv:(char * _Nullable * _Nullable)argv appLaunchOpts:(NSDictionary *)launchOpts;
- (void)showUnityWindow;
- (void)pause:(int)pause;
- (void)unloadApplication;
- (void)setDataBundleId:(const char *)bundleId;
- (void)setExecuteHeader:(void *)header;
- (void)registerFrameworkListener:(id<UnityFrameworkListener>)listener;
- (void)unregisterFrameworkListener:(id<UnityFrameworkListener>)obj;
- (void)sendMessageToGOWithName:(const char *)goName functionName:(const char *)name message:(const char *)msg;
@end

@interface UnityAppController : UIResponder
@property (nonatomic, readonly) UIViewController *rootViewController;
@end

@interface UnityLauncher : NSObject <UnityFrameworkListener>
+ (instancetype)shared;
- (void)launchUnityIfNeeded;
- (void)showUnity;
- (void)hideUnityAndShowNative;
- (void)killUnityAndShowNative;
- (void)requestJsonFromNative:(NSString *)messageId
                      message:(NSString *)message;
- (void)changeContentViewTextMessage:(NSString *)message;
- (void)handleUnityMessage:(NSNotification *)notification;
- (UIViewController *)unityRootViewController;
@end

static UnityFramework *_ufw = nil;
static BOOL _needsRelaunch = NO;

@implementation UnityLauncher

+ (instancetype)shared {
    static UnityLauncher *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [UnityLauncher new];
    });
    return instance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(handleUnityMessage:)
            name:@"UnityMessageNotification"
            object:nil];
        
        
    }
    return self;
}

- (UnityFramework *)loadUnityFramework {
    if (_ufw) return _ufw;

    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *ufwPath = [bundlePath stringByAppendingPathComponent:@"Frameworks/UnityFramework.framework"];
    NSBundle *ufwBundle = [NSBundle bundleWithPath:ufwPath];
    if (![ufwBundle isLoaded]) {
        [ufwBundle load];
    }

    Class ufwClass = [ufwBundle principalClass];
    if (!ufwClass) {
        NSLog(@"[UaaL] Failed to get UnityFramework principal class");
        return nil;
    }

    UnityFramework *ufw = [ufwClass performSelector:@selector(getInstance)];
    if ([ufw appController] && _ufw) {
        return _ufw;
    }

    [ufw setExecuteHeader:(void *)_NSGetMachExecuteHeader()];

    const char *mainBundleId = [[[NSBundle mainBundle] bundleIdentifier] UTF8String];
    [ufw setDataBundleId:mainBundleId];
    [ufw registerFrameworkListener:self];
    
    _ufw = ufw;
    return ufw;
}

- (void)launchUnityIfNeeded {
    NSLog(@"[UaaL] launchUnityIfNeeded called, _ufw = %@", _ufw);
    
    
    UnityFramework *ufw = [self loadUnityFramework];
    NSLog(@"[UaaL] loadUnityFramework returned: %@", ufw);
    
    if (!ufw) return;

    if (![ufw appController] || _needsRelaunch) {
        NSLog(@"[UaaL] running embedded...");
        _needsRelaunch = NO;
        NSArray<NSString *> *arguments = [NSProcessInfo processInfo].arguments;
        int argc = (int)arguments.count;
        char **argv = (char **)calloc((size_t)argc, sizeof(char *));
        for (int i = 0; i < argc; ++i) {
            const char *utf8 = [arguments[i] UTF8String];
            argv[i] = strdup(utf8 ? utf8 : "");
        }

        [ufw runEmbeddedWithArgc:argc argv:argv appLaunchOpts:@{}];
        NSLog(@"[UaaL] runEmbeddedWithArgc finished");
    }
    else {
        NSLog(@"[UaaL] appController exists, skipping runEmbedded");
    }

    NSLog(@"[UaaL] calling showUnityWindow");
    [ufw showUnityWindow];
}

- (void)showUnity {
    if (_ufw) {
        [_ufw pause:0];
        [_ufw showUnityWindow];
    } else {
        [self launchUnityIfNeeded];
    }
}


- (void)hideUnityAndShowNative{
    NSLog(@"hideUnityAndShowNative called");
    if (_ufw) {
        [_ufw pause:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"ShowNativeUINotification"
                object:nil];
        });
    }
}

- (void)killUnityAndShowNative{
    NSLog(@"killUnityAndShowNative called");
    if (_ufw) {
        _needsRelaunch = YES;
        [_ufw unloadApplication];
    }
}

- (void)changeContentViewTextMessage:(NSString *)message
{
    NSLog(@"changeContentViewTextMessage, text: %@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"ChangeUnityTextMessageNotification"
            object:nil
            userInfo:@{@"message":message}
        ];
    });
}


- (void)requestJsonFromNative:(NSString *)messageId
                      message:(NSString *)message;
{
    NSLog(@"requestJsonFromNative, text: %@", message);
    NSString *jsonData = [JsonLoader loadJsonNamed:message];
    if (!jsonData) return;

    NSData *jsonBytes = [jsonData dataUsingEncoding:NSUTF8StringEncoding];

    const NSUInteger kChunkSize = 256;

    NSUInteger totalBytes = jsonBytes.length;
    NSUInteger totalChunks = (totalBytes + kChunkSize - 1) / kChunkSize;

    for (NSUInteger chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++)
    {
        NSUInteger location = chunkIndex * kChunkSize;
        NSUInteger length = MIN(kChunkSize, totalBytes - location);

        NSData *chunkData =
            [jsonBytes subdataWithRange:NSMakeRange(location, length)];

        NSString *base64 =
            [chunkData base64EncodedStringWithOptions:0];

        NSString *msgJson =
            [JsonLoader buildMessageJsonWithId:messageId
                                   chunkIndex:chunkIndex
                                  totalChunks:totalChunks
                                         data:base64];

        [_ufw sendMessageToGOWithName:"NativeBridge"
                         functionName:"OnMessageReceived"
                              message:[msgJson UTF8String]];
    }
}


- (void)handleUnityMessage:(NSNotification *)notification
{
    NSDictionary *msg = notification.userInfo;
    
    NSString *type = msg[@"type"];
    NSString *payload = msg[@"payload"];
    
    if ([type isEqualToString:@"UpdateText"])
    {
        NSLog(@"Message received, Update text: %@", payload);
        [self changeContentViewTextMessage:payload];
    }
    else if ([type isEqualToString:@"HideUnity"])
    {
        NSLog(@"Message received, Hide Unity");
        [self hideUnityAndShowNative];
    }
    else if ([type isEqualToString:@"KillUnity"])
    {
        NSLog(@"Message received, Kill Unity");
        [self killUnityAndShowNative];
    }
    else if ([type isEqualToString:@"RequestJson"])
    {
        NSLog(@"Message received, RequestJson: %@", payload);
        [self requestJsonFromNative:type message:payload];
    }
}




- (UIViewController *)unityRootViewController {
    UnityAppController *controller = (UnityAppController *)[_ufw appController];
    return controller.rootViewController;
}

#pragma mark - UnityFrameworkListener

- (void)unityDidUnload:(NSNotification *)notification {
    NSLog(@"[UaaL] unityDidUnload called, setting _ufw to nil");
    [_ufw unregisterFrameworkListener:self];
    _ufw = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"ShowNativeUINotification"
            object:nil];
    });
}

@end



#else

@interface UnityLauncher : NSObject
+ (instancetype)shared;
- (void)launchUnityIfNeeded;
- (void)showUnity;
- (void)hideUnityAndShowNative;
- (void)killUnityAndShowNative;
- (void)handleUnityMessage:(NSNotification *)notification;
- (UIViewController *)unityRootViewController;
@end

@implementation UnityLauncher

+ (instancetype)shared {
    static UnityLauncher *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [UnityLauncher new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(handleUnityMessage:)
            name:@"UnityMessageNotification"
            object:nil];
    }
    return self;
}

- (void)launchUnityIfNeeded {
    NSLog(@"[UaaL] Unity is not available on the simulator");
}

- (void)showUnity {
    NSLog(@"[UaaL] Unity is not available on the simulator");
}

- (UIViewController *)unityRootViewController {
    return nil;
}

- (void)hideUnityAndShowNative {
    NSLog(@"[UaaL] Unity is not available on the simulator");
}

- (void)killUnityAndShowNative{
    NSLog(@"[UaaL] Unity is not available on the simulator");
}

- (void)handleUnityMessage:(NSNotification *)notification
{
    NSLog(@"[UaaL] Unity is not available on the simulator");
}

@end

#endif
