//
//  GeneralTalkCommentCell.m
//  Tokopedia
//
//  Created by Tokopedia on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralTalkCommentCell.h"
#import "TalkCommentList.h"
#import "ShopReputation.h"
#import "SmileyAndMedal.h"

@implementation GeneralTalkCommentCell

- (void)awakeFromNib {
    self.user_image.layer.cornerRadius = self.user_image.frame.size.width/2;
    [self.user_name setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamMedium" size:14.0f]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Method
- (IBAction)actionSmile:(id)sender {
    [_del actionSmile:sender];
}

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralTalkCommentCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)layoutSubviews {

    [super layoutSubviews];
    self.commentlabel.preferredMaxLayoutWidth = self.commentlabel.frame.size.width;
}

- (void)setComment:(TalkCommentList *)list {
    _comment = list;
    GeneralTalkCommentCell *cell = self;

    cell.commentlabel.text = list.comment_message;

    NSString *name = list.isSeller? list.comment_shop_name : list.comment_user_name;
    cell.user_name.text = name;

    cell.create_time.text = list.comment_create_time;

    [cell.user_name setLabelBackground:list.comment_user_label];

    if(list.is_just_sent) {
        cell.create_time.text = @"Kirim...";
    } else {
        cell.create_time.text = list.comment_create_time;
    }

    if(list.isSeller) {
        [SmileyAndMedal generateMedalWithLevel:list.comment_shop_reputation.reputation_badge_object.level
                                       withSet:list.comment_shop_reputation.reputation_badge_object.set
                                     withImage:cell.btnReputation isLarge:NO];
        [cell.btnReputation setTitle:@"" forState:UIControlStateNormal];
    } else {
        if(list.comment_user_reputation==nil
                || (list.comment_user_reputation.no_reputation!=nil
                && [list.comment_user_reputation.no_reputation isEqualToString:@"1"])) {
            [cell.btnReputation
                    setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral_smile_small" ofType:@"png"]]
                    forState:UIControlStateNormal];
            [cell.btnReputation setTitle:@"" forState:UIControlStateNormal];
        }
        else {
            [cell.btnReputation
                    setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small" ofType:@"png"]]
                    forState:UIControlStateNormal];

            [cell.btnReputation
                    setTitle:[NSString stringWithFormat:@"%@%%", (list.comment_user_reputation==nil? @"0":list.comment_user_reputation.positive_percentage)]
                    forState:UIControlStateNormal];
        }
    }

    if(list.is_not_delivered) {
        cell.commentfailimage.hidden = NO;
        cell.create_time.text = @"Gagal Kirim.";

        UITapGestureRecognizer *errorSendCommentGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapErrorComment)];
        [cell.commentfailimage addGestureRecognizer:errorSendCommentGesture];
        [cell.commentfailimage setUserInteractionEnabled:YES];
    } else {
        cell.commentfailimage.hidden = YES;
    }

    NSURL *url;
    if (list.isSeller) {
        url = [NSURL URLWithString:list.comment_shop_image];
    } else {
        url = [NSURL URLWithString:list.comment_user_image];
    }

    UIImageView *user_image = cell.user_image;
    user_image.image = nil;

    [user_image setImageWithURL:url placeholderImage:[UIImage imageNamed:@"default-boy.png"]];
}


@end
