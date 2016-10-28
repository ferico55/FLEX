//
//  FavoriteShopRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 1/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "FavoriteShopRequest.h"
#import "TokopediaNetworkManager.h"
#import "V4Response.h"

#define PER_PAGE 12

@implementation FavoriteShopRequest{
    TokopediaNetworkManager *networkManager;
    TokopediaNetworkManager *productFeedNetworkManager;
    FavoritedShopResult* favShops;
    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_productFeedObjectManager;
}

- (id)init{
    self = [super init];
    if(self){
        networkManager = [TokopediaNetworkManager new];
        productFeedNetworkManager = [TokopediaNetworkManager new];
    }
    return self;
}

#pragma mark Public Function
-(void)requestFavoriteShopListings{
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/home/get_list_fave_shop_id.pl"
                                method:RKRequestMethodGET
                             parameter:@{@"action":@"get_favorite_shop"}
                               mapping:[SimpleFavoritedShop mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                 id temp = [result objectForKey:@""];
                                 NSArray* favoriteShops = ((SimpleFavoritedShop*)temp).data.shop_id_list;
                                 [_delegate didReceiveAllFavoriteShopString:[self generateShopStringFromArray:favoriteShops]];
                             }
                             onFailure:^(NSError *errorResult) {
                                 [_delegate failToRequestAllFavoriteShopString];
                             }];
}

-(void)requestFavoriteShopListingsWithPage:(NSInteger)page{
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/home/get_favorite_shop.pl"
                                method:RKRequestMethodGET
                             parameter:@{@"action":@"get_favorite_shop",
                                         @"per_page":@(PER_PAGE),
                                         @"page":@(page)}
                               mapping:[FavoritedShop mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                 id temp = [result objectForKey:@""];
                                 [_delegate didReceiveFavoriteShopListing:((FavoritedShop*)temp).data];
                             }
                             onFailure:^(NSError *errorResult) {
                                 [_delegate failToRequestFavoriteShopListing];
                             }];
}

+(void)requestActionButtonFavoriteShop:(NSString*)shopId withAdKey:(NSString*)adKey onSuccess:(void(^)(FavoriteShopActionResult* data))onSuccess onFailure:(void(^)())onFailure{
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithDictionary:@{@"shop_id":shopId}];
    
    if (adKey && ![adKey isEqualToString:@""]){
        [parameter addEntriesFromDictionary: @{@"ad_key":adKey}];
    }
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/favorite-shop/fav_shop.pl"
                                method:RKRequestMethodPOST
                             parameter:parameter
                               mapping:[V4Response mappingWithData:[FavoriteShopActionResult mapping]]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                 V4Response<FavoriteShopActionResult *>* response = [result objectForKey:@""];
                                 
                                 if ([response.data.is_success integerValue] == 1) {
                                     onSuccess(response.data);
                                 } else {
                                    onFailure();
                                 }
                             }
                             onFailure:^(NSError *errorResult) {
                                 onFailure();
                             }];
}

-(void)requestProductFeedWithFavoriteShopString:(NSString*)favoriteShopString withPage:(NSInteger)page{
    networkManager.isUsingHmac = NO;
    productFeedNetworkManager.isParameterNotEncrypted = YES;
    UserAuthentificationManager *userAuth = [UserAuthentificationManager new];
    
    [productFeedNetworkManager requestWithBaseUrl:[NSString aceUrl]
                                             path:@"/search/v2.3/product"
                                           method:RKRequestMethodGET
                                        parameter:@{@"device":@"ios",
                                                    @"rows":@(PER_PAGE),
                                                    @"start":@((page*PER_PAGE)),
                                                    @"shop_id":favoriteShopString,
                                                    @"ob":@(10),
                                                    @"user_id":[userAuth getUserId],
                                                    @"source":@"feed"}
                                          mapping:[SearchAWS mapping]
                                        onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                            NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                            id temp = [result objectForKey:@""];
                                            [_delegate didReceiveProductFeed:(SearchAWS*)temp];
                                        }
                                        onFailure:^(NSError *errorResult) {
                                            [_delegate failToRequestProductFeed];
                                        }];
}

-(void)cancelAllOperation{
    [_objectmanager.operationQueue cancelAllOperations];
    [_productFeedObjectManager.operationQueue cancelAllOperations];
}

#pragma mark Utils Method

//return string with format: shop_id_0, shop_id_1, shop_id_2, dst
-(NSMutableString*) generateShopString{
    NSMutableString* result = [NSMutableString string];
    if(favShops.list.count){
        for (FavoritedShopList* shop in favShops.list) {
            [result appendFormat:@"%@,",shop.shop_id];
        }
        [result deleteCharactersInRange:NSMakeRange([result length]-1, 1)];
    }
    return result;
}

-(NSString*) generateShopStringFromArray:(NSArray*)favoriteShops{
    NSMutableString* result = [NSMutableString string];
    if(favoriteShops.count){
        for (NSString* shopId in favoriteShops) {
            [result appendFormat:@"%@,",shopId];
        }
        [result deleteCharactersInRange:NSMakeRange([result length]-1, 1)];
    }
    return result;
}

@end
