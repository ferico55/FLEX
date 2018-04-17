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

- (NSDictionary *)constantsToExport
{
    return @{ @"HomeSectionHeader": @(1),
              @"HomeSectionRecommendation": @(2)
              };
}

- (NSArray<NSString *> *)supportedEvents {
  return @[
    @"HotlistScrollToTop", @"didLogin", @"didLogout", @"didWishlistProduct",
    @"didRemoveWishlistProduct", @"changeLayoutCell", @"navBarButtonTapped",
    @"popNavigation", @"shouldRefresh", @"RedirectToHomeTab",
    @"DidTapFavoriteShopButton", @"DidEditProfile", @"didTapAturOnTopChat", @"didTapInfoOnGroupChat", @"didTapShareOnGroupChat", @"homeTabScrollToRecommendation", @"didReceiveGroupChatNotification"
  ];
}

- (void)sendScrollToTopEvent {
    [self sendEventWithName:@"HotlistScrollToTop" body:nil];
}

- (void)sendLoginEvent: (NSDictionary*) userId {
    [self sendEventWithName:@"didLogin" body:userId];
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

- (void)popNavigation {
    [self sendEventWithName:@"popNavigation" body:nil];
}

- (void)sendRedirectHomeTabEvent {
    [self sendEventWithName:@"RedirectToHomeTab" body:nil];
}

- (void)sendFavoriteShopEvent {
    [self sendEventWithName:@"DidTapFavoriteShopButton" body:nil];
}

- (void)sendProfileEditedEvent {
    [self sendEventWithName:@"DidEditProfile" body:nil];
}

- (void)didTapAturOnTopChat {
    [self sendEventWithName:@"didTapAturOnTopChat" body:nil];
}

- (void)didTapInfoOnGroupChat {
    [self sendEventWithName:@"didTapInfoOnGroupChat" body:nil];
}

- (void)didTapShareOnGroupChat:(NSInteger)shareTag {
    [self sendEventWithName:@"didTapShareOnGroupChat" body:@(shareTag)];
}

- (void) shouldScrollToSection: (HomeSection) section {
    [self sendEventWithName:@"homeTabScrollToRecommendation" body: @(section)];
}

- (void)sendNotificationToGroupChat:(NSDictionary*) notificationData {
    [self sendEventWithName:@"didReceiveGroupChatNotification" body:notificationData];
}

@end
    
