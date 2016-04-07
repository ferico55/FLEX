//
//  Payment.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Payment.h"

@implementation Payment
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Payment class]];
    [mapping addAttributeMappingsFromArray:@[@"payment_image",
                                             @"payment_id",
                                             @"payment_name",
                                             @"payment_info",
                                             @"payment_default_status"
                                             ]];
    return mapping;
}
@end
