//
//  GeneralTextFieldCell.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 6/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "GeneralTextFieldCell.h"

@implementation GeneralTextFieldCell

+ (id)newCell {
    NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"GeneralTextFieldCell"
                                               owner:nil
                                             options:0];
    
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
