//
//  CatalogShopAWSResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 2/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CatalogShopAWSResult.h"
#import "CatalogShopAWSProductResult.h"
#import "Tokopedia-Swift.h"

@implementation CatalogShopAWSResult

+ (RKObjectMapping *)objectMapping {
    RKObjectMapping *catalogShopAWSResultMapping = [RKObjectMapping mappingForClass:[CatalogShopAWSResult class]];
    
    [catalogShopAWSResultMapping addAttributeMappingsFromArray:@[@"search_url",
                                                                 @"share_url",
                                                                 @"total_record"]];
    
    [catalogShopAWSResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                                                toKeyPath:@"paging"
                                                                                              withMapping:[Paging mapping]]];
    
    
    [catalogShopAWSResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_products"
                                                                                                toKeyPath:@"catalog_products"
                                                                                              withMapping:[CatalogShopAWSProductResult objectMapping]]];
    
    return catalogShopAWSResultMapping;
}


@end
