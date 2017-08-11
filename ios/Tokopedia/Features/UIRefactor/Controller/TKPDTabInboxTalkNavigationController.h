//
//  TKPDTabInboxTalkNavigationController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TKPDTabInboxTalkNavigationController;
@class TKPDTabNavigationItem;

#pragma mark -
#pragma mark TKPDTabInboxTalkNavigationController protocol

@protocol TKPDTabInboxTalkNavigationControllerDelegate <NSObject>

//@required
//- (void) tabBarController:(TKPDTabInboxTalkNavigationController *)tabBarController withViewController:(UIViewController *)viewController;

@optional

- (BOOL)tabBarController:(TKPDTabInboxTalkNavigationController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabInboxTalkNavigationController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabInboxTalkNavigationController *)tabBarController childControllerContentInset:(UIEdgeInsets)insets;

@end


#pragma mark -
#pragma mark TKPDTabInboxTalkNavigationController

@interface TKPDTabInboxTalkNavigationController : UIViewController

@property (strong, nonatomic) UIViewController *splitVC;

@property (nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;
@property (nonatomic, weak, setter = setSelectedViewController:) UIViewController *selectedViewController;
@property (nonatomic, setter = setSelectedIndex:) NSInteger selectedIndex;
@property (nonatomic, weak) id<TKPDTabInboxTalkNavigationControllerDelegate> delegate;

@property (nonatomic, readonly, assign) UIEdgeInsets contentInsetForChildController;

@property (nonatomic, copy, setter = setData:) NSDictionary *data;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceButtons;

//+ (id)allocinit;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;


@end

#pragma mark -
#pragma mark UIViewController category

@interface UIViewController (TKPDTabInboxTalkNavigationController)

@property (nonatomic, readonly, strong) TKPDTabInboxTalkNavigationController *TKPDTabInboxTalkNavigationController;
@property (nonatomic, readwrite, strong) TKPDTabNavigationItem *TKPDTabNavigationItem;

@end

