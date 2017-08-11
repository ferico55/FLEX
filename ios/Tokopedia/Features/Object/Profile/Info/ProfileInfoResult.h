//
//  ProfileInfoResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserInfo.h"
#import "ShopStats.h"
#import "ShopInfo.h"
#import "ResponseSpeed.h"

@interface ProfileInfoResult : NSObject

@property (nonatomic, strong) UserInfo *user_info;
@property (nonatomic, strong) ShopStats *shop_stats;
@property (nonatomic, strong) ShopInfo *shop_info;
@property (nonatomic, strong) ResponseSpeed *respond_speed;

+ (RKObjectMapping *)mapping;

@end
