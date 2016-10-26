//
//  ContainerViewController.h
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileInfo.h"

@interface UserContainerViewController : UIViewController<UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;
@property CGPoint contentOffset;
@property (strong, nonatomic) ProfileInfo *profile;
@property (strong, nonatomic) NSString *profileUserID;
@end
