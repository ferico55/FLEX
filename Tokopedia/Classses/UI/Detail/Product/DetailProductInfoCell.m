//
//  DetailProductInfoCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/23/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailProductInfoCell.h"

@implementation DetailProductInfoCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"DetailProductInfoCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    _categorybuttons = [NSArray sortViewsWithTagInArray:_categorybuttons];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - View Gestures
- (IBAction)tag:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        [_delegate DetailProductInfoCell:self withbuttonindex:btn.tag];
    }
}

@end
