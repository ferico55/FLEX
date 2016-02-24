//
//  FilterCategoryViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "FilterCategoryViewCell.h"

@implementation FilterCategoryViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *nib = [bundle loadNibNamed:@"FilterCategoryViewCell" owner:self options:nil];
        self = [nib objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.checkmarkImageView.hidden = NO;        
    }
}

@end
