//
//  Owner.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Owner.h"

@implementation Owner
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Owner class]];
    [mapping addAttributeMappingsFromArray:@[@"owner_image", @"owner_phone", @"owner_id", @"owner_email", @"owner_name", @"owner_messenger"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"owner_reputation" toKeyPath:@"owner_reputation" withMapping:[ReputationDetail mapping]]];
    return mapping;
}
@end
