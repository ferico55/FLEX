//
//  PageChildViewController.h
//  PagePageChildViewControllerExample
//
//  Created by Mani Shankar on 26/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NavigationBarBlurController;

@interface ShopProductPageViewController : UIViewController

@property (assign, nonatomic) NSInteger indexNumber;
@property (nonatomic, strong) NSDictionary *data;

@property (weak, nonatomic) IBOutlet UILabel *screenLabel;

@property (weak, nonatomic) NavigationBarBlurController *blurController;

@end
