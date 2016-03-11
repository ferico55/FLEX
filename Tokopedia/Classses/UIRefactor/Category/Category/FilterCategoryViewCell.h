//
//  FilterCategoryViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCategoryViewCell : UITableViewCell

typedef NS_ENUM(NSUInteger, ArrowDirection) {
    ArrowDirectionUp,
    ArrowDirectionDown,
};

@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftPaddingConstraint;

- (void)showCheckmark;
- (void)hideCheckmark;

- (void)showArrow;
- (void)hideArrow;
- (void)setArrowDirection:(ArrowDirection)direction;

@end
