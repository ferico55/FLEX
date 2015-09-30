//
//  NotifyAttributes.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NotifyAttributes.h"

NSString *const TKPNotifyBuyerKey = @"notify_buyer";
NSString *const TKPExpLoyalBuyerKey = @"expiry_time_loyal_buyer";
NSString *const TKPNotifySellerKey = @"notify_seller";
NSString *const TKPExpLoyalSellerKey = @"expiry_time_loyal_seller";

@implementation NotifyAttributes

#pragma mark - TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPNotifyBuyerKey,TKPExpLoyalBuyerKey,TKPNotifySellerKey,TKPExpLoyalSellerKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
