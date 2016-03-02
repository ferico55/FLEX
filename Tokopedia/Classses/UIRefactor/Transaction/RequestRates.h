//
//  RequestRates.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RateResponse.h"


@interface RequestRates : NSObject

+(void)doRequestWithNames:(NSArray *)names origin:(NSString*)origin destination:(NSString *)destination weight:(NSString*)weight onSuccess:(void(^)(RateData* rateData))success onFailure:(void(^)(NSError* errorResult)) error;

@end
