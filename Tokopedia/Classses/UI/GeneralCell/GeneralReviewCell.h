//
//  GeneralReviewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StarsRateView.h"

#define kTKPDGENERALREVIEWCELLIDENTIFIER @"GeneralReviewCellIdentifier"

#pragma mark - Hotlist Result  Cell Delegate
@protocol GeneralReviewCellDelegate <NSObject>
@required
-(void)GeneralReviewCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@optional
- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath;
@end

#pragma mark - General Review Cell
@interface GeneralReviewCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<GeneralReviewCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<GeneralReviewCellDelegate> delegate;
#endif


@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNamelabel;
@property (weak, nonatomic) IBOutlet UILabel *productNamelabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *commentlabel;
@property (weak, nonatomic) IBOutlet StarsRateView *qualityrate;
@property (weak, nonatomic) IBOutlet StarsRateView *speedrate;
@property (weak, nonatomic) IBOutlet StarsRateView *servicerate;
@property (weak, nonatomic) IBOutlet StarsRateView *accuracyrate;
@property (weak, nonatomic) IBOutlet UIButton *commentbutton;
@property (weak, nonatomic) IBOutlet UIButton *editReviewButton;
@property (weak, nonatomic) IBOutlet UIButton *reportReviewButton;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UIView *inputReviewView;
@property (weak, nonatomic) IBOutlet UIView *contentReview;
@property (strong,nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSIndexPath *indexpath;

@property (nonatomic) BOOL productViewIsHidden;

+(id)newcell;

@end
