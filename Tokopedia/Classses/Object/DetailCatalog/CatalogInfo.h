//
//  CatalogInfo.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CatalogPrice.h"
#import "CatalogImage.h"

@interface CatalogInfo : NSObject

@property (nonatomic, strong) NSString *catalog_description;
@property (nonatomic, strong) NSString *catalog_key;
@property (nonatomic, strong) NSString *catalog_department_id;
@property (nonatomic, strong) NSString *catalog_id;
@property (nonatomic, strong) NSString *catalog_name;
@property (nonatomic, strong) CatalogPrice *catalog_price;
@property (nonatomic, strong) NSArray *catalog_image;

@end
