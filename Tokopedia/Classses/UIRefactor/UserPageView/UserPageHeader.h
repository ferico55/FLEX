//
//  ContainerViewController.h
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileInfo.h"

@protocol UserPageHeaderDelegate <NSObject>

- (void)didLoadImage:(UIImage *)image;
- (void)didReceiveProfile:(ProfileInfo *)profile;
- (id)didReceiveNavigationController;

@end

@interface UserPageHeader : UIViewController
{
    IBOutlet UIButton *btnRate;
}
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSDictionary *data;
@property CGPoint contentOffset;
@property (strong, nonatomic) ProfileInfo *profile;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (nonatomic, retain) IBOutlet UIView *header;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) id<UserPageHeaderDelegate> delegate;


- (UIView *)getManipulatedView;
- (void)setHeaderProfile:(ProfileInfo*)profile;
@end
