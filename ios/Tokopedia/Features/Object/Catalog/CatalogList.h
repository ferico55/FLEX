//
//  CatalogList.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CatalogList.h"

@interface CatalogList : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *catalog_description;
@property (nonatomic, strong, nonnull) NSString *catalog_id;
@property (nonatomic, strong, nonnull) NSString *catalog_name;
@property (nonatomic, strong, nonnull) NSString *catalog_price;
@property (nonatomic, strong, nonnull) NSString *catalog_image;

@end
