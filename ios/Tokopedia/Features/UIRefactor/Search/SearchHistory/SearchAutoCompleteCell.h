//
//  SearchAutoCompleteCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SearchAutoCompleteViewModel.h"
#import "Tokopedia-Swift.h"

@interface SearchAutoCompleteCell : UICollectionViewCell
@property (strong, nonatomic, nonnull) IBOutlet UILabel *searchTitle;
@property (strong, nonatomic, nonnull) IBOutlet UIButton *closeButton;
@property (strong, nonatomic, nonnull) IBOutlet UIImageView *searchLoopImageView;
@property (strong, nonatomic, nonnull) IBOutlet NSLayoutConstraint *searchTitleLeadingToSuperViewConstraint;
@property (nonatomic, copy, nullable) void (^didTapAutoFillButton)(NSString* _Nonnull text);

- (void)setSearchCell:(SearchSuggestionItem* _Nonnull) item section:(SearchSuggestionData* _Nonnull) data;

@end
