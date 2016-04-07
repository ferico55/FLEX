//
//  CountRatingResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CountRatingResult.h"

@implementation CountRatingResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[CountRatingResult class]];
    [mapping addAttributeMappingsFromArray:@[@"count_score_good", @"count_score_bad", @"count_score_neutral"]];
    return mapping;
}
@end
