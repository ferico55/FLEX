//
//  BankAccountFormResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "BankAccountFormResult.h"

@implementation BankAccountFormResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BankAccountFormResult class]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                            toKeyPath:@"paging"
                                                                          withMapping:[Paging mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                            toKeyPath:@"list"
                                                                          withMapping:[BankAccountFormList mapping]]];
    
    return mapping;
    
}

@end
