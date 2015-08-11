//
//  InboxTalkViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductTalkDetailViewController;

@interface InboxTalkViewController : GAITrackedViewController

@property (strong,nonatomic) NSDictionary *data;

- (void)removeData:(NSString *)inboxID;
- (void)reportTalk:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath;
@property (strong, nonatomic) ProductTalkDetailViewController *detailViewController;

@end
