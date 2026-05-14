//
//  UnityLauncher.h
//  NativeiOSApp
//
//  Created by Kenson Tsang on 11/05/2026.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnityLauncher : NSObject
+ (instancetype)shared;
- (void)launchUnityIfNeeded;
- (void)showUnity;
- (void)hideUnityAndShowNative;
- (UIViewController *)unityRootViewController;
@end

NS_ASSUME_NONNULL_END
