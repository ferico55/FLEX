//
//  ResolutionCenterCreatePOSTProduct.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreatePOSTProduct.h"

@implementation ResolutionCenterCreatePOSTProduct
+(RKObjectMapping *)mapping{
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreatePOSTProduct class]];
    [productMapping addAttributeMappingsFromArray:@[@"product_id",
                                                    @"trouble_id",
                                                    @"quantity",
                                                    @"order_dtl_id",
                                                    @"remark"
                                                    ]];
    return productMapping;
}
@end
