//
//  RedirectHandler.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RedirectHandler.h"

#import "InboxMessageViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"

#import "NotificationState.h"

@implementation RedirectHandler

- (void)proxyRequest:(int)state{
    if(state == STATE_NEW_MESSAGE) {
        
    }
    
    [self redirectToMessage];
}

- (void)redirectToMessage {
    UINavigationController *nav = (UINavigationController*)_delegate;
    
    InboxMessageViewController *vc = [InboxMessageViewController new];
    vc.data=@{@"nav":@"inbox-message"};
    
    InboxMessageViewController *vc1 = [InboxMessageViewController new];
    vc1.data=@{@"nav":@"inbox-message-sent"};
    
    InboxMessageViewController *vc2 = [InboxMessageViewController new];
    vc2.data=@{@"nav":@"inbox-message-archive"};
    
    InboxMessageViewController *vc3 = [InboxMessageViewController new];
    vc3.data=@{@"nav":@"inbox-message-trash"};
    NSArray *vcs = @[vc,vc1, vc2, vc3];
    
    TKPDTabInboxMessageNavigationController *inboxController = [TKPDTabInboxMessageNavigationController new];
    [inboxController setSelectedIndex:2];
    [inboxController setViewControllers:vcs];
    
    [nav.navigationController pushViewController:inboxController animated:YES];
}

- (void)redirectToTalk {
    
}

- (void)redirectToReview {
    
}

- (void)redirectToNewOrder {
    
}

@end
