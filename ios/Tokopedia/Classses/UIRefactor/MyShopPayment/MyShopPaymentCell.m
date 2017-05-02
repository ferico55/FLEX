//
//  MyShopPaymentCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "MyShopPaymentCell.h"

@implementation MyShopPaymentCell

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"MyShopPaymentCell" owner:nil options:0];
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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)tap:(id)sender {
    [_delegate MyShopPaymentCell:self withindexpath:_indexPath];
}

@end
