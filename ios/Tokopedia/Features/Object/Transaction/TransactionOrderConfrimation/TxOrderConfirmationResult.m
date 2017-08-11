//
//  TxOrderConfirmationResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmationResult.h"
#import "Tokopedia-Swift.h"

@implementation TxOrderConfirmationResult
+(NSDictionary *)attributeMappingDictionary
{
    return nil;
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"page" toKeyPath:@"page" withMapping:[Paging mapping]]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[TxOrderConfirmationList mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
