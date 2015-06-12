//
//  SearchAutoCompleteCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SearchAutoCompleteViewModel.h"

@interface SearchAutoCompleteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *searchTitle;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;

- (void)setViewModel:(SearchAutoCompleteViewModel *)viewModel;
- (void)setBoldSearchText:(NSString*)searchText;


@end
