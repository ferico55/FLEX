//
//  PriceAlertRequest.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriceAlertResult.h"

@interface PriceAlertRequest : NSObject

- (void)requestGetPriceAlertWithDepartmentID:(NSString*)departmentID
                                        page:(NSInteger)page
                                   onSuccess:(void(^)(PriceAlertResult *result))successCallback
                                   onFailure:(void(^)(NSError *error))errorCallback;

@end
