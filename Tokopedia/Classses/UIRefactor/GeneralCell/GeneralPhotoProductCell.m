//
//  GeneralPhotoProductCell.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "GeneralPhotoProductCell.h"

@implementation GeneralPhotoProductCell

+ (id)initCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralPhotoProductCell" owner:nil options:0];
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
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_indexPath.row inSection:sender.view.tag-1];
    if ([self.delegate respondsToSelector:@selector(didSelectCell:atIndexPath:)]) {
        [self.delegate didSelectCell:self atIndexPath:indexPath];
    }
}

@end
