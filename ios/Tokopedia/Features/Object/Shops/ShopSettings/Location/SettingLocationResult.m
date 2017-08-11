//
//  SettingLocationResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SettingLocationResult.h"
#import "Tokopedia-Swift.h"

@implementation SettingLocationResult

+ (RKObjectMapping *)objectMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"is_allow"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[Address mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging" toKeyPath:@"paging" withMapping:[Paging mapping]]];
    return mapping;
}

@end
