//
//  AlertPriceNotificationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailPriceAlertViewController;

@interface AlertPriceNotificationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tblPriceAlert;
    IBOutlet UIView *viewCategory;
    IBOutlet UIImageView *imgArrow;
    IBOutlet NSLayoutConstraint *constraintSpaceViewCategoryAndTbl;
}

- (IBAction)actionShowCategory:(id)sender;
- (void)updatePriceAlert:(NSString *)strPrice;
- (void)replaceDataSelected:(id)data;

@property (strong, nonatomic) DetailPriceAlertViewController *detailViewController;
@property (strong, nonatomic) UIViewController *splitVC;



@end
