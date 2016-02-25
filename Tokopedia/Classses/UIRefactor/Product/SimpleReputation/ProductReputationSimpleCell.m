//
//  ProductReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "ProductReputationSimpleCell.h"
#import "DetailReviewReputationViewModel.h"
#import "ReviewList.h"
#import "NavigateViewController.h"
#import "TTTAttributedLabel.h"

@interface ProductReputationSimpleCell()<
TTTAttributedLabelDelegate
>

@end
@implementation ProductReputationSimpleCell

- (void)awakeFromNib {
    _starInactiveImage = [UIImage imageNamed:@"icon_star_med.png"];
    _starActiveImage = [UIImage imageNamed:@"icon_star_active_med.png"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


//TODO: wrong viewmodel!!, API too fcku bloated,  change this later!
- (void)setReputationModelView:(DetailReviewReputationViewModel *)viewModel {
    [self setReputationMessage:viewModel.review_message];
    [self setReputationStars:viewModel.review_rate_quality withAccuracy:viewModel.review_rate_accuracy];
    [self setUser:viewModel.review_user_name withCreateTime:viewModel.review_create_time andWithImage:viewModel.review_user_image];
    
    [self.productView setHidden:YES];
    [self.productView setFrame:CGRectZero];

    if(_isHelpful){
        //_reputationMessageLabel.textColor = [UIColor colorWithRed:0.097 green:0.5 blue:0.095 alpha:1];
        [_leftBorderView setHidden:NO];
        
    }else{
        //_reputationMessageLabel.textColor = [UIColor blackColor];
        [_leftBorderView setHidden:YES];
    }
    //add border bottom
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.reputationBuyerView.frame.size.height - 40, self.reputationBuyerView.frame.size.width, 0.5f);
    
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [self.reputationBuyerView.layer addSublayer:bottomBorder];
}


- (void)setShopReputationModelView:(ReviewList *)viewModel{
    [self setReputationMessage:viewModel.review_message];
    [self setReputationStars:viewModel.review_rate_quality withAccuracy:viewModel.review_rate_accuracy];
    [self setUser:viewModel.review_user_name withCreateTime:viewModel.review_create_time andWithImage:viewModel.review_user_image];
    [self setReputationProduct:viewModel.review_product_name withProductID:viewModel.review_product_id];
    
    //add border bottom
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.reputationBuyerView.frame.size.height , self.reputationBuyerView.frame.size.width, 0.5f);
    
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [self.reputationBuyerView.layer addSublayer:bottomBorder];
    
    _productID = viewModel.review_product_id;
    _productName = viewModel.review_product_name;
    _productImage = viewModel.review_product_image;
}
- (IBAction)showMoreTapped:(id)sender {
    
}

#pragma mark - internally used method
- (void)setReputationMessage:(NSString*)message {
    //count label height dynamically
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSString *strLihatSelengkapnya = @"Lihat Selengkapnya";
    NSString *strDescription = [NSString convertHTML:message];
    
    if(strDescription.length > 80) {
        strDescription = [NSString stringWithFormat:@"%@... %@", [strDescription substringToIndex:80], strLihatSelengkapnya];
        
        NSRange range = [strDescription rangeOfString:strLihatSelengkapnya];
        _reputationMessageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        _reputationMessageLabel.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor lightGrayColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        _reputationMessageLabel.linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:78/255.0f green:134/255.0f blue:38/255.0f alpha:1.0f] range:NSMakeRange(strDescription.length-strLihatSelengkapnya.length, strLihatSelengkapnya.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gotham Medium" size:_reputationMessageLabel.font.pointSize] range:NSMakeRange(0, strDescription.length)];
        _reputationMessageLabel.attributedText = str;
        [_reputationMessageLabel addLinkToURL:[NSURL URLWithString:@""] withRange:range];
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gotham Medium" size:_reputationMessageLabel.font.pointSize] range:NSMakeRange(0, strDescription.length)];
        _reputationMessageLabel.attributedText = str;
        _reputationMessageLabel.delegate = nil;
        [_reputationMessageLabel addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
    }
    
    CGFloat heightOfMessage = 45;
    /*
    CGRect sizeOfMessage = [messageLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10, 0)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                                           context:nil];
    sizeOfMessage.size.width = [UIScreen mainScreen].bounds.size.width-20;
    messageLabel.frame = sizeOfMessage;
     */
    
    
    //set vertical origin of user view
    CGRect newFrame = self.reputationBuyerView.frame;
    newFrame.origin.y = heightOfMessage + 20;
    newFrame.size.width = [UIScreen mainScreen].bounds.size.width - 20;
    self.reputationBuyerView.frame = newFrame;
    
    //set wrapper viewheight
    CGRect reputationViewFrame = self.listReputationView.frame;
    reputationViewFrame.size.height = self.reputationBuyerView.frame.size.height + 10 + _reputationMessageLabel.frame.size.height;
    self.listReputationView.frame = reputationViewFrame;
    
    _reputationMessageLabel.delegate = self;
}

- (void)setReputationStars:(NSString*)quality withAccuracy:(NSString*)accuracy {
    //add score
    EDStarRating *starQualityRating = self.reputationStarQualityRating;
    starQualityRating.backgroundImage = nil;
    starQualityRating.starImage = _starInactiveImage;
    starQualityRating.starHighlightedImage = _starActiveImage;
    starQualityRating.maxRating = 5.0;
    starQualityRating.horizontalMargin = 1.0;
    starQualityRating.rating = [quality integerValue];
    starQualityRating.displayMode = EDStarRatingDisplayAccurate;
    
    
    EDStarRating *starAccuracyRating = self.reputationStarAccuracyRating;
    starAccuracyRating.backgroundImage = nil;
    starAccuracyRating.starImage = _starInactiveImage;
    starAccuracyRating.starHighlightedImage = _starActiveImage;
    starAccuracyRating.maxRating = 5.0;
    starAccuracyRating.horizontalMargin = 1.0;
    starAccuracyRating.rating = [accuracy integerValue];
    starAccuracyRating.displayMode = EDStarRatingDisplayAccurate;
}

- (void)setUser:(NSString*)userName withCreateTime:(NSString*)createTime andWithImage:(NSString*)imageUrl{
    //set star position
    CGRect starFrame = self.reputationStarQualityView.frame;
    starFrame.origin.x = 0;
    self.reputationStarQualityView.frame = starFrame;
    
    CGRect starAccuracyFrame = self.reputationStarAccuracyView.frame;
    starAccuracyFrame.origin.x = self.reputationStarQualityView.frame.origin.x + self.reputationStarQualityView.frame.size.width + 20;
    self.reputationStarAccuracyView.frame = starAccuracyFrame;
    
    
    
    [self.reputationBuyerLabel setText:userName];
    [self.reputationDateLabel setText:createTime];
    
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    self.reputationBuyerImage.image = nil;
    
    [self.reputationBuyerImage setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [self.reputationBuyerImage setImage:image];
        self.reputationBuyerImage.layer.cornerRadius = self.reputationBuyerImage.frame.size.width/2;
        self.reputationBuyerImage.clipsToBounds = YES;
        
    } failure:nil];

}

- (void)setReputationProduct:(NSString*)productName withProductID:(NSString*)productID {
    [self.productNameButton setTitle:productName forState:UIControlStateNormal];
}

- (IBAction)tapProduct:(id)sender {
    NavigateViewController *navigator = [[NavigateViewController alloc] init];
    [navigator navigateToProductFromViewController:_delegate withName:_productName withPrice:nil withId:_productID withImageurl:_productImage withShopName:nil];
}

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point
{
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [_delegate showMoreDidTappedInIndexPath:_indexPath];
}



@end
