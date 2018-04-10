//
//  ReactTopChatManager.m
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 13/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactTopChatManager.h"
#import "Tokopedia-Swift.h"
#import <React/RCTConvert.h>

@implementation ReactTopChatManager

RCT_EXPORT_MODULE(ChatManager);

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(showChatTemplateTips) {
    ChatTemplateTipsActionSheet *chatTemplateTipsActionSheet = [ChatTemplateTipsActionSheet new];
    [chatTemplateTipsActionSheet show];
}

RCT_EXPORT_METHOD(toGroupChatDetail) {
    UIViewController *topViewController = [UIApplication topViewController];
    UIViewController *viewController =  [[GroupChatDetailViewController alloc] init];
    [topViewController.navigationController pushViewController:viewController animated:YES];
}

RCT_EXPORT_METHOD(setGroupChatNavbar:(NSDictionary*) props){
    NSDictionary *passData = [[NSMutableDictionary alloc] init];
    
    if([props objectForKey:@"imageUrl"]){
        NSString *imageUrl = [RCTConvert NSString:props[@"imageUrl"]];
        [passData setValue:imageUrl forKey:@"imageUrl"];
    }
    
    if([props objectForKey:@"titleBar"]){
        NSString *titleBar = [RCTConvert NSString:props[@"titleBar"]];
        [passData setValue:titleBar forKey:@"titleBar"];
    }
    
    if([props objectForKey:@"totalParticipant"]){
        NSString *totalParticipant = [RCTConvert NSString:props[@"totalParticipant"]];
        [passData setValue:totalParticipant forKey:@"totalParticipant"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_GROUPCHAT_NAVBAR" object:nil userInfo:passData];
}

RCT_EXPORT_METHOD(setTabBar:(NSDictionary*) props){
    NSDictionary *passData = [[NSMutableDictionary alloc] init];
    
    if([props objectForKey:@"hideTabBar"]){
        [passData setValue:props[@"hideTabBar"] forKey:@"hideTabBar"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_CHAT_TAB" object:nil userInfo:passData];
}
@end
