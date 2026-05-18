#import <Foundation/Foundation.h>

extern "C" {

    void SendMessageToNative(const char* message) {
        NSString *msg = message
        ? [NSString stringWithUTF8String:message]
        : @"";

        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];

        NSError *error = nil;

        id jsonObject =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:0
                                              error:&error];

        if (error || ![jsonObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Invalid JSON message");
            return;
        }

        NSDictionary *dict = (NSDictionary *)jsonObject;

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"UnityMessageNotification"
                object:nil
                userInfo:dict];
        });
    }

}