//
//  PageChildViewController.h
//  PagePageChildViewControllerExample
//
//  Created by Mani Shankar on 26/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EtalaseList.h"
@class ShopPageHeader;

@interface ShopProductPageViewController : GAITrackedViewController

@property (assign, nonatomic) NSInteger indexNumber;
@property (nonatomic, strong) NSDictionary *data;

@property (weak, nonatomic) IBOutlet UILabel *screenLabel;

@property (nonatomic, strong) ShopPageHeader *shopPageHeader;
@property (nonatomic, strong) EtalaseList *initialEtalase;

- (void)openEtalaseWithId:(NSString *)etalaseId;

@end
