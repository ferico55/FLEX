//
//  CatalogShopAWSResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 2/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CatalogShopAWSProductResult.h"
@class Paging;

@interface CatalogShopAWSResult : NSObject

@property (nonatomic, strong, nonnull) NSString* search_url;
@property (nonatomic, strong, nonnull) NSString* share_url;
@property (nonatomic, strong, nonnull) NSString* total_record;
@property (nonatomic, strong, nonnull) Paging *paging;
@property (nonatomic, strong, nonnull) NSArray<CatalogShopAWSProductResult*>* catalog_products;

+ (RKObjectMapping *_Nonnull)objectMapping;

@end
