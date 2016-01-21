//
//  FavoriteShopRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 1/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoritedShopCell.h"
#import "FavoritedShop.h"
#import "FavoriteShopResult.h"
#import "FavoriteShopAction.h"

#import "string_home.h"
#import "search.h"
#import "detail.h"

#import "SearchAWS.h"
#import "SearchAWSResult.h"
#import "SearchAWSProduct.h"

@protocol FavoriteShopRequestDelegate <NSObject>
- (void) didReceiveFavoriteShopListing:(FavoritedShopResult*)favoriteShops;
- (void) didReceiveActionButtonFavoriteShopConfirmation:(FavoriteShopAction*)action;
- (void) didReceiveProductFeed:(NSArray<SearchAWSProduct*>*)products;
@end

@interface FavoriteShopRequest : NSObject
-(void)requestFavoriteShopListingsWithPage:(NSInteger)page;
-(void)requestActionButtonFavoriteShop:(NSString*)shopId withAdKey:(NSString*)adKey;
-(void)requestProductFeedWithFavoriteShopList:(FavoriteShopResult*)favoriteShopResult;

@property (weak, nonatomic) id<FavoriteShopRequestDelegate> delegate;
@end
