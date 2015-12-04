//
//  ProductDetailReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductDetailReputationCell.h"
#import "SmileyAndMedal.h"

@implementation ProductDetailReputationCell

- (void)awakeFromNib {
    if([tvDesc respondsToSelector:@selector(textContainerInset)]) {
        tvDesc.textContainerInset = UIEdgeInsetsZero;
        tvDesc.textContainer.lineFragmentPadding = 0;
    }
    self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
    tvDesc.backgroundColor = [UIColor clearColor];
    [tvDesc sizeToFit];
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
    [_del actionTapStar:((UITapGestureRecognizer *) sender).view];
}

- (IBAction)actionTryAgain:(id)sender {
    [_del actionTryAgain:sender];
}

#pragma mark - Method 
- (void)setStar:(NSString *)level withSet:(NSString *)strSet {
    [SmileyAndMedal generateMedalWithLevel:level withSet:strSet withImage:arrImageView isLarge:YES];
}

#pragma mark - Setter Getter
- (UIButton *)getBtnTryAgain {
    return btnRetry;
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
