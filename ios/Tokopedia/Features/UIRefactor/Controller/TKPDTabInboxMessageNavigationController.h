//
//  TKPDTabInboxMessageNavigationController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InboxMessageDetailViewController;
@class TKPDTabInboxMessageNavigationController;

#pragma mark -
#pragma mark TKPDTabInboxMessageNavigationController protocol

@protocol TKPDTabInboxMessageNavigationControllerDelegate <NSObject>

//@required
//- (void) tabBarController:(TKPDTabInboxMessageNavigationController *)tabBarController withViewController:(UIViewController *)viewController;

@optional

- (BOOL)tabBarController:(TKPDTabInboxMessageNavigationController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabInboxMessageNavigationController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabInboxMessageNavigationController *)tabBarController childControllerContentInset:(UIEdgeInsets)insets;

@end

#pragma mark -
#pragma mark TKPDTabNavigationItem

@interface TKPDTabNavigationItem : UITabBarItem
@end

#pragma mark -
#pragma mark TKPDTabInboxMessageNavigationController

@interface TKPDTabInboxMessageNavigationController : UIViewController

@property (nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;
@property (nonatomic, weak, setter = setSelectedViewController:) UIViewController *selectedViewController;
@property (nonatomic, setter = setSelectedIndex:) NSInteger selectedIndex;
@property (nonatomic, weak) id<TKPDTabInboxMessageNavigationControllerDelegate> delegate;

@property (strong, nonatomic) UIViewController *splitVC;


@property (nonatomic, readonly, assign) UIEdgeInsets contentInsetForChildController;

@property (nonatomic, copy, setter = setData:) NSDictionary *data;

//+ (id)allocinit;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;


@end

#pragma mark -
#pragma mark UIViewController category

@interface UIViewController (TKPDTabInboxMessageNavigationController)

@property (nonatomic, readonly, strong) TKPDTabInboxMessageNavigationController *TKPDTabInboxMessageNavigationController;
@property (nonatomic, readwrite, strong) TKPDTabNavigationItem *TKPDTabNavigationItem;

@end

