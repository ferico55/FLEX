//
//  RequestCancelResolution.m
//  Tokopedia
//
//  Created by IT Tkpd on 5/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestCancelResolution.h"
#import "string_inbox_resolution_center.h"
#import "InboxResolutionCenter.h"
#import "ResolutionAction.h"
#import "TokopediaNetworkManager.h"

@interface RequestCancelResolution()

@end

@implementation RequestCancelResolution

#pragma mark - Request

+(void)fetchCancelComplainID:(NSString*)complainID
                      detail:(InboxResolutionCenterList*)resolution
                     success:(void (^)(InboxResolutionCenterList *resolution))success
                     failure:(void (^)(NSError *error))failure {
    
    NSDictionary* param = @{@"action"           : @"cancel_resolution",
                            @"resolution_id"    : complainID?:@""
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"action/resolution-center.pl" method:RKRequestMethodPOST parameter:param mapping:[ResolutionAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        ResolutionAction *response = [successResult.dictionary objectForKey:@""];
        if (response.result.is_success == 1) {
            success(resolution);
//            StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:response.result.message_status?:@[@"Anda telah berhasil membatalkan komplain"] delegate:self];
//            [alert show];

        } else{
            failure(nil);
        }
        
    } onFailure:^(NSError *errorResult) {
        failure(errorResult);
    }];
    
}

@end
