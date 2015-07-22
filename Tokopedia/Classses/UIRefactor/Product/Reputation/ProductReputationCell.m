//
//  ProductReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "ProductReputationViewController.h"
#import "ProductReputationCell.h"
#import "ViewLabelUser.h"


@implementation ProductReputationCell {
    UIImageView *imageProduct;
    UILabel *labelProductName;
    UIView *viewSeparatorProduct;
}

- (void)awakeFromNib {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    [viewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamBook" size:15.0f]];
    lblDesc = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [viewContent addSubview:lblDesc];
    
    
    imageProfile.layer.cornerRadius = imageProfile.bounds.size.height/2.0f;
    imageProfile.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    if(isProductCell) {
        viewSeparatorProduct.frame = CGRectMake(CPaddingTopBottom, imageProfile.frame.origin.y+imageProfile.bounds.size.height+CPaddingTopBottom, lineSeparatorDesc.bounds.size.width, 1);
        imageProduct.frame = CGRectMake(imageProfile.frame.origin.x, CPaddingTopBottom + viewSeparatorProduct.frame.origin.y+viewSeparatorProduct.bounds.size.height, CheightImage, CheightImage);
        labelProductName.frame = CGRectMake(viewLabelUser.frame.origin.x, imageProduct.frame.origin.y, viewLabelUser.bounds.size.width, imageProduct.bounds.size.height);
        lblDesc.frame = CGRectMake(lblDesc.frame.origin.x, CPaddingTopBottom + imageProduct.frame.origin.y+imageProduct.bounds.size.height, lblDesc.bounds.size.width, lblDesc.bounds.size.height);
    }
    
    
    lblDateDesc.frame = CGRectMake(imageProfile.frame.origin.x, CPaddingTopBottom+lblDesc.frame.origin.y+lblDesc.bounds.size.height, lblDesc.bounds.size.width, lblDateDesc.bounds.size.height);
    viewContentRating.frame = CGRectMake(imageProfile.frame.origin.x, lblDateDesc.frame.origin.y+lblDateDesc.bounds.size.height+CPaddingTopBottom, viewContent.bounds.size.width-(imageProfile.frame.origin.x*2), (viewContentRating.isHidden)?0:CHeightContentRate);
    lineSeparatorDesc.frame = CGRectMake(0, 0, viewContentRating.bounds.size.width, lineSeparatorDesc.bounds.size.height);
    
    lblKualitas.frame = CGRectMake(lblKualitas.frame.origin.x, lineSeparatorDesc.frame.origin.y+lineSeparatorDesc.bounds.size.height+CPaddingTopBottom, lblKualitas.bounds.size.width, lblKualitas.bounds.size.height);
    viewStarKualitas.frame = CGRectMake(lblKualitas.frame.origin.x+lblKualitas.bounds.size.width, lblKualitas.frame.origin.y, viewStarKualitas.bounds.size.width, viewStarKualitas.bounds.size.height);
    
    viewStarAkurasi.frame = CGRectMake(viewContentRating.bounds.size.width-viewStarAkurasi.bounds.size.width-lblKualitas.frame.origin.x, lblKualitas.frame.origin.y, viewStarAkurasi.bounds.size.width, viewStarAkurasi.bounds.size.height);
    lblAkurasi.frame = CGRectMake(viewStarAkurasi.frame.origin.x-lblAkurasi.bounds.size.width, viewStarAkurasi.frame.origin.y+3, lblAkurasi.bounds.size.width, lblAkurasi.bounds.size.height);
    
    
    //View content action
    viewContentAction.frame = CGRectMake(0, viewContentRating.frame.origin.y+viewContentRating.bounds.size.height, viewContent.bounds.size.width, viewContentAction.isHidden?0:CHeightContentAction);
    viewSeparatorKualitas.frame = CGRectMake(0, 0, viewContent.bounds.size.width, viewSeparatorKualitas.bounds.size.height);
    btnLike.frame = CGRectMake(viewContentRating.frame.origin.x, viewSeparatorKualitas.frame.origin.y+viewSeparatorKualitas.bounds.size.height, btnLike.bounds.size.width, viewContentAction.bounds.size.height);
    btnDislike.frame = CGRectMake(btnLike.frame.origin.x+btnLike.bounds.size.width+3, btnLike.frame.origin.y, btnDislike.bounds.size.width, btnLike.bounds.size.height);
    btnMore.frame = CGRectMake(viewContent.bounds.size.width-btnMore.bounds.size.width-viewContentRating.frame.origin.x, btnLike.frame.origin.y, btnMore.bounds.size.width, btnLike.bounds.size.height);
    btnChat.frame = CGRectMake(btnMore.frame.origin.x-8-btnMore.bounds.size.width, btnMore.frame.origin.y, btnMore.bounds.size.width, btnLike.bounds.size.height);
    
    
    viewContent.frame = CGRectMake(viewContent.frame.origin.x, viewContent.frame.origin.y, self.contentView.bounds.size.width-(viewContent.frame.origin.x*2), viewContentAction.frame.origin.y+viewContentAction.bounds.size.height);
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.bounds.size.width, viewContent.frame.origin.y+viewContent.bounds.size.height+CPaddingTopBottom);
}


#pragma mark - Method
- (void)setHiddenAction:(BOOL)hidden {
    viewContentAction.hidden = hidden;
}

- (void)setHiddenRating:(BOOL)hidden {
    viewContentRating.hidden = hidden;
}

- (void)initProductCell {
    if(viewSeparatorProduct == nil) {
        isProductCell = YES;        
        viewSeparatorProduct = [[UIView alloc] initWithFrame:CGRectZero];
        imageProduct = [[UIImageView alloc] initWithFrame:CGRectZero];
        labelProductName = [[UILabel alloc] initWithFrame:CGRectZero];
        labelProductName.font = [UIFont fontWithName:@"Gotham Medium" size:15.0f];
        labelProductName.textColor = [UIColor colorWithRed:66/255.0f green:66/255.0f blue:66/255.0f alpha:1.0f];
        labelProductName.numberOfLines = 3;
        [viewContent addSubview:viewSeparatorProduct];
        [viewContent addSubview:imageProduct];
        [viewContent addSubview:labelProductName];
    }
}

- (void)setImageKualitas:(int)total {
    for(int i=0;i<arrImageKualitas.count;i++) {
        ((UIImageView *) [arrImageKualitas objectAtIndex:i]).image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<total)? @"icon_star_active":@"icon_star" ofType:@"png"]];
    }
}

- (void)setImageAkurasi:(int)total {
    for(int i=0;i<arrImageKualitas.count;i++) {
        ((UIImageView *) [arrImageAkurasi objectAtIndex:i]).image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<total)? @"icon_star_active":@"icon_star" ofType:@"png"]];
    }
}


#pragma mark - Action
- (IBAction)actionRate:(id)sender {
    [_delegate actionRate:sender];
}

- (IBAction)actionLike:(id)sender {
    [_delegate actionLike:sender];
}

- (IBAction)actionDisLike:(id)sender {
    [_delegate actionDisLike:sender];
}

- (IBAction)actionChat:(id)sender {
    [_delegate actionChat:sender];
}

- (IBAction)actionMore:(id)sender {
    [_delegate actionMore:sender];
}


#pragma mark - Setter and Getter
- (UIImageView *)getProductImage {
    return imageProduct;
}

- (void)setLabelProductName:(NSString *)strProductName {
    labelProductName.text = strProductName;
}

- (UIView *)getViewContent {
    return viewContent;
}

- (UIView *)getViewContentAction {
    return viewContentAction;
}

- (ViewLabelUser *)getLabelUser {
    return viewLabelUser;
}

- (UIView *)getViewSeparatorKualitas {
    return viewSeparatorKualitas;
}

- (TTTAttributedLabel *)getLabelDesc {
    return lblDesc;
}

- (UIImageView *)getImageProfile
{
    return imageProfile;
}

- (UIButton *)getBtnRateEmoji {
    return btnRateEmoji;
}

- (UIButton *)getBtnLike {
    return btnLike;
}

- (UIButton *)getBtnDisLike {
    return btnDislike;
}

- (UIButton *)getBtnChat {
    return btnChat;
}

- (UIButton *)getBtnMore {
    return btnMore;
}

- (UILabel *)getLabelProductName {
    return labelProductName;
}

- (void)setPercentage:(NSString *)strPercentage
{
    lblPercentageRage.text = [NSString stringWithFormat:@"%@%%", strPercentage];
}

- (void)setLabelUser:(NSString *)strUser withUserLabel:(NSString *)strUserLabel
{
    [viewLabelUser setLabelBackground:strUserLabel];
    [viewLabelUser setText:strUser];
}


- (void)setLabelDate:(NSString *)strDate
{
    lblDateDesc.text = strDate;
}

- (void)setHiddenViewLoad:(BOOL)isLoading {
    if(! isLoading) {
        viewContentLoad.hidden = NO;
        [actLoading startAnimating];
    }
    else {
        viewContentLoad.hidden = YES;
        [actLoading stopAnimating];
    }
}

- (void)setDescription:(NSString *)strDescription
{
    [_delegate initLabelDesc:lblDesc withText:strDescription];
    lblDesc.frame = CGRectMake(imageProfile.frame.origin.x, CPaddingTopBottom + (isProductCell? imageProduct.frame.origin.y+imageProduct.bounds.size.height : imageProfile.frame.origin.y+imageProfile.bounds.size.height), viewContent.bounds.size.width-(imageProfile.frame.origin.x*2), 0);
    CGSize tempSizeDesc = [lblDesc sizeThatFits:CGSizeMake(lblDesc.bounds.size.width, 9999)];
    CGRect tempLblRect = lblDesc.frame;
    tempLblRect.size.height = tempSizeDesc.height;
    lblDesc.frame = tempLblRect;
}
@end
