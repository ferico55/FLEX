//
//  CatalogShopCell.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogShopCell.h"

@implementation CatalogShopCell

- (void)awakeFromNib {
    [viewContentStar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionContentStar:)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)actionContentStar:(id)sender {
    [_delegate actionContentStar:((UITapGestureRecognizer *) sender).view];
}

- (IBAction)tap:(id)sender
{
    if ([[sender view] isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)[sender view];
        if (button.tag == 1) {
            [self.delegate tableViewCell:self didSelectBuyButtonAtIndexPath:_indexPath];
        } else if (button.tag == 2) {
            [self.delegate tableViewCell:self didSelectOtherProductAtIndexPath:_indexPath];
        }
    } else {
        UIView *view = (UIView *)[sender view];
        if (view.tag == 1) {
            [self.delegate tableViewCell:self didSelectShopAtIndexPath:_indexPath];
        } else if (view.tag == 2) {
            [self.delegate tableViewCell:self didSelectProductAtIndexPath:_indexPath];
        }
    }
}

- (void)setTagContentStar:(int)tag {
    viewContentStar.tag = tag;
}
@end