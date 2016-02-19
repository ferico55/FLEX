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
#import "NavigateViewController.h"
#import <QuartzCore/QuartzCore.h>

#define GIVE_REVIEW_CELL_IDENTIFIER @"GiveReviewCellIdentifier"
#define REVIEW_DETAIL_CELL_IDENTIFIER @"ReviewDetailCellIdentifier"
#define SKIPPED_REVIEW_CELL_IDENTIFIER @"SkippedReviewCellIdentifier"

@interface MyReviewDetailViewController ()
<
    UICollectionViewDelegateFlowLayout,
    MyReviewDetailRequestDelegate,
    DetailReputationReviewComponentDelegate
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
    
    BOOL _page;
    BOOL _isRefreshing;
    BOOL _isUserCanGiveReview;
    BOOL _isUserHasGiveReview;
    BOOL _isSellerHasGiveComment;
    BOOL _isUserSkipReview;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureGTM];
    
    _dataManager = [[MyReviewDetailDataManager alloc] initWithCollectionView:_collectionView
                                                                        role:_detailMyInboxReputation.role
                                                                    delegate:self];
    _collectionView.delegate = self;
    
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
    
    //    _reviewDetailTable.tableHeaderView = _tableHeaderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods
- (void)setHeaderView {
    // Set Reviewee Image
    [_userImageView setImageWithURL:[NSURL URLWithString:_detailMyInboxReputation.reviewee_picture]
                   placeholderImage:[UIImage imageNamed:@"icon_profile_picture.png"]];
    [_userImageView setCornerRadius:_userImageView.frame.size.width/2];
    [_userImageView setClipsToBounds:YES];
    
    
    // Set Reviewee Name
    [_revieweeNameViewLabel setText:_detailMyInboxReputation.reviewee_name];
    [_revieweeNameViewLabel setText:[UIColor colorWithRed:18/255.0f green:199/255.0f blue:0 alpha:1.0f]
                           withFont:[UIFont fontWithName:@"GothamMedium" size:14.0f]];
    [_revieweeNameViewLabel setLabelBackground:[_detailMyInboxReputation.reviewee_role isEqualToString:@"1"]?@"Pembeli":@"Penjual"];
    _revieweeNameViewLabel.center = CGPointMake(CGRectGetMidX(_userInfoView.bounds), _revieweeNameViewLabel.center.y);
    
    // Set Reviewee Reputation Score
    // 1: Reviewee is Buyer
    // 2: Reviewee is Seller
    if([_detailMyInboxReputation.role isEqualToString:@"1"]) {
        [SmileyAndMedal generateMedalWithLevel:_detailMyInboxReputation.shop_badge_level.level
                                       withSet:_detailMyInboxReputation.shop_badge_level.set
                                     withImage:_reputationScoreButton
                                       isLarge:NO];
        [_reputationScoreButton setTitle:@""
                                forState:UIControlStateNormal];
    } else {
        [_reputationScoreButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small"
                                                                                                          ofType:@"png"]]
                                forState:UIControlStateNormal];
        [_reputationScoreButton setTitle:[NSString stringWithFormat:@"%@%%", (_detailMyInboxReputation.user_reputation==nil? @"0":_detailMyInboxReputation.user_reputation.positive_percentage)]
                                forState:UIControlStateNormal];
    }
    
    // Set Label for Reviewee
    if ([_detailMyInboxReputation.role isEqualToString:@"1"]) {
        _theirScoreLabel.text = @"Nilai untuk Penjual";
    } else {
        _theirScoreLabel.text = @"Nilai untuk Pembeli";
    }
    
    
    NSDictionary<NSString*, NSString*>* theirScoreImageNameByType = @{
                                                                      @"smiley_neutral":@"icon_netral.png",
                                                                      @"smiley_bad":@"icon_sad.png",
                                                                      @"smiley_good":@"icon_smile.png",
                                                                      @"smiley_none":[_detailMyInboxReputation.reputation_progress isEqualToString:@"2"]?@"icon_review_locked.png":@"icon_question_mark_green30.png",
                                                                      @"grey_question_mark":@"icon_question_mark30.png",
                                                                      @"blue_question_mark":@"icon_checklist_grey.png"
                                                                      };
    
    NSDictionary<NSString*, NSString*>* myScoreImageNameByType = @{
                                                                   @"smiley_neutral":@"icon_netral.png",
                                                                   @"smiley_bad":@"icon_sad.png",
                                                                   @"smiley_good":@"icon_smile.png",
                                                                   @"smiley_none":[_detailMyInboxReputation.reputation_progress isEqualToString:@"2"]?@"icon_review_locked.png":@"icon_question_mark30.png",
                                                                   @"grey_question_mark":@"icon_question_mark30.png",
                                                                   @"blue_question_mark":@"icon_checklist_grey.png"
                                                                   };
    
    UIImage *theirScore = [UIImage imageNamed:[theirScoreImageNameByType objectForKey:_detailMyInboxReputation.their_score_image]];
    UIImage *myScore = [UIImage imageNamed:[myScoreImageNameByType objectForKey:_detailMyInboxReputation.my_score_image]];
    [_theirScoreButton setImage:theirScore forState:UIControlStateNormal];
    [_myScoreButton setImage:myScore forState:UIControlStateNormal];
    
    
    if (![_detailMyInboxReputation.score_edit_time_fmt isEqualToString:@"0"]) {
        _isMyScoreEditedLabel.hidden = NO;
        _isMyScoreEditedLabel.text = @"(edited)";
    } else {
        _isMyScoreEditedLabel.hidden = YES;
    }
}

#pragma mark - Action


#pragma mark - Table View Delegate and Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyReviewDetailTableViewCell *cell = nil;
    DetailReputationReview *currentReview = _reviewList[indexPath.row];
    
    if ([currentReview.review_message isEqualToString:@"0"] || currentReview.review_message == nil) {
        if ([_detailMyInboxReputation.role isEqualToString:@"1"]) {
            cell = (MyReviewDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:GIVE_REVIEW_CELL_IDENTIFIER];
            
            if (cell == nil) {
                cell = [MyReviewDetailTableViewCell newCellWithIdentifier:GIVE_REVIEW_CELL_IDENTIFIER];
                cell.delegate = self;
            }
            
            [cell.giveReviewButton.layer setBorderColor:[[UIColor colorWithRed:18.0/255
                                                                         green:199.0/255
                                                                          blue:0
                                                                         alpha:1] CGColor]];
            [cell.giveReviewButton.layer setBorderWidth:2.0];
            [cell.giveReviewButton.layer setCornerRadius:5.0];
            [cell.giveReviewButton setClipsToBounds:YES];
            
            if ([currentReview.review_is_skipable isEqualToString:@"1"]) {
                [cell.skipReviewButton setHidden:NO];
            } else {
                [cell.skipReviewButton setHidden:YES];
            }
        } else if ([_detailMyInboxReputation.role isEqualToString:@"2"]) {
            cell = (MyReviewDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NO_REVIEW_GIVEN_CELL_IDENTIFIER];
            
            if (cell == nil) {
                cell = [MyReviewDetailTableViewCell newCellWithIdentifier:NO_REVIEW_GIVEN_CELL_IDENTIFIER];
                cell.delegate = self;
            }
        }
        
    } else if (![currentReview.review_message isEqualToString:@"0"] || currentReview.review_message != nil) {
        cell = (MyReviewDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:REVIEW_DETAIL_CELL_IDENTIFIER];
        
        if (cell == nil) {
            cell = [MyReviewDetailTableViewCell newCellWithIdentifier:REVIEW_DETAIL_CELL_IDENTIFIER];
            cell.delegate = self;
        }
        
        cell.reviewMessageLabel.text = currentReview.review_message;
        [cell.reviewMessageLabel sizeToFit];
        
        for (int ii = 0; ii < cell.qualityStarsImagesArray.count; ii++) {
            UIImageView *temp = cell.qualityStarsImagesArray[ii];
            temp.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:((ii < [currentReview.product_rating_point intValue])?@"icon_star_active":@"icon_star") ofType:@"png"]];
        }
        
        for (int ii = 0; ii < cell.accuracyStarsImagesArray.count; ii++) {
            UIImageView *temp = cell.accuracyStarsImagesArray[ii];
            temp.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:((ii < [currentReview.product_accuracy_point intValue])?@"icon_star_active":@"icon_star") ofType:@"png"]];
        }
        
        if ([currentReview.review_is_allow_edit isEqualToString:@"1"]) {
            [cell.editReviewButton setHidden:NO];
        } else {
            [cell.editReviewButton setHidden:YES];
        }
        
        if (![currentReview.review_response.response_message isEqualToString:@"0"]) {
            cell.reviewCommentView.hidden = NO;
            [cell.shopImage setImageWithURL:[NSURL URLWithString:currentReview.product_owner.shop_img]
                           placeholderImage:[UIImage imageNamed:@"icon_shop_grey.png"]];
            [cell.shopImage setCornerRadius:cell.shopImage.frame.size.width/2];
            [cell.shopImage setClipsToBounds:YES];
            
            cell.shopName.text = currentReview.product_owner.shop_name;
            [cell setMedalWithLevel:currentReview.shop_badge_level.level
                                set:currentReview.shop_badge_level.set];
            cell.theirCommentLabel.text = currentReview.review_response.response_message;
            [cell.theirCommentLabel sizeToFit];
            
            cell.sellersCommentTimestampLabel.text = currentReview.review_response.response_create_time;
        } else {
            cell.reviewCommentView.hidden = YES;
        }
        
    } else if ([currentReview.review_is_skipped isEqualToString:@"1"]) {
        cell = (MyReviewDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:SKIPPED_REVIEW_CELL_IDENTIFIER];
        
        if (cell == nil) {
            cell = [MyReviewDetailTableViewCell newCellWithIdentifier:SKIPPED_REVIEW_CELL_IDENTIFIER];
            cell.delegate = self;
        }
    }
    
    [cell.productImage setImageWithURL:[NSURL URLWithString:currentReview.product_image]
                      placeholderImage:[UIImage imageNamed:@"image_toped_loading_grey.png"]];
    cell.productNameLabel.text = currentReview.product_name;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailReputationReview *currentReview = _reviewList[indexPath.row];
    MyReviewDetailTableViewCell *cell;
    int height = 0;
    
    if ([currentReview.review_message isEqualToString:@"0"] || currentReview.review_message == nil) {
        if ([_detailMyInboxReputation.role isEqualToString:@"1"]) {
            cell = [MyReviewDetailTableViewCell newCellWithIdentifier:GIVE_REVIEW_CELL_IDENTIFIER];
            height = cell.frame.size.height;
        } else if ([_detailMyInboxReputation.role isEqualToString:@"2"]) {
            cell = [MyReviewDetailTableViewCell newCellWithIdentifier:NO_REVIEW_GIVEN_CELL_IDENTIFIER];
            height = cell.frame.size.height;
        }
        
    } else if (![currentReview.review_message isEqualToString:@"0"] || currentReview.review_message != nil) {
        cell = [MyReviewDetailTableViewCell newCellWithIdentifier:REVIEW_DETAIL_CELL_IDENTIFIER];
        height = cell.frame.size.height;
        if (![currentReview.review_response.response_message isEqualToString:@"0"]) {
            height = height + cell.reviewCommentView.frame.size.height;
        }
    } else if ([currentReview.review_is_skipped isEqualToString:@"1"]) {
        cell = [MyReviewDetailTableViewCell newCellWithIdentifier:SKIPPED_REVIEW_CELL_IDENTIFIER];
        height = cell.frame.size.height;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _reviewList.count;
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

#pragma mark - DetailReputationReview Delegate
- (void)didTapHeaderWithReview:(DetailReputationReview *)review {
    [_navigator navigateToProductFromViewController:self
                                           withName:review.product_name
                                          withPrice:nil
                                             withId:review.product_id
                                       withImageurl:review.product_image
                                       withShopName:review.shop_name];
}

@end
