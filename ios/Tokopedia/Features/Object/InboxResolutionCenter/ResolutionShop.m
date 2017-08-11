//
//  ResolutionShop.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionShop.h"

@implementation ResolutionShop

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"shop_image",
                      @"shop_name",
                      @"shop_url",
                      @"shop_id"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_reputation" toKeyPath:@"shop_reputation" withMapping:[ShopReputation mapping]]];
    return mapping;
}

@end
