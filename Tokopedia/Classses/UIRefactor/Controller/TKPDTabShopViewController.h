//
//  TKPDTabShopViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopDelegate.h"
#import "Shop.h"

@interface TKPDTabShopViewController : UIViewController

@property (strong, nonatomic) NSDictionary *data;
@property CGPoint contentOffset;
@property (strong, nonatomic) Shop *shop;

@end
