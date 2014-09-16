//
//  CustomTabBarController.h
//  tokopedia
//
//  Created by IT Tkpd on 8/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TKPDTabBarDelegate <NSObject>

@end

@interface TKPDTabBarController : UITabBarController

@property (nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;
@property (nonatomic, weak, setter = setSelectedViewController:) UIViewController *selectedViewController;

@end
