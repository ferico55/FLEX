//
//  InboxMessageDetailViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 11/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
@class InboxMessageViewController;
@class TTTAttributedLabel;
@class RSKGrowingTextView;

@interface InboxMessageDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSDictionary *data;
@property (copy) void(^onMessagePosted)(NSString* replyMessage);
@property (weak, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIView *messagingview;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *buttonloadmore;
@property (weak, nonatomic) IBOutlet UIButton *buttonsend;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) IBOutlet RSKGrowingTextView *textView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageViewBottomConstraint;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *participantsLabel;




@end
