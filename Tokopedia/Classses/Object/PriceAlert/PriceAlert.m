//
//  PriceAlert.m
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PriceAlert.h"

@implementation PriceAlert

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[PriceAlert class]];
    
    [mapping addAttributeMappingsFromArray:@[@"status",
                                             @"server_process_time",
                                             @"message_error"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"data"
                                                                          withMapping:[PriceAlertResult mapping]]];
    
    return mapping;
}

@end
