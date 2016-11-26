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
#import "SimpleFavoritedShop.h"

@protocol FavoriteShopRequestDelegate <NSObject>
- (void) didReceiveFavoriteShopListing:(FavoritedShopResult*)favoriteShops;
- (void) didReceiveProductFeed:(SearchAWS*)feed;
- (void) didReceiveAllFavoriteShopString:(NSString*)favoriteShops;

- (void) failToRequestFavoriteShopListing;
- (void) failToRequestProductFeed;
- (void) failToRequestAllFavoriteShopString;

@end

@interface FavoriteShopRequest : NSObject
-(void)requestFavoriteShopListings;
-(void)requestFavoriteShopListingsWithPage:(NSInteger)page;
+(void)requestActionButtonFavoriteShop:(NSString*)shopId withAdKey:(NSString*)adKey onSuccess:(void(^)(FavoriteShopActionResult* data))onSuccess onFailure:(void(^)())onFailure;
-(void)requestProductFeedWithFavoriteShopString:(NSString*)favoriteShopString withPage:(NSInteger)p;
-(void)cancelAllOperation;

@property (weak, nonatomic) id<FavoriteShopRequestDelegate> delegate;
@end
