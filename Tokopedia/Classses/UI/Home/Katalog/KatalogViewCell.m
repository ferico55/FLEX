//
//  KatalogViewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "KatalogViewCell.h"

@implementation KatalogViewCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"KatalogViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}

@end
