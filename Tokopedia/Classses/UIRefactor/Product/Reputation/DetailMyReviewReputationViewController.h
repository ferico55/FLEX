//
//  DetailMyReviewReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailMyInboxReputation, TTTAttributedLabel;

@interface DetailMyReviewReputationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIActivityIndicatorView *actIndicator;
    IBOutlet UIView *viewFooter;
    IBOutlet UITableView *tableContent;
}

@property (nonatomic, unsafe_unretained) DetailMyInboxReputation *detailMyInboxReputation;
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription;
@end
