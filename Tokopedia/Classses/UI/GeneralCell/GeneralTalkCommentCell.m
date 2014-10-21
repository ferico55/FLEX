//
//  GeneralTalkCommentCell.m
//  Tokopedia
//
//  Created by Tokopedia on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralTalkCommentCell.h"

@implementation GeneralTalkCommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

@end
