//
//  AlertPriceNotificationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertPriceNotificationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tblPriceAlert;
    IBOutlet UIView *viewCategory;
    IBOutlet UIImageView *imgArrow;
    IBOutlet NSLayoutConstraint *constraintSpaceViewCategoryAndTbl;
}

- (IBAction)actionShowKategory:(id)sender;
@end
