//
//  PriceAlertRequest.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "PriceAlertRequest.h"
#import "TokopediaNetworkManager.h"
#import "PriceAlert.h"

@implementation PriceAlertRequest {
    TokopediaNetworkManager *getPriceAlertNetworkManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        getPriceAlertNetworkManager = [TokopediaNetworkManager new];
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)requestGetPriceAlertWithDepartmentID:(NSString *)departmentID
                                        page:(NSInteger)page
                                   onSuccess:(void (^)(PriceAlertResult *))successCallback
                                   onFailure:(void (^)(NSError *))errorCallback {
    getPriceAlertNetworkManager.isParameterNotEncrypted = NO;
    getPriceAlertNetworkManager.isUsingHmac = YES;
    
    [getPriceAlertNetworkManager requestWithBaseUrl:[NSString v4Url]
                                               path:@"/v4/inbox-price-alert/get_price_alert.pl"
                                             method:RKRequestMethodGET
                                          parameter:@{@"department_id" : departmentID,
                                                      @"page" : @(page)}
                                            mapping:[PriceAlert mapping]
                                          onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                              NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                              PriceAlert *obj = [result objectForKey:@""];
                                              successCallback(obj.data);
                                          }
                                          onFailure:^(NSError *errorResult) {
                                              errorCallback(errorResult);
                                          }];
}

@end
