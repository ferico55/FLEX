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
    lineSeparatorDesc.frame = CGRectMake(imageProfile.frame.origin.x, lblDateDesc.frame.origin.y+lblDateDesc.bounds.size.height+CPaddingTopBottom, viewContent.bounds.size.width-(imageProfile.frame.origin.x*2), lineSeparatorDesc.bounds.size.height);
    
    lblKualitas.frame = CGRectMake(lblKualitas.frame.origin.x, lineSeparatorDesc.frame.origin.y+lineSeparatorDesc.bounds.size.height+CPaddingTopBottom, lblKualitas.bounds.size.width, lblKualitas.bounds.size.height);
    viewStarKualitas.frame = CGRectMake(lblKualitas.frame.origin.x+lblKualitas.bounds.size.width, lblKualitas.frame.origin.y-3, viewStarKualitas.bounds.size.width, viewStarKualitas.bounds.size.height);
    
    viewStarAkurasi.frame = CGRectMake(viewContent.bounds.size.width-viewStarAkurasi.bounds.size.width-lblKualitas.frame.origin.x, lblKualitas.frame.origin.y-3, viewStarAkurasi.bounds.size.width, viewStarAkurasi.bounds.size.height);
    lblAkurasi.frame = CGRectMake(viewStarAkurasi.frame.origin.x-lblAkurasi.bounds.size.width, viewStarAkurasi.frame.origin.y+3, lblAkurasi.bounds.size.width, lblAkurasi.bounds.size.height);
    viewSeparatorKualitas.frame = CGRectMake(0, lblAkurasi.frame.origin.y+lblAkurasi.bounds.size.height+CPaddingTopBottom, viewContent.bounds.size.width, viewSeparatorKualitas.bounds.size.height);

    
    btnLike.frame = CGRectMake(lblKualitas.frame.origin.x, viewSeparatorKualitas.frame.origin.y+viewSeparatorKualitas.bounds.size.height, btnLike.bounds.size.width, btnLike.bounds.size.height);
    btnDislike.frame = CGRectMake(btnLike.frame.origin.x+btnLike.bounds.size.width+3, btnLike.frame.origin.y, btnDislike.bounds.size.width, btnDislike.bounds.size.height);
    btnMore.frame = CGRectMake(viewContent.bounds.size.width-btnMore.bounds.size.width, btnLike.frame.origin.y, btnMore.bounds.size.width, btnMore.bounds.size.height);
    btnChat.frame = CGRectMake(btnMore.frame.origin.x-3-btnChat.bounds.size.width, btnMore.frame.origin.y, btnChat.bounds.size.width, btnChat.bounds.size.height);
    viewContent.frame = CGRectMake(viewContent.frame.origin.x, viewContent.frame.origin.y, self.contentView.bounds.size.width-(viewContent.frame.origin.x*2), btnChat.frame.origin.y+btnChat.bounds.size.height+CPaddingTopBottom);
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.bounds.size.width, viewContent.frame.origin.y+viewContent.bounds.size.height+CPaddingTopBottom);
}


#pragma mark - Method
- (void)initProductCell {
    isProductCell = YES;
    viewSeparatorProduct = [[UIView alloc] initWithFrame:CGRectZero];
    imageProduct = [[UIImageView alloc] initWithFrame:CGRectZero];
    labelProductName = [[UILabel alloc] initWithFrame:CGRectZero];
    labelProductName.font = [UIFont fontWithName:@"GothamBook" size:15.0f];
    labelProductName.numberOfLines = 3;
    [viewContent addSubview:viewSeparatorProduct];
    [viewContent addSubview:imageProduct];
    [viewContent addSubview:labelProductName];
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

- (void)setPercentage:(NSString *)strPercentage
{
    lblPercentageRage.text = [NSString stringWithFormat:@"%@%%", strPercentage];
}

- (void)setLabelUser:(NSString *)strUser withTag:(int)tag
{
    [viewLabelUser setText:strUser];
    [viewLabelUser setColor:3];
}


- (void)setLabelDate:(NSString *)strDate
{
    lblDateDesc.text = strDate;
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
