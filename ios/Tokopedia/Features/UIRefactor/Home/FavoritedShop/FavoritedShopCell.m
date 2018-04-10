//
//  FavoritedShopCell.m
//  Tokopedia
//
//  Created by Tokopedia on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoritedShopCell.h"
#import "Tokopedia-Swift.h"

@implementation FavoritedShopCell

@synthesize delegate = _delegate;

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"FavoritedShopCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

#pragma mark - Initialization

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - View Gesture
- (IBAction)gesture:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                [_delegate FavoritedShopCell:self withindexpath:_indexpath withimageview:_shopimageview];
                break;
            }
                
            default:
                break;
        }
    }
    
}


#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    ((UIButton *)sender).enabled = NO;
    [_delegate didFollowPromotedShop:_promoResult];
}

- (void)setupButtonIsFavorited:(BOOL)isFavorited {
    _isfavoritedshop.hidden = isFavorited;
    [_isfavoritedshop setImage:[UIImage imageNamed:isFavorited?@"icon_check_favorited":@"icon_follow_plus"] forState:UIControlStateNormal];
    [_isfavoritedshop setTitle:isFavorited?@" Favorit":@"Favoritkan" forState:UIControlStateNormal];
    [_isfavoritedshop setTitleColor:isFavorited?[UIColor colorWithRed:0 green:0 blue:0 alpha:0.53]:[UIColor whiteColor] forState:UIControlStateNormal];
    [_isfavoritedshop setBackgroundColor:isFavorited?[UIColor whiteColor]:[UIColor fromHexString:@"#42B549"]];
    [_isfavoritedshop setBorderColor:isFavorited?[UIColor colorWithRed:0 green:0 blue:0 alpha:0.53]:[UIColor fromHexString:@"#42B549"]];
    _isfavoritedshop.enabled = isFavorited ? NO : YES;
    _isfavoritedshop.accessibilityLabel = isFavorited?@"Favorit":@"Favoritkan";
}

@end

