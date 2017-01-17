//
//  DepositSummary.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DepositSummary.h"

@implementation DepositSummary : NSObject

+ (RKObjectMapping *)mapping {
    RKObjectMapping *depositSummaryMapping = [RKObjectMapping mappingForClass:[DepositSummary class]];
    
    [depositSummaryMapping addAttributeMappingsFromArray:@[@"status",
                                                           @"server_process_time",
                                                           @"message_error"]];
    
    [depositSummaryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                          toKeyPath:@"data"
                                                                                        withMapping:[DepositSummaryResult mapping]]];
    
    return depositSummaryMapping;
}

@end
