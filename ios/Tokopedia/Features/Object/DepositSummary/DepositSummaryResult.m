//
//  DepositSummaryResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DepositSummaryResult.h"
#import "DepositSummaryList.h"
#import "Tokopedia-Swift.h"

@implementation DepositSummaryResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *depositSummaryResultMapping = [RKObjectMapping mappingForClass:[DepositSummaryResult class]];
    
    [depositSummaryResultMapping addAttributeMappingsFromArray:@[@"start_date",
                                                                 @"end_date",
                                                                 @"error_date",
                                                                 @"user_id"]];
    
    [depositSummaryResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                                                toKeyPath:@"paging"
                                                                                              withMapping:[Paging mapping]]];
    
    [depositSummaryResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"summary"
                                                                                                toKeyPath:@"summary"
                                                                                              withMapping:[DepositSummaryDetail mapping]]];
    
    [depositSummaryResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                                                toKeyPath:@"list"
                                                                                              withMapping:[DepositSummaryList mapping]]];
    
    return depositSummaryResultMapping;
}

@end
