//
//  ShopReviewViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopReviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSDictionary *data;

@end
