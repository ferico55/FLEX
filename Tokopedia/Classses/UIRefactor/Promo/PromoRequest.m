//
//  PromoRequest.m
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoRequest.h"
#import "TokopediaNetworkManager.h"
#import "string_promo.h"

typedef NS_ENUM(NSInteger, PromoRequestType) {
    PromoRequestTypeProductSearch,
    PromoRequestTypeProductHotlist,
    PromoRequestTypeProductFeed,
    PromoRequestTypeShopFeed,
};

@interface PromoRequest () {
    TokopediaNetworkManager *_networkManager;
    __weak RKObjectManager *_objectManager;
    
    TokopediaNetworkManager *_actionNetworkManager;
    __weak RKObjectManager *_actionObjectManager;
    
    PromoRequestType _requestType;
    
    NSString *_query;
    NSString *_departmentId;
    NSString *_key;
    
    NSString *_adKey;
    NSString *_adSemKey;
    NSString *_adR;
    NSInteger _source;
}

@end

@implementation PromoRequest

-(void)requestForFavoriteShop:(void (^)(NSArray<PromoResult*> *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    [_networkManager requestWithBaseUrl:[NSString topAdsUrl]
                                   path:@"/promo/v1/display/shops"
                                 method:RKRequestMethodGET
                              parameter:@{@"src":@"fav_shop",
                                          @"item":@"3",
                                          @"page":@"1"
                                          }
                                mapping:[PromoResponse mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  PromoResponse *response = [[successResult dictionary] objectForKey:@""];
                                  successCallback(response.data);
                              } onFailure:^(NSError *errorResult) {
                                  errorCallback(errorResult);
                              }];
}

-(void)requestForProductQuery:(NSString *)query
                   department:(NSString *)department
                         page:(NSInteger)page
                       source:(NSString*)source
              filterParameter:(NSDictionary *)filterParameter
                    onSuccess:(void (^)(NSArray<PromoResult*> *))successCallback
                    onFailure:(void (^)(NSError *))errorCallback
{
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
    [parameter setObject: @"4" forKey:@"item"];
    [parameter setObject: source forKey: @"src"];
    [parameter setObject: @(page) forKey:@"page"];
    [parameter setObject: department forKey: @"dep_id"];
    [parameter setObject: query forKey: @"q"];
    [parameter addEntriesFromDictionary:filterParameter];
    
    [_networkManager requestWithBaseUrl:[NSString topAdsUrl]
                                   path:@"/promo/v1.1/display/products"
                                 method:RKRequestMethodGET
                              parameter:parameter
                                mapping:[PromoResponse mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  PromoResponse *response = [[successResult dictionary] objectForKey:@""];
                                  successCallback(response.data);
                              } onFailure:^(NSError *errorResult) {
                                  errorCallback(errorResult);
                              }];
}

- (void)requestForProductHotlist:(NSString *)hotlistId
                      department:(NSString *)department
                            page:(NSInteger)page
                 filterParameter:(NSDictionary *)filterParameter
                       onSuccess:(void (^)(NSArray<PromoResult *> *))successCallback
                       onFailure:(void (^)(NSError *))errorCallback
{
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
    [parameter setObject: @"4" forKey:@"item"];
    [parameter setObject: @"hotlist" forKey: @"src"];
    [parameter setObject: @(page) forKey:@"page"];
    [parameter setObject: department forKey: @"dep_id"];
    [parameter setObject: hotlistId forKey: @"h"];
    [parameter addEntriesFromDictionary:filterParameter];
    
    //need to remove q for hotlist to get topads, request by gun
    [parameter removeObjectForKey:@"q"];
    
    [_networkManager requestWithBaseUrl:[NSString topAdsUrl]
                                   path:@"/promo/v1.1/display/products"
                                 method:RKRequestMethodGET
                              parameter:parameter
                                mapping:[PromoResponse mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  PromoResponse *response = [[successResult dictionary] objectForKey:@""];
                                  successCallback(response.data);
                              } onFailure:^(NSError *errorResult) {
                                  errorCallback(errorResult);
                              }];
}

-(void)requestForProductFeedWithPage:(NSInteger)page onSuccess:(void (^)(NSArray<PromoResult *> *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    
    [_networkManager requestWithBaseUrl:[NSString topAdsUrl]
                                   path:@"/promo/v1.1/display/products"
                                 method:RKRequestMethodGET
                              parameter:@{@"item": @"4",
                                          @"src":@"fav_product",
                                          @"page":@(page)
                                          }
                                mapping:[PromoResponse mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  PromoResponse *response = [[successResult dictionary] objectForKey:@""];
                                  successCallback(response.data);
                              } onFailure:^(NSError *errorResult) {
                                  errorCallback(errorResult);
                              }];
}

- (void)requestForClickURL:(NSString *)clickURL
                 onSuccess:(void (^)(void))successCallback
                 onFailure:(void (^)(NSError *))errorCallback{
    [NSURLConnection sendAsynchronousRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:clickURL]]
                                                              queue:[NSOperationQueue new]
                                                  completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable error) {
                                                      if ([data length] >0 && error == nil)
                                                      {
                                                          successCallback();
                                                      }
                                                      else if ([data length] == 0 && error == nil)
                                                      {
                                                          errorCallback(error);
                                                      }
                                                      else if (error != nil){
                                                          errorCallback(error);
                                                      }
                                                  }];
}

@end
