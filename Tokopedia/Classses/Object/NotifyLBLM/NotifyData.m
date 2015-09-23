//
//  NotifyData.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NotifyData.h"

NSString *const TKPNotifyIDKey = @"notify_id";
NSString *const TKPWSNotifyIDKey = @"id";
NSString *const TKPTypeKey = @"type";
NSString *const TKPAttributesKey = @"attributes";

@implementation NotifyData

#pragma mark - TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPNotifyIDKey,TKPTypeKey];
    NSArray *wsKeys = @[TKPWSNotifyIDKey,TKPTypeKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:wsKeys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPAttributesKey toKeyPath:TKPAttributesKey withMapping:[NotifyAttributes mapping]]];
    return mapping;
}


@end
