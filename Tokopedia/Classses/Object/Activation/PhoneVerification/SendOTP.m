//
//  SendOTP.m
//  Tokopedia
//
//  Created by Johanes Effendi on 11/27/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendOTP.h"

@implementation SendOTP

+(NSDictionary *) attributeMappingDictionary{
    NSArray* keys = @[@"status",
                      @"server_process_time"];
    
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping *) mapping{
    // setup object mappings
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"data"
                                                                          withMapping:[SendOTPResult mapping]]];
    
    return mapping;
}

@end