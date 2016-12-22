//
//  InboxMessageCell.m
//  Tokopedia
//
//  Created by Tokopedia on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageCell.h"
#import "SmileyAndMedal.h"
#import "CMPopTipView.h"

@interface InboxMessageCell () <
CMPopTipViewDelegate,
SmileyDelegate
>

@end

@implementation InboxMessageCell
{
    CMPopTipView* popTipView;
}

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"InboxMessageCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}


#pragma mark - Initialization

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.isEditing) {
        [super setSelected:selected animated:animated];
    } else {
        if (selected) {
            self.contentView.backgroundColor = [UIColor colorWithRed:232 / 255.0 green:245 / 255.0 blue:233 / 255.0 alpha:1];
        } else {
            self.contentView.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (self.isEditing) {
        [super setHighlighted:highlighted animated:animated];
    } else {
       if (highlighted) {
           self.contentView.backgroundColor = [UIColor colorWithRed:232 / 255.0 green:245 / 255.0 blue:233 / 255.0 alpha:1];
       } else {
           self.contentView.backgroundColor = [UIColor clearColor];
       }
    }
}

- (IBAction)actionSmile:(id)sender {
    InboxMessageList *list = _message;
    
    if(! (list.user_reputation.no_reputation!=nil && [list.user_reputation.no_reputation isEqualToString:@"1"])) {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:list.user_reputation.neutral withRepSmile:list.user_reputation.positive withRepSad:list.user_reputation.negative withDelegate:self];
        
        //Init pop up
        popTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
        popTipView.delegate = self;
        popTipView.backgroundColor = [UIColor whiteColor];
        popTipView.animation = CMPopTipAnimationSlide;
        popTipView.dismissTapAnywhere = YES;
        popTipView.leftPopUp = YES;
        
        UIButton *button = (UIButton *)sender;
        [popTipView presentPointingAtView:button inView:_popTipAnchor animated:YES];
    }
}

- (void)setMessage:(InboxMessageList *)list {
    self.message_title.text = list.user_full_name;
    self.message_create_time.text =list.message_create_time;
    self.message_reply.text = list.message_reply;
    [self.message_title setLabelBackground:list.user_label];
    
    
    NSURL* userImageUrl = [NSURL URLWithString:list.user_image];
    
    UIImageView *thumb = self.userimageview;
    thumb = [UIImageView circleimageview:thumb];
    thumb.image = nil;
    
    [thumb setImageWithURL:userImageUrl placeholderImage:[UIImage imageNamed:@"default-boy.png"]];
    
    if(list.user_reputation.no_reputation!=nil && [list.user_reputation.no_reputation isEqualToString:@"1"]) {
        [self.btnReputasi setImage:[UIImage imageNamed:@"icon_neutral_smile_small"] forState:UIControlStateNormal];
        [self.btnReputasi setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [self.btnReputasi setImage:[UIImage imageNamed:@"icon_smile_small"] forState:UIControlStateNormal];
        [self.btnReputasi setTitle:[NSString stringWithFormat:@"%@%%", list.user_reputation.positive_percentage] forState:UIControlStateNormal];
    }
    
    if([list.message_read_status isEqualToString:@"1"]) {
        self.is_unread.hidden = YES;
    } else if (_displaysUnreadIndicator) {
        self.is_unread.hidden = NO;
    }
}

#pragma mark - ToolTip Delegate
- (void)dismissAllPopTipViews
{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}

#pragma mark - Smiley Delegate
- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}
@end
