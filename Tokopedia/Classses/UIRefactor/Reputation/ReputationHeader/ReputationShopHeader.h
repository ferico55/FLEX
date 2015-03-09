//
//  ContainerViewController.h
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shop.h"

@protocol ReputationShopDelegate <NSObject>

- (void)didLoadImage:(UIImage *)image;
- (void)didReceiveShop:(Shop *)shop;
- (id)didReceiveNavigationController;

@end

@interface ReputationShopHeader : UIView


@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) Shop *shop;
@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIView *footer;

@property (weak, nonatomic) id<ReputationShopDelegate> delegate;


@end
