//
//  Reputation.m
//  Tokopedia
//
//  Created by Tonito Acen on 3/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReputationDetail.h"

@implementation ReputationDetail

+ (RKObjectMapping *)mapping{
    RKObjectMapping *reputationDetail = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [reputationDetail addAttributeMappingsFromArray:@[@"positive_percentage",
                                                      @"negative",
                                                      @"positive",
                                                      @"neutral",
                                                      @"no_reputation"]];
    return reputationDetail;
}

@end
