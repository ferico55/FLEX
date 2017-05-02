//
//  ShopInfo.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Quality.h"

#define CQuality @"quality"
#define CAccuracy @"accuracy"


@interface Rating : NSObject

@property (nonatomic, strong) NSString *product_rate_accuracy_point;
@property (nonatomic, strong) NSString *product_rating_point;
@property (nonatomic, strong) NSString *product_rating_star_point;
@property (nonatomic, strong) NSString *product_accuracy_star_rate;
@property (nonatomic, strong) Quality *quality;
@property (nonatomic, strong) Quality *accuracy;

+(RKObjectMapping*)mapping;
@end