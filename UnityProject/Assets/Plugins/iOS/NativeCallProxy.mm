#import <Foundation/Foundation.h>

extern "C" {
    void CloseUnityView() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"CloseUnityNotification"
                object:nil];
        });
    }
}