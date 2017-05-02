//
//  SecurityRequestOTP.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SecurityRequestOTP.h"

@implementation SecurityRequestOTP


+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromArray:@[@"status",
                                             @"message_error",
                                             @"message_status"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[SecurityRequestOTPResult mapping]]];
    
    
    return mapping;
}

@end
