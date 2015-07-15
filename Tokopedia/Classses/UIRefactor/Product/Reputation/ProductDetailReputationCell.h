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
- (void)actionTryAgain:(id)sender;
- (void)actionHapus:(id)sender;
@end


@interface ProductDetailReputationCell : UITableViewCell
{
    IBOutlet UIButton *btnRetry, *btnHapus;
    IBOutlet ViewLabelUser *viewLabelUser;
    IBOutletCollection(UIImageView) NSArray *arrImageView;
    IBOutlet UITextView *tvDesc;
    IBOutlet UILabel *lblDate;
    IBOutlet UIImageView *imgProfile;
    IBOutlet NSLayoutConstraint *constraintHeightDesc;
    IBOutlet UIView *viewStar;
}

@property (nonatomic, unsafe_unretained) id<ProductDetailReputationDelegate> delegate;

- (UIButton *)getBtnHapus;
- (UIButton *)getBtnTryAgain;
- (IBAction)actionTryAgain:(id)sender;
- (IBAction)actionHapus:(id)sender;
- (void)setStar:(int)valueStar;
- (ViewLabelUser *)getViewLabelUser;
- (UIView *)getViewStar;
- (UITextView *)getTvDesc;
- (UILabel *)getLblDate;
- (UIImageView *)getImgProfile;
@end
