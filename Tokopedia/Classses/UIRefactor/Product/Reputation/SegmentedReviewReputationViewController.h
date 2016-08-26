//
//  SegmentedReviewReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CTagSemua 0
#define CTagProductSaya 1
#define CTagReviewSaya 2

#define CTagSemuaReview @"all"
#define CTagBelumDibaca @"unread"
#define CtagBelumDireviw @"unassessed"
@class MyReviewReputationViewController, SplitReputationViewController;

@interface SegmentedReviewReputationViewController : UIViewController
{
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UIView *viewContent, *viewContentAction, *viewShadow;
    IBOutlet UIButton *btnAllReview, *btnBelumDibaca, *btnBelumDireview;
    IBOutlet NSLayoutConstraint *constTopCheckList;
    IBOutlet UILabel *lblDescChangeReviewStyle;
    IBOutlet UIView *segmentedControlView;
}

@property (nonatomic, unsafe_unretained) SplitReputationViewController *splitVC;
@property (nonatomic) int selectedIndex;
@property (nonatomic) BOOL getDataFromMasterDB;
@property (nonatomic) BOOL userHasShop;

- (NSString *)getSelectedFilter;
- (IBAction)actionReview:(id)sender;
- (IBAction)actionBelumDibaca:(id)sender;
- (IBAction)actionBelumDireview:(id)sender;
- (IBAction)actionValueChange:(id)sender;
- (int)getSelectedSegmented;
- (void)setNavigationTitle:(NSString *)strTitle;
- (MyReviewReputationViewController *)getSegmentedViewController;
@end
