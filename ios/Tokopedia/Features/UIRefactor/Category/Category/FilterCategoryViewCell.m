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

- (void)showCheckmark {
    UIImage *image = [UIImage imageNamed:@"icon-checkmark-filled.png"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.checkmarkImageView.image = image;
    UIColor *greenColor = [UIColor colorWithRed:72.0/255.0 green:187.0/255.0 blue:72.0/255.0 alpha:1];
    self.checkmarkImageView.tintColor = greenColor;
    self.checkmarkImageView.hidden = NO;
}

- (void)hideCheckmark {
    self.checkmarkImageView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.checkmarkImageView.hidden = NO;        
    }
}

- (void)showArrow {
    self.arrowImageView.hidden = NO;
}

- (void)hideArrow {
    self.arrowImageView.hidden = YES;
}

- (void)setArrowDirection:(ArrowDirection)direction {
    if (direction == ArrowDirectionUp) {
        UIImage *image = [UIImage imageNamed:@"icon-minus-math.png"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.arrowImageView.image = image;
    } else if (direction == ArrowDirectionDown) {
        UIImage *image = [UIImage imageNamed:@"icon-plus-math.png"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.arrowImageView.image = image;
    }
}

@end
