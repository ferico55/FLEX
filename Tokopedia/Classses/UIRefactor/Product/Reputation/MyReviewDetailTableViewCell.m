//
//  MyReviewDetailTableViewCell.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailTableViewCell.h"

@implementation MyReviewDetailTableViewCell

#pragma mark - Factory Methods
+ (id)newCell {
    NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"MyReviewDetailTableViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Actions
- (IBAction)tapToGiveReview:(UIButton*)sender {
    [_delegate giveReviewAtIndexPath:_indexPath];
}

- (IBAction)tapToSkipReview:(UIButton*)sender {
    [_delegate skipReviewAtIndexPath:_indexPath];
}

- (IBAction)tapToEditReview:(UIButton*)sender {
    [_delegate editReviewAtIndexPath:_indexPath];
}

- (IBAction)tapToViewImages:(UITapGestureRecognizer*)sender {
    [_delegate goToImageViewerAtIndexPath:_indexPath];
}

- (IBAction)tapToProductDetail:(UITapGestureRecognizer*)sender {
    [_delegate goToProductDetailAtIndexPath:_indexPath];
}

@end
