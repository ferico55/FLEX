//
//  DetailPriceAlertViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailPriceAlertViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tblDetailPriceAlert;
    IBOutlet UIImageView *imgUpDownKondisi;
    IBOutlet UIView *viewKondisi, *viewLineHeader;
    IBOutlet NSLayoutConstraint *constraintHeightTable, *constraintVerticalKondisiAndTable, *constraintYLineHeader;
}

- (IBAction)actionShowCondition:(id)sender;
@end
