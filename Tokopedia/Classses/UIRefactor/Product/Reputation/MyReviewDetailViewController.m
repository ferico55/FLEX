//
//  MyReviewDetailViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailViewController.h"
#import "MyReviewDetailRequest.h"
#import "NavigateViewController.h"
#import "MyReviewReputationViewModel.h"
#import "MyReviewDetailTableViewCell.h"
#import "ShopBadgeLevel.h"
#import "SmileyAndMedal.h"
#import "UIImageView+AFNetworking.h"
#import "ViewLabelUser.h"
#import "MyReviewDetailDataManager.h"
#import "DetailReputationReviewComponentDelegate.h"
#import "MyReviewDetailHeaderDelegate.h"
#import "MyReviewDetailHeaderSmileyDelegate.h"
#import "NavigateViewController.h"
#import "GiveReviewRatingViewController.h"
#import "MyReviewDetailHeader.h"
#import "CMPopTipView.h"
#import "GiveReviewResponseViewController.h"
#import <QuartzCore/QuartzCore.h>

#define GIVE_REVIEW_CELL_IDENTIFIER @"GiveReviewCellIdentifier"
#define REVIEW_DETAIL_CELL_IDENTIFIER @"ReviewDetailCellIdentifier"
#define SKIPPED_REVIEW_CELL_IDENTIFIER @"SkippedReviewCellIdentifier"

@interface MyReviewDetailViewController ()
<
    UICollectionViewDelegateFlowLayout,
    MyReviewDetailRequestDelegate,
    DetailReputationReviewComponentDelegate,
    MyReviewDetailHeaderDelegate,
    MyReviewDetailHeaderSmileyDelegate
>
{
    TAGContainer *_gtmContainer;
    MyReviewDetailRequest *_myReviewDetailRequest;
    DetailReputationReview *_detailReputationReview;
    
    NSMutableArray *_reviewList;
    
    NSString *_baseURL, *_baseActionURL;
    NSString *_postURL, *_postActionURL;
    NavigateViewController *_navigator;
    
    UIRefreshControl *_refreshControl;
    IBOutlet UICollectionView *_collectionView;
    MyReviewDetailDataManager *_dataManager;
    
    CMPopTipView *_cmPopTipView;
    
    BOOL _page;
    BOOL _isRefreshing;
}

@property (weak, nonatomic) IBOutlet UITableView *reviewDetailTable;

@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (strong, nonatomic) IBOutlet UIView *remainingTimeView;
@property (strong, nonatomic) IBOutlet UIView *pageTitleView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *theirScoreView;
@property (weak, nonatomic) IBOutlet UIView *myScoreView;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet ViewLabelUser *revieweeNameViewLabel;
@property (weak, nonatomic) IBOutlet UIButton *reputationScoreButton;

@property (weak, nonatomic) IBOutlet UILabel *myScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *myScoreButton;
@property (weak, nonatomic) IBOutlet UILabel *isMyScoreEditedLabel;

@property (weak, nonatomic) IBOutlet UILabel *theirScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *theirScoreButton;
@property (weak, nonatomic) IBOutlet UILabel *isTheirScoreEditedLabel;

@property (weak, nonatomic) IBOutlet UILabel *reviewTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceTitleLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MyReviewDetailViewController
{
    UIView *_headerView;
}

- (void)viewDidLayoutSubviews {
    CGRect frame = _headerView.frame;
    frame.size.width = self.view.bounds.size.width;
    _headerView.frame = frame;
    [_headerView sizeToFit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureGTM];
    
    _dataManager = [[MyReviewDetailDataManager alloc] initWithCollectionView:_collectionView
                                                                        role:_detailMyInboxReputation.role
                                                                    isDetail:NO
                                                                    delegate:self];
    
    _collectionView.delegate = self;
    
    MyReviewDetailHeader *header = [[MyReviewDetailHeader alloc] initWithInboxDetail:_detailMyInboxReputation
                                                                            delegate:self
                                                                      smileyDelegate:self];
    
    _headerView = header;
    CGRect frame = header.frame;
    frame.size.width = self.view.bounds.size.width;
    header.frame = frame;
    [header sizeToFit];
    
    
    frame = header.frame;
    frame.origin.y = -header.frame.size.height;
    header.frame = frame;

    [_collectionView addSubview:header];
    _collectionView.contentInset = UIEdgeInsetsMake(header.frame.size.height, 0, 8, 0);
    
//    dispatch_after(3, dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:2 animations:^{
//            _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//        }];
//
//    });
//
    
    
    _myReviewDetailRequest = [MyReviewDetailRequest new];
    _myReviewDetailRequest.delegate = self;
    [_myReviewDetailRequest requestGetListReputationReviewWithDetail:_detailMyInboxReputation
                                                            autoRead:_autoRead];
    
    _navigator = [NavigateViewController new];
    
    if ([_detailMyInboxReputation.role isEqualToString:@"1"]) {
        _detailMyInboxReputation.updated_reputation_review = @"0";
    }
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    _invoiceTitleLabel.text = _detailMyInboxReputation.invoice_ref_num;
    _pageTitleView.frame = CGRectMake(0, 0, self.view.bounds.size.width-(72*2), self.navigationController.navigationBar.bounds.size.height);
    self.navigationItem.titleView = _pageTitleView;
    
    _navigator = [NavigateViewController new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My Review Detail Request Delegate
- (void)didReceiveReviewListing:(MyReviewReputationResult *)myReviews {
    
    [_reviewList removeAllObjects];
    
    if (_page == 0) {
        _isRefreshing = NO;
        [_dataManager replaceReviews:myReviews.list];
    } else {
        [_dataManager addReviews:myReviews.list];
    }
}

- (void)didSkipReview:(SkipReviewResult *)skippedReview {
    _detailReputationReview = nil;
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil lewati ulasan"]
                                                                     delegate:self];
    [alert show];
    
    //    [_reviewDetailTable reloadData];
    
    [_myReviewDetailRequest requestGetListReputationReviewWithDetail:_detailMyInboxReputation
                                                            autoRead:_autoRead];
}

- (void)didFailSkipReview:(SkipReview *)skipReview {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda gagal lewati ulasan"]
                                                                   delegate:self];
    [alert show];
}

#pragma mark - GTM
- (void)configureGTM {
    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _baseURL = [_gtmContainer stringForKey:GTMKeyInboxReputationBase];
    _postURL = [_gtmContainer stringForKey:GTMKeyInboxReputationPost];
    
    _baseActionURL = [_gtmContainer stringForKey:GTMKeyInboxActionReputationBase];
    _postActionURL = [_gtmContainer stringForKey:GTMKeyInboxActionReputationPost];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return  [_dataManager sizeForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_dataManager announceWillAppearForItemInCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_dataManager announceDidDisappearForItemInCell:cell];
}

#pragma mark - Reputation Detail Cells Delegate
- (void)didTapHeaderWithReview:(DetailReputationReview *)review {
    [_navigator navigateToProductFromViewController:self
                                           withName:review.product_name
                                          withPrice:nil
                                             withId:review.product_id
                                       withImageurl:review.product_image
                                       withShopName:review.shop_name];
}

- (void)didTapToGiveReview:(DetailReputationReview *)review {
    GiveReviewRatingViewController *vc = [GiveReviewRatingViewController new];
    vc.detailMyReviewReputation = self;
    vc.detailReputationReview = review;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Header Delegate
- (void)didTapRevieweeNameWithID:(NSString *)revieweeID {
    if ([_detailMyInboxReputation.role isEqualToString:@"2"]) {
        [_navigator navigateToProfileFromViewController:self withUserID:revieweeID];
    } else {
        [_navigator navigateToShopFromViewController:self withShopID:revieweeID];
    }
}

- (void)didTapRevieweeReputation:(id)sender role:(NSString *)role {
//    if ([role isEqualToString:@"1"]) {
//        int paddingRightLeftContent = 10;
//        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
//        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
//        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp
//                                 andPadding:paddingRightLeftContent
//                       withReputationNetral:_detailMyInboxReputation.user_reputation.neutral
//                               withRepSmile:_detailMyInboxReputation.user_reputation.positive
//                                 withRepSad:_detailMyInboxReputation.user_reputation.negative
//                               withDelegate:self];
//        
//        //Init pop up
//        _cmPopTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
//        _cmPopTipView.delegate = self;
//        _cmPopTipView.backgroundColor = [UIColor whiteColor];
//        _cmPopTipView.animation = CMPopTipAnimationSlide;
//        _cmPopTipView.dismissTapAnywhere = YES;
//        _cmPopTipView.leftPopUp = YES;
//        
//        [_cmPopTipView presentPointingAtView:sender
//                                      inView:self.view
//                                    animated:YES];
//    } else {
//        NSString *strText = [NSString stringWithFormat:@"%@ %@", _detailMyInboxReputation.reputation_score, CStringPoin];
//        [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
//    }
}

- (void)didTapToGiveResponse:(DetailReputationReview *)review {
    GiveReviewResponseViewController *vc = [GiveReviewResponseViewController new];
    vc.inbox = _detailMyInboxReputation;
    vc.review = review;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Smiley Delegate
- (void)didTapReviewerScore:(DetailMyInboxReputation*)inbox {
    
    NSDictionary<NSString*, NSString*>* myScoreMessageByType = @{
                                                                   @"smiley_neutral":[inbox.role isEqualToString:@"1"]?@"Nilai dari Penjual: \"Netral\"":@"Nilai dari Pembeli: \"Netral\"",
                                                                   @"smiley_bad":[inbox.role isEqualToString:@"1"]?@"Nilai dari Penjual: \"Tidak Puas\"":@"Nilai dari Pembeli : \"Tidak Puas\"",
                                                                   @"smiley_good":[inbox.role isEqualToString:@"1"]?@"Nilai dari Penjual: \"Puas\"":@"Nilai dari Pembeli: \"Puas\"",
                                                                   @"smiley_none":[inbox.role isEqualToString:@"1"]?@"Penjual telah melewati batas waktu penilaian":@"Pembeli telah melewati batas waktu penilaian",
                                                                   @"grey_question_mark":[inbox.role isEqualToString:@"1"]?@"Penjual belum memberi nilai untuk Anda":@"Pembeli belum memberi nilai untuk Anda",
                                                                   @"blue_question_mark":[inbox.role isEqualToString:@"1"]?@"Beri nilai Penjual untuk melihat nilai Anda":@"Beri nilai Pembeli untuk melihat nilai Anda"
                                                                   };
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                      message:[myScoreMessageByType objectForKey:inbox.my_score_image]
                                     delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Methods
- (void)initPopUp:(NSString *)strText withSender:(id)sender withRangeDesc:(NSRange)range
{
    UILabel *lblShow = [[UILabel alloc] init];
    CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strText attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    [lblShow setAttributedText:attributedText];
    
    
    CGSize tempSize = [lblShow sizeThatFits:CGSizeMake(self.view.bounds.size.width-40, 9999)];
    lblShow.frame = CGRectMake(0, 0, tempSize.width, tempSize.height);
    lblShow.backgroundColor = [UIColor clearColor];
    
    //Init pop up
    _cmPopTipView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    _cmPopTipView.delegate = self;
    _cmPopTipView.backgroundColor = [UIColor blackColor];
    _cmPopTipView.animation = CMPopTipAnimationSlide;
    _cmPopTipView.dismissTapAnywhere = YES;
    _cmPopTipView.leftPopUp = YES;
    
    UIButton *button = (UIButton *)sender;
    [_cmPopTipView presentPointingAtView:button
                                  inView:self.view
                                animated:YES];
}

@end
