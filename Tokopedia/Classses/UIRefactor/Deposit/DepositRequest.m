//
//  DepositRequest.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DepositRequest.h"
#import "DepositSummary.h"
#import "TokopediaNetworkManager.h"

@interface DepositRequest()

@end

@implementation DepositRequest {
    TokopediaNetworkManager *getDepositSummaryRequest;
}

- (id)init {
    self = [super init];
    
    if (self) {
        getDepositSummaryRequest = [TokopediaNetworkManager new];
    }
    
    return self;
}

#pragma mark - Public Functions
- (void)requestGetDepositSummaryWithStartDate:(NSString *)startDate
                                      endDate:(NSString *)endDate
                                         page:(NSInteger)page
                                      perPage:(NSInteger)perPage
                                    onSuccess:(void (^)(DepositSummaryResult *))successCallback
                                    onFailure:(void (^)(NSError *))errorCallback {
    getDepositSummaryRequest.isParameterNotEncrypted = NO;
    getDepositSummaryRequest.isUsingHmac = YES;
    
    [getDepositSummaryRequest requestWithBaseUrl:[NSString v4Url]
                                            path:@"/v4/deposit/get_summary.pl"
                                          method:RKRequestMethodGET
                                       parameter:@{@"start_date" : startDate,
                                                   @"end_date"   : endDate,
                                                   @"page"       : @(page),
                                                   @"per_page"   : @(perPage)}
                                         mapping:[DepositSummary mapping]
                                       onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                           NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                           DepositSummary *obj = [result objectForKey:@""];
                                           successCallback(obj.data);
                                       }
                                       onFailure:^(NSError *errorResult) {
                                           errorCallback(errorResult);
                                       }];
}



@end
