//
//  TalkCell.m
//  Tokopedia
//
//  Created by Tonito Acen on 7/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TalkCell.h"
#import "TalkModelView.h"
#import "ViewLabelUser.h"

@implementation TalkCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTalkViewModel:(TalkModelView *)modelView {
    [self.messageLabel setText:modelView.talkMessage];
    [self.createTimeLabel setText:modelView.createTime];
    [self.totalCommentButton setTitle:[NSString stringWithFormat:@"%@ Komentar", modelView.totalComment] forState:UIControlStateNormal];
    
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:modelView.userImage] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    self.userImageView.image = nil;
    [self.userImageView setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [self.userImageView setImage:image];
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width/2;
    } failure:nil];
    
    NSURLRequest *productImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:modelView.productImage] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    self.productImageView.image = nil;
    [self.productImageView setImageWithURLRequest:productImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [self.productImageView setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productImageView setImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
        [self.productImageView setContentMode:UIViewContentModeCenter];
    }];
    
    [self.productButton setTitle:modelView.productName forState:UIControlStateNormal];
    [self.userButton setLabelBackground:modelView.userLabel];
    [self.userButton setText:modelView.userName];
    [self.unreadImageView setHidden:[modelView.readStatus isEqualToString:@"1"] ? NO : YES];
    
    
}

@end
