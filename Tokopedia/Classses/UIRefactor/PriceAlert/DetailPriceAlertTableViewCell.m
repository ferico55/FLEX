//
//  DetailPriceAlertTableViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailPriceAlertTableViewCell.h"

@implementation DetailPriceAlertTableViewCell

- (void)awakeFromNib {
    btnBuy.layer.cornerRadius = 3.0f;
    imagePerson.layer.cornerRadius = imagePerson.bounds.size.width/2.0f;
    imageProduct.layer.masksToBounds = YES;
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
- (void)setImgProduct:(UIImage *)imgProduct
{
    imageProduct.image = imgProduct;
}

- (void)setImgPerson:(UIImage *)imgPerson
{
    imagePerson.image = imgPerson;
}

- (void)setName:(NSString *)strName
{
    lblName.text = strName;
}

- (void)setNameProduct:(NSString *)strNameProduct
{
    lblProductName.text = strNameProduct;
}

- (void)setKondisiProduct:(NSString *)strKondisiProduct
{
    lblConditionProduct.text = strKondisiProduct;
}

- (void)setDateProduct:(NSDate *)date
{
    lblProductDate.text = @"20123/12/12";
}
@end
