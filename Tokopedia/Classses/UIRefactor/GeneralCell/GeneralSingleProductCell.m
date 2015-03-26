//
//  GeneralSingleProductCell.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "GeneralSingleProductCell.h"

@implementation GeneralSingleProductCell

+ (id)initCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralSingleProductCell" owner:nil options:0];
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
    [super setSelected:selected animated:animated];
}

- (IBAction)tap:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectCell:atIndexPath:)]) {
        [self.delegate didSelectCell:self atIndexPath:_indexPath];
    }
}

@end
