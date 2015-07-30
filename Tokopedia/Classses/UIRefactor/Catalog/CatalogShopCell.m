//
//  CatalogShopCell.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogShopCell.h"

@implementation CatalogShopCell

- (void)awakeFromNib {
    [viewContentStar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionContentStar:)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)actionContentStar:(id)sender {
    [_delegate actionContentStar:((UITapGestureRecognizer *) sender).view];
}

- (IBAction)tap:(id)sender
{
    if ([[sender view] isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)[sender view];
        if (button.tag == 1) {
            [self.delegate tableViewCell:self didSelectBuyButtonAtIndexPath:_indexPath];
        } else if (button.tag == 2) {
            [self.delegate tableViewCell:self didSelectOtherProductAtIndexPath:_indexPath];
        }
    } else {
        UIView *view = (UIView *)[sender view];
        if (view.tag == 1) {
            [self.delegate tableViewCell:self didSelectShopAtIndexPath:_indexPath];
        } else if (view.tag == 2) {
            [self.delegate tableViewCell:self didSelectProductAtIndexPath:_indexPath];
        }
    }
}

- (void)setTagContentStar:(int)tag {
    viewContentStar.tag = tag;
}

- (void)setShopRate:(NSInteger)valueStar
{
    valueStar = valueStar>0?valueStar:0;
    if(valueStar == 0) {
        for(int i=0;i<self.stars.count;i++) {
            UIImageView *tempImage = self.stars[i];
            if(i == valueStar) {
                tempImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal" ofType:@"png"]];
            }
            else
                tempImage.image = nil;
        }
        
        return;
    }
    
    
    ///Set medal image
    int n = 0;
    if(valueStar<10 || (valueStar>250 && valueStar<=500) || (valueStar>10000 && valueStar<=20000) || (valueStar>500000 && valueStar<=1000000)) {
        n = 1;
    }
    else if((valueStar>10 && valueStar<=40) || (valueStar>500 && valueStar<=1000) || (valueStar>20000 && valueStar<=50000) || (valueStar>1000000 && valueStar<=2000000)) {
        n = 2;
    }
    else if((valueStar>40 && valueStar<=90) || (valueStar>1000 && valueStar<=2000) || (valueStar>50000 && valueStar<=100000) || (valueStar>2000000 && valueStar<=5000000)) {
        n = 3;
    }
    else if((valueStar>90 && valueStar<=150) || (valueStar>2000 && valueStar<=5000) || (valueStar>100000 && valueStar<=200000) || (valueStar>5000000 && valueStar<=10000000)) {
        n = 4;
    }
    else if((valueStar>150 && valueStar<=250) || (valueStar>5000 && valueStar<=10000) || (valueStar>200000 && valueStar<=500000) || valueStar>10000000) {
        n = 5;
    }
    
    //Check image medal
    UIImage *tempImage;
    if(valueStar <= 250) {
        tempImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_bronze" ofType:@"png"]];
    }
    else if(valueStar <= 10000) {
        tempImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_silver" ofType:@"png"]];
    }
    else if(valueStar <= 500000) {
        tempImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_gold" ofType:@"png"]];
    }
    else {
        tempImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_diamond_one" ofType:@"png"]];
    }
    
    
    for(int i=0;i<self.stars.count;i++) {
        UIImageView *temporaryImage = self.stars[i];
        if(i < n) {
            temporaryImage.image = tempImage;
        }
        else
            temporaryImage.image = nil;
    }
}

@end