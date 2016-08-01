//
//  ResolutionCenterSellerEditProductCell.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterSellerEditProductCell.h"

@interface ResolutionCenterSellerEditProductCell ()


@end

@implementation ResolutionCenterSellerEditProductCell

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ResolutionCenterSellerEditProductCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
