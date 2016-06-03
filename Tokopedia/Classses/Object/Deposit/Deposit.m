//
//  DepositInfo.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Deposit.h"

@implementation Deposit

+ (RKObjectMapping *)mapping {
    RKObjectMapping *depositMapping = [RKObjectMapping mappingForClass:[Deposit class]];
    
    [depositMapping addAttributeMappingsFromArray:@[@"status",
                                                    @"server_process_time"]];
    
    [depositMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                   toKeyPath:@"data"
                                                                                 withMapping:[DepositResult mapping]]];
    
    return depositMapping;
}

@end
