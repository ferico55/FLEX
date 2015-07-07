//
//  PriceAlertCell.h
//  Tokopedia
//
//  Created by Tokopedia on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PriceAlertCell : UITableViewCell
{
    IBOutlet UIImageView *imgProductView;
    IBOutlet UIButton *btnProductName;
    IBOutlet UILabel *lblProductDate;
    IBOutlet UILabel *lblPriceNotification;
    IBOutlet UILabel *lblLowPrice;
    IBOutlet UIView *viewContent, *viewUnread;
    IBOutlet UIButton *btnClose;
    IBOutlet NSLayoutConstraint *constraintHeightProductName;
    IBOutlet NSLayoutConstraint *constraintYViewContent;
    IBOutlet NSLayoutConstraint *constraintXViewContent;
    IBOutlet NSLayoutConstraint *constraintBottomViewContent;
    IBOutlet NSLayoutConstraint *constraintTraillingViewContent;
    IBOutlet NSLayoutConstraint *constraingTrailingProductNameAndX;
}
@property (nonatomic, strong) UIViewController *viewController;

- (void)setImageProduct:(UIImage *)imgProduct;
- (void)setProductName:(NSString *)strProductName;
- (void)setLblDateProduct:(NSString *)date;
- (void)setLowPrice:(NSString *)strPrice;
- (void)setPriceNotification:(NSString *)strPrice;
- (void)setTagBtnClose:(int)tag;
- (IBAction)actionDelete:(id)sender;
- (UIImageView *)getProductImage;
- (UIView *)getViewContent;
- (UIView *)getViewUnread;
- (UIButton *)getBtnClose;
- (UIButton *)getBtnProductName;
- (NSLayoutConstraint *)getConstraintHeigthProductName;
- (NSLayoutConstraint *)getConstraintY;
- (NSLayoutConstraint *)getConstraintX;
- (NSLayoutConstraint *)getConstraintBottom;
- (NSLayoutConstraint *)getConstraintTrailling;
- (NSLayoutConstraint *)getConstraintProductNameAndX;
@end
