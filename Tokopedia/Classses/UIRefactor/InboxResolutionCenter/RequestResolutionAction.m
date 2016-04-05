//
//  RequestResolutionAction.m
//  Tokopedia
//
//  Created by Renny Runiawati on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestResolutionAction.h"
#import "StickyAlertView+NetworkErrorHandler.h"

@implementation RequestResolutionAction

+(void)fetchCancelResolutionID:(NSString*)resolutionID
                           success:(void(^) (ResolutionActionResult* data))success
                           failure:(void(^)(NSError* error))failure {
    
    NSDictionary* param = @{
                            @"resolution_id" : resolutionID?:@""
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/cancel_resolution.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success == 1) {
                                     [StickyAlertView showSuccessMessage:response.message_status?:@[@"Anda telah berhasil membatalkan komplain."]];
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membatalkan resolusi"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

@end
