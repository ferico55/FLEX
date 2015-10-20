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
NSString *const TKPLinkLBLMKey = @"link";
NSString *const TKPContentBuyer1Key = @"content_buyer_1";
NSString *const TKPContentBuyer2Key = @"content_buyer_2";
NSString *const TKPContentBuyer3Key = @"content_buyer_3";
NSString *const TKPContentMerchant1Key = @"content_merchant_1";
NSString *const TKPContentMerchant2Key = @"content_merchant_2";
NSString *const TKPContentMerchant3Key = @"content_merchant_3";

@implementation NotifyAttributes

#pragma mark - TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPNotifyBuyerKey,TKPExpLoyalBuyerKey,TKPNotifySellerKey,TKPExpLoyalSellerKey,TKPLinkLBLMKey,TKPContentBuyer1Key,TKPContentBuyer2Key,TKPContentBuyer3Key,TKPContentMerchant1Key,TKPContentMerchant2Key,TKPContentMerchant3Key];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
