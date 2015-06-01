//
//  PriceAlertCell.m
//  Tokopedia
//
//  Created by Tokopedia on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PriceAlertCell.h"
#define CStringFormatRupiah @"Rp."

@implementation PriceAlertCell
{
    NSDateFormatter *dateFormat;
}

- (void)awakeFromNib {
    dateFormat = [NSDateFormatter new];
    dateFormat.dateFormat = @"dd MM yyyy, HH:mm WIB";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
    
    }
    
    return self;
}



#pragma mark - Action View
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)actionDelete:(id)sender
{
    id view = [self superview];
    while (view && ![view isKindOfClass:[UITableView class]]) {
        view = [view superview];
    }
    UITableView *tempTableView = ((UITableView *) view);
    UIViewController *tempViewController = ((UIViewController *) tempTableView.delegate);
    
    if([tempViewController respondsToSelector:@selector(actionCloseCell:)])
        [tempViewController performSelector:@selector(actionCloseCell:) withObject:sender];
}
#pragma clang diagnostic pop

#pragma mark - SetView
- (void)setImageProduct:(UIImage *)imgProduct
{
    imgProductView.image = imgProduct;
}

- (void)setProductName:(NSString *)strProductName
{
    [btnProductName setTitle:strProductName forState:UIControlStateNormal];
}

- (UIButton *)getBtnProductName
{
    return btnProductName;
}

- (void)setLblDateProduct:(NSDate *)date
{
    lblDateProduct.text = [dateFormat stringFromDate:date];
}

- (void)setLowPrice:(NSString *)strPrice
{
    lblLowPrice.text = strPrice;
}

- (void)setTagBtnClose:(int)tag
{
    btnClose.tag = tag;
}

- (void)setPriceNotification:(NSString *)strPrice
{
    lblPriceNotification.text = strPrice;
}

#pragma mark - GetView
- (UIImageView *)getProductImage
{
    return imgProductView;
}

- (UIView *)getViewContent
{
    return viewContent;
}

- (UIButton *)getBtnClose
{
    return btnClose;
}

- (NSLayoutConstraint *)getConstraintY
{
    return constraintYViewContent;
}

- (NSLayoutConstraint *)getConstraintX
{
    return constraintXViewContent;
}

- (NSLayoutConstraint *)getConstraintBottom
{
    return constraintBottomViewContent;
}

- (NSLayoutConstraint *)getConstraintProductNameAndX
{
    return constraingTrailingProductNameAndX;
}

- (NSLayoutConstraint *)getConstraintTrailling
{
    return constraintTraillingViewContent;
}
@end
