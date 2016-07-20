//
//  BankAccountGetDefaultForm.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "BankAccountGetDefaultForm.h"

@implementation BankAccountGetDefaultForm

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BankAccountGetDefaultForm class]];
    
    [mapping addAttributeMappingsFromArray:@[@"status",
                                             @"server_process_time",
                                             @"message_error"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"result"
                                                                          withMapping:[BankAccountGetDefaultFormResult mapping]]];
    
    return mapping;
    
}

@end
