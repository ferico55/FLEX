//
//  SearchAutoCompleteDomains.m
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAutoCompleteHotlist.h"

@implementation SearchAutoCompleteHotlist

- (SearchAutoCompleteViewModel *)viewModel {
    if (_viewModel == nil) {
        SearchAutoCompleteViewModel *viewModel = [[SearchAutoCompleteViewModel alloc] init];
        [viewModel setTitle:self.title];
        _viewModel = viewModel;
    }
    return _viewModel;
}

@end
