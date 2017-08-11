//
//  SendOTPResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 11/27/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendOTPResult.h"
@implementation SendOTPResult

+(NSDictionary *) attributeMappingDictionary{
    NSArray *keys = @[@"is_success"];
    
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping *) mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    return mapping;
}

@end