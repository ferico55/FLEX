//
//  TKPDTabInboxReviewNavigationController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TKPDTabInboxReviewNavigationController;
@class TKPDTabNavigationItem;

#pragma mark -
#pragma mark TKPDTabInboxReviewNavigationController protocol

@protocol TKPDTabInboxReviewNavigationControllerDelegate <NSObject>

//@required
//- (void) tabBarController:(TKPDTabInboxReviewNavigationController *)tabBarController withViewController:(UIViewController *)viewController;

@optional

- (BOOL)tabBarController:(TKPDTabInboxReviewNavigationController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabInboxReviewNavigationController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(TKPDTabInboxReviewNavigationController *)tabBarController childControllerContentInset:(UIEdgeInsets)insets;

@end


#pragma mark -
#pragma mark TKPDTabInboxReviewNavigationController

@interface TKPDTabInboxReviewNavigationController : UIViewController {
    IBOutlet UILabel *lblDescChangeReviewStyle;
}

@property (nonatomic, strong) UIViewController *splitVC;

@property (nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;
@property (nonatomic, weak, setter = setSelectedViewController:) UIViewController *selectedViewController;
@property (nonatomic, setter = setSelectedIndex:) NSInteger selectedIndex;
@property (nonatomic, weak) id<TKPDTabInboxReviewNavigationControllerDelegate> delegate;

@property (nonatomic, readonly, assign) UIEdgeInsets contentInsetForChildController;

@property (nonatomic, copy, setter = setData:) NSDictionary *data;

//+ (id)allocinit;
- (IBAction)actionNewReview:(id)sender;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
- (NSString *)getTitleNavReview;

@end

#pragma mark -
#pragma mark UIViewController category

@interface UIViewController (TKPDTabInboxReviewNavigationController)

@property (nonatomic, readonly, strong) TKPDTabInboxReviewNavigationController *TKPDTabInboxReviewNavigationController;
@property (nonatomic, readwrite, strong) TKPDTabNavigationItem *TKPDTabNavigationItem;

@end

