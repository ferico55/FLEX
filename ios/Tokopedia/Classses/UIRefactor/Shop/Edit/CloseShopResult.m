//
//  CloseShopResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 5/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CloseShopResult.h"

@implementation CloseShopResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[CloseShopResult class]];
    [mapping addAttributeMappingsFromArray:@[@"is_success"]];    
    return mapping;

}
@end
