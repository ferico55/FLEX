//
//  SearchResultShopCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SearchResultShopCell.h"

@implementation SearchResultShopCell

#pragma mark - Factory methods
+ (id)newcell {
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"SearchResultShopCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}


#pragma mark - View Action
- (IBAction)gesture:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                [_delegate SearchResultShopCell:self withindexpath:_indexpath];
                break;
            }
                
            default:
                break;
        }
    }
}


- (void)setModelView:(SearchShopModelView *)modelView {
    self.shopName.text = modelView.shopName;
    [self.shopImage setImageWithURL:[NSURL URLWithString:modelView.shopImageUrl]];
    self.shopImage.layer.masksToBounds = YES;
    self.shopImage.layer.cornerRadius = self.shopImage.frame.size.width / 2;
    
    self.shopLocation.text = modelView.shopLocation;
    self.goldBadgeView.hidden = modelView.isGoldShop ? NO : YES;
    
}

@end
