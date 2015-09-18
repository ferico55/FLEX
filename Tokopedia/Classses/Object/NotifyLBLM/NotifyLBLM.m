//
//  NotifyLBLM.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NotifyLBLM.h"

NSString *const TKPDataNotifyKey = @"data";

NSString *const TKPStatusNotifyKey = @"status";

@implementation NotifyLBLM

#pragma mark - TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPStatusNotifyKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPDataNotifyKey toKeyPath:TKPDataNotifyKey withMapping:[NotifyData mapping]]];
    return mapping;
}

@end
