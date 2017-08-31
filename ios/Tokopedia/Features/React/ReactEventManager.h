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
- (void)sendLoginEvent;
- (void)sendLogoutEvent;
- (void)didWishlistProduct:(NSString*)productId;
- (void)didRemoveWishlistProduct:(NSString*)productId;
- (void)navBarButtonTapped:(id)index;

@end
