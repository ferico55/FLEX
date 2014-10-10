//
//  TKPDTabShopNavigationController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TKPDTabShopNavigationController;

#pragma mark -
#pragma mark TKPDTabShopNavigationController protocol

@protocol TKPDTabShopNavigationControllerDelegate <NSObject>
@optional

- (BOOL)tabBarController:(TKPDTabShopNavigationController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabShopNavigationController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabShopNavigationController *)tabBarController childControllerContentInset:(UIEdgeInsets)insets;

@end

#pragma mark -
#pragma mark TKPDTabShopNavigationItem

@interface TKPDTabShopNavigationItem : UITabBarItem
@end

#pragma mark -
#pragma mark TKPDTabShopNavigationController

@interface TKPDTabShopNavigationController : UIViewController

@property (nonatomic, strong) NSDictionary *data;

@property (nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;
@property (nonatomic, weak, setter = setSelectedViewController:) UIViewController *selectedViewController;
@property (nonatomic, setter = setSelectedIndex:) NSInteger selectedIndex;
@property (nonatomic, weak) id<TKPDTabShopNavigationControllerDelegate> delegate;

@property (nonatomic, readonly, assign) UIEdgeInsets contentInsetForChildController;

//+ (id)allocinit;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end

#pragma mark -
#pragma mark UIViewController category

@interface UIViewController (TKPDTabShopNavigationController)

@property (nonatomic, readonly, strong) TKPDTabShopNavigationController *TKPDTabNavigationController;
@property (nonatomic, readwrite, strong) TKPDTabShopNavigationItem *TKPDTabShopNavigationItem;

@end
