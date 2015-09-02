//
//  CatalogShopViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Catalog.h"

@interface CatalogShopViewController : UIViewController

@property (strong, nonatomic) Catalog *catalog;
@property (strong, nonatomic) NSMutableArray *catalog_shops;

@end
