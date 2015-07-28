//
//  MyReviewReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyReviewReputationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIView *viewFooter, *viewShadow;
    IBOutlet UITableView *tableContent;
}


@property (nonatomic, strong) NSString *strNav;
- (void)actionReview:(id)sender;
- (void)actionReviewRate:(id)sender;
- (void)actionBelumDibaca:(id)sender;
- (void)actionBelumDireview:(id)sender;
- (void)actionFlagReview:(id)sender;
@end
