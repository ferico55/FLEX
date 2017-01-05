//
//  CatalogShopAWSResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 2/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CatalogShopAWSProductResult.h"
#import "Paging.h"

@interface CatalogShopAWSResult : NSObject

@property (nonatomic, strong) NSString* search_url;
@property (nonatomic, strong) NSString* share_url;
@property (nonatomic, strong) NSString* total_record;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray<CatalogShopAWSProductResult*>* catalog_products;

+ (RKObjectMapping*)objectMapping;

@end
