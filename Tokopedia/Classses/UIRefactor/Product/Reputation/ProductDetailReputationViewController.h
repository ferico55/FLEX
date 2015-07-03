//
//  ProductDetailReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HPGrowingTextView;

@interface ProductDetailReputationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIView *viewMessage;
    IBOutlet UIButton *btnSend;
    IBOutlet UITableView *tableReputation;
    IBOutlet HPGrowingTextView *growTextView;
    IBOutlet NSLayoutConstraint *constraintHeightViewMessage, *constHeightViewContent;
}

- (IBAction)actionSend:(id)sender;
@end
