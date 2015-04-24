//
//  ShopNotesViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shop.h"

@interface ShopNotesViewController : UIViewController

@property (nonatomic, strong) NSDictionary *data;
@property (assign, nonatomic) NSInteger pageIndex;
@property (assign, nonatomic) NSInteger index;

@property CGPoint contentOffset;
@property (strong, nonatomic) Shop *shop;
@property (assign, nonatomic) NSInteger indexNumber;

@end
