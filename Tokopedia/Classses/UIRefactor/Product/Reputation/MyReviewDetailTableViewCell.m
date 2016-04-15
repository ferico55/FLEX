//
//  MyReviewDetailTableViewCell.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailTableViewCell.h"
#import "SmileyAndMedal.h"

@implementation MyReviewDetailTableViewCell

#pragma mark - Factory Methods
+ (id)newCellWithIdentifier:(NSString*)identifier {
    NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"MyReviewDetailTableViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]] && [[o reuseIdentifier] isEqualToString:identifier]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    _accuracyStarsImagesArray = [NSArray sortViewsWithTagInArray:_accuracyStarsImagesArray];
    _qualityStarsImagesArray = [NSArray sortViewsWithTagInArray:_qualityStarsImagesArray];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    screenSize.width = screenSize.width - 20;
    
    CGRect frame = _reviewCommentView.frame;
    frame.size.width = screenSize.width;
    frame.origin.y = _horizontalBorder.frame.origin.y + _horizontalBorder.frame.size.height;
    _reviewCommentView.frame = frame;
    [_reviewDetailView addSubview:_reviewCommentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Methods
- (void)setMedalWithLevel:(NSString*)level set:(NSString*)set {
    [SmileyAndMedal generateMedalWithLevel:level withSet:set withImage:_medalImagesArray isLarge:YES];
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
