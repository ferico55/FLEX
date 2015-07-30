//
//  ProductDetailReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductDetailReputationCell.h"

@implementation ProductDetailReputationCell

- (void)awakeFromNib {
    if([tvDesc respondsToSelector:@selector(textContainerInset)]) {
        tvDesc.textContainerInset = UIEdgeInsetsZero;
        tvDesc.textContainer.lineFragmentPadding = 0;
    }
    self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
    tvDesc.backgroundColor = [UIColor clearColor];
    [viewStar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapStar:)]];
    [viewStar setUserInteractionEnabled:YES];
    
    imgProfile.layer.cornerRadius = imgProfile.bounds.size.width/2.0f;
    imgProfile.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGSize)getSizeDesc
{
    UILabel *tempLbl = [[UILabel alloc] init];
    tempLbl.font = tvDesc.font;
    tempLbl.numberOfLines = 0;
    tempLbl.textColor = tvDesc.textColor;
    tempLbl.text = tvDesc.text;
    
    return [tempLbl sizeThatFits:CGSizeMake(tvDesc.bounds.size.width, 9999)];
}

- (void)updateConstraints
{
    constraintHeightDesc.constant = [self getSizeDesc].height;
    [super updateConstraints];
}


#pragma mark - Action
- (void)actionTapStar:(id)sender {
    [_delegate actionTapStar:((UITapGestureRecognizer *) sender).view];
}

- (IBAction)actionTryAgain:(id)sender {
    [_delegate actionTryAgain:sender];
}

- (IBAction)actionHapus:(id)sender {
    [_delegate actionHapus:sender];
}

#pragma mark - Method 
- (void)setStar:(int)valueStar {
    valueStar = valueStar>0?valueStar:0;
    if(valueStar == 0) {
        for(int i=0;i<arrImageView.count;i++) {
            UIImageView *tempImage = arrImageView[i];
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
    
    
    for(int i=0;i<arrImageView.count;i++) {
        UIImageView *temporaryImage = arrImageView[i];
        if(i < n) {
            temporaryImage.image = tempImage;
        }
        else
            temporaryImage.image = nil;
    }
}


#pragma mark - Setter Getter
- (UIButton *)getBtnTryAgain {
    return btnRetry;
}

- (UIButton *)getBtnHapus {
    return btnHapus;
}

- (UIView *)getViewStar {
    return viewStar;
}

- (ViewLabelUser *)getViewLabelUser {
    return viewLabelUser;
}

- (UITextView *)getTvDesc {
    return tvDesc;
}

- (UILabel *)getLblDate {
    return lblDate;
}

- (UIImageView *)getImgProfile {
    return imgProfile;
}
@end
