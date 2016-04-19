//
//  ShopSettings.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopSettingsResult.h"

@interface ShopSettings : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) ShopSettingsResult *result;

+ (RKObjectMapping *)objectMapping;

@end
