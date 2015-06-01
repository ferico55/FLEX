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
    IBOutlet UIView *viewLineHeader, *viewSeparatorUrutkan;
    IBOutlet UIButton *btnSort, *btnFilter;
    IBOutlet NSLayoutConstraint *constraintHeightTable, *constraintWidthSeparatorButton, *constraintYLineHeader, *constraintWidthUrutkan, *constraintWidthFilter;
}

@property (nonatomic, unsafe_unretained) UIImage *imageHeader;
@property (nonatomic, unsafe_unretained) DetailPriceAlert *detailPriceAlert;
- (void)updatePriceAlert:(NSString *)strPrice;
- (IBAction)actionSort:(id)sender;
- (IBAction)actionFilter:(id)sender;
@end
