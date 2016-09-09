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

@implementation ProductReputationCell {
    UIImageView *imageProduct;
    UILabel *labelProductName;
    UIView *viewSeparatorProduct;
}

- (void)awakeFromNib {
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
    if(isProductCell) {
        viewSeparatorProduct.frame = CGRectMake(CPaddingTopBottom, imageProfile.frame.origin.y+imageProfile.bounds.size.height+CPaddingTopBottom, self.bounds.size.width, 1);
        imageProduct.frame = CGRectMake(imageProfile.frame.origin.x, CPaddingTopBottom + viewSeparatorProduct.frame.origin.y+viewSeparatorProduct.bounds.size.height, CheightImage, CheightImage);
        labelProductName.frame = CGRectMake(viewLabelUser.frame.origin.x, imageProduct.frame.origin.y, viewLabelUser.bounds.size.width, imageProduct.bounds.size.height);
        lblDesc.frame = CGRectMake(lblDesc.frame.origin.x, CPaddingTopBottom + imageProduct.frame.origin.y+imageProduct.bounds.size.height + CPaddingTopBottom, lblDesc.bounds.size.width, lblDesc.bounds.size.height);
        viewAttachedImages.frame = CGRectMake(viewAttachedImages.frame.origin.x, 8 + lblDesc.frame.origin.y + lblDesc.bounds.size.height + 8, viewAttachedImages.bounds.size.width, viewAttachedImages.bounds.size.height);
    }
    
    btnMore.frame = CGRectMake((self.bounds.size.width-(viewContent.frame.origin.x*2))-10-btnMore.bounds.size.width, 5, btnMore.bounds.size.width, btnMore.bounds.size.height);
    
    if (_hasAttachedImages) {
        lblDateDesc.frame = CGRectMake(imageProfile.frame.origin.x, CPaddingTopBottom+lblDesc.frame.origin.y+lblDesc.bounds.size.height+CPaddingTopBottom + viewAttachedImages.bounds.size.height + 8, lblDesc.bounds.size.width, lblDateDesc.bounds.size.height);
        viewContentRating.frame = CGRectMake(imageProfile.frame.origin.x, lblDateDesc.frame.origin.y+lblDateDesc.bounds.size.height+CPaddingTopBottom, (self.bounds.size.width-(viewContent.frame.origin.x*2))-(imageProfile.frame.origin.x*2), (viewContentRating.isHidden)?0:CHeightContentRate);
        lineSeparatorDesc.frame = CGRectMake(0, 0, viewContentRating.bounds.size.width, lineSeparatorDesc.bounds.size.height);
        
        lblKualitas.frame = CGRectMake(lblKualitas.frame.origin.x, lineSeparatorDesc.frame.origin.y+lineSeparatorDesc.bounds.size.height+((viewContentRating.bounds.size.height-lblKualitas.bounds.size.height)/2.0f), lblKualitas.bounds.size.width, lblKualitas.bounds.size.height);
        viewStarKualitas.frame = CGRectMake(lblKualitas.frame.origin.x+lblKualitas.bounds.size.width+2, lblKualitas.frame.origin.y-3, viewStarKualitas.bounds.size.width, viewStarKualitas.bounds.size.height);
        
        viewStarAkurasi.frame = CGRectMake(viewContentRating.bounds.size.width-viewStarAkurasi.bounds.size.width, viewStarKualitas.frame.origin.y, viewStarAkurasi.bounds.size.width, viewStarAkurasi.bounds.size.height);
        lblAkurasi.frame = CGRectMake(viewStarAkurasi.frame.origin.x-lblAkurasi.bounds.size.width-2, lblKualitas.frame.origin.y, lblAkurasi.bounds.size.width, lblAkurasi.bounds.size.height);
        
        
        //View content action
        viewContentAction.frame = CGRectMake(0, viewContentRating.frame.origin.y+viewContentRating.bounds.size.height, (self.bounds.size.width-(viewContent.frame.origin.x*2)), viewContentAction.isHidden?0:CHeightContentAction);
        viewSeparatorKualitas.frame = CGRectMake(0, 0, (self.bounds.size.width-(viewContent.frame.origin.x*2)), viewSeparatorKualitas.bounds.size.height);
        btnLike.frame = CGRectMake(viewContentRating.frame.origin.x, viewSeparatorKualitas.frame.origin.y+viewSeparatorKualitas.bounds.size.height, btnLike.bounds.size.width, viewContentAction.bounds.size.height);
        btnDislike.frame = CGRectMake(btnLike.frame.origin.x+btnLike.bounds.size.width+3, btnLike.frame.origin.y, btnDislike.bounds.size.width, btnLike.bounds.size.height);
        btnChat.frame = CGRectMake((self.bounds.size.width-(viewContent.frame.origin.x*2))-btnChat.bounds.size.width-viewContentRating.frame.origin.x, btnLike.frame.origin.y+5, btnChat.bounds.size.width, btnChat.bounds.size.height);
        viewContent.frame = CGRectMake(viewContent.frame.origin.x, viewContent.frame.origin.y, [[UIScreen mainScreen] bounds].size.width-(viewContent.frame.origin.x*2), viewContentAction.frame.origin.y+viewContentAction.bounds.size.height);
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, viewContent.frame.origin.y+viewContent.bounds.size.height+CPaddingTopBottom);
        
        
        if(! viewContentLoad.isHidden) {
            viewContentLoad.frame = CGRectMake(0, 0, viewContentAction.bounds.size.width, viewContentLoad.bounds.size.height);
            actLoading.frame = CGRectMake((viewContentLoad.bounds.size.width-actLoading.bounds.size.width)/2.0f, (viewContentLoad.bounds.size.height-actLoading.bounds.size.height)/2.0f, actLoading.bounds.size.width, actLoading.bounds.size.height);
        }
        [btnChat setHidden:YES];
    } else {
        lblDateDesc.frame = CGRectMake(imageProfile.frame.origin.x, CPaddingTopBottom+lblDesc.frame.origin.y+lblDesc.bounds.size.height+CPaddingTopBottom, lblDesc.bounds.size.width, lblDateDesc.bounds.size.height);
        viewContentRating.frame = CGRectMake(imageProfile.frame.origin.x, lblDateDesc.frame.origin.y+lblDateDesc.bounds.size.height+CPaddingTopBottom, (self.bounds.size.width-(viewContent.frame.origin.x*2))-(imageProfile.frame.origin.x*2), (viewContentRating.isHidden)?0:CHeightContentRate);
        lineSeparatorDesc.frame = CGRectMake(0, 0, viewContentRating.bounds.size.width, lineSeparatorDesc.bounds.size.height);
        
        lblKualitas.frame = CGRectMake(lblKualitas.frame.origin.x, lineSeparatorDesc.frame.origin.y+lineSeparatorDesc.bounds.size.height+((viewContentRating.bounds.size.height-lblKualitas.bounds.size.height)/2.0f), lblKualitas.bounds.size.width, lblKualitas.bounds.size.height);
        viewStarKualitas.frame = CGRectMake(lblKualitas.frame.origin.x+lblKualitas.bounds.size.width+2, lblKualitas.frame.origin.y-3, viewStarKualitas.bounds.size.width, viewStarKualitas.bounds.size.height);
        
        viewStarAkurasi.frame = CGRectMake(viewContentRating.bounds.size.width-viewStarAkurasi.bounds.size.width, viewStarKualitas.frame.origin.y, viewStarAkurasi.bounds.size.width, viewStarAkurasi.bounds.size.height);
        lblAkurasi.frame = CGRectMake(viewStarAkurasi.frame.origin.x-lblAkurasi.bounds.size.width-2, lblKualitas.frame.origin.y, lblAkurasi.bounds.size.width, lblAkurasi.bounds.size.height);
        
        viewAttachedImages.frame = CGRectMake(0,0,0,0);
        
        
        //View content action
        viewContentAction.frame = CGRectMake(0, viewContentRating.frame.origin.y+viewContentRating.bounds.size.height, (self.bounds.size.width-(viewContent.frame.origin.x*2)), viewContentAction.isHidden?0:CHeightContentAction);
        viewSeparatorKualitas.frame = CGRectMake(0, 0, (self.bounds.size.width-(viewContent.frame.origin.x*2)), viewSeparatorKualitas.bounds.size.height);
        btnLike.frame = CGRectMake(viewContentRating.frame.origin.x, viewSeparatorKualitas.frame.origin.y+viewSeparatorKualitas.bounds.size.height, btnLike.bounds.size.width, viewContentAction.bounds.size.height);
        btnDislike.frame = CGRectMake(btnLike.frame.origin.x+btnLike.bounds.size.width+3, btnLike.frame.origin.y, btnDislike.bounds.size.width, btnLike.bounds.size.height);
        btnChat.frame = CGRectMake((self.bounds.size.width-(viewContent.frame.origin.x*2))-btnChat.bounds.size.width-viewContentRating.frame.origin.x, btnLike.frame.origin.y+5, btnChat.bounds.size.width, btnChat.bounds.size.height);
        viewContent.frame = CGRectMake(viewContent.frame.origin.x, viewContent.frame.origin.y, [[UIScreen mainScreen] bounds].size.width-(viewContent.frame.origin.x*2), viewContentAction.frame.origin.y+viewContentAction.bounds.size.height);
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, viewContent.frame.origin.y+viewContent.bounds.size.height+CPaddingTopBottom);
        
        
        if(! viewContentLoad.isHidden) {
            viewContentLoad.frame = CGRectMake(0, 0, viewContentAction.bounds.size.width, viewContentLoad.bounds.size.height);
            actLoading.frame = CGRectMake((viewContentLoad.bounds.size.width-actLoading.bounds.size.width)/2.0f, (viewContentLoad.bounds.size.height-actLoading.bounds.size.height)/2.0f, actLoading.bounds.size.width, actLoading.bounds.size.height);
        }
        [btnChat setHidden:YES];
    }
    
    
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
    lblDesc.frame = CGRectMake(imageProfile.frame.origin.x,
                               CPaddingTopBottom + (isProductCell
                                                    ?
                                                    imageProduct.frame.origin.y+imageProduct.bounds.size.height
                                                    :
                                                    imageProfile.frame.origin.y+imageProfile.bounds.size.height)+CPaddingTopBottom,
                               viewContent.frame.size.width,
                               0);
    CGSize tempSizeDesc = [lblDesc sizeThatFits:CGSizeMake(lblDesc.bounds.size.width, 9999)];
    CGRect tempLblRect = lblDesc.frame;
    tempLblRect.size.height = tempSizeDesc.height;
    lblDesc.frame = tempLblRect;
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
            }
        }
    }
    
    if (isProductCell) {
        viewAttachedImages.frame = CGRectMake(imageProfile.frame.origin.x,
                                              24 + imageProfile.frame.origin.y + imageProfile.bounds.size.height + lblDesc.frame.origin.y + lblDesc.bounds.size.height,
                                              viewContent.frame.size.width,
                                              66);
    } else {
        viewAttachedImages.frame = CGRectMake(imageProfile.frame.origin.x,
                                              16 + lblDesc.frame.origin.y + lblDesc.bounds.size.height,
                                              viewContent.frame.size.width,
                                              66);
    }
    
}

- (void)nothing:(id)sender {
    
}

- (void)enableLikeButton{
    [btnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like_active" ofType:@"png"]] forState:UIControlStateNormal];
}

- (void)disableLikeButton{
    [btnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like" ofType:@"png"]] forState:UIControlStateNormal];
}

- (void)resetLikeDislikeButton{
    [btnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like" ofType:@"png"]] forState:UIControlStateNormal];
    [btnDislike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike" ofType:@"png"]] forState:UIControlStateNormal];
}

- (void)enableDislikeButton{
    [btnDislike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike_active" ofType:@"png"]] forState:UIControlStateNormal];
}

-(void)disableDislikeButton{
    [btnDislike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike" ofType:@"png"]] forState:UIControlStateNormal];
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
