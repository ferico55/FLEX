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

#import "NavigateViewController.h"


@implementation RedirectHandler
{
    NavigateViewController *_navigate;
}

-(NavigateViewController*)navigate
{
    if (!_navigate) {
        _navigate = [NavigateViewController new];
    }
    
    return _navigate;
}

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
    } else if(state == STATE_NEW_REPSYS || state == STATE_NEW_REVIEW || state == STATE_EDIT_REPSYS || state == STATE_EDIT_REVIEW || state == STATE_REPLY_REVIEW) {
        [self redirectToReview];
    } else if(state == STATE_NEW_ORDER) {
        [self redirectToNewOrder];
    }
}

- (void)redirectToMessage {
    _navigationController = (UINavigationController*)_delegate;
    [[self navigate]navigateToInboxMessageFromViewController:_navigationController];
}

- (void)redirectToTalk {
    _navigationController = (UINavigationController*)_delegate;
    [[self navigate]navigateToInboxTalkFromViewController:_navigationController];
}

- (void)redirectToReview {
    _navigationController = (UINavigationController*)_delegate;
    [[self navigate]navigateToInboxReviewFromViewController:_navigationController];
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
