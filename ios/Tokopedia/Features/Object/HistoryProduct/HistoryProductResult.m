//
//  HistoryProductResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "HistoryProductResult.h"
#import "Tokopedia-Swift.h"

@implementation HistoryProductResult

+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                            toKeyPath:@"paging"
                                                                          withMapping:[Paging mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                            toKeyPath:@"list"
                                                                          withMapping:[HistoryProductList mapping]]];
    
    return mapping;
}

@end
