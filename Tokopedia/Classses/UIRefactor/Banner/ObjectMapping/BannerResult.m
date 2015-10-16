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

@implementation BannerResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPBannerKey toKeyPath:TKPBannerKey withMapping:[BannerList mapping]]];
    
    return mapping;
}

+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

@end
