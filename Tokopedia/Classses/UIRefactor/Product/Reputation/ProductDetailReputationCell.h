//
//  ProductDetailReputationCell.h
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewLabelUser;
@protocol ProductDetailReputationDelegate <NSObject>
- (void)actionTapStar:(UIView *)sender;
@end


@interface ProductDetailReputationCell : UITableViewCell
{
    IBOutlet ViewLabelUser *viewLabelUser;
    IBOutletCollection(UIImageView) NSArray *arrImageView;
    IBOutlet UITextView *tvDesc;
    IBOutlet UILabel *lblDate;
    IBOutlet UIImageView *imgProfile;
    IBOutlet NSLayoutConstraint *constraintHeightDesc;
    IBOutlet UIView *viewStar;
}

@property (nonatomic, unsafe_unretained) id<ProductDetailReputationDelegate> delegate;

- (void)setStar:(int)valueStar;
- (ViewLabelUser *)getViewLabelUser;
- (UIView *)getViewStar;
- (UITextView *)getTvDesc;
- (UILabel *)getLblDate;
- (UIImageView *)getImgProfile;
@end
