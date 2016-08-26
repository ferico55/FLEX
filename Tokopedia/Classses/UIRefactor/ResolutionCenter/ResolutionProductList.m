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
    
    
    [mapping addAttributeMappingsFromDictionary:@{@"pt_is_free_return":@"is_free_return",
                                                  @"pt_primary_dtl_photo":@"primary_dtl_photo",
                                                  @"pt_product_name":@"product_name",
                                                  @"pt_primary_photo":@"primary_photo",
                                                  @"pt_show_input_quantity":@"show_input_quantity",
                                                  @"pt_product_id":@"product_id",
                                                  @"pt_order_dtl_id":@"order_dtl_id",
                                                  @"pt_quantity":@"quantity"
                                                  }];
    return mapping;
}
@end
