//
//  Reputation.m
//  Tokopedia
//
//  Created by Tonito Acen on 3/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReputationDetail.h"

@implementation ReputationDetail

+ (RKObjectMapping *)mapping {
    RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:self];
    [reviewUserReputationMapping addAttributeMappingsFromArray:@[@"positive_percentage",
                                                                 @"no_reputation",
                                                                 @"negative",
                                                                 @"neutral",
                                                                 @"positive"]];
    
    return reviewUserReputationMapping;
}

@end
