//
//  InboxTicketCell.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketCell.h"

@implementation InboxTicketCell
{
    IBOutlet UIView* _selectionMarker;
}

+ (id)initCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"InboxTicketCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    _selectionMarker.hidden = !selected;
}

@end
