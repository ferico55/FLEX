//
//  PageChildViewController.h
//  PagePageChildViewControllerExample
//
//  Created by Mani Shankar on 26/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopPageHeader.h"

@interface ShopTalkPageViewController : GAITrackedViewController

@property (assign, nonatomic) NSInteger indexNumber;
@property (nonatomic, strong) NSDictionary *data;

@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (nonatomic, strong) ShopPageHeader *shopPageHeader;

@property (nonatomic, copy) void(^onTabSelected)(ShopPageTab);
@property BOOL showHomeTab;
@end
