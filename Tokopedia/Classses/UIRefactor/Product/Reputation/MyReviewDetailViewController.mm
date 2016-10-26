//
//  MyReviewDetailViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailViewController.h"
#import "NavigateViewController.h"
#import "MyReviewReputationViewModel.h"
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
#import "ReviewRequest.h"
#import "ReviewImageAttachment.h"
#import "UIImageView+AFNetworking.h"
#import "ImageStorage.h"
#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@interface MyReviewDetailViewController ()
<
    UICollectionViewDelegateFlowLayout,
    DetailReputationReviewComponentDelegate,
    MyReviewDetailHeaderDelegate,
    MyReviewDetailHeaderSmileyDelegate,
    UIActionSheetDelegate,
    UIAlertViewDelegate,
    LoadingViewDelegate,
    CMPopTipViewDelegate,
    SmileyDelegate
>
{
    TAGContainer *_gtmContainer;
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
    NSInteger _count;
    NavigateViewController *_navigator;
    
    UIRefreshControl *_refreshControl;
    IBOutlet UICollectionView *_collectionView;
    MyReviewDetailDataManager *_dataManager;
    
    CMPopTipView *_cmPopTipView;
    
    ImageStorage *_imageCache;
    
    LoadingView *_loadingView;
    
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
    
    _isRefreshView = NO;
    _getDataFromMasterInServer = @"0";
    
    _imageCache = [ImageStorage new];
    [_imageCache initImageStorage];
    [_imageCache loadImageNamed:@"icon_toped_loading_grey.png" description:@"IconTopedLoadingGrey"];
    [_imageCache loadImageNamed:@"icon_arrow_down.png" description:@"IconArrowDown"];
    [_imageCache loadImageNamed:@"icon_profile_picture.jpeg" description:@"IconProfilePicture"];
    [_imageCache loadImageNamed:@"icon_smile_small.png" description:@"IconSmileSmall"];
    [_imageCache loadImageNamed:@"icon_medal14.png" description:@"IconMedal"];
    [_imageCache loadImageNamed:@"icon_medal_bronze14.png" description:@"IconMedalBronze"];
    [_imageCache loadImageNamed:@"icon_medal_silver14.png" description:@"IconMedalSilver"];
    [_imageCache loadImageNamed:@"icon_medal_gold14.png" description:@"IconMedalGold"];
    [_imageCache loadImageNamed:@"icon_medal_diamond_one14.png" description:@"IconMedalDiamond"];
    [_imageCache loadImageNamed:@"icon_countdown.png" description:@"IconCountdown"];
    [_imageCache loadImageNamed:@"icon_review_locked.png" description:@"IconReviewLocked"];
    [_imageCache loadImageNamed:@"icon_sad_grey.png" description:@"IconSadGrey"];
    [_imageCache loadImageNamed:@"icon_sad.png" description:@"IconSad"];
    [_imageCache loadImageNamed:@"icon_neutral_grey.png" description:@"IconNeutralGrey"];
    [_imageCache loadImageNamed:@"icon_netral.png" description:@"IconNeutral"];
    [_imageCache loadImageNamed:@"icon_smile_grey.png" description:@"IconSmileGrey"];
    [_imageCache loadImageNamed:@"icon_smile.png" description:@"IconSmile"];
    [_imageCache loadImageNamed:@"icon_question_mark30.png" description:@"IconQuestionMark"];
    [_imageCache loadImageNamed:@"icon_checklist.png" description:@"IconChecklist"];
    [_imageCache loadImageNamed:@"icon_star_active.png" description:@"IconStarActive"];
    [_imageCache loadImageNamed:@"icon_star.png" description:@"IconStar"];
    [_imageCache loadImageNamed:@"icon_order_cancel-01.png" description:@"IconDelete"];
    [_imageCache loadImageNamed:@"icon_default_shop.jpg" description:@"IconDefaultShop"];
    
    _dataManager = [[MyReviewDetailDataManager alloc] initWithCollectionView:_collectionView
                                                                        role:_detailMyInboxReputation.role
                                                                    isDetail:NO
                                                                  imageCache:_imageCache
                                                                    delegate:self];
    
    
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = YES;
    
    _header = [[MyReviewDetailHeader alloc] initWithInboxDetail:_detailMyInboxReputation
                                                     imageCache:_imageCache
                                                       delegate:self
                                                 smileyDelegate:self];
    
    [self setHeaderPosition];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];
    [_header addSubview:_refreshControl];

    _reviewRequest = [ReviewRequest new];
    [_reviewRequest requestGetListReputationReviewWithReputationID:_detailMyInboxReputation.reputation_id
                                                 reputationInboxID:_detailMyInboxReputation.reputation_inbox_id
                                                 getDataFromMaster:_getDataFromMasterInServer
                                                              role:_detailMyInboxReputation.role
                                                          autoRead:_autoRead
                                                         onSuccess:^(MyReviewReputationResult *result) {
                                                             [_loadingView removeFromSuperview];
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
                                                             [_refreshControl endRefreshing];
                                                             [_reviewList removeAllObjects];
                                                             [_dataManager removeAllReviews];
                                                             [self getLoadingView];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshDataWithNotification:)
                                                 name:@"RefreshData"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Inbox Review Detail Page"];
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
    __weak __typeof(self) weakSelf = self;

    if (buttonIndex == 0) {
        if (actionSheet.tag == 100) {
            GiveReviewRatingViewController *vc = [GiveReviewRatingViewController new];
            vc.myReviewDetailViewController = self;
            vc.review = _selectedReview;
            vc.isEdit = YES;
            vc.token = _token;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (actionSheet.tag == 200) {
            ReportViewController *vc = [ReportViewController new];
            vc.onFinishWritingReport = ^(NSString *message) {
                [weakSelf reportReviewWithMessage:message];
            };

            vc.strProductID = _selectedReview.product_id;
            vc.strShopID = _selectedReview.shop_id;
            vc.strReviewID = _selectedReview.review_id;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (actionSheet.tag == 300) {
            [_reviewRequest requestDeleteReputationReviewResponseWithReputationID:_selectedReview.reputation_id
                                                                         reviewID:_selectedReview.review_id
                                                                           shopID:_selectedReview.shop_id
                                                                        onSuccess:^(ResponseCommentResult *result) {
                                                                            [self refreshData];
                                                                        }
                                                                        onFailure:^(NSError *error) {
                                                                            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda gagal membalas ulasan"]
                                                                                                                                           delegate:self];
                                                                            [alert show];
                                                                        }];
        }
    }
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex && (alertView.tag == 10 || alertView.tag == 20 || alertView.tag == 30)) {
        [_reviewRequest requestInsertReputationWithReputationID:_detailMyInboxReputation.reputation_id
                                                           role:_detailMyInboxReputation.role
                                                          score:_score
                                                      onSuccess:^(GeneralActionResult *result) {
                                                          NSDateFormatter *date = [NSDateFormatter new];
                                                          date.dateFormat = @"d MMMM yyyy, HH:mm";
                                                        
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
                                                          
                                                          if ([_score isEqualToString:@"-1"]) {
                                                              StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Saya tidak puas"]
                                                                                                                               delegate:self];
                                                              
                                                              [alert show];
                                                          } else if ([_score isEqualToString:@"1"]) {
                                                              StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Saya cukup puas"]
                                                                                                                               delegate:self];
                                                              
                                                              [alert show];
                                                          } else if ([_score isEqualToString:@"2"]) {
                                                              StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Saya puas"]
                                                                                                                               delegate:self];
                                                              
                                                              [alert show];
                                                          }
                                                          
                                                          [self refreshData];
                                                      }
                                                      onFailure:^(NSError *error) {
                                                          
                                                      }];
    } else if (alertView.tag == 40 && buttonIndex != alertView.cancelButtonIndex) {
        [_reviewRequest requestSkipProductReviewWithProductID:_selectedReview.product_id
                                                 reputationID:_selectedReview.reputation_id
                                                       shopID:_selectedReview.shop_id
                                                    onSuccess:^(SkipReviewResult *result) {
                                                        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda berhasil melewati ulasan"]
                                                                                                                         delegate:self];
                                                        
                                                        [alert show];
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshData"
                                                                                                            object:nil
                                                                                                          userInfo:@{@"n" : @"1"}];
                                                    }
                                                    onFailure:^(NSError *error) {
                                                        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda gagal melewati ulasan"]
                                                                                                                       delegate:self];
                                                        
                                                        [alert show];
                                                    }];
    }
}

#pragma mark - Reputation Detail Cells Delegate
- (void)didTapProductWithReview:(DetailReputationReview *)review{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [_navigator navigateToProductFromViewController:self
                                               withName:review.product_name
                                              withPrice:nil
                                                 withId:review.product_id
                                           withImageurl:review.product_image
                                           withShopName:review.shop_name];
    }
}

- (void)didTapToGiveReview:(DetailReputationReview *)review {
    GiveReviewRatingViewController *vc = [GiveReviewRatingViewController new];
    vc.myReviewDetailViewController = self;
    vc.review = review;
    vc.isEdit = NO;
    vc.token = _token;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapToSkipReview:(DetailReputationReview *)review {
    _selectedReview = review;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Apakah Anda yakin melewati review ini?"
                                                   delegate:self
                                          cancelButtonTitle:@"Tidak"
                                          otherButtonTitles:@"Ya", nil];
    alert.tag = 40;
    [alert show];
}

- (void)didTapToEditReview:(DetailReputationReview *)review atView:(UIView *)view {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Batal"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Ubah", nil];
    _selectedReview = review;
    actionSheet.tag = 100;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
        [actionSheet showFromRect:view.frame inView:view.superview animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:self.view];
    }
}

- (void)didTapToReportReview:(DetailReputationReview *)review atView:(UIView *)view {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Batal"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Lapor", nil];
    _selectedReview = review;
    actionSheet.tag = 200;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
        [actionSheet showFromRect:view.frame inView:view.superview animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:self.view];
    }
}

- (void)didTapToDeleteResponse:(DetailReputationReview *)review atView:(UIView *)view {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Batal"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Hapus", nil];
    _selectedReview = review;
    actionSheet.tag = 300;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
        [actionSheet showFromRect:view.frame inView:view.superview animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:self.view];
    }
}

- (void)didTapAttachedImages:(DetailReputationReview *)review withIndex:(NSInteger)index {
    NSMutableArray *descriptionArray = [NSMutableArray new];
    NSMutableArray<UIImageView*> *imageArray = [NSMutableArray new];
    
    _count = 0;
    
    for (ReviewImageAttachment *imageAttachment in review.review_image_attachment) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageAttachment.uri_large]];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        UIImageView *imageView = [UIImageView new];
        [imageView setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"attached_image_placeholder.png"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      _count++;
                                      [imageView setImage:image];
                                      [descriptionArray addObject:imageAttachment.desc?:@""];
                                      [imageArray addObject:imageView];
                                      if (_count == review.review_image_attachment.count) {
                                          [_navigator navigateToShowImageFromViewController:self withImageDictionaries:imageArray imageDescriptions:descriptionArray indexImage:index];
                                      }
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      
                                      
                                  }];
        
    }
}

- (void)didTapRevieweeReputation:(id)sender onReview:(DetailReputationReview *)review atView:(UIView *)view {
    NSString *strText = [NSString stringWithFormat:@"%@ %@", review.product_owner.shop_reputation_score, CStringPoin];
    [self initPopUp:strText atView:view withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
}


#pragma mark - Header Delegate
- (void)didTapRevieweeNameWithID:(NSString *)revieweeID {
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        if ([_detailMyInboxReputation.role isEqualToString:@"2"]) {
            [_navigator navigateToProfileFromViewController:self withUserID:revieweeID];
        } else {
            [_navigator navigateToShopFromViewController:self withShopID:revieweeID];
        }
    }
}

- (void)didTapRevieweeReputation:(id)sender role:(NSString *)role atView:(UIView *)view {
    if ([role isEqualToString:@"1"]) {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp
                                 andPadding:paddingRightLeftContent
                       withReputationNetral:_detailMyInboxReputation.user_reputation.neutral
                               withRepSmile:_detailMyInboxReputation.user_reputation.positive
                                 withRepSad:_detailMyInboxReputation.user_reputation.negative
                               withDelegate:self];
        
        //Init pop up
        _cmPopTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
        _cmPopTipView.delegate = self;
        _cmPopTipView.backgroundColor = [UIColor whiteColor];
        _cmPopTipView.animation = CMPopTipAnimationSlide;
        _cmPopTipView.dismissTapAnywhere = YES;
        _cmPopTipView.leftPopUp = YES;
        
        [_cmPopTipView presentPointingAtView:view
                                      inView:view.superview
                                    animated:YES];
    } else {
        NSString *strText = [NSString stringWithFormat:@"%@ %@", _detailMyInboxReputation.reputation_score, CStringPoin];
        [self initPopUp:strText atView:view withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
    }
}

- (void)didTapToGiveResponse:(DetailReputationReview *)review {
    GiveReviewResponseViewController *vc = [GiveReviewResponseViewController new];
    vc.inbox = _detailMyInboxReputation;
    vc.review = review;
    vc.imageCache = _imageCache;
    
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
    
    if ([_selectedInbox.role isEqualToString:@"2"]) {
        if ([_selectedInbox.buyer_score isEqualToString:@"1"]) {
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
                                                  cancelButtonTitle:@"Tidak"
                                                  otherButtonTitles:@"Ya", nil];
            _score = @"-1";
            alert.tag = 10;
            [alert show];
        }
    } else {
        if ([_selectedInbox.seller_score isEqualToString:@"1"]) {
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
                                                  cancelButtonTitle:@"Tidak"
                                                  otherButtonTitles:@"Ya", nil];
            _score = @"-1";
            alert.tag = 10;
            [alert show];
        }
    }
}

- (void)didTapNeutralSmiley:(DetailMyInboxReputation*)inbox {
    _selectedInbox = inbox;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Apakah Anda yakin memberi nilai Netral?"
                                                   delegate:self
                                          cancelButtonTitle:@"Tidak"
                                          otherButtonTitles:@"Ya", nil];
    _score = @"1";
    alert.tag = 20;
    [alert show];
}

- (void)didTapSatisfiedSmiley:(DetailMyInboxReputation*)inbox {
    _selectedInbox = inbox;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Apakah Anda yakin memberi nilai Puas?"
                                                   delegate:self
                                          cancelButtonTitle:@"Tidak"
                                          otherButtonTitles:@"Ya", nil];
    _score = @"2";
    alert.tag = 30;
    [alert show];
}

- (void)reportReviewWithMessage:(NSString *)textMessage {
    [_reviewRequest requestReportReviewWithReviewID:_selectedReview.review_id
                                             shopID:_selectedReview.shop_id
                                        textMessage:textMessage
                                          onSuccess:^(GeneralAction *action) {
                                              [self.navigationController popViewControllerAnimated:YES];

                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (action.message_error) {
                                                      NSArray *array = action.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                                                      StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                                                      [alert show];
                                                  } else {
                                                      if ([action.data.is_success isEqualToString:@"1"]) {
                                                          NSArray *array = action.message_status?:[[NSArray alloc] initWithObjects:@"Laporan Kamu telah sukses terkirim", nil];
                                                          StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:array delegate:self];
                                                          [stickyAlertView show];
                                                      } else {
                                                          StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Gagal kirim report"] delegate:self];
                                                          [stickyAlertView show];
                                                      }
                                                  }
                                              });
                                          }
                                          onFailure:^(NSError *error) {
                                              
                                              
                                          }];
}

#pragma mark - Lucky Deal Delegate
- (void)showPopUpLuckyDeal:(LuckyDealWord *)words {
    [_navigator popUpLuckyDeal:words];
}

#pragma mark - Loading View Delegate
- (void)pressRetryButton {
    [_reviewRequest requestGetListReputationReviewWithReputationID:_detailMyInboxReputation.reputation_id
                                                 reputationInboxID:_detailMyInboxReputation.reputation_inbox_id
                                                 getDataFromMaster:_getDataFromMasterInServer
                                                              role:_detailMyInboxReputation.role
                                                          autoRead:_autoRead
                                                         onSuccess:^(MyReviewReputationResult *result) {
                                                             [_loadingView removeFromSuperview];
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
                                                             [_refreshControl endRefreshing];
                                                             [_reviewList removeAllObjects];
                                                             [_dataManager removeAllReviews];
                                                             [self getLoadingView];
                                                         }];
}

#pragma mark - Pop Tip View Delegate
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    [_cmPopTipView dismissAnimated:YES];
    _cmPopTipView = nil;
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

- (void)initPopUp:(NSString *)strText atView:(UIView*)view withRangeDesc:(NSRange)range
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
    
    
    [_cmPopTipView presentPointingAtView:view
                                  inView:view.superview
                                animated:YES];
}

- (void)refreshData {
    [_reviewRequest requestGetListReputationReviewWithReputationID:_detailMyInboxReputation.reputation_id
                                                 reputationInboxID:_detailMyInboxReputation.reputation_inbox_id
                                                 getDataFromMaster:_getDataFromMasterInServer
                                                              role:_detailMyInboxReputation.role
                                                          autoRead:_autoRead
                                                         onSuccess:^(MyReviewReputationResult *result) {
                                                             [_loadingView removeFromSuperview];
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
                                                             [_refreshControl endRefreshing];
                                                             [_reviewList removeAllObjects];
                                                             [_dataManager removeAllReviews];
                                                             [self getLoadingView];
                                                         }];
    
    [_header removeFromSuperview];
    
    _header = [[MyReviewDetailHeader alloc] initWithInboxDetail:_selectedInbox?:_detailMyInboxReputation
                                                     imageCache:_imageCache
                                                       delegate:self
                                                 smileyDelegate:self];
    
    [self setHeaderPosition];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];
    [_header addSubview:_refreshControl];
}

- (void)refreshDataWithNotification:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *getDataFromMaster = [userInfo objectForKey:@"n"]?:_getDataFromMasterInServer;
    
    [_reviewRequest requestGetListReputationReviewWithReputationID:_detailMyInboxReputation.reputation_id
                                                 reputationInboxID:_detailMyInboxReputation.reputation_inbox_id
                                                 getDataFromMaster:getDataFromMaster
                                                              role:_detailMyInboxReputation.role
                                                          autoRead:_autoRead
                                                         onSuccess:^(MyReviewReputationResult *result) {
                                                             [_loadingView removeFromSuperview];
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
                                                             [_refreshControl endRefreshing];
                                                             [_reviewList removeAllObjects];
                                                             [_dataManager removeAllReviews];
                                                             [self getLoadingView];
                                                         }];
    
    [_header removeFromSuperview];
    
    _header = [[MyReviewDetailHeader alloc] initWithInboxDetail:_selectedInbox?:_detailMyInboxReputation
                                                     imageCache:_imageCache
                                                       delegate:self
                                                 smileyDelegate:self];
    
    [self setHeaderPosition];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self
                        action:@selector(refreshData)
              forControlEvents:UIControlEventValueChanged];
    [_header addSubview:_refreshControl];
}

- (void)getLoadingView {
    if (_loadingView == nil) {
        _loadingView = [LoadingView new];
        _loadingView.delegate = self;
    }
    
    CGRect frame = _loadingView.frame;
    frame.size.width = self.view.bounds.size.width;
    _loadingView.frame = frame;
    [_loadingView sizeToFit];
    
    frame = _loadingView.frame;
    frame.origin.y = 0;
    _loadingView.frame = frame;
    
    [_collectionView addSubview:_loadingView];
}

- (void)doRequestGetListReputationReviewWithGetDataFromMaster:(NSString*)getDataFromMaster {
    
}

@end
