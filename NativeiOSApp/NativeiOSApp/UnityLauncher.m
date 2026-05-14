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
- (void)unloadApplication;
- (void)setDataBundleId:(const char *)bundleId;
- (void)setExecuteHeader:(void *)header;
- (void)registerFrameworkListener:(id<UnityFrameworkListener>)listener;
- (void)unregisterFrameworkListener:(id<UnityFrameworkListener>)obj;
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
            selector:@selector(hideUnityAndShowNative)
            name:@"HideUnityNotification"
            object:nil];
        
        
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(killUnityAndShowNative)
            name:@"KillUnityNotification"
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


- (void)hideUnityAndShowNative {
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
            name:@"HideUnityNotification"
            object:nil];
        
        
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(killUnityAndShowNative)
            name:@"KillUnityNotification"
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

@end

#endif
