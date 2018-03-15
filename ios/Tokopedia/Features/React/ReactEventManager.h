//
//  ReactTabManager.h
//  Tokopedia
//
//  Created by Samuel Edwin on 5/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface ReactEventManager : RCTEventEmitter<RCTBridgeModule>

- (void)sendScrollToTopEvent;
- (void)sendLoginEvent:(NSDictionary*)userId;
- (void)sendLogoutEvent;
- (void)didWishlistProduct:(NSString*)productId;
- (void)didRemoveWishlistProduct:(NSString*)productId;
- (void)changeLayoutCell:(NSInteger)cellType;
- (void)navBarButtonTapped:(id)index;
- (void)popNavigation;
- (void)sendRefreshEvent;
- (void)sendRedirectHomeTabEvent;
- (void)sendFavoriteShopEvent;
- (void)sendProfileEditedEvent;

@end
