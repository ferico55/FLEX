//
//  DetailTotalLikeDislike.m
//  Tokopedia
//
//  Created by Tokopedia on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailTotalLikeDislike.h"

@implementation DetailTotalLikeDislike
+ (RKObjectMapping *)mapping{
    RKObjectMapping *detailTotalLikeMapping = [RKObjectMapping mappingForClass:[DetailTotalLikeDislike class]];
    [detailTotalLikeMapping addAttributeMappingsFromArray:@[@"total_like", @"total_dislike"]];
    return detailTotalLikeMapping;
}
@end
