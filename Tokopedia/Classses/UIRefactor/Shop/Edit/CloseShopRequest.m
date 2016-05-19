//
//  CloseShopRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 5/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CloseShopRequest.h"
#import "TokopediaNetworkManager.h"

#define CLOSE_SHOP_ACTION_OPEN 1
#define CLOSE_SHOP_ACTION_CLOSE 2
#define CLOSE_SHOP_ACTION_SET_SCHEDULE 3
#define CLOSE_SHOP_ACTION_ABORT_SCHEDULE 4
#define CLOSE_SHOP_ACTION_EXTEND_SCHEDULE 5

@implementation CloseShopRequest{
    TokopediaNetworkManager* _networkManager;
}

-(void)requestActionCloseShopFromNowUntil:(NSString *)dateUntil closeNote:(NSString *)closeNote onSuccess:(void (^)(CloseShopResponse *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    [_networkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/action/myshop-info/update_shop_close.pl"
                                 method:RKRequestMethodGET
                              parameter:@{@"closed_note":closeNote,
                                          @"close_end":dateUntil,
                                          @"close_action":@(CLOSE_SHOP_ACTION_CLOSE)
                                          }
                                mapping:[CloseShopResponse mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  CloseShopResponse *result = [successResult.dictionary objectForKey:@""];
                                  successCallback(result);
                              } onFailure:^(NSError *errorResult) {
                                  errorCallback(errorResult);
                              }];
}

-(void)requestActionOpenShopWithUserId:(NSString *)shopId onSuccess:(void (^)(CloseShopResponse *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    [_networkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/action/myshop-info/update_shop_close.pl"
                                 method:RKRequestMethodGET
                              parameter:@{@"close_action":@(CLOSE_SHOP_ACTION_OPEN)
                                          }
                                mapping:[CloseShopResponse mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  CloseShopResponse *result = [successResult.dictionary objectForKey:@""];
                                  successCallback(result);
                              } onFailure:^(NSError *errorResult) {
                                  errorCallback(errorResult);
                              }];
}


@end

