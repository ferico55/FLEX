//
//  SearchAutoCompleteCell.m
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAutoCompleteCell.h"
#import "UIView+HVDLayout.h"

@implementation SearchAutoCompleteCell

- (void)awakeFromNib {
    // Initialization code
    [self.contentView HVD_fillInSuperViewWithInsets:UIEdgeInsetsZero];
}

- (void)setViewModel:(SearchAutoCompleteViewModel *)viewModel {
    [_searchTitle setText:viewModel.title];
    [self setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    
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
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont title2ThemeMedium]} range:range];
    [_searchTitle setAttributedText:attributedText];
}

- (void) setGreenSearchText:(NSString*)searchText {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[_searchTitle text]];
    
    NSRange range = [[_searchTitle text] rangeOfString:searchText options:NSCaseInsensitiveSearch];
    UIColor *tokopediaGreenColor = [UIColor colorWithRed:65.0/255 green:181.0/255 blue:73.0/255 alpha:1.0];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:tokopediaGreenColor} range: range];
    [_searchTitle setAttributedText:attributedText];
}


@end
