//
//  JasonUtilAction.m
//  Tokopedia
//
//  Created by Tonito Acen on 2/20/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "JasonToolsAction.h"
#import "WebViewController.h"
#import "Tokopedia-Swift.h"

@implementation JasonToolsAction

- (void)seamless{
    dispatch_async(dispatch_get_main_queue(), ^{
        WebViewController* controller = [WebViewController new];
        UserAuthentificationManager* userManager = [UserAuthentificationManager new];
        NSString* url = self.options[@"url"];
        
        controller.strURL = [userManager webViewUrlFromUrl:url];
        controller.shouldAuthorizeRequest = YES;
        
        UIViewController* vc = [UIApplication topViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
        [vc.navigationController pushViewController:controller animated:YES];
    });
    
    [[Jason client] success];
}

@end
