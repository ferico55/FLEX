//
//  preorderDetail.m
//  Tokopedia
//
//  Created by atnlie on 12/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "PreorderDetail.h"

@implementation PreorderDetail

+ (NSDictionary *)attributeMappingDictionary{
    NSArray *keys = @[@"preorder_process_time_type_string",
                      @"preorder_process_time_type",
                      @"preorder_process_time",
                      @"preorder_status"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping*)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
