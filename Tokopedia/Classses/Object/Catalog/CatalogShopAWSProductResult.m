//
//  CatalogShopAWSProductResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 2/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CatalogShopAWSProductResult.h"
#import "SearchAWSShop.h"
#import "SearchAWSProduct.h"

@implementation CatalogShopAWSProductResult

+ (RKObjectMapping *)objectMapping {
    RKObjectMapping *catalogShopAWSProduceResultMapping = [RKObjectMapping mappingForClass:[CatalogShopAWSProductResult class]];
    
    [catalogShopAWSProduceResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop"
                                                                                                toKeyPath:@"shop"
                                                                                              withMapping:[SearchAWSShop mapping]]];
    
    
    [catalogShopAWSProduceResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"products"
                                                                                                toKeyPath:@"products"
                                                                                              withMapping:[SearchAWSProduct mapping]]];
    
    return catalogShopAWSProduceResultMapping;
}

@end
