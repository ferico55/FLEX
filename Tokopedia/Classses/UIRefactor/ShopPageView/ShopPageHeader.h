//
//  ContainerViewController.h
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shop.h"

typedef NS_ENUM(NSUInteger, ShopPageTab) {
    ShopPageTabHome,
    ShopPageTabProduct,
    ShopPageTabDiscussion,
    ShopPageTabReview,
    ShopPageTabNote,
    ShopPageTabUnknown
};

@protocol ShopPageHeaderDelegate <NSObject>

- (void)didLoadImage:(UIImage *)image;
- (void)didReceiveShop:(Shop *)shop;
- (id)didReceiveNavigationController;

@end

@interface ShopPageHeader : UIViewController

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSDictionary *data;
@property CGPoint contentOffset;
@property (strong, nonatomic) Shop *shop;


@property (nonatomic, retain) IBOutlet UIView *header;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) id<ShopPageHeaderDelegate> delegate;

- (instancetype)initWithSelectedTab:(ShopPageTab)tab;
- (void)setHeaderShopPage:(Shop *)userInfo;
@end
