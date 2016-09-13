//
//  SearchAutoCompleteCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SearchAutoCompleteViewModel.h"

@interface SearchAutoCompleteCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *searchTitle;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIImageView *searchLoopImageView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchTitleLeadingToSuperViewConstraint;
- (void)setViewModel:(SearchAutoCompleteViewModel *)viewModel;
- (void)setBoldSearchText:(NSString*)searchText;
- (void)setGreenSearchText:(NSString*)searchText;


@end
