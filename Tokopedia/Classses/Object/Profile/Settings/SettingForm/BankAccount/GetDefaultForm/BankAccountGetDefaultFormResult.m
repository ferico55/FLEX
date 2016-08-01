//
//  BankAccountGetDefaultFormResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "BankAccountGetDefaultFormResult.h"

@implementation BankAccountGetDefaultFormResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BankAccountGetDefaultFormResult class]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"default_bank"
                                                                            toKeyPath:@"default_bank"
                                                                          withMapping:[BankAccountGetDefaultFormDefaultBank mapping]]];
    
    return mapping;
    
}

@end
