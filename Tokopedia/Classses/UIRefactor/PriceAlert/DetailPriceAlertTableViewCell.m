//
//  DetailPriceAlertTableViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailPriceAlertTableViewCell.h"
@implementation CustomButton
@synthesize tagIndexPath;
@end



@implementation DetailPriceAlertTableViewCell

- (void)awakeFromNib {
    btnBuy.layer.cornerRadius = 3.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Action View
- (IBAction)actionBuy:(id)sender
{
    id view = [self superview];
    while (view && ![view isKindOfClass:[UITableView class]]) {
        view = [view superview];
    }
    UITableView *tempTableView = ((UITableView *) view);
    UIViewController *tempViewController = ((UIViewController *) tempTableView.delegate);
    
    if([tempViewController respondsToSelector:@selector(actionBuy:)])
        [tempViewController performSelector:@selector(actionBuy:) withObject:sender];
}

- (IBAction)actionProductName:(id)sender
{
    id view = [self superview];
    while (view && ![view isKindOfClass:[UITableView class]]) {
        view = [view superview];
    }
    UITableView *tempTableView = ((UITableView *) view);
    UIViewController *tempViewController = ((UIViewController *) tempTableView.delegate);
    
    if([tempViewController respondsToSelector:@selector(actionProductName:)])
        [tempViewController performSelector:@selector(actionProductName:) withObject:sender];
}

#pragma mark - SetView
- (CustomButton *)getBtnBuy
{
    return btnBuy;
}


- (CustomButton *)getBtnProductName
{
    return btnProductName;
}

- (void)setNameProduct:(NSString *)strNameProduct
{
    [btnProductName setTitle:strNameProduct forState:UIControlStateNormal];
}

- (void)setProductPrice:(NSString *)strPriceProduct
{
    lblPriceProduct.text = strPriceProduct;
}

- (void)setKondisiProduct:(NSString *)strKondisiProduct
{
    lblConditionProduct.text = strKondisiProduct;
}
@end
