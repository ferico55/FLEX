//
//  GenerateHostRequest.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenerateHostResult.h"

@interface GenerateHostRequest : NSObject

- (void)requestGenerateHostWithNewAdd:(NSString*)newAdd
                            onSuccess:(void(^)(GenerateHostResult* result))successCallback
                            onFailure:(void(^)(NSError* errorResult))errorCallback;

@end
