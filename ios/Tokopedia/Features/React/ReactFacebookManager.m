//
//  ReactFacebookManager
//  Tokopedia
//
//  Created by Ferico Samuel on 21/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactFacebookManager.h"

@implementation ReactFacebookManager{
    RCTResponseSenderBlock _callback;
}

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(shareToFacebook:(NSString*) message productID:(NSString*) productID url:(NSString*) url callback: (RCTResponseSenderBlock)callback) {
    _callback = callback;
    FBSDKShareLinkContent *fbShareContent = [FBSDKShareLinkContent new];
    fbShareContent.contentURL = [NSURL URLWithString:url];
    fbShareContent.quote = message;
    
    [FBSDKShareDialog showFromViewController: [UIApplication sharedApplication].keyWindow.rootViewController
                                 withContent:fbShareContent
                                    delegate:self];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    _callback(@[[NSNull null]]);
    _callback = nil;
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    _callback(@[[NSNull null]]);
    _callback = nil;
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    _callback(@[[NSNull null]]);
    _callback = nil;
}

@end
