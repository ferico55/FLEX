//
//  Quality.m
//  Tokopedia
//
//  Created by Tokopedia on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "Quality.h"

@implementation Quality
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Quality class]];
    [mapping addAttributeMappingsFromArray:@[@"rating_star",
                                             @"average",
                                             @"one_star_rank",
                                             @"count_total",
                                             @"four_star_rank",
                                             @"five_star_rank",
                                             @"two_star_rank",
                                             @"three_star_rank"]];
    return mapping;
}
@end
