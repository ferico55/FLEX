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
#import "ReviewImageAttachment.h"
#import <Masonry/Masonry.h>

@implementation ProductReputationCell {
    UIImageView *imageProduct;
    UILabel *labelProductName;
    UIView *viewSeparatorProduct;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    arrAttachedImages = [NSArray sortViewsWithTagInArray:arrAttachedImages];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    [viewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont title2Theme]];
    lblDesc = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [viewContent addSubview:lblDesc];
    
    [viewContentRating addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)]];
    [viewContentAction addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)]];
    imageProfile.layer.cornerRadius = imageProfile.bounds.size.height/2.0f;
    imageProfile.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [imageProfile mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@8);
        make.top.equalTo(@8);
    }];
    
    [lblDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(- CPaddingTopBottom);
        make.height.greaterThanOrEqualTo(@17);
        make.left.equalTo(imageProfile);
        if(isProductCell) {
            make.top.equalTo(labelProductName.mas_bottom).with.offset(CPaddingTopBottom);
        }
        else {
            make.top.equalTo(imageProfile.mas_bottom).with.offset(CPaddingTopBottom * 2);
        }
    }];
    
    [viewSeparatorProduct mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lblDateDesc);
        make.top.equalTo(viewStarKualitas).with.offset(-CPaddingTopBottom);
        make.height.equalTo(@(1));
        make.right.equalTo(viewContent).with.offset(CPaddingTopBottom);
    }];
    [viewAttachedImages mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lblDesc.mas_bottom).with.offset(16);
    }];
    if(isProductCell) {
        [imageProduct mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageProfile.mas_left);
            make.top.equalTo(imageProfile.mas_bottom).with.offset(CPaddingTopBottom * 2);
            make.width.equalTo(@(CheightImage));
            make.height.equalTo(@(CheightImage));
        }];
        [labelProductName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(viewLabelUser);
            make.top.equalTo(imageProduct);
            make.right.equalTo(lblDesc);
            make.height.equalTo(imageProduct);
        }];
    }
    
    btnMore.frame = CGRectMake(((self.bounds.size.width-(viewContent.frame.origin.x*2))-10-btnMore.bounds.size.width), 5, btnMore.bounds.size.width, btnMore.bounds.size.height);
    
    if (_hasAttachedImages) {
        [viewAttachedImages mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lblDesc.mas_bottom).with.offset(CPaddingTopBottom);
            make.height.equalTo(@(CheightImage));
            make.width.equalTo(lblDesc.mas_width);
            make.left.equalTo(imageProfile);
        }];
        [lblDateDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageProfile);
            make.width.equalTo(lblDesc);
            make.height.greaterThanOrEqualTo(@(17));
            make.top.equalTo(viewAttachedImages.mas_bottom).with.offset(CPaddingTopBottom * 2);
        }];
    } else {
        [lblDateDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageProfile);
            make.top.equalTo(lblDesc.mas_bottom).with.offset(CPaddingTopBottom * 2);
            make.width.equalTo(lblDesc);
            make.height.greaterThanOrEqualTo(@(17));
        }];
    }
    
    [viewContentRating mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(imageProfile);
        make.top.equalTo(lblDateDesc.mas_bottom).with.offset(CPaddingTopBottom);
        make.height.equalTo(@(viewContentRating.isHidden ? 0 : CHeightContentRate));
        make.width.equalTo(@((self.bounds.size.width-(viewContent.frame.origin.x*2))-(imageProfile.frame.origin.x*2)));
    }];
    
    [lineSeparatorDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewContentAction.mas_top).with.offset(-CPaddingTopBottom/2);
        make.left.equalTo(@(0)).with.offset(-CPaddingTopBottom * 2);
        make.right.equalTo(viewContent).with.offset(CPaddingTopBottom * 2);
        make.height.equalTo(@(1));
    }];
    
    [lblKualitas mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageProfile);
        make.top.equalTo(viewContentRating).with.offset(((viewContentRating.bounds.size.height-lblKualitas.bounds.size.height)/2.0f));
    }];
    [viewStarKualitas mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lblKualitas.mas_right).with.offset(2);
        make.top.equalTo(lblKualitas).with.offset(-3);
    }];
    [lblAkurasi mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lblKualitas);
        make.left.equalTo(viewStarKualitas.mas_right).with.offset(viewStarKualitas.frame.size.width + 8);
    }];
    [viewStarAkurasi mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lblAkurasi.mas_right).with.offset(2);
        make.top.equalTo(viewStarKualitas);
    }];
    
    viewAttachedImages.frame = CGRectMake(0,0,0,0);
    
    [viewContentAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.top.equalTo(viewContentRating.mas_bottom);
        make.right.equalTo(lblDesc);
        make.height.equalTo(@(viewContentAction.isHidden?0:CHeightContentAction));
    }];
    
    [viewSeparatorKualitas mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(0));
        make.height.equalTo(@(0));
        make.top.equalTo(@(-1000));
    }];
    [viewSeparatorKualitas setHidden:YES];
    [btnLike mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewContentRating);
        make.top.equalTo(viewContentAction);
        make.height.equalTo(viewContentAction);
    }];
    [btnDislike mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnLike.mas_right).with.offset(-40);
        make.top.equalTo(btnLike);
        make.size.equalTo(btnLike);
    }];
    [btnChat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnLike).with.offset(5);
        make.size.equalTo(btnLike);
        make.left.equalTo(@((self.bounds.size.width-(viewContent.frame.origin.x*2))-btnChat.bounds.size.width-viewContentRating.frame.origin.x));
    }];
    [viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(CPaddingTopBottom));
        make.top.equalTo(@(CPaddingTopBottom / 2));
        make.width.equalTo(@([[UIScreen mainScreen] bounds].size.width-(viewContent.frame.origin.x*2)));
        make.bottom.equalTo(viewContentAction).with.offset(-CPaddingTopBottom + 2);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.width.equalTo(@([[UIScreen mainScreen] bounds].size.width));
        make.bottom.equalTo(viewContent);
    }];
    
    if(! viewContentLoad.isHidden) {
        actLoading.frame = CGRectMake((viewContentLoad.bounds.size.width-actLoading.bounds.size.width)/2.0f, (viewContentLoad.bounds.size.height-actLoading.bounds.size.height)/2.0f, actLoading.bounds.size.width, actLoading.bounds.size.height);
    }
    [btnChat setHidden:YES];
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
        viewSeparatorProduct.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
        imageProduct = [[UIImageView alloc] initWithFrame:CGRectZero];
        labelProductName = [[UILabel alloc] initWithFrame:CGRectZero];
        labelProductName.font = [UIFont smallThemeMedium];
        labelProductName.textColor = [UIColor colorWithRed:66/255.0f green:66/255.0f blue:66/255.0f alpha:1.0f];
        labelProductName.numberOfLines = 3;
        [viewContent addSubview:viewSeparatorProduct];
        [viewContent addSubview:imageProduct];
        [viewContent addSubview:labelProductName];
    }
}

- (void)setImageKualitas:(int)total {
    for(int i=0;i<arrImageKualitas.count;i++) {
        ((UIImageView *) [arrImageKualitas objectAtIndex:i]).image = [UIImage imageNamed:(i<total)? @"icon_star_active":@"icon_star"];
    }
}

- (void)setImageAkurasi:(int)total {
    for(int i=0;i<arrImageKualitas.count;i++) {
        ((UIImageView *) [arrImageAkurasi objectAtIndex:i]).image = [UIImage imageNamed:(i<total)? @"icon_star_active":@"icon_star"];
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

- (IBAction)tapOnAttachedImage:(id)sender {
    [_delegate didTapAttachedImage:sender];
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

- (UIView *)getViewSeparatorProduct {
    return viewSeparatorProduct;
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

- (UILabel *)getLabelPercentageRate {
    return lblPercentageRage;
}

- (void)setPercentage:(NSString *)strPercentage
{
    if(strPercentage.length==0 || [strPercentage isEqualToString:@"0"])
        lblPercentageRage.text = @"";
    else
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
}

- (void)setAttachedImages:(NSArray *)attachedImages {
    for (int ii = 0; ii < attachedImages.count; ii++) {
        for (UIImageView *imageView in arrAttachedImages) {
            if (imageView.tag == ii) {
                ReviewImageAttachment *image = attachedImages[ii];
                
                [imageView setImageWithURL:[NSURL URLWithString:image.uri_thumbnail]
                          placeholderImage:[UIImage imageNamed:@"image_not_loading.png"]];
                [imageView setUserInteractionEnabled:YES];
                [imageView setHidden:NO];
                [imageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnAttachedImage:)]];
            }
        }
    }
}

- (void)nothing:(id)sender {
    
}

- (void)enableLikeButton{
    [btnLike setImage:[UIImage imageNamed:@"icon_like_active"] forState:UIControlStateNormal];
}

- (void)disableLikeButton{
    [btnLike setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
}

- (void)resetLikeDislikeButton{
    [btnLike setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
    [btnDislike setImage:[UIImage imageNamed:@"icon_dislike"] forState:UIControlStateNormal];
}

- (void)enableDislikeButton{
    [btnDislike setImage:[UIImage imageNamed:@"icon_dislike_active"] forState:UIControlStateNormal];
}

-(void)disableDislikeButton{
    [btnDislike setImage:[UIImage imageNamed:@"icon_dislike"] forState:UIControlStateNormal];
}

- (void)disableTouchLikeDislikeButton{
    [btnLike setUserInteractionEnabled:NO];
    [btnDislike setUserInteractionEnabled:NO];
}

- (void)enableTouchLikeDislikeButton{
    [btnLike setUserInteractionEnabled:YES];
    [btnDislike setUserInteractionEnabled:YES];
}

@end
