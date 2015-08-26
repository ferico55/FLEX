//
//  SearchAutoCompleteCell.m
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAutoCompleteCell.h"

@implementation SearchAutoCompleteCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setViewModel:(SearchAutoCompleteViewModel *)viewModel {
    [_searchTitle setText:viewModel.title];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.imageUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_searchImage setContentMode:UIViewContentModeCenter];
    [_searchImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [_searchImage setContentMode:UIViewContentModeScaleAspectFill];
        [_searchImage setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [_searchImage setImage:nil];
    }];
}

- (void)setBoldSearchText:(NSString *)searchText {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[_searchTitle text]];
    
    NSRange range = [[_searchTitle text] rangeOfString:searchText options:NSCaseInsensitiveSearch];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]} range:range];
    [_searchTitle setAttributedText:attributedText];
}


@end
