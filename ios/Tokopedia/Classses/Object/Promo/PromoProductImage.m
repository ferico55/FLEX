//
//  PromoProductImage.m
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoProductImage.h"

@implementation PromoProductImage
+(RKObjectMapping *)mapping{
    RKObjectMapping *promoProductImageMapping = [RKObjectMapping mappingForClass:[PromoProductImage class]];
    [promoProductImageMapping addAttributeMappingsFromArray:@[@"m_url",
                                                              @"s_url",
                                                              @"xs_url"
                                                              ]];
    
    return promoProductImageMapping;
}
@end
