//
//  TKPDTabHomeNavigationController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "home.h"

@class TKPDTabHomeNavigationController;

#pragma mark -
#pragma mark TKPDTabHomeNavigationController protocol

@protocol TKPDTabHomeNavigationControllerDelegate <NSObject>
@optional

- (BOOL)tabBarController:(TKPDTabHomeNavigationController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabHomeNavigationController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabHomeNavigationController *)tabBarController childControllerContentInset:(UIEdgeInsets)insets;

@end

#pragma mark -
#pragma mark TKPDTabHomeNavigationItem

@interface TKPDTabHomeNavigationItem : UITabBarItem
@end

#pragma mark -
#pragma mark TKPDTabHomeNavigationController

@interface TKPDTabHomeNavigationController : UIViewController

@property (nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;
@property (nonatomic, weak, setter = setSelectedViewController:) UIViewController *selectedViewController;
@property (nonatomic, setter = setSelectedIndex:) NSInteger selectedIndex;
@property (nonatomic, weak) id<TKPDTabHomeNavigationControllerDelegate> delegate;

@property (nonatomic, readonly, assign) UIEdgeInsets contentInsetForChildController;

//+ (id)allocinit;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated withtitles:(NSArray*)titles;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end

#pragma mark -
#pragma mark UIViewController category

@interface UIViewController (TKPDTabHomeNavigationController)

@property (nonatomic, readonly, strong) TKPDTabHomeNavigationController *TKPDTabNavigationController;
@property (nonatomic, readwrite, strong) TKPDTabHomeNavigationItem *TKPDTabHomeNavigationItem;

@end
