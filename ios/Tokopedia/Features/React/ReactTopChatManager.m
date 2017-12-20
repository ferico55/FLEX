//
//  ReactTopChatManager.m
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 13/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactTopChatManager.h"
#import "Tokopedia-Swift.h"

@implementation ReactTopChatManager

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(showChatTemplateTips) {
    ChatTemplateTipsActionSheet *chatTemplateTipsActionSheet = [ChatTemplateTipsActionSheet new];
    [chatTemplateTipsActionSheet show];
}

@end
