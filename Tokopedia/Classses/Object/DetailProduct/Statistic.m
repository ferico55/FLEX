//
//  Statistic.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Statistic.h"

@implementation Statistic
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"product_sold_count",
                      @"product_transaction_count",
                      @"product_success_rate",
                      @"product_view_count",
                      @"product_quality_rate",
                      @"product_accuracy_rate",
                      @"product_quality_point",
                      @"product_accuracy_point",
                      @"product_cancel_rate",
                      @"product_talk_count",
                      @"product_review_count"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
