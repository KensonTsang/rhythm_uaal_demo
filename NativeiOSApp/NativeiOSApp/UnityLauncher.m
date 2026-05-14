//
//  UnityLauncher.m
//  NativeiOSApp
//
//  Created by Kenson Tsang on 11/05/2026.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if !TARGET_OS_SIMULATOR

#include <crt_externs.h>

@protocol UnityFrameworkListener @end

@interface UnityFramework : NSObject
+ (UnityFramework *)getInstance;
- (id)appController;
- (void)runEmbeddedWithArgc:(int)argc argv:(char * _Nullable * _Nullable)argv appLaunchOpts:(NSDictionary *)launchOpts;
- (void)showUnityWindow;
- (void)pause:(int)pause;
- (void)setDataBundleId:(const char *)bundleId;
- (void)setExecuteHeader:(void *)header;
- (void)registerFrameworkListener:(id<UnityFrameworkListener>)listener;
@end

@interface UnityAppController : UIResponder
@property (nonatomic, readonly) UIViewController *rootViewController;
@end

@interface UnityLauncher : NSObject <UnityFrameworkListener>
+ (instancetype)shared;
- (void)launchUnityIfNeeded;
- (void)showUnity;
- (void)hideUnityAndShowNative;
- (UIViewController *)unityRootViewController;
@end

static UnityFramework *_ufw = nil;

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
            selector:@selector(hideUnityAndShowNative)
            name:@"CloseUnityNotification"
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
    UnityFramework *ufw = [self loadUnityFramework];
    if (!ufw) return;

    if (![ufw appController]) {
        NSArray<NSString *> *arguments = [NSProcessInfo processInfo].arguments;
        int argc = (int)arguments.count;
        char **argv = (char **)calloc((size_t)argc, sizeof(char *));
        for (int i = 0; i < argc; ++i) {
            const char *utf8 = [arguments[i] UTF8String];
            argv[i] = strdup(utf8 ? utf8 : "");
        }

        [ufw runEmbeddedWithArgc:argc argv:argv appLaunchOpts:@{}];
    }

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


- (void)hideUnityAndShowNative {
    if (_ufw) {
        [_ufw pause:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"ShowNativeUINotification"
                object:nil];
        });
    }
}



- (UIViewController *)unityRootViewController {
    UnityAppController *controller = (UnityAppController *)[_ufw appController];
    return controller.rootViewController;
}

#pragma mark - UnityFrameworkListener

- (void)unityDidUnload:(NSNotification *)notification {
    _ufw = nil;
}

@end

#else

@interface UnityLauncher : NSObject
+ (instancetype)shared;
- (void)launchUnityIfNeeded;
- (void)showUnity;
- (void)hideUnityAndShowNative;
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
            selector:@selector(hideUnityAndShowNative)
            name:@"CloseUnityNotification"
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

@end

#endif
