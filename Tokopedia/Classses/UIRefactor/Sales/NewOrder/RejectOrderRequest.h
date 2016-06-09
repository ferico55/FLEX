//
//  RejectOrderRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RejectOrderResponse.h"

@interface RejectOrderRequest : NSObject
-(void)requestForOrderRejectionReasonOnSuccess:(void (^)(NSArray*))successCallback
                                   onFailure:(void (^)(NSError *))errorCallback;
@end
