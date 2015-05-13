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
#import "InboxTalkViewController.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "InboxReviewViewController.h"
#import "TKPDTabInboxReviewNavigationController.h"
#import "SalesNewOrderViewController.h"

#import "NotificationState.h"

@implementation RedirectHandler

- (id)init {
    self = [super init];
    
    if(self != nil) {
        
    }
    
    return self;
}

- (void)proxyRequest:(int)state{
    if(state == STATE_NEW_MESSAGE) {
        [self redirectToMessage];
    } else if(state == STATE_NEW_TALK) {
        [self redirectToTalk];
    } else if(state == STATE_NEW_REVIEW) {
        [self redirectToReview];
    } else if(state == STATE_NEW_ORDER) {
        [self redirectToNewOrder];
    }
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
    UINavigationController *nav = (UINavigationController*)_delegate;
    _navigationController = (UINavigationController*)_delegate;
    
    InboxTalkViewController *vc = [InboxTalkViewController new];
    vc.data=@{@"nav":@"inbox-talk"};
    
    InboxTalkViewController *vc1 = [InboxTalkViewController new];
    vc1.data=@{@"nav":@"inbox-talk-my-product"};
    
    InboxTalkViewController *vc2 = [InboxTalkViewController new];
    vc2.data=@{@"nav":@"inbox-talk-following"};
    
    NSArray *vcs = @[vc,vc1, vc2];
    
    TKPDTabInboxTalkNavigationController *nc = [TKPDTabInboxTalkNavigationController new];
    [nc setSelectedIndex:2];
    [nc setViewControllers:vcs];
    [nav.navigationController pushViewController:nc animated:YES];
}

- (void)redirectToReview {
    UINavigationController *nav = (UINavigationController*)_delegate;
    _navigationController = (UINavigationController*)_delegate;
    
    InboxReviewViewController *vc = [InboxReviewViewController new];
    vc.data=@{@"nav":@"inbox-review"};
    
    InboxReviewViewController *vc1 = [InboxReviewViewController new];
    vc1.data=@{@"nav":@"inbox-review-my-product"};
    
    InboxReviewViewController *vc2 = [InboxReviewViewController new];
    vc2.data=@{@"nav":@"inbox-review-my-review"};
    
    NSArray *vcs = @[vc,vc1, vc2];
    
    TKPDTabInboxReviewNavigationController *nc = [TKPDTabInboxReviewNavigationController new];
    [nc setSelectedIndex:2];
    [nc setViewControllers:vcs];
    nc.hidesBottomBarWhenPushed = YES;
    [nav.navigationController pushViewController:nc animated:YES];
}

- (void)redirectToNewOrder {
    UINavigationController *nav = (UINavigationController*)_delegate;
    _navigationController = (UINavigationController*)_delegate;
    
    SalesNewOrderViewController *controller = [[SalesNewOrderViewController alloc] init];
    if ([_navigationController conformsToProtocol:@protocol(NewOrderDelegate)]) {
        controller.delegate = (id <NewOrderDelegate>)_navigationController;
    }
    controller.hidesBottomBarWhenPushed = YES;
    
    [nav.navigationController pushViewController:controller animated:YES];
    
}

@end
