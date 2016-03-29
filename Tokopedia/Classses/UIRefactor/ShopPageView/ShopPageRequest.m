//
//  ShopPageRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopPageRequest.h"
#import "TokopediaNetworkManager.h"
#define PRODUCT_PER_PAGE 12
#define TALK_PER_PAGE 6

@implementation ShopPageRequest{
    TokopediaNetworkManager* _productNetworkManager;
    TokopediaNetworkManager* _talkNetworkManager;
    TokopediaNetworkManager* _reviewNetworkManager;
    TokopediaNetworkManager* _notesNetworkManager;
}

-(void)requestForShopProductPageListingWithShopId:(NSString *)shopId etalaseId:(NSString *)etalaseId keyWord:(NSString*)keyWord page:(NSInteger)page order_by:(NSString *)orderBy shop_domain:(NSString *)shopDomain onSuccess:(void (^)(ShopProductPageResult *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _productNetworkManager = [TokopediaNetworkManager new];
    _productNetworkManager.isUsingHmac = YES;
    [_productNetworkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                          path:@"/v4/shop/get_shop_product.pl"
                                        method:RKRequestMethodGET
                                     parameter:@{@"shop_id"     :shopId,
                                                 @"etalase_id"  :etalaseId,
                                                 @"keyword"     :keyWord,
                                                 @"page"        :@(page),
                                                 @"per_page"    :@(PRODUCT_PER_PAGE),
                                                 @"order_by"    :orderBy,
                                                 @"shop_domain" :shopDomain,
                                                 }
                                       mapping:[ShopProductPageResponse mapping]
                                     onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                         ShopProductPageResponse* result = [successResult.dictionary objectForKey:@""];
                                         successCallback(result.data);
                                     } onFailure:^(NSError *errorResult) {
                                         errorCallback(errorResult);
                                     }];
}

-(void)requestForShopTalkPageListingWithShopId:(NSString *)shopId page:(NSInteger)page shop_domain:(NSString *)shopDomain onSuccess:(void (^)(ShopProductPageResult *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    /*
    _talkNetworkManager = [TokopediaNetworkManager new];
    _talkNetworkManager.isUsingHmac = YES;
    [_talkNetworkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                       path:@"/v4/shop/get_shop_talk.pl"
                                     method:RKRequestMethodGET
                                  parameter:@{}
                                    mapping:<#(RKObjectMapping *)#>
                                  onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                      
                                  }
                                  onFailure:^(NSError *errorResult) {
                                      
                                  }];
     */
}

-(NSString*)splitUriToPage:(NSString *)uri{
    if(!_productNetworkManager){
        _productNetworkManager = [TokopediaNetworkManager new];
        _productNetworkManager.isUsingHmac = YES;
    }
    return [_productNetworkManager splitUriToPage:uri];
}

@end
