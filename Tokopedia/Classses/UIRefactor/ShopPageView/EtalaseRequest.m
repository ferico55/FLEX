//
//  EtalaseRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 4/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EtalaseRequest.h"

@implementation EtalaseRequest{
    TokopediaNetworkManager* etalaseNetworkManager;
    TokopediaNetworkManager* myEtalaseNetworkManager;
    TokopediaNetworkManager* addNetworkManager;
    TokopediaNetworkManager* editNetworkManager;
    TokopediaNetworkManager* deleteNetworkManager;
}

-(void)requestEtalaseFilterWithShopId:(NSString *)shopId page:(NSInteger)page onSuccess:(void (^)(Etalase *etalase))successCallback onFailure:(void (^)(NSError *error))errorCallback{
    etalaseNetworkManager = [TokopediaNetworkManager new];
    etalaseNetworkManager.isUsingHmac = YES;
    [etalaseNetworkManager requestWithBaseUrl:[NSString v4Url]
                                         path:@"/v4/shop/get_shop_etalase.pl"
                                       method:RKRequestMethodGET
                                    parameter:@{@"shop_id"    : shopId,
                                                @"page"       : @(page)}
                                      mapping:[Etalase mapping]
                                    onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                        Etalase *etalase = [successResult.dictionary objectForKey:@""];
                                        successCallback(etalase);
                                    }onFailure:^(NSError *errorResult) {
                                        errorCallback(errorResult);
                                    }];
}

-(void)requestMyShopEtalaseWithShopId:(NSString *)shopId page:(NSInteger)page onSuccess:(void (^)(Etalase *etalase))successCallback onFailure:(void (^)(NSError *error))errorCallback{
    myEtalaseNetworkManager = [TokopediaNetworkManager new];
    myEtalaseNetworkManager.isUsingHmac = YES;
    [myEtalaseNetworkManager requestWithBaseUrl:[NSString v4Url]
                                           path:@"/v4/myshop-etalase/get_shop_etalase.pl"
                                         method:RKRequestMethodGET
                                      parameter:@{@"shop_id"    : shopId,
                                                  @"page"       : @(page)}
                                        mapping:[Etalase mapping]
                                      onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                          Etalase *etalase = [successResult.dictionary objectForKey:@""];
                                          successCallback(etalase);
                                      }onFailure:^(NSError *errorResult) {
                                          errorCallback(errorResult);
                                      }];
}

-(void)requestActionAddEtalaseWithName:(NSString *)name userId:(NSString *)userId onSuccess:(void (^)(ShopSettings *shopSettings))successCallback onFailure:(void (^)(NSError *))errorCallback{
    addNetworkManager = [TokopediaNetworkManager new];
    addNetworkManager.isUsingHmac = YES;
    [addNetworkManager requestWithBaseUrl:[NSString v4Url]
                                     path:@"/v4/action/myshop-etalase/event_shop_add_etalase.pl"
                                   method:RKRequestMethodGET
                                parameter:@{@"etalase_name":name,
                                            @"user_id":userId
                                            }
                                  mapping:[ShopSettings mapping]
                                onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                    ShopSettings *shopSettings = [successResult.dictionary objectForKey:@""];
                                    successCallback(shopSettings);
                                } onFailure:^(NSError *errorResult) {
                                    errorCallback(errorResult);
                                }];
}

-(void)requestActionEditEtalaseWithId:(NSString *)etalaseId name:(NSString *)name userId:(NSString *)userId onSuccess:(void (^)(ShopSettings *shopSettings, NSString* name))successCallback onFailure:(void (^)(NSError *))errorCallback{
    editNetworkManager = [TokopediaNetworkManager new];
    editNetworkManager.isUsingHmac = YES;
    [editNetworkManager requestWithBaseUrl:[NSString v4Url]
                                      path:@"/v4/action/myshop-etalase/event_shop_edit_etalase.pl"
                                    method:RKRequestMethodGET
                                 parameter:@{@"etalase_id":etalaseId,
                                             @"etalase_name":name,
                                             @"user_id":userId}
                                   mapping:[ShopSettings mapping]
                                 onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                     ShopSettings *shopSettings = [successResult.dictionary objectForKey:@""];
                                     successCallback(shopSettings, name);
                                 } onFailure:^(NSError *errorResult) {
                                     errorCallback(errorResult);
                                 }];
}

-(NSString *)splitUriToPage:(NSString *)uri{
    if(!etalaseNetworkManager){
        etalaseNetworkManager = [TokopediaNetworkManager new];
        etalaseNetworkManager.isUsingHmac = YES;
    }
    return [etalaseNetworkManager splitUriToPage:uri];
}

-(void)cancelAllRequest{
    if(etalaseNetworkManager) [etalaseNetworkManager requestCancel];
    if(myEtalaseNetworkManager) [myEtalaseNetworkManager requestCancel];
}



@end
