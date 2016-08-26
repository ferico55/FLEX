//
//  ResolutionProductResponse.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionProductResponse.h"

@implementation ResolutionProductResponse

+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ResolutionProductResponse class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"server_process_time"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[ResolutionProductData mapping]]];
    return mapping;    
}
@end
