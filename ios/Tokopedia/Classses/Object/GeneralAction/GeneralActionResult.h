//
//  GeneralActionResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LuckyDeal.h"

#define CFeedBackID @"feedback_id"

@interface GeneralActionResult : NSObject

@property (nonatomic, strong) NSString *feedback_id;
@property (nonatomic, strong) NSString *is_success;
@property (strong, nonatomic) LuckyDeal *ld;

+ (RKObjectMapping*)mapping;
+(RKObjectMapping*)generalMapping;

@end
