//
//  DetailPriceAlertViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailPriceAlert;

@interface DetailPriceAlertViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tblDetailPriceAlert;
    IBOutlet UIView *viewKondisi, *viewLineHeader;
    IBOutlet NSLayoutConstraint *constraintHeightTable, *constraintVerticalKondisiAndTable, *constraintYLineHeader;
}

@property (nonatomic, unsafe_unretained) UIImage *imageHeader;
@property (nonatomic, unsafe_unretained) DetailPriceAlert *detailPriceAlert;
- (void)updatePriceAlert:(NSString *)strPrice;
- (IBAction)actionSort:(id)sender;
- (IBAction)actionFilter:(id)sender;
@end
