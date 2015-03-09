//
//  TKPDTabProfileNavigationController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TKPDTabProfileNavigationController;

#pragma mark -
#pragma mark TKPDTabProfileNavigationController protocol

@protocol TKPDTabProfileNavigationControllerDelegate <NSObject>
@optional

- (BOOL)tabBarController:(TKPDTabProfileNavigationController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabProfileNavigationController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabProfileNavigationController *)tabBarController childControllerContentInset:(UIEdgeInsets)insets;

@end

#pragma mark -
#pragma mark TKPDTabProfileNavigationItem

@interface TKPDTabProfileNavigationItem : UITabBarItem
@end

#pragma mark -
#pragma mark TKPDTabProfileNavigationController

@interface TKPDTabProfileNavigationController : UIViewController

@property (nonatomic, strong, setter = setData:) NSDictionary *data;

@property (nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;
@property (nonatomic, weak, setter = setSelectedViewController:) UIViewController *selectedViewController;
@property (nonatomic, setter = setSelectedIndex:) NSInteger selectedIndex;
@property (nonatomic, weak) id<TKPDTabProfileNavigationControllerDelegate> delegate;

@property (nonatomic, readonly, assign) UIEdgeInsets contentInsetForChildController;

//+ (id)allocinit;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end

#pragma mark -
#pragma mark UIViewController category

@interface UIViewController (TKPDTabProfileNavigationController)

@property (nonatomic, readonly, strong) TKPDTabProfileNavigationController *TKPDTabNavigationController;
@property (nonatomic, readwrite, strong) TKPDTabProfileNavigationItem *TKPDTabProfileNavigationItem;

@end
