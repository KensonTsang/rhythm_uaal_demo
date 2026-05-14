#import <Foundation/Foundation.h>

extern "C" {

    void HideUnityView() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"HideUnityNotification"
                object:nil];
        });
    }


    void KillUnityView() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"KillUnityNotification"
                object:nil];
        });
    }

}