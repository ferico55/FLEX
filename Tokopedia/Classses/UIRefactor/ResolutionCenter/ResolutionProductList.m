//
//  ResolutionProductList.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionProductList.h"

@implementation ResolutionProductList
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ResolutionProductList class]];
    [mapping addAttributeMappingsFromArray:@[@"primary_photo",
                                             @"order_dtl_id",
                                             @"product_id",
                                             @"show_input_quantity",
                                             @"quantity",
                                             @"primary_dtl_photo",
                                             @"product_name"
                                             ]];
    return mapping;
}
@end
