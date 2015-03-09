//
//  ReputationDetailViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReputationDetailViewController.h"

@implementation ReputationDetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _commentLabel.text = @"Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter";
    
    _commentReplyLabel.text = @"Reply Comment Aja ini Reply Comment Aja ini Reply Comment Aja ini Reply Comment Aja ini";
    
    [self setCustomMessageHeight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    _scrollView.contentSize = _contentView.frame.size;
}



-(void)setCustomMessageHeight {
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    style.alignment = NSTextAlignmentJustified;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_commentLabel.text attributes:attributes];
    NSAttributedString *attributedReplyCommentText = [[NSAttributedString alloc] initWithString:_commentReplyLabel.text attributes:attributes];
    
    _commentLabel.attributedText = attributedText;
    _commentReplyLabel.attributedText = attributedReplyCommentText;
    
    //custom label height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [_commentLabel.text sizeWithFont:_commentLabel.font constrainedToSize:maximumLabelSize lineBreakMode:_commentLabel.lineBreakMode];
    
    CGRect newFrame2 = _ratingView.frame;
    newFrame2.origin.y += expectedLabelSize.height - _commentLabel.frame.size.height;
    _ratingView.frame = newFrame2;
    
    CGRect newFrame3 = _commentReply.frame;
    newFrame3.origin.y += expectedLabelSize.height - _commentLabel.frame.size.height;
    _commentReply.frame = newFrame3;
    
    CGRect newFrame4 = _uploadedImageView.frame;
    newFrame4.origin.y += expectedLabelSize.height - _commentLabel.frame.size.height;
    _uploadedImageView.frame = newFrame4;
    
    CGRect newFrame = _commentLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    _commentLabel.frame = newFrame;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect inputFrame = _inputView.frame;
    inputFrame.origin.y = screenRect.size.height - _inputView.frame.size.height - 65;
    _inputView.frame = inputFrame;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
