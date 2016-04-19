//
//  DepositFormInfo.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DepositForm.h"

@implementation DepositForm

+ (RKObjectMapping *)mapping {
    RKObjectMapping *depositFormMapping = [RKObjectMapping mappingForClass:[DepositForm class]];
    
    [depositFormMapping addAttributeMappingsFromArray:@[@"status",
                                                        @"message_error",
                                                        @"server_process_time"]];
    
    [depositFormMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                       toKeyPath:@"data"
                                                                                     withMapping:[DepositFormResult mapping]]];
    
    return depositFormMapping;
}

@end
