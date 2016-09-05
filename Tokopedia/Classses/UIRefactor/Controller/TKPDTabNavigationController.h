//
//  TKPDTabNavigationController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TKPDTabNavigationController;

#pragma mark -
#pragma mark TKPDTabNavigationController protocol

@protocol TKPDTabNavigationControllerDelegate <NSObject>
@optional

- (BOOL)tabBarController:(TKPDTabNavigationController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabNavigationController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabNavigationController *)tabBarController childControllerContentInset:(UIEdgeInsets)insets;

@end

#pragma mark -
#pragma mark TKPDTabNavigationItem

@interface TKPDTabNavigationItemInNavVC : UITabBarItem
@end

#pragma mark -
#pragma mark TKPDTabNavigationController

@interface TKPDTabNavigationController : UIViewController

@property (nonatomic, strong) NSString *navigationTitle;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentcontrol;

@property (nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;
@property (nonatomic, weak, setter = setSelectedViewController:) UIViewController *selectedViewController;
@property (nonatomic, setter = setSelectedIndex:) NSInteger selectedIndex;
@property (nonatomic, weak) id<TKPDTabNavigationControllerDelegate> delegate;

@property (nonatomic, readonly, assign) UIEdgeInsets contentInsetForChildController;

@property (nonatomic, copy, setter = setData:) NSMutableDictionary *data;

//+ (id)allocinit;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
- (void)changeNavigationTitle:(NSNotification*)notification;

@end

#pragma mark -
#pragma mark UIViewController category

@interface UIViewController (TKPDTabNavigationController)

@property (nonatomic, readonly, strong) TKPDTabNavigationController *TKPDTabNavigationController;
@property (nonatomic, readwrite, strong) TKPDTabNavigationItemInNavVC *TKPDTabNavigationItem;

@end

