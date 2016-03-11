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
#import "ReportViewController.h"
#import "RequestLDExtension.h"
#import "ReviewRequest.h"
#import <QuartzCore/QuartzCore.h>

@interface MyReviewDetailViewController ()
<
    UICollectionViewDelegateFlowLayout,
    MyReviewDetailRequestDelegate,
    DetailReputationReviewComponentDelegate,
    MyReviewDetailHeaderDelegate,
    MyReviewDetailHeaderSmileyDelegate,
    UIActionSheetDelegate,
    ReportViewControllerDelegate,
    UIAlertViewDelegate,
    requestLDExttensionDelegate
>
{
    TAGContainer *_gtmContainer;
    MyReviewDetailRequest *_myReviewDetailRequest;
    ReviewRequest *_reviewRequest;
    DetailReputationReview *_detailReputationReview;
    DetailReputationReview *_selectedReview;
    DetailMyInboxReputation *_selectedInbox;
    
    MyReviewDetailHeader *_header;
    
    NSMutableArray *_reviewList;
    
    NSString *_baseURL, *_baseActionURL;
    NSString *_postURL, *_postActionURL;
    NSString *_getDataFromMasterInServer;
    NSString *_score;
    NSString *_token;
    NavigateViewController *_navigator;
    
    UIRefreshControl *_refreshControl;
    IBOutlet UICollectionView *_collectionView;
    MyReviewDetailDataManager *_dataManager;
    
    CMPopTipView *_cmPopTipView;
    
    RequestLDExtension *_request;
    
    BOOL _page;
    BOOL _isRefreshing;
    BOOL _isRefreshView;
    
}

@property (strong, nonatomic) IBOutlet UIView *pageTitleView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

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
    
    _isRefreshView = NO;
    _getDataFromMasterInServer = @"0";
    
    _dataManager = [[MyReviewDetailDataManager alloc] initWithCollectionView:_collectionView
                                                                        role:_detailMyInboxReputation.role
                                                                    isDetail:NO
                                                                    delegate:self];
    
    
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = YES;
    
    _header = [[MyReviewDetailHeader alloc] initWithInboxDetail:_detailMyInboxReputation
                                                                            delegate:self
                                                                      smileyDelegate:self];
    
    [self setHeaderPosition];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];
    [_header addSubview:_refreshControl];

    
    _myReviewDetailRequest = [MyReviewDetailRequest new];
    _myReviewDetailRequest.delegate = self;
    
    _reviewRequest = [ReviewRequest new];
    [_reviewRequest requestGetListReputationReviewWithReputationID:_detailMyInboxReputation.reputation_id
                                                 reputationInboxID:_detailMyInboxReputation.reputation_inbox_id
                                                      isUsingRedis:_getDataFromMasterInServer
                                                              role:_detailMyInboxReputation.role
                                                          autoRead:_autoRead
                                                         onSuccess:^(MyReviewReputationResult *result) {
                                                             _token = result.token;
                                                             
                                                             [_refreshControl endRefreshing];
                                                             [_reviewList removeAllObjects];
                                                             
                                                             if (_page == 0) {
                                                                 _isRefreshing = NO;
                                                                 [_dataManager removeAllReviews];
                                                                 [_dataManager replaceReviews:result.list];
                                                             } else {
                                                                 [_dataManager removeAllReviews];
                                                                 [_dataManager addReviews:result.list];
                                                             }
                                                         } onFailure:^(NSError *errorResult) {
                                                             
                                                         }];
    
    
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
    _pageTitleView.userInteractionEnabled = YES;
    [_pageTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(tapToInvoice)]];
    self.navigationItem.titleView = _pageTitleView;
    
    _navigator = [NavigateViewController new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData)
                                                 name:@"RefreshData"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My Review Detail Request Delegate
- (void)didReceiveReviewListing:(MyReviewReputationResult *)myReviews {
    
    [_refreshControl endRefreshing];
    [_reviewList removeAllObjects];
    
    if (_page == 0) {
        _isRefreshing = NO;
        [_dataManager removeAllReviews];
        [_dataManager replaceReviews:myReviews.list];
    } else {
        [_dataManager removeAllReviews];
        [_dataManager addReviews:myReviews.list];
    }
}

- (void)didSkipReview:(SkipReviewResult *)skippedReview {
    _detailReputationReview = nil;
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil lewati ulasan"]
                                                                     delegate:self];
    [alert show];
    
    _page = 0;
    _getDataFromMasterInServer = @"1";
    [_reviewList removeAllObjects];
    [_collectionView reloadData];
    
    _detailMyInboxReputation.unassessed_reputation_review = [NSString stringWithFormat:@"%d", [_detailMyInboxReputation.unassessed_reputation_review intValue]-1];
    
    [_myReviewDetailRequest requestGetListReputationReviewWithDetail:_detailMyInboxReputation
                                                            autoRead:_autoRead
                                           getDataFromMasterInServer:_getDataFromMasterInServer];
    
    _getDataFromMasterInServer = @"0";
}

- (void)didFailSkipReview:(SkipReview *)skipReview {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda gagal lewati ulasan"]
                                                                   delegate:self];
    [alert show];
}

- (void)didDeleteReputationReviewResponse:(ResponseCommentResult *)response {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil menghapus komentar"]
                                                                     delegate:self];
    [alert show];
    
    [_collectionView reloadData];
    
    int unassessedReputationReview = [_detailMyInboxReputation.unassessed_reputation_review intValue];
    unassessedReputationReview++;
    
    _detailMyInboxReputation.unassessed_reputation_review = [NSString stringWithFormat:@"%d", unassessedReputationReview];
}

- (void)didInsertReputation:(GeneralAction *)action {
    NSDateFormatter *date = [NSDateFormatter new];
    date.dateFormat = @"d MMMM yyyy, HH:mm";
    if ([action.data.is_success isEqualToString:@"1"]) {
        if (![action.data.ld.url isEqualToString:@""] && action.data.ld.url) {
            _request = [RequestLDExtension new];
            _request.luckyDeal = action.data.ld;
            _request.delegate = self;
            [_request doRequestMemberExtendURLString:action.data.ld.url];
        }
        
        if ([_selectedInbox.role isEqualToString:@"2"]) {
            if (_selectedInbox.buyer_score != nil && ![_selectedInbox.buyer_score isEqualToString:@""]) {
                _selectedInbox.score_edit_time_fmt = [date stringFromDate:[NSDate date]];
            }
            
            _selectedInbox.buyer_score = _score;
        } else {
            if (_selectedInbox.seller_score != nil && ![_selectedInbox.seller_score isEqualToString:@""]) {
                _selectedInbox.score_edit_time_fmt = [date stringFromDate:[NSDate date]];
            }
            
            _selectedInbox.seller_score = _score;
        }
            
    } else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:action.message_error
                                                                       delegate:self];
        [alert show];
    }
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
    return [_dataManager sizeForItemAtIndexPath:indexPath];
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

#pragma mark - Actions
- (void)tapToInvoice {
    [NavigateViewController navigateToInvoiceFromViewController:self
                                     withInvoiceURL:_detailMyInboxReputation.invoice_uri];
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        GiveReviewRatingViewController *vc = [GiveReviewRatingViewController new];
        vc.detailMyReviewReputation = self;
        vc.detailReputationReview = _selectedReview;
        vc.isEdit = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (actionSheet.tag == 200) {
        ReportViewController *vc = [ReportViewController new];
        vc.delegate = self;
        vc.strProductID = _selectedReview.product_id;
        vc.strShopID = _selectedReview.shop_id;
        vc.strReviewID = _selectedReview.review_id;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [_myReviewDetailRequest requestDeleteReputationReviewResponse:_selectedReview];
    }
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex && (alertView.tag == 10 || alertView.tag == 20 || alertView.tag == 30)) {
        [_myReviewDetailRequest requestInsertReputation:_selectedInbox withScore:_score];
    }
}

#pragma mark - Reputation Detail Cells Delegate
- (void)didTapProductWithReview:(DetailReputationReview *)review{
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
    vc.isEdit = NO;
    vc.token = _token;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapToSkipReview:(DetailReputationReview *)review {
    _selectedReview = review;
    
    
    [_myReviewDetailRequest requestSkipReviewWithDetail:review];
}

- (void)didTapToEditReview:(DetailReputationReview *)review {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Batal"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Ubah", nil];
    _selectedReview = review;
    actionSheet.tag = 100;
    
    [actionSheet showInView:self.view];
}

- (void)didTapToReportReview:(DetailReputationReview *)review {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Batal"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Lapor", nil];
    _selectedReview = review;
    actionSheet.tag = 200;
    
    [actionSheet showInView:self.view];
}

- (void)didTapToDeleteResponse:(DetailReputationReview *)review {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Batal"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Hapus", nil];
    _selectedReview = review;
    actionSheet.tag = 300;
    
    [actionSheet showInView:self.view];
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
    
    NSString *smileyNoneString = @"";
    
    if ([inbox.reputation_progress isEqualToString:@"2"]) {
        if ([inbox.role isEqualToString:@"1"]) {
            smileyNoneString = @"Penjual telah melewati batas waktu penilaian";
        } else {
            smileyNoneString = @"Pembeli telah melewati batas waktu penilaian";
        }
    } else {
        if ([inbox.role isEqualToString:@"1"]) {
            smileyNoneString = @"Penjual belum memberi nilai untuk Anda";
        } else {
            smileyNoneString = @"Pembeli belum memberi nilai untuk Anda";
        }
    }
    
    NSDictionary<NSString*, NSString*>* myScoreMessageByType = @{
                                                                   @"smiley_neutral":[inbox.role isEqualToString:@"1"]?@"Nilai dari Penjual: \"Netral\"":@"Nilai dari Pembeli: \"Netral\"",
                                                                   @"smiley_bad":[inbox.role isEqualToString:@"1"]?@"Nilai dari Penjual: \"Tidak Puas\"":@"Nilai dari Pembeli : \"Tidak Puas\"",
                                                                   @"smiley_good":[inbox.role isEqualToString:@"1"]?@"Nilai dari Penjual: \"Puas\"":@"Nilai dari Pembeli: \"Puas\"",
                                                                   @"smiley_none":smileyNoneString,
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

- (void)didTapLockedSmiley {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Anda telah melewati batas waktu penilaian."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

- (void)didTapNotSatisfiedSmiley:(DetailMyInboxReputation*)inbox {
    _selectedInbox = inbox;
    if ([_detailMyInboxReputation.their_score_image isEqualToString:@"smiley_neutral"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Maaf, Anda tidak bisa melakukan penurunan nilai"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Apakah Anda yakin memberi nilai Tidak Puas?"
                                                       delegate:self
                                              cancelButtonTitle:@"Ya"
                                              otherButtonTitles:@"Tidak", nil];
        _score = @"-1";
        alert.tag = 10;
        [alert show];
    }
}

- (void)didTapNeutralSmiley:(DetailMyInboxReputation*)inbox {
    _selectedInbox = inbox;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Apakah Anda yakin memberi nilai Netral?"
                                                   delegate:self
                                          cancelButtonTitle:@"Ya"
                                          otherButtonTitles:@"Tidak", nil];
    _score = @"1";
    alert.tag = 20;
    [alert show];
}

- (void)didTapSatisfiedSmiley:(DetailMyInboxReputation*)inbox {
    _selectedInbox = inbox;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Apakah Anda yakin memberi nilai Puas?"
                                                   delegate:self
                                          cancelButtonTitle:@"Ya"
                                          otherButtonTitles:@"Tidak", nil];
    _score = @"2";
    alert.tag = 30;
    [alert show];
}

#pragma mark - Report View Delegate
- (NSDictionary *)getParameter {
    return nil;
}

- (NSString *)getPath {
    return @"action/review.pl";
}

- (UIViewController *)didReceiveViewController {
    return self;
}

#pragma mark - Lucky Deal Delegate
- (void)showPopUpLuckyDeal:(LuckyDealWord *)words {
    [_navigator popUpLuckyDeal:words];
}

#pragma mark - Methods
- (void)setHeaderPosition {
    _headerView = _header;
    CGRect frame = _header.frame;
    frame.size.width = self.view.bounds.size.width;
    _header.frame = frame;
    [_header sizeToFit];
    
    
    frame = _header.frame;
    frame.origin.y = -_header.frame.size.height;
    _header.frame = frame;
    
    [_collectionView addSubview:_header];
    _collectionView.contentInset = UIEdgeInsetsMake(_header.frame.size.height, 0, 8, 0);
}

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

- (void)refreshData {
    [_reviewRequest requestGetListReputationReviewWithReputationID:_detailMyInboxReputation.reputation_id
                                                 reputationInboxID:_detailMyInboxReputation.reputation_inbox_id
                                                      isUsingRedis:_getDataFromMasterInServer
                                                              role:_detailMyInboxReputation.role
                                                          autoRead:_autoRead
                                                         onSuccess:^(MyReviewReputationResult *result) {
                                                             [_refreshControl endRefreshing];
                                                             [_reviewList removeAllObjects];
                                                             
                                                             if (_page == 0) {
                                                                 _isRefreshing = NO;
                                                                 [_dataManager removeAllReviews];
                                                                 [_dataManager replaceReviews:result.list];
                                                             } else {
                                                                 [_dataManager removeAllReviews];
                                                                 [_dataManager addReviews:result.list];
                                                             }
                                                         } onFailure:^(NSError *errorResult) {
                                                             
                                                         }];
    
    _header = [[MyReviewDetailHeader alloc] initWithInboxDetail:_detailMyInboxReputation
                                             delegate:self
                                       smileyDelegate:self];
    
//    [self setHeaderPosition];
}

@end
