//
//  ReactTabManager.m
//  Tokopedia
//
//  Created by Samuel Edwin on 5/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactEventManager.h"

@implementation ReactEventManager

RCT_EXPORT_MODULE(EventManager)


- (NSArray<NSString *> *)supportedEvents {
    return @[@"HotlistScrollToTop", @"didLogin", @"didLogout", @"didWishlistProduct", @"didRemoveWishlistProduct", @"changeLayoutCell", @"navBarButtonTapped", @"shouldRefresh"];
}

- (void)sendScrollToTopEvent {
    [self sendEventWithName:@"HotlistScrollToTop" body:nil];
}

- (void)sendLoginEvent {
    [self sendEventWithName:@"didLogin" body:nil];
}

- (void)sendLogoutEvent {
    [self sendEventWithName:@"didLogout" body:nil];
}

- (void)didWishlistProduct:(NSString*)productId {
    [self sendEventWithName:@"didWishlistProduct" body:productId];
}

- (void)didRemoveWishlistProduct:(NSString*)productId {
    [self sendEventWithName:@"didRemoveWishlistProduct" body:productId];
}

- (void)changeLayoutCell:(NSInteger)cellType {
    [self sendEventWithName:@"changeLayoutCell" body:@(cellType)];
}

- (void)navBarButtonTapped:(id)index {
    [self sendEventWithName:@"navBarButtonTapped" body:index];
}

- (void)sendRefreshEvent {
    [self sendEventWithName:@"shouldRefresh" body:nil];
}

@end
