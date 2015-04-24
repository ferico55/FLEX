//
//  ProductListMyShopFilterViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EtalaseList.h"

@protocol ProductListMyShopFilterDelegate <NSObject>

- (void)filterProductEtalase:(EtalaseList *)etalase
                  department:(NSString *)department
                     catalog:(NSString *)catalog
                     picture:(NSString *)picture
                   condition:(NSString *)condition;

@end

@interface ProductListMyShopFilterViewController : UITableViewController

@property (assign, nonatomic) id<ProductListMyShopFilterDelegate> delegate;
@property (strong, nonatomic) NSString *shopID;

@end