//
//  GeneralTalkCommentCell.m
//  Tokopedia
//
//  Created by Tokopedia on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralTalkCommentCell.h"

@implementation GeneralTalkCommentCell

static CGFloat messageTextSize = 14.0;
static CGFloat textMarginVertical = 30.0f;

- (void)awakeFromNib {
    self.user_image.layer.cornerRadius = self.user_image.frame.size.width/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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

+ (CGSize)messageSize:(NSString*)message {
    return [message sizeWithFont:[UIFont systemFontOfSize:messageTextSize]
               constrainedToSize:CGSizeMake([self maxTextWidth], CGFLOAT_MAX)
                   lineBreakMode:NSLineBreakByWordWrapping];
}

+ (CGFloat)maxTextWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 220.0f;
    } else {
        return 400.0f;
    }
}

+ (CGFloat)textMarginVertical {
    return textMarginVertical;
}


@end
