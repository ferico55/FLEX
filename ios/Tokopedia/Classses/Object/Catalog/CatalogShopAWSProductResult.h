//
//  CatalogShopAWSProductResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 2/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchAWSShop.h"
#import "SearchAWSProduct.h"

@interface CatalogShopAWSProductResult : NSObject

@property (nonatomic, strong, nonnull) SearchAWSShop* shop;
@property (nonatomic, strong, nonnull) NSArray* products;

+ (RKObjectMapping*_Nonnull)objectMapping;

@end
