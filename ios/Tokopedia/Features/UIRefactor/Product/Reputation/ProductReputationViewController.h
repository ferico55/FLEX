//
//  ProductReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTTAttributedLabel;

@interface ProductReputationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    //Outlet for Header
    IBOutlet UIView *viewHeader, *viewFooter, *viewStarOne, *viewStarTwo, *viewStarThree, *viewStarFour, *viewStarFive;
    IBOutlet UIActivityIndicatorView *footerActIndicator;
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutletCollection(UIImageView) NSArray *arrImageHeaderRating;
    IBOutlet UILabel *lblTotalHeaderRating, *lblDescTotalHeaderRating, *lblTotal5Rate, *lblTotal4Rate, *lblTotal3Rate, *lblTotal2Rate, *lblTotal1Rate;
    IBOutlet UIProgressView *progress5, *progress4, *progress3, *progress2, *progress1;
    IBOutlet NSLayoutConstraint *constWidthLblRate5, *constWidthLblRate4, *constWidthLblRate3, *constWidthLblRate2, *constWidthLblRate1;
    
    //Main Outlet
    IBOutlet UITableView *tableContent;
}

@property (nonatomic, strong) NSString *strShopDomain, *strProductID;
@property (nonatomic, weak) IBOutlet UIView *filterView;
@property (strong, nonatomic) IBOutlet UIView *helpfulReviewFooter;
@property (strong, nonatomic) IBOutlet UIView *helpfulReviewHeader;
@property (strong, nonatomic) IBOutlet UITableViewCell *helpfulReviewLoadMoreCell;
@property (strong, nonatomic) IBOutlet UIButton *buttonShowMore;
@property (strong, nonatomic) IBOutlet UIView *middleMargin;



- (void)reloadTable;
- (IBAction)actionResetFilter:(id)sender;
- (IBAction)actionFilter6Month:(id)sender;
- (IBAction)actionFilterAllTime:(id)sender;
- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc;
- (IBAction)actionSegmentedValueChange:(id)sender;
@end
