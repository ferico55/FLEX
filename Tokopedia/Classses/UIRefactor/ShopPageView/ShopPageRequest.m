//
//  ShopPageRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopPageRequest.h"
#import "TokopediaNetworkManager.h"

@implementation ShopPageRequest{
    TokopediaNetworkManager* _productNetworkManager;
    TokopediaNetworkManager* _talkNetworkManager;
    TokopediaNetworkManager* _reviewNetworkManager;
    TokopediaNetworkManager* _notesNetworkManager;
}

-(void)requestForShopProductPageListingWithShopId:(NSString *)shopId onSuccess:(void (^)(NSArray<ShopProductPageResult *> *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _productNetworkManager.isUsingHmac = YES;
    [_productNetworkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                          path:@"/v4/shop/get_shop_product.pl"
                                        method:RKRequestMethodGET
                                     parameter:@{@"shop_id":shopId
                                                 }
                                       mapping:[ShopProductPageResponse mapping]
                                     onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                         ShopProductPageResponse* result = [successResult.dictionary objectForKey:@""];
                                         successCallback(result.data);
                                     } onFailure:^(NSError *errorResult) {
                                         errorCallback(errorResult);
                                     }];
}

@end
