//
//  DepartmentTree.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "home.h"
#import "DepartmentTree.h"

@implementation DepartmentTree

+ (RKMapping *)childMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[DepartmentChild class]];
    [mapping addAttributeMappingsFromArray:@[kTKPDHOME_APIHREFKEY, kTKPDHOME_APITREEKEY, kTKPDHOME_APIDIDKEY, kTKPDHOME_APITITLEKEY]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"child"
                                             mapping:[self selfMapping]];
    return mapping;
}

+ (RKMapping *)selfMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[kTKPDHOME_APIHREFKEY, kTKPDHOME_APITREEKEY, kTKPDHOME_APIDIDKEY, kTKPDHOME_APITITLEKEY]];
    return mapping;
}

@end
