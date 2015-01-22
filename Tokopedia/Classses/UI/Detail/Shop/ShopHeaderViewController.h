//
//  ShopHeaderViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shop.h"

@protocol ShopHeaderDelegate <NSObject>

- (void)didLoadImage:(UIImage *)image;
- (void)didReceiveShop:(Shop *)shop;

@end

@interface ShopHeaderViewController : UIViewController

@property (strong, nonatomic) NSDictionary *data;
//@property (weak, nonatomic) id parent;
@property (weak, nonatomic) UIImage *coverImage;
@property (weak, nonatomic) id<ShopHeaderDelegate> delegate;
@property (strong, nonatomic) Shop *shop;

- (void)didScroll:(UIScrollView *)scrollView;

@end
