//
//  RequestTrack.m
//  Tokopedia
//
//  Created by Renny Runiawati on 4/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestTrack.h"

@implementation RequestTrack

+(void)fetchTrackResoAWB:(NSString*)AWB
                shipmentID:(NSString*)shipmentID
                  success:(void(^)(TrackOrderResult* data))success
                   failed:(void(^)(NSError * error))failed {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    NSDictionary* param = @{
                            @"shipment_id":shipmentID,
                            @"shipping_ref": AWB
                            };
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-resolution-center/track_shipping_ref.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[Track mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 Track *response = [successResult.dictionary objectForKey:@""];
                                 if(response.message_error || response.data == nil)
                                 {
                                     NSArray *messages = response.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                                     [StickyAlertView showErrorMessage:messages];
                                     failed(nil);
                                 } else{
                                     success(response.data);
                                 }
                             } onFailure:^(NSError *errorResult) {
                                 failed(errorResult);
                             }];
}

+(void)fetchTrackOrderID:(NSString*)orderID
                 success:(void(^)(TrackOrderResult* data))success
                  failed:(void(^)(NSError * error))failed {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    NSDictionary* param = @{
                            @"order_id":orderID,
                            };
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tracking-order/track_order.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[Track mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 Track *response = [successResult.dictionary objectForKey:@""];
                                 if(response.message_error || response.data == nil)
                                 {
                                     NSArray *messages = response.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                                     [StickyAlertView showErrorMessage:messages];
                                     failed(nil);
                                 } else{
                                     success(response.data);
                                 }
                             } onFailure:^(NSError *errorResult) {
                                 failed(errorResult);
                             }];
}

@end
