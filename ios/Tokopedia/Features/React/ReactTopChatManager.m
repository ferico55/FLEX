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

typedef NS_ENUM(NSUInteger, TPUrl) {
    TPUrlProduction,
    TPUrlStaging
};

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

RCT_EXPORT_METHOD(ensureLogin) {
    UIViewController *topViewController = [UIApplication topViewController];
    [AuthenticationService.shared ensureLoggedInFromViewController:topViewController onSuccess:nil];
}

RCT_EXPORT_METHOD(setGroupChatNavbar:(NSDictionary*) props){
    NSDictionary *passData = [[NSMutableDictionary alloc] init];
    
    if([props objectForKey:@"setNavbarTranslucent"]){
        BOOL status = [[props objectForKey:@"setNavbarTranslucent"] boolValue];
        [passData setValue:@(status) forKey:@"setNavbarTranslucent"];
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
    
    if([props objectForKey:@"setToAtur"]){
        BOOL status = [[props objectForKey:@"setToAtur"] boolValue];
        [passData setValue:@(status) forKey:@"setToAtur"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_CHAT_TAB" object:nil userInfo:passData];
}

-(NSString*)sendbirdKey {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* keys = @{
                           @(TPUrlProduction) : @"C32AC42B-B073-4F76-B662-CF33A68031EB",
                           @(TPUrlStaging) : @"55F9D875-9A57-4BB4-BA87-06DFB8842E99"
                           };
    
    return [keys objectForKey:TPUrlIndex];
}

- (NSDictionary*)constantsToExport {
    return @{
             @"sendbirdKey" : [self sendbirdKey],
             };
}

@end
