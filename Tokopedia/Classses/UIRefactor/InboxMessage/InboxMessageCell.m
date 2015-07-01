//
//  InboxMessageCell.m
//  Tokopedia
//
//  Created by Tokopedia on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageCell.h"

@implementation InboxMessageCell

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
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
