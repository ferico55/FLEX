//
//  ProductTalkDetailViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 10/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Detail Product Talk Detail View Controller
@interface ProductTalkDetailViewController : UIViewController

@property (strong,nonatomic) NSDictionary *data;
@property (strong, nonatomic) UIViewController *masterViewController;

-(void)replaceDataSelected:(NSDictionary *)data;

@end
