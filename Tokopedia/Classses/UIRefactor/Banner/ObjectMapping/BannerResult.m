//
//  BannerResult.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "BannerResult.h"
#import <RestKit/ObjectMapping/RKObjectMapping.h>

NSString *const TKPBannerKey = @"banner";
NSString *const TKPTickerKey = @"ticker";

@implementation BannerResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPBannerKey toKeyPath:TKPBannerKey withMapping:[BannerList mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPTickerKey toKeyPath:TKPTickerKey withMapping:[BannerTicker mapping]]];
    
    return mapping;
}

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPTickerKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

@end
