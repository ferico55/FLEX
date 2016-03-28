//
//  ResolutionDetail.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionDetail.h"

@implementation ResolutionDetail
// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_last" toKeyPath:@"resolution_last" withMapping:[ResolutionLast mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_order" toKeyPath:@"resolution_order" withMapping:[ResolutionOrder mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_by" toKeyPath:@"resolution_by" withMapping:[ResolutionBy mapping]]];

    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_shop" toKeyPath:@"resolution_shop" withMapping:[ResolutionShop mapping]]];

    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_customer" toKeyPath:@"resolution_customer" withMapping:[ResolutionCustomer mapping]]];

    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_dispute" toKeyPath:@"resolution_dispute" withMapping:[ResolutionDispute mapping]]];

    return mapping;
}


@end
