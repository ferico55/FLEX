//
//  SearchAutoCompleteCell.m
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAutoCompleteCell.h"
#import "UIView+HVDLayout.h"

static const NSString* SEARCH_AUTOCOMPLETE = @"autocomplete";
static const NSString* RECENT_SEARCH = @"recent_search";
@interface SearchAutoCompleteCell()
    @property (strong, nonatomic) IBOutlet UIButton *autoFillButton;
@end

@implementation SearchAutoCompleteCell

- (void)setSearchCell:(SearchSuggestionItem*) item section:(SearchSuggestionData*) data {
    [_searchTitle setText:item.keyword];
    
    _closeButton.hidden = YES;
    _searchLoopImageView.hidden = YES;
    _autoFillButton.hidden = NO;
    _searchTitleLeadingToSuperViewConstraint.constant = 21;
    if([data.id isEqual: RECENT_SEARCH]) {
        _closeButton.hidden = NO;
        _autoFillButton.hidden = YES;
    } else if ([data.id isEqual: SEARCH_AUTOCOMPLETE]){
        _searchLoopImageView.hidden = NO;
        _searchTitleLeadingToSuperViewConstraint.constant = 46;
    }
}

- (void)setBoldSearchText:(NSString *)searchText {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[_searchTitle text]];
    
    NSRange range = [[_searchTitle text] rangeOfString:searchText options:NSCaseInsensitiveSearch];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont title2ThemeMedium]} range:range];
    [_searchTitle setAttributedText:attributedText];
}

- (void) setGreenSearchText:(NSString*)searchText {
    if(searchText != nil) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[_searchTitle text]];
        
        NSRange range = [[_searchTitle text] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        UIColor *tokopediaGreenColor = [UIColor colorWithRed:65.0/255 green:181.0/255 blue:73.0/255 alpha:1.0];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:tokopediaGreenColor} range: range];
        [_searchTitle setAttributedText:attributedText];
    }
}
- (IBAction)didTapAutoFillButton:(UIButton *)sender {
    if (self. didTapAutoFillButton) {
        self.didTapAutoFillButton(_searchTitle.text);
    }
}


@end
