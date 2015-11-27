//
//  ProductReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "ProductReputationSimpleCell.h"
#import "DetailReviewReputationViewModel.h"


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
    //count label height dynamically
    UILabel *messageLabel = self.reputationMessageLabel;
    
    [messageLabel setText:viewModel.review_message];
    [messageLabel sizeToFit];
    
    //set label attribute
    NSString *labelText = viewModel.review_message;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    messageLabel.attributedText = attributedString ;
    
    CGRect sizeOfMessage = [messageLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10, 0)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                                           context:nil];
    sizeOfMessage.size.width = [UIScreen mainScreen].bounds.size.width-20;
    messageLabel.frame = sizeOfMessage;
    
    //set vertical origin of user view
    CGRect newFrame = self.reputationBuyerView.frame;
    newFrame.origin.y = sizeOfMessage.size.height + 20;
    newFrame.size.width = [UIScreen mainScreen].bounds.size.width - 20;
    self.reputationBuyerView.frame = newFrame;
    
    //set star position
    CGRect starFrame = self.reputationStarQualityView.frame;
    starFrame.origin.x = self.reputationDateLabel.frame.origin.x;
    self.reputationStarQualityView.frame = starFrame;
    
    CGRect starAccuracyFrame = self.reputationStarAccuracyView.frame;
    starAccuracyFrame.origin.x = self.reputationStarQualityView.frame.origin.x + self.reputationStarQualityView.frame.size.width + 20;
    self.reputationStarAccuracyView.frame = starAccuracyFrame;
    
    //set wrapper viewheight
    CGRect reputationViewFrame = self.listReputationView.frame;
    reputationViewFrame.size.height = self.reputationBuyerView.frame.size.height + 10 + messageLabel.frame.size.height;
    self.listReputationView.frame = reputationViewFrame;
    
    [self.reputationBuyerLabel setText:viewModel.review_user_name];
    [self.reputationDateLabel setText:viewModel.review_create_time];
    
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    self.reputationBuyerImage.image = nil;
    
    [self.reputationBuyerImage setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [self.reputationBuyerImage setImage:image];
        self.reputationBuyerImage.layer.cornerRadius = self.reputationBuyerImage.frame.size.width/2;
        self.reputationBuyerImage.clipsToBounds = YES;
        
    } failure:nil];
    
    //add border bottom
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.reputationBuyerView.frame.size.height + 10, self.reputationBuyerView.frame.size.width, 0.5f);
    
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [self.reputationBuyerView.layer addSublayer:bottomBorder];

    
    //add score
    EDStarRating *starQualityRating = self.reputationStarQualityRating;
    starQualityRating.backgroundImage = nil;
    starQualityRating.starImage = _starInactiveImage;
    starQualityRating.starHighlightedImage = _starActiveImage;
    starQualityRating.maxRating = 5.0;
    starQualityRating.horizontalMargin = 1.0;
    starQualityRating.rating = [viewModel.review_rate_quality integerValue];
    starQualityRating.displayMode = EDStarRatingDisplayAccurate;
    
    
    EDStarRating *starAccuracyRating = self.reputationStarAccuracyRating;
    starAccuracyRating.backgroundImage = nil;
    starAccuracyRating.starImage = _starInactiveImage;
    starAccuracyRating.starHighlightedImage = _starActiveImage;
    starAccuracyRating.maxRating = 5.0;
    starAccuracyRating.horizontalMargin = 1.0;
    starAccuracyRating.rating = [viewModel.review_rate_accuracy integerValue];
    starAccuracyRating.displayMode = EDStarRatingDisplayAccurate;
}
@end
