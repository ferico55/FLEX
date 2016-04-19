//
//  ContainerViewController.h
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shop.h"
#import "EtalaseList.h"

@interface ShopContainerViewController : UIViewController<UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSDictionary *data;
@property CGPoint contentOffset;
@property (strong, nonatomic) Shop *shop;
@property (strong, nonatomic) EtalaseList *initialEtalase;

- (void)showPopUp:(NSString *)strText withSender:(id)sender;
- (UIViewController *)getActiveViewController;
@end

