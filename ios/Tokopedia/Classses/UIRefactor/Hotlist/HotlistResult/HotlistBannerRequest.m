//
//  HotlistBanner.m
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HotlistBannerRequest.h"
#import "HotlistBanner.h"
#import "StickyAlertView.h"

@implementation HotlistBannerRequest

#pragma mark - Tokopedia Network Manager

+(void)fetchHotlistBannerWithQuery:(NSString*)query
                           onSuccess:(void(^)(HotlistBannerResult* data))success
                            onFailure:(void(^)(NSError * error))failure{
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    NSDictionary *parameter = @{@"key" : query?:@""};
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/hotlist/get_hotlist_banner.pl"
                                method:RKRequestMethodGET
                             parameter:parameter
                               mapping:[HotlistBanner mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 HotlistBanner *banner = [successResult.dictionary objectForKey:@""];
                                 
                                 if ( banner!= nil && banner.message_error.count == 0) {
                                     success(banner.data);
                                 } else{
                                     [StickyAlertView showErrorMessage:banner.message_error?:@[@"Gagal memuat hotlist"]];
                                     failure(nil);
                                 }
                                 
    } onFailure:^(NSError *errorResult) {
        
        failure(errorResult);
        
    }];
}

@end
