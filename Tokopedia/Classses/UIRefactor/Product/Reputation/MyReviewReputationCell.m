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

@implementation MyReviewReputationCell

- (void)awakeFromNib {
    CGSize newSize = CGSizeMake(btnReview.bounds.size.height-5, btnReview.bounds.size.height-5);
    UIGraphicsBeginImageContext(newSize);
    [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [btnReview setImage:newImage forState:UIControlStateNormal];
    
    
    btnReview.layer.cornerRadius = btnReview.bounds.size.height/2.0f;
    btnReview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btnReview.layer.borderWidth = 1.0f;
    btnReview.layer.masksToBounds = YES;

    labelUser.userInteractionEnabled = YES;
    [labelUser addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionLabelUser:)]];
    
    [imageFlagReview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionFlagReview:)]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Getter
- (UIImageView *)getImageFlagReview {
    return imageFlagReview;
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
    [labelUser setText:[UIColor lightGrayColor] withFont:[UIFont fontWithName:@"GothamBook" size:btnInvoice.titleLabel.font.pointSize]];
    
    [labelUser setLabelBackground:[object.reviewee_role isEqualToString:@"1"]? CPembeli:CPenjual];
    [btnInvoice setTitle:object.invoice_ref_num forState:UIControlStateNormal];
    [btnFooter setTitle:[NSString stringWithFormat:CFormatWaitYourReview, object.unassessed_reputation_review] forState:UIControlStateNormal];
    
    //Set color smile
    btnReview.enabled = YES;
    if([object.reviewee_score isEqualToString:CRevieweeScroreBad]) {
        [btnReview setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else if([object.reviewee_score isEqualToString:CRevieweeScroreNetral]) {
        [btnReview setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else if([object.reviewee_score isEqualToString:CRevieweeScroreGood]) {
        btnReview.enabled = NO;
        [btnReview setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else {
        [btnReview setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral" ofType:@"png"]] forState:UIControlStateNormal];
    }
    
    //Check flag has reviewed or not
    //1&4. kedua pihak sudah kasih reputation
    //2&5. salah satu sudah kasih
    //3&6. 2 pihak belum kasih
    if([object.reviewee_score_status isEqualToString:@"1"] || [object.reviewee_score_status isEqualToString:@"4"]) {
        imageFlagReview.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]];
        imageFlagReview.userInteractionEnabled = YES;
    }
    else if([object.reviewee_score_status isEqualToString:@"2"] || [object.reviewee_score_status isEqualToString:@"5"]) {
        imageFlagReview.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_silver" ofType:@"png"]];
        imageFlagReview.userInteractionEnabled = YES;
    }
    else {
        imageFlagReview.userInteractionEnabled = NO;
        imageFlagReview.image = nil;
    }
    
    //check read unread status
    viewFlagReadUnread.hidden = [object.read_status isEqualToString:@"1"];
    

    //Set image profile
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:object.reviewee_picture] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = imageProfile;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
        [thumb setContentMode:UIViewContentModeScaleAspectFill];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
}
@end
