//
//  AddShop.h
//  Tokopedia
//
//  Created by Tokopedia on 4/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddShopResult.h"

@interface AddShop : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) AddShopResult *result;

+ (RKObjectMapping *)mapping;

@end
