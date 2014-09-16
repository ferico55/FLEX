//
//  KatalogViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KatalogViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UINavigationController *navcon;

@property (strong,nonatomic) NSDictionary *data;

@end
