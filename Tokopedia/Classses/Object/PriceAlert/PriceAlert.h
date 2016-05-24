//
//  PriceAlert.h
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriceAlertResult.h"

@interface PriceAlert : NSObject
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) PriceAlertResult *result;
@property (nonatomic, strong) PriceAlertResult *data;

+ (RKObjectMapping*)mapping;

@end
