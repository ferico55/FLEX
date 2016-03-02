//
//  ShopBadgeLevel.h
//  Tokopedia
//
//  Created by Tokopedia on 8/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#define CLevel @"level"
#define CSet @"set"

#import <Foundation/Foundation.h>

@interface ShopBadgeLevel : NSObject <TKPObjectMapping>
@property (nonatomic, strong) NSString *level;
@property (nonatomic, strong) NSString *set;
@end
