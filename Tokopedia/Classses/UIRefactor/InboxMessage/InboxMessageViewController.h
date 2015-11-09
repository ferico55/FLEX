//
//  InboxMessageViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InboxMessageDetailViewController;

@interface InboxMessageViewController : UIViewController

@property (strong,nonatomic) NSDictionary *data;

@property (strong, nonatomic) InboxMessageDetailViewController *detailViewController;


@end
