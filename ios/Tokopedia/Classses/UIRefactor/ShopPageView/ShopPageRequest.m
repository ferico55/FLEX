//
//  ShopPageRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopPageRequest.h"
#import "TokopediaNetworkManager.h"
#import "Tokopedia-Swift.h"

#define PRODUCT_PER_PAGE 12
#define REVIEW_PER_PAGE 5
#define TALK_PER_PAGE 5

@implementation ShopPageRequest{
    TokopediaNetworkManager* _containerNetworkManager;
    TokopediaNetworkManager* _productNetworkManager;
    TokopediaNetworkManager* _talkNetworkManager;
    TokopediaNetworkManager* _reviewNetworkManager;
    TokopediaNetworkManager* _notesNetworkManager;
}

-(void)requestForShopPageContainerWithShopId:(NSString *)shopId shopDomain:(NSString *)shopDomain onSuccess:(void (^)(Shop *shop))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _containerNetworkManager = [TokopediaNetworkManager new];
    _containerNetworkManager.isUsingHmac = YES;
    
    [_containerNetworkManager requestWithBaseUrl:[NSString v4Url]
                                            path:@"/v4/shop/get_shop_info.pl"
                                          method:RKRequestMethodGET
                                       parameter:@{@"shop_id":shopId,
                                                   @"shop_domain":shopDomain?:@""
                                                   }
                                         mapping:[Shop mapping]
                                       onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                           Shop *shop = [successResult.dictionary objectForKey:@""];
                                           successCallback(shop);
                                       }
                                       onFailure:^(NSError *errorResult) {
                                           errorCallback(errorResult);
                                       }];
     
}

-(void)requestForShopProductPageListingWithShopId:(NSString *)shopId etalaseId:(NSString *)etalaseId keyWord:(NSString*)keyWord page:(NSInteger)page order_by:(NSString *)orderBy shop_domain:(NSString *)shopDomain onSuccess:(void (^)(ShopProductPageResult *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _productNetworkManager = [TokopediaNetworkManager new]; //yg ini keknya ga pernah dimasukkin
    _productNetworkManager.isUsingHmac = YES;
    [_productNetworkManager requestWithBaseUrl:[NSString v4Url]
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

-(void)requestForShopTalkPageListingWithShopId:(NSString *)shopId page:(NSInteger)page shop_domain:(NSString *)shopDomain onSuccess:(void (^)(Talk *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _talkNetworkManager = [TokopediaNetworkManager new];
    _talkNetworkManager.isUsingHmac = YES;
    [_talkNetworkManager requestWithBaseUrl:[NSString kunyitUrl]
                                       path:@"/talk/v2/read"
                                     method:RKRequestMethodGET
                                  parameter:@{@"page"           : @(page),
                                              @"per_page"       : @(TALK_PER_PAGE),
                                              @"shop_domain"    : shopDomain,
                                              @"shop_id"        : shopId,
                                              @"type"           : @"s"
                                              }
                                    mapping:[Talk mapping_v4]
                                  onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                      Talk *talk = [successResult.dictionary objectForKey:@""];
                                      successCallback(talk);
                                  }
                                  onFailure:^(NSError *errorResult) {
                                      errorCallback(errorResult);
                                  }];
     
}

-(void)requestForShopReviewPageListingWithShopId:(NSString *)shopId page:(NSInteger)page shop_domain:(NSString *)shopDomain onSuccess:(void (^)(Review *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _reviewNetworkManager = [TokopediaNetworkManager new];
    _reviewNetworkManager.isUsingHmac = YES;
    [_reviewNetworkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/shop/get_shop_review.pl"
                                     method:RKRequestMethodGET
                                  parameter:@{@"page"           : @(page),
                                              @"per_page"       : @(REVIEW_PER_PAGE),
                                              @"shop_domain"    : shopDomain,
                                              @"shop_id"        : shopId
                                              }
                                    mapping:[Review mapping_v4]
                                  onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                      Review *review = [successResult.dictionary objectForKey:@""];
                                      successCallback(review);
                                  }
                                  onFailure:^(NSError *errorResult) {
                                      errorCallback(errorResult);
                                  }];
}

-(void)requestForShopNotesPageListingWithShopId:(NSString *)shopId shop_domain:(NSString *)shopDomain onSuccess:(void (^)(Notes *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _notesNetworkManager = [TokopediaNetworkManager new];
    _notesNetworkManager.isUsingHmac = YES;
    [_notesNetworkManager requestWithBaseUrl:[NSString v4Url]
                                        path:@"/v4/shop/get_shop_notes.pl"
                                      method:RKRequestMethodGET
                                   parameter:@{@"shop_id":shopId,
                                               @"shop_domain":shopDomain
                                               }
                                     mapping:[Notes mapping]
                                   onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                       Notes *notes = [successResult.dictionary objectForKey:@""];
                                       successCallback(notes);
                                   } onFailure:^(NSError *errorResult) {
                                       errorCallback(errorResult);
                                   }];
}

-(NSString*)splitUriToPage:(NSString *)uri{
    if(!_productNetworkManager){
        _productNetworkManager = [TokopediaNetworkManager new];
        _productNetworkManager.isUsingHmac = YES;
    }
    return [_productNetworkManager splitUriToPage:uri];
}

@end
