//
//  ShopTalkViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopHeaderViewController.h"

@interface ShopTalkViewController : UIViewController

@property (nonatomic, strong) NSDictionary *data;
@property CGPoint contentOffset;
@property (strong, nonatomic) Shop *shop;

@end
