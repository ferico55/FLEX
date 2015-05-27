//
//  DetailPriceAlertTableViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailPriceAlertTableViewCell.h"
@implementation CustomButtonBuy
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
- (void)actionBuy:(id)sender
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

#pragma mark - SetView
- (CustomButtonBuy *)getBtnBuy
{
    return btnBuy;
}

- (void)setNameProduct:(NSString *)strNameProduct
{
    lblProductName.text = strNameProduct;
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
