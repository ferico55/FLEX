//
//  DepositRequest.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DepositSummaryResult.h"

@interface DepositRequest : NSObject

- (void)requestGetDepositSummaryWithStartDate:(NSString*)startDate
                                      endDate:(NSString*)endDate
                                         page:(NSInteger)page
                                      perPage:(NSInteger)perPage
                                    onSuccess:(void(^)(DepositSummaryResult *data))successCallback
                                    onFailure:(void(^)(NSError *errorResult))errorCallback;

@end
