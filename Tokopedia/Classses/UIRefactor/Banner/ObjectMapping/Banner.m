//
//  Banner.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "Banner.h"
#import <RestKit/ObjectMapping/RKObjectMapping.h>

NSString *const TKPBannerStatusKey = @"status";
NSString *const TKPBannerServerKey = @"server_process_time";
NSString *const TKPBannerResultKey = @"result";


@implementation Banner

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPBannerServerKey, TKPBannerStatusKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPBannerResultKey toKeyPath:TKPBannerResultKey withMapping:[BannerResult mapping]]];
    return mapping;

}

@end
