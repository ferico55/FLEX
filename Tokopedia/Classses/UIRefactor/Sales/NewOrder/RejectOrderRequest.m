//
//  RejectOrderRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectOrderRequest.h"
#import "TokopediaNetworkManager.h"

@implementation RejectOrderRequest{
    TokopediaNetworkManager *orderRejectionReasonNetworkManager;
}
-(void)requestForOrderRejectionReasonOnSuccess:(void (^)(NSArray *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    orderRejectionReasonNetworkManager = [TokopediaNetworkManager new];
    orderRejectionReasonNetworkManager.isUsingHmac = YES;
    orderRejectionReasonNetworkManager.isUsingDefaultError = NO;
    [orderRejectionReasonNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                      path:@"/v4/myshop-order/get_reject_order_reason.pl"
                                                    method:RKRequestMethodGET
                                                 parameter:@{}
                                                   mapping:[RejectOrderResponse mapping]
                                                 onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                     RejectOrderResponse *result = [successResult.dictionary objectForKey:@""];
                                                     successCallback(result.data.reason);
                                                 } onFailure:^(NSError *errorResult) {
                                                     errorCallback(errorResult);
                                                 }];
}
@end
