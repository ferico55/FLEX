//
//  MyReviewReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "string_inbox_message.h"
#import "MyReviewReputationViewModel.h"
#import "MyReviewReputationCell.h"
#import "ViewLabelUser.h"
//#define CTagPembeli 1
//#define CTagPenjual 2
#define CFormatWaitYourReview @"%@ Produk menunggu review anda"
#define CFormatWaitYourComment @"%@ Produk menunggu komentar anda"
#define CFormatUlasanIsEdit @"%@ Ulasan produk telah diperbaharui"
#define CStringLihaReview @"Lihat Review"

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
    CGRect rect = CGRectMake(0, 0, 20 ,20);
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] drawInRect:rect];
    imageQSmile = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]] drawInRect:rect];
    imageQNetral = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]] drawInRect:rect];
    imageQBad = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    imageQuestionBlue = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_questionmark_blue" ofType:@"png"]];
    imageQuestionGray = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_questionmark_grey" ofType:@"png"]];
    imageSad = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]];
    imageNetral = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]];
    imageSmile = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]];
    imageNeutral = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral" ofType:@"png"]];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Setter
- (NSLayoutConstraint *)getTopViewContentConstraint {
    return constraintTopViewContent;
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

- (UIButton *)getBtnReview {
    return btnReview;
}

#pragma mark - Action
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
    [labelUser setText:[UIColor colorWithRed:69/255.0f green:124/255.0f blue:16/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamBook" size:btnInvoice.titleLabel.font.pointSize]];
    
    [labelUser setLabelBackground:[object.reviewee_role isEqualToString:@"1"]? CPembeli:CPenjual];
    [btnInvoice setTitle:object.invoice_ref_num forState:UIControlStateNormal];
    
    
    if(object.unassessed_reputation_review==nil || [object.unassessed_reputation_review isEqualToString:@"0"]) {
        if(object.updated_reputation_review==nil || [object.updated_reputation_review isEqualToString:@"0"] || [object.role isEqualToString:@"1"])//1 is buyer
            [btnFooter setTitle:CStringLihaReview forState:UIControlStateNormal];
        else
            [btnFooter setTitle:[NSString stringWithFormat:CFormatUlasanIsEdit, object.updated_reputation_review] forState:UIControlStateNormal];
    }
    else {
        [btnFooter setTitle:[NSString stringWithFormat:([object.role isEqualToString:@"2"]? CFormatWaitYourComment:CFormatWaitYourReview), object.unassessed_reputation_review] forState:UIControlStateNormal];
    }
    
    
    //Set color smile
    btnReview.enabled = !(object.score_edit_time_fmt!=nil && ![object.score_edit_time_fmt isEqualToString:@"0"]);
    if([([object.role isEqualToString:@"2"]?object.buyer_score:object.seller_score) isEqualToString:CRevieweeScroreBad]) {
        [btnReview setImage:imageSad forState:UIControlStateNormal];
    }
    else if([([object.role isEqualToString:@"2"]?object.buyer_score:object.seller_score) isEqualToString:CRevieweeScroreNetral]) {
        [btnReview setImage:imageNetral forState:UIControlStateNormal];
    }
    else if([([object.role isEqualToString:@"2"]?object.buyer_score:object.seller_score) isEqualToString:CRevieweeScroreGood]) {
        btnReview.enabled = NO;
        [btnReview setImage:imageSmile forState:UIControlStateNormal];
    }
    else {
        [btnReview setImage:imageNeutral forState:UIControlStateNormal];
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
    viewFlagReadUnread.hidden = [object.read_status isEqualToString:@"1"];
    

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
}
@end
