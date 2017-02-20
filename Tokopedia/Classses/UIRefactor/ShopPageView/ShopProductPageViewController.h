//
//  PageChildViewController.h
//  PagePageChildViewControllerExample
//
//  Created by Mani Shankar on 26/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EtalaseList.h"
#import "ShopPageHeader.h"

@class ShopProductFilter;

@interface ShopProductPageViewController : GAITrackedViewController

@property (assign, nonatomic) NSInteger indexNumber;
@property (nonatomic, strong) NSDictionary *data;

@property (weak, nonatomic) IBOutlet UILabel *screenLabel;

@property (nonatomic, strong) ShopPageHeader *shopPageHeader;
@property (nonatomic, strong) EtalaseList *initialEtalase;

@property(nonatomic, copy) void(^onTabSelected)(ShopPageTab);
@property BOOL showHomeTab;
@property (nonatomic) Shop *shop;

- (void)showProductsWithFilter:(ShopProductFilter *)filter;

@end
