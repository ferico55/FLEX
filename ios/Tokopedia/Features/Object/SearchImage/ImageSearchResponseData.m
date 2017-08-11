//
//  ImageSearchResponseData.m
//  Tokopedia
//
//  Created by Tokopedia on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ImageSearchResponseData.h"

@implementation ImageSearchResponseData

+ (RKObjectMapping *)mapping {
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[SearchAWSProduct class]];
    [productMapping addAttributeMappingsFromArray:@[@"shop_lucky",
                                                    @"shop_id",
                                                    @"shop_gold_status",
                                                    @"shop_url",
                                                    @"is_owner",
                                                    @"rate",
                                                    @"product_id",
                                                    @"product_image_full",
                                                    @"product_talk_count",
                                                    @"product_image",
                                                    @"product_price",
                                                    @"product_sold_count",
                                                    @"shop_location",
                                                    @"product_wholesale",
                                                    @"shop_name",
                                                    @"product_review_count",
                                                    @"similarity_rank",
                                                    @"condition",
                                                    @"product_name",
                                                    @"product_url"]];
    
    RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:self];
    [dataMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"similar_prods" toKeyPath:@"similar_prods" withMapping:productMapping]];
    
    return dataMapping;
}

@end
