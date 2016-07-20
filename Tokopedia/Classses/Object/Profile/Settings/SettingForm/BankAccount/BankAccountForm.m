//
//  BankAccountForm.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "BankAccountForm.h"

@implementation BankAccountForm

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BankAccountForm class]];
    
    [mapping addAttributeMappingsFromArray:@[@"status",
                                             @"message_error",
                                             @"server_process_time"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"result"
                                                                          withMapping:[BankAccountFormResult mapping]]];
    
    return mapping;
}

@end
