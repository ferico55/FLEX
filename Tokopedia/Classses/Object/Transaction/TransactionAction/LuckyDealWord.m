//
//  LuckyDealWord.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "LuckyDealWord.h"

@implementation LuckyDealWord
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[
                      @"notify_buyer",
                      @"expiry_time_loyal_buyer",
                      @"notify_seller",
                      @"expiry_time_loyal_seller",
                      @"link",
                      @"content_buyer_1",
                      @"content_buyer_2",
                      @"content_buyer_3",
                      @"content_merchant_1",
                      @"content_merchant_2",
                      @"content_merchant_3"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
    
}

@end
