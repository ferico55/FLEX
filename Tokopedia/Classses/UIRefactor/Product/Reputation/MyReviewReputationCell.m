//
//  MyReviewReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailProductViewController.h"
#import "ShopBadgeLevel.h"
#import "string_inbox_message.h"
#import "SmileyAndMedal.h"
#import "MyReviewReputationViewModel.h"
#import "MyReviewReputationCell.h"
#import "ReputationDetail.h"
#import "ViewLabelUser.h"
#import "NavigationHelper.h"
//#define CTagPembeli 1
//#define CTagPenjual 2
#define CFormatWaitYourReview @"%@ Produk menunggu ulasan anda"
#define CFormatWaitYourComment @"%@ Produk menunggu komentar anda"
#define CFormatUlasanIsEdit @"%@ Ulasan produk telah diperbaharui"
#define CStringLihaReview @"Lihat Ulasan"
#define CFormatUlasanDiKomentari @"%@ Ulasan produk telah dikomentari"

@implementation MyReviewReputationCell
{
    IBOutlet UIView* _selectionMarker;
}

- (void)awakeFromNib {
    CGSize newSize = CGSizeMake(btnReview.bounds.size.height-5, btnReview.bounds.size.height-5);
    UIGraphicsBeginImageContext(newSize);
    [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [btnReview setImage:newImage forState:UIControlStateNormal];
    btnReview.layer.cornerRadius = btnReview.bounds.size.height/2.0f;
    btnReview.layer.borderColor = [UIColor colorWithRed:224/255.0f green:224/255.0f blue:224/255.0f alpha:1.0f].CGColor;
    btnReview.layer.borderWidth = 1.0f;
    btnReview.layer.masksToBounds = YES;
    
    imageProfile.layer.cornerRadius = imageProfile.bounds.size.height/2.0f;
    imageProfile.layer.masksToBounds = YES;
    imageProfile.contentMode = UIViewContentModeScaleAspectFit;

    [imageFlagReview setUserInteractionEnabled:YES];
    [labelUser addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionLabelUser:)]];
    [imageFlagReview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionFlagReview:)]];
    [labelUser setUserInteractionEnabled: [NavigationHelper shouldDoDeepNavigation]];
    
    //Set image
    imageQSmile = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile20" ofType:@"png"]];
    imageQNetral = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral20" ofType:@"png"]];
    imageQBad = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad20" ofType:@"png"]];
    
    
    imageQuestionBlue = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_questionmark_blue" ofType:@"png"]];
    imageQuestionGray = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_questionmark_grey" ofType:@"png"]];
    imageSad = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad25" ofType:@"png"]];
    imageNetral = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral25" ofType:@"png"]];
    imageSmile = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile25" ofType:@"png"]];
    imageNoSmile = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral25" ofType:@"png"]];
    
    imageFlagReview.layer.cornerRadius = imageFlagReview.bounds.size.width/2.0f;
    imageFlagReview.layer.masksToBounds = YES;
    
    btnFooter.userInteractionEnabled = [NavigationHelper shouldDoDeepNavigation];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    viewContent.backgroundColor = selected ? [UIColor colorWithRed:232 / 255.0 green:245 / 255.0 blue:233 / 255.0 alpha:1] : [UIColor whiteColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    viewContent.backgroundColor = highlighted ? [UIColor colorWithRed:232 / 255.0 green:245 / 255.0 blue:233 / 255.0 alpha:1] : [UIColor whiteColor];
}


#pragma mark - Setter
- (NSLayoutConstraint *)getTopViewContentConstraint {
    return constraintTopViewContent;
}

- (NSLayoutConstraint *)getConstHeightBtnInvoce {
    return constHeightBtnInvoce;
}

- (NSLayoutConstraint *)getConstHegithBtnFooter {
    return constraintHeightBtnFooter;
}

- (void)setLeftViewContentContraint:(int)n {
    constraintLeftViewContent.constant = n;
}

- (void)setBottomViewContentContraint:(int)n {
    cosntraintBottomViewContent.constant = n;
}

- (void)setRightViewContentContraint:(int)n {
    constraintRightViewContent.constant = n;
}

- (void)setTopViewContentContraint:(int)n {
    constraintTopViewContent.constant = n;
}

#pragma mark - Getter
- (UIImageView *)getImageFlagReview {
    return imageFlagReview;
}

- (UIView *)getViewContent {
    return viewContent;
}

- (UIButton *)getBtnInvoice {
    return btnInvoice;
}

- (ViewLabelUser *)getLabelUser {
    return labelUser;
}

- (UIButton *)getBtnFooter {
    return btnFooter;
}

- (UIButton *)getBtnReputation {
    return btnReputation;
}

- (UIView *)getViewFlagReadUnread {
    return viewFlagReadUnread;
}

- (UIButton *)getBtnReview {
    return btnReview;
}

#pragma mark - Action
- (IBAction)actionPopUp:(id)sender {
    [_delegate actionReputasi:sender];
}

- (void)actionFlagReview:(id)sender {
    [_delegate actionFlagReview:((UITapGestureRecognizer *) sender).view];
}

- (IBAction)actionFooter:(id)sender {
    [_delegate actionFooter:sender];
}

- (IBAction)actionInvoice:(id)sender {
    [_delegate actionInvoice:sender];
}

- (IBAction)actionReview:(id)sender {
    [_delegate actionReviewRate:sender];
}

- (void)actionLabelUser:(id)sender {
    [_delegate actionLabelUser:sender];
}

#pragma mark - Method
- (void)isLoadInView:(BOOL)isLoad withView:(UIView *)view {
    if(isLoad) {
        if(activityRating == nil) {
            activityRating = [[UIActivityIndicatorView alloc] init];
            activityRating.color = [UIColor lightGrayColor];
        }
        
        view.hidden = YES;
        activityRating.frame = view.frame;
        activityRating.center = view.center;
        [activityRating startAnimating];
        [view.superview addSubview:activityRating];
    }
    else {
        [activityRating stopAnimating];
        [activityRating removeFromSuperview];
        view.hidden = NO;
    }
}

- (void)setView:(MyReviewReputationViewModel *)object {
    [labelUser setText:object.reviewee_name];
    [labelUser setText:[UIColor colorWithRed:69/255.0f green:124/255.0f blue:16/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamMedium" size:13.0f]];
    
    [labelUser setLabelBackground:[object.reviewee_role isEqualToString:@"1"]? CPembeli:CPenjual];
    
    
    [UIView setAnimationsEnabled:NO];
    [btnInvoice setTitle:object.invoice_ref_num forState:UIControlStateNormal];
    
    if(object.unassessed_reputation_review==nil || [object.unassessed_reputation_review isEqualToString:@"0"]) {
        if(object.updated_reputation_review==nil || [object.updated_reputation_review isEqualToString:@"0"] || [object.role isEqualToString:@"1"]) {//1 is buyer
            if(object.updated_reputation_review!=nil && ![object.updated_reputation_review isEqualToString:@"0"]) {
                [btnFooter setTitle:[NSString stringWithFormat:CFormatUlasanDiKomentari, object.updated_reputation_review] forState:UIControlStateNormal];
            }
            else
                [btnFooter setTitle:CStringLihaReview forState:UIControlStateNormal];
        }
        else
            [btnFooter setTitle:[NSString stringWithFormat:CFormatUlasanIsEdit, object.updated_reputation_review] forState:UIControlStateNormal];
    }
    else {
        [btnFooter setTitle:[NSString stringWithFormat:([object.role isEqualToString:@"2"]? CFormatWaitYourComment:CFormatWaitYourReview), object.unassessed_reputation_review] forState:UIControlStateNormal];
    }
    
    
    
    
    // set right smiley interaction
    if([object.reputation_progress isEqualToString:@"0"]) {
        btnReview.userInteractionEnabled = YES;        
    } else if([object.reputation_progress isEqualToString:@"1"]) {
        btnReview.userInteractionEnabled = YES;
    } else if([object.reputation_progress isEqualToString:@"2"]) {
        btnReview.userInteractionEnabled = YES;
    } else if([object.reputation_progress isEqualToString:@""]){
        btnReview.userInteractionEnabled = YES;
    } else {
        btnReview.userInteractionEnabled = NO;
    }
    
    //set right smiley image
    [self setSmileyButton:btnReview withImageString:object.their_score_image];
    
    //set left smiley image
    [self setSmileyImage:imageFlagReview withImageString:object.my_score_image];
    
    if(btnReview.isUserInteractionEnabled) {
        [btnReview setBackgroundColor:[UIColor whiteColor]];
    }
    else {
        [btnReview setBackgroundColor:[UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f]];
    }
    
    
   
    viewFlagReadUnread.hidden = [object.show_bookmark isEqualToString:@"1"]?NO:YES;

        
    

    //Set image profile
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:object.reviewee_picture] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = imageProfile;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_profile_picture" ofType:@"jpeg"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
        [thumb setContentMode:UIViewContentModeScaleAspectFill];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    
    //Set reputation
    if([object.role isEqualToString:@"1"]) {//Buyer
        [SmileyAndMedal generateMedalWithLevel:object.shop_badge_level.level withSet:object.shop_badge_level.set withImage:btnReputation isLarge:NO];
        [btnReputation setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [btnReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
        [btnReputation setTitle:[NSString stringWithFormat:@"%@%%", (object.user_reputation==nil? @"0":object.user_reputation.positive_percentage)] forState:UIControlStateNormal];
    }
    
    
    
    [UIView setAnimationsEnabled:YES];
}

- (void)setSmileyImage:(UIImageView*)image withImageString:(NSString*)img {
    UIImage *buttonImage;
    if([img isEqualToString:@"smiley_neutral"]) {
        buttonImage = imageQNetral;
    } else if([img isEqualToString:@"smiley_bad"]) {
        buttonImage = imageQBad;
    } else if([img isEqualToString:@"smiley_good"]) {
        buttonImage = imageSmile;
    } else if([img isEqualToString:@"smiley_none"]) {
        buttonImage = imageNoSmile;
    } else if([img isEqualToString:@"grey_question_mark"]) {
        buttonImage = imageQuestionGray;
    } else if([img isEqualToString:@"blue_question_mark"]) {
        buttonImage = imageQuestionBlue;
    }
    
    [image setImage:buttonImage];
}

- (void)setSmileyButton:(UIButton*)button withImageString:(NSString*)img {
    UIImage *buttonImage;
    if([img isEqualToString:@"smiley_neutral"]) {
        buttonImage = imageQNetral;
    } else if([img isEqualToString:@"smiley_bad"]) {
        buttonImage = imageQBad;
    } else if([img isEqualToString:@"smiley_good"]) {
        buttonImage = imageSmile;
        [button setUserInteractionEnabled:NO];
    } else if([img isEqualToString:@"smiley_none"]) {
        buttonImage = imageNoSmile;
    } else if([img isEqualToString:@"grey_question_mark"]) {
        buttonImage = imageQuestionGray;
    } else if([img isEqualToString:@"blue_question_mark"]) {
        buttonImage = imageQuestionBlue;
    }
    
    [button setImage:buttonImage forState:UIControlStateNormal];
}


@end
