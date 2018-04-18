//
//  PageChildViewController.h
//  PagePageChildViewControllerExample
//
//  Created by Mani Shankar on 26/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EtalaseList.h"

@class ShopProductFilter;
@class Shop;

@interface ShopProductPageViewController : GAITrackedViewController

@property (assign, nonatomic) NSInteger indexNumber;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) ProductTracker *objectTracker;

@property (weak, nonatomic) IBOutlet UILabel *screenLabel;

@property (nonatomic, strong) EtalaseList *initialEtalase;

@property (nonatomic) Shop *shop;

@property (nonatomic) BOOL hasAttribution;

- (void)showProductsWithFilter:(ShopProductFilter *)filter;

@end
