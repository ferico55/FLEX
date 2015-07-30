//
//  MyReviewReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailProductViewController.h"
#import "string_inbox_message.h"
#import "MyReviewReputationViewModel.h"
#import "MyReviewReputationCell.h"
#import "ReputationDetail.h"
#import "ViewLabelUser.h"
//#define CTagPembeli 1
//#define CTagPenjual 2
#define CFormatWaitYourReview @"%@ Produk menunggu ulasan anda"
#define CFormatWaitYourComment @"%@ Produk menunggu komentar anda"
#define CFormatUlasanIsEdit @"%@ Ulasan produk telah diperbaharui"
#define CStringLihaReview @"Lihat Ulasan"
#define CFormatUlasanDiKomentari @"%@ Ulasan produk telah dikomentari"

@implementation MyReviewReputationCell

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

    labelUser.userInteractionEnabled = YES;
    [labelUser addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionLabelUser:)]];
    [imageFlagReview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionFlagReview:)]];
    
    //Set image
    imageQSmile = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile20" ofType:@"png"]];
    imageQNetral = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral20" ofType:@"png"]];
    imageQBad = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad20" ofType:@"png"]];
    
    
    imageQuestionBlue = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_questionmark_blue" ofType:@"png"]];
    imageQuestionGray = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_questionmark_grey" ofType:@"png"]];
    imageSad = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad25" ofType:@"png"]];
    imageNetral = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral25" ofType:@"png"]];
    imageSmile = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile25" ofType:@"png"]];
    imageNeutral = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral25" ofType:@"png"]];
    
    imageFlagReview.layer.cornerRadius = imageFlagReview.bounds.size.width/2.0f;
    imageFlagReview.layer.masksToBounds = YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    
    
    //Set color smile
    btnReview.userInteractionEnabled = !(object.score_edit_time_fmt!=nil && ![object.score_edit_time_fmt isEqualToString:@"0"]);
    if([([object.role isEqualToString:@"2"]?object.buyer_score:object.seller_score) isEqualToString:CRevieweeScroreBad]) {
        [btnReview setImage:imageSad forState:UIControlStateNormal];
    }
    else if([([object.role isEqualToString:@"2"]?object.buyer_score:object.seller_score) isEqualToString:CRevieweeScroreNetral]) {
        [btnReview setImage:imageNetral forState:UIControlStateNormal];
    }
    else if([([object.role isEqualToString:@"2"]?object.buyer_score:object.seller_score) isEqualToString:CRevieweeScroreGood]) {
        btnReview.userInteractionEnabled = NO;
        [btnReview setImage:imageSmile forState:UIControlStateNormal];
    }
    else {
        [btnReview setImage:imageNeutral forState:UIControlStateNormal];
    }
    
    
    if(btnReview.isUserInteractionEnabled) {
        [btnReview setBackgroundColor:[UIColor whiteColor]];
    }
    else {
        [btnReview setBackgroundColor:[UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f]];
    }
    
    
    
    //Check flag has reviewed or not
    //1&4. kedua pihak sudah kasih reputation
    //2&5. salah satu sudah kasih
    //3&6. 2 pihak belum kasih
    imageFlagReview.userInteractionEnabled = YES;

    NSString *strScore = object.buyer_score;
    if([object.role isEqualToString:@"2"]) {//Seller
        strScore = object.seller_score;
    }
    
    //Set icon smiley
    if(([object.seller_score isEqualToString:CRevieweeScroreBad] || [object.seller_score isEqualToString:CRevieweeScroreNetral] || [object.seller_score isEqualToString:CRevieweeScroreGood]) && (([object.buyer_score isEqualToString:CRevieweeScroreBad] || [object.buyer_score isEqualToString:CRevieweeScroreNetral] || [object.buyer_score isEqualToString:CRevieweeScroreGood]))) {
        if([strScore isEqualToString:CRevieweeScroreBad]) {
            imageFlagReview.image = imageQBad;
        }
        else if([strScore isEqualToString:CRevieweeScroreNetral]) {
            imageFlagReview.image = imageQNetral;
        }
        else if([strScore isEqualToString:CRevieweeScroreGood]) {
            imageFlagReview.image = imageQSmile;
        }
    }
    else {
        if([strScore isEqualToString:CRevieweeScroreBad] || [strScore isEqualToString:CRevieweeScroreNetral] || [strScore isEqualToString:CRevieweeScroreGood]) {
            imageFlagReview.image = imageQuestionBlue;
        }
        else {
            imageFlagReview.image = imageQuestionGray;
        }
    }
    
    
    //check read unread status
    BOOL removeFlag;
    if([object.role isEqualToString:@"2"]) {//Seller
        removeFlag = !(object.buyer_score==nil || [object.buyer_score isEqualToString:@"0"] || [object.buyer_score isEqualToString:@""]);
    }
    else {
        removeFlag = (object.seller_score==nil || [object.seller_score isEqualToString:@"0"] || [object.seller_score isEqualToString:@""]);
    }
        
        
    viewFlagReadUnread.hidden = [object.unassessed_reputation_review isEqualToString:@"0"] && [object.updated_reputation_review isEqualToString:@"0"] && removeFlag;

        
    

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
        [self generateMedal:object.reputation_score];
        [btnReputation setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [btnReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
        [btnReputation setTitle:[NSString stringWithFormat:@"%@%%", (object.user_reputation==nil? @"0":object.user_reputation.positive_percentage)] forState:UIControlStateNormal];
    }
}




- (void)generateMedal:(NSString *)strValue {
    int valueStar = strValue==nil||[strValue isEqualToString:@""]?0:[strValue intValue];
    valueStar = valueStar>0?valueStar:0;
    if(valueStar == 0) {
        [btnReputation setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal14" ofType:@"png"]] withCount:1] forState:UIControlStateNormal];
    }
    else {
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
        if(valueStar <= 250) {
            [btnReputation setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_bronze14" ofType:@"png"]] withCount:n] forState:UIControlStateNormal];
        }
        else if(valueStar <= 10000) {
            [btnReputation setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_silver14" ofType:@"png"]] withCount:n] forState:UIControlStateNormal];
        }
        else if(valueStar <= 500000) {
            [btnReputation setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_gold14" ofType:@"png"]] withCount:n] forState:UIControlStateNormal];
        }
        else {
            [btnReputation setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_diamond_one14" ofType:@"png"]] withCount:n] forState:UIControlStateNormal];
        }
    }
}
@end
