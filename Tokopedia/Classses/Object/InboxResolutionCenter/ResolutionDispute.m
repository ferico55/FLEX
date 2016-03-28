//
//  ResolutionDispute.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionDispute.h"

@implementation ResolutionDispute

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"dispute_update_time",
                      @"dispute_is_responded",
                      @"dispute_create_time",
                      @"dispute_is_expired",
                      @"dispute_update_time_short",
                      @"dispute_is_call_admin",
                      @"dispute_create_time_short",
                      @"dispute_status",
                      @"dispute_deadline",
                      @"dispute_resolution_id",
                      @"dispute_detail_url",
                      @"dispute_30_days",
                      @"dispute_split_info"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
