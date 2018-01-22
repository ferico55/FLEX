//
//  EtalaseList.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "EtalaseList.h"

@implementation EtalaseList

- (NSString *)etalase_name {
    return [_etalase_name kv_decodeHTMLCharacterEntities];
}

+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[EtalaseList class]];
    [mapping addAttributeMappingsFromArray:@[@"etalase_id", @"etalase_name", @"etalase_num_product", @"etalase_total_product", @"etalase_url", @"etalase_badge"]];
    [mapping addAttributeMappingsFromDictionary:@{@"use_ace": @"useAce"}];
    return mapping;
}

- (BOOL)isGetListProductFromAce {
    return ([self.useAce integerValue] == 1);
}

@end
