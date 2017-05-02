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

- (IBAction)didTapAutoFillButton:(UIButton *)sender {
    if (self. didTapAutoFillButton) {
        self.didTapAutoFillButton(_searchTitle.text);
    }
}

@end
