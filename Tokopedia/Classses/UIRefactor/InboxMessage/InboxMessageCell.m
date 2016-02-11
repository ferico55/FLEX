//
//  InboxMessageCell.m
//  Tokopedia
//
//  Created by Tokopedia on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageCell.h"

@implementation InboxMessageCell
{
    IBOutlet UIView* _selectionMarker;
}

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"InboxMessageCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
//            ((InboxMessageCell *) o).message_title.inboxMessageCell = o;
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
        _selectionMarker.hidden = !selected;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (self.isEditing) {
        [super setHighlighted:highlighted animated:animated];
    } else {
        _selectionMarker.hidden = !highlighted;
    }
}

- (IBAction)actionSmile:(id)sender {
    [_del actionSmile:sender];
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
        [self.btnReputasi setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
        [self.btnReputasi setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [self.btnReputasi setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
        [self.btnReputasi setTitle:[NSString stringWithFormat:@"%@%%", list.user_reputation.positive_percentage] forState:UIControlStateNormal];
    }
}
@end
