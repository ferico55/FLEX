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


#pragma mark - Setter Getter
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
