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
#import <QuartzCore/QuartzCore.h>

#define GIVE_REVIEW_CELL_IDENTIFIER @"GiveReviewCellIdentifier"
#define REVIEW_DETAIL_CELL_IDENTIFIER @"ReviewDetailCellIdentifier"
#define SKIPPED_REVIEW_CELL_IDENTIFIER @"SkippedReviewCellIdentifier"

@interface MyReviewDetailViewController () <UITableViewDataSource, UITableViewDelegate, MyReviewDetailRequestDelegate> {
    TAGContainer *_gtmContainer;
    MyReviewDetailRequest *_myReviewDetailRequest;
    DetailReputationReview *_detailReputationReview;
    
    NSMutableArray *_reviewList;
    
    NSString *_baseURL, *_baseActionURL;
    NSString *_postURL, *_postActionURL;
    NavigateViewController *_navigator;
    
    UIRefreshControl *_refreshControl;
    
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
    
    
    
    _reviewDetailTable.tableHeaderView = _tableHeaderView;
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
    
    // Set Smiley for Reviewee (Right Side)
    if ([_detailMyInboxReputation.their_score_image isEqualToString:@"smiley_neutral"]) {
        [_theirScoreButton setImage:[UIImage imageNamed:@"icon_netral.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.their_score_image isEqualToString:@"smiley_bad"]) {
        [_theirScoreButton setImage:[UIImage imageNamed:@"icon_sad.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.their_score_image isEqualToString:@"smiley_good"]) {
        [_theirScoreButton setImage:[UIImage imageNamed:@"icon_smile.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.their_score_image isEqualToString:@"smiley_none"]) {
        [_theirScoreButton setImage:[UIImage imageNamed:([_detailMyInboxReputation.reputation_progress isEqualToString:@"2"])?@"icon_review_locked.png":@"icon_question_mark_green30.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.their_score_image isEqualToString:@"grey_question_mark"]) {
        [_theirScoreButton setImage:[UIImage imageNamed:@"icon_question_mark30.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.their_score_image isEqualToString:@"blue_question_mark"]) {
        [_theirScoreButton setImage:[UIImage imageNamed:@"icon_checklist_grey.png"] forState:UIControlStateNormal];
    }
    
    if (![_detailMyInboxReputation.score_edit_time_fmt isEqualToString:@"0"]) {
        _isMyScoreEditedLabel.hidden = NO;
        _isMyScoreEditedLabel.text = @"(edited)";
    } else {
        _isMyScoreEditedLabel.hidden = YES;
    }
    
    // Set Smiley for Reviewer (Left Side)
    if ([_detailMyInboxReputation.my_score_image isEqualToString:@"smiley_neutral"]) {
        [_myScoreButton setImage:[UIImage imageNamed:@"icon_netral.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.my_score_image isEqualToString:@"smiley_bad"]) {
        [_myScoreButton setImage:[UIImage imageNamed:@"icon_sad.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.my_score_image isEqualToString:@"smiley_good"]) {
        [_myScoreButton setImage:[UIImage imageNamed:@"icon_smile.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.my_score_image isEqualToString:@"smiley_none"]) {
        [_myScoreButton setImage:[UIImage imageNamed:([_detailMyInboxReputation.reputation_progress isEqualToString:@"2"])?@"icon_review_locked.png":@"icon_question_mark30.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.my_score_image isEqualToString:@"grey_question_mark"]) {
        [_myScoreButton setImage:[UIImage imageNamed:@"icon_question_mark30.png"] forState:UIControlStateNormal];
    } else if ([_detailMyInboxReputation.my_score_image isEqualToString:@"blue_question_mark"]) {
        [_myScoreButton setImage:[UIImage imageNamed:@"icon_checklist_grey.png"] forState:UIControlStateNormal];
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
        
        cell.reviewMessageTextView.text = currentReview.review_message;
        
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
            cell.shopName.text = currentReview.product_owner.shop_name;
            [cell setMedalWithLevel:currentReview.shop_badge_level.level
                                set:currentReview.shop_badge_level.set];
            cell.sellersCommentTextView.text = currentReview.review_response.response_message;
            cell.sellersCommentTimestampLabel.text = currentReview.review_response.response_create_time;
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
            cell = (MyReviewDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:GIVE_REVIEW_CELL_IDENTIFIER];
            
        } else if ([_detailMyInboxReputation.role isEqualToString:@"2"]) {
            cell = (MyReviewDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NO_REVIEW_GIVEN_CELL_IDENTIFIER];
            
        }
        
    } else if (![currentReview.review_message isEqualToString:@"0"] || currentReview.review_message != nil) {
        cell = (MyReviewDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:REVIEW_DETAIL_CELL_IDENTIFIER];
        
        if (![currentReview.review_response.response_message isEqualToString:@"0"]) {
            
        }
        
    } else if ([currentReview.review_is_skipped isEqualToString:@"1"]) {
        cell = (MyReviewDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:SKIPPED_REVIEW_CELL_IDENTIFIER];
        
    }
    return 200;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _reviewList.count;
}

#pragma mark - My Review Detail Request Delegate
- (void)didReceiveReviewListing:(MyReviewReputationResult *)myReviews {
    
    [_reviewList removeAllObjects];
    
    if (_page == 0) {
        _isRefreshing = NO;
        _reviewList = [myReviews.list mutableCopy];
    } else {
        [_reviewList addObjectsFromArray:myReviews.list];
    }
    
    [self setHeaderView];
    
    [_reviewDetailTable reloadData];
}

- (void)didSkipReview:(SkipReviewResult *)skippedReview {
    _detailReputationReview = nil;
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil lewati ulasan"]
                                                                     delegate:self];
    [alert show];
    
    [_reviewDetailTable reloadData];
    
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

@end
