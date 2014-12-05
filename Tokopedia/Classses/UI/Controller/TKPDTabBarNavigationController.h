//
//  TKPDTabBarNavigationController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKPDTabBarNavigationController;

#pragma mark -
#pragma mark TKPDTabBarNavigationController protocol

@protocol TKPDTabBarNavigationControllerDelegate <NSObject>
@optional

- (BOOL)tabBarController:(TKPDTabBarNavigationController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabBarNavigationController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabBarNavigationController *)tabBarController childControllerContentInset:(UIEdgeInsets)insets;

@end

#pragma mark -
#pragma mark TKPDTabBarNavigationItem

@interface TKPDTabBarNavigationItem : UITabBarItem
@end

#pragma mark -
#pragma mark TKPDTabBarNavigationController

@interface TKPDTabBarNavigationController : UIViewController

@property (nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;
@property (nonatomic, weak, setter = setSelectedViewController:) UIViewController *selectedViewController;
@property (nonatomic, setter = setSelectedIndex:) NSInteger selectedIndex;
@property (nonatomic, weak) id<TKPDTabBarNavigationControllerDelegate> delegate;

@property (nonatomic, readonly, assign) UIEdgeInsets contentInsetForChildController;

//+ (id)allocinit;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated withtitles:(NSArray*)titles;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end

#pragma mark -
#pragma mark UIViewController category

@interface UIViewController (TKPDTabBarNavigationController)

@property (nonatomic, readonly, strong) TKPDTabBarNavigationController *TKPDTabNavigationController;
@property (nonatomic, readwrite, strong) TKPDTabBarNavigationItem *TKPDTabBarNavigationItem;

@end
