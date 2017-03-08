//
//  SearchAutoCompleteShopCell.m
//  Tokopedia
//
//  Created by Ronald on 1/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "SearchAutoCompleteShopCell.h"
#import "UIView+HVDLayout.h"

@interface SearchAutoCompleteShopCell ()

@property (strong, nonatomic) IBOutlet UIImageView *shopImage;
@property (strong, nonatomic) IBOutlet UIImageView *shopBadge;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shopNameLeading;

@end

@implementation SearchAutoCompleteShopCell

- (void)setSearchItem:(SearchSuggestionItem *)searchItem {
    [_shopName setText:searchItem.keyword];
    [_shopImage setImageWithURL:[NSURL URLWithString:searchItem.imageURI]];

    if (searchItem.isOfficial) {
        _shopNameLeading.constant = 40;
        _shopBadge.hidden = NO;
    } else {
        _shopNameLeading.constant = 20;
        _shopBadge.hidden = YES;
    }
}


@end
