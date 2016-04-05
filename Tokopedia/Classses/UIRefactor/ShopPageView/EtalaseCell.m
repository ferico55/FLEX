//
//  EtalaseCell.m
//  Tokopedia
//
//  Created by Johanes Effendi on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EtalaseCell.h"

@implementation EtalaseCell

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"EtalaseCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if(_showCheckImage){
        [_checkImageView setHidden:NO];
        self.accessoryType = UITableViewCellAccessoryNone;
    }else if(_showChevron){
        [_checkImageView setHidden:YES];
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
}

@end
