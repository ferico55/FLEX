//
//  ProductReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
@class Paging;
#import "AdvanceReview.h"
#import "CMPopTipView.h"
#import "detail.h"
#import "DetailReputationReview.h"
#import "LoadingView.h"
#import "LikeDislike.h"
#import "LikeDislikePost.h"
#import "LikeDislikePostResult.h"
#import "NoResultView.h"
#import "ProductReputationCell.h"
#import "ProductOwner.h"
#import "ProductDetailReputationViewController.h"
#import "ProductReputationViewController.h"
#import "ReportViewController.h"
#import "RatingList.h"
#import "ReviewResponse.h"
#import "Review.h"
#import "ShopReputation.h"
#import "ShopBadgeLevel.h"
#import "SmileyAndMedal.h"
#import "String_Reputation.h"
#import "TotalLikeDislikePost.h"
#import "TotalLikeDislike.h"
#import "TokopediaNetworkManager.h"
#import "ProductReputationSimpleCell.h"
#import "HelpfulReviewRequest.h"
#import "ReviewRequest.h"
#import "Tokopedia-Swift.h"
#define CCellIdentifier @"cell"
#define CTagGetProductReview 1

static NSInteger userViewHeight = 70;

@interface ProductReputationViewController ()<TTTAttributedLabelDelegate, UIActionSheetDelegate, LoadingViewDelegate, ReportViewControllerDelegate, HelpfulReviewRequestDelegate, ProductReputationSimpleDelegate>
@end

@implementation ProductReputationViewController
{
    
    NSMutableParagraphStyle *style;
    CMPopTipView *popTipView;
    UIRefreshControl *refreshControl;
    LoadingView *loadingView;
    NoResultView *noResultView;
    
    int page, filterStar;
    NSString *strUri;
    NSMutableArray *arrList;
    NSMutableArray<DetailReputationReview*> *helpfulReviews;
    NSDictionary *auth;
    TokopediaNetworkManager *tokopediaNetworkManager;
    
    HelpfulReviewRequest *helpfulReviewRequest;
    ReviewRequest *reviewRequest;
    ReviewResult *reviewResult;
    BOOL isShowingMore, animationHasShown;
    UserAuthentificationManager *userManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    page = 0;
    
    [self initTable];
    tableContent.backgroundColor = [UIColor clearColor];
    tableContent.estimatedRowHeight = 282;
    tableContent.rowHeight = UITableViewAutomaticDimension;
    
    userManager = [UserAuthentificationManager new];
    auth = [userManager getUserLoginData];
    [self setLoadingView:YES];
    helpfulReviewRequest = [HelpfulReviewRequest new];
    helpfulReviewRequest.delegate = self;
    [helpfulReviewRequest requestHelpfulReview:_strProductID];
    
    //Add gesture to view star
    viewStarOne.tag = 1;
    viewStarTwo.tag = 2;
    viewStarThree.tag = 3;
    viewStarFour.tag = 4;
    viewStarFive.tag = 5;
    
    helpfulReviews = [[NSMutableArray alloc]init];
    isShowingMore = NO;
    
    [viewStarOne addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureViewStar:)]];
    [viewStarTwo addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureViewStar:)]];
    [viewStarThree addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureViewStar:)]];
    [viewStarFour addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureViewStar:)]];
    [viewStarFive addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureViewStar:)]];
    
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0") && !UIAccessibilityIsReduceTransparencyEnabled()) {
        _filterView.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = _filterView.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_filterView addSubview:blurEffectView];
    } else {
        [_filterView setBackgroundColor:[UIColor whiteColor]];
        [_filterView setAlpha:0.95];
    }
    
    UINib *cellNib = [UINib nibWithNibName:@"ProductReputationTableViewCell" bundle:nil];
    [tableContent registerNib:cellNib forCellReuseIdentifier:@"ProductReputationTableViewCellIdentifier"];
    
    reviewRequest = [ReviewRequest new];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    animationHasShown = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unloadRequesting];
}

#pragma mark - Method View
- (void)initNavigation {
    self.title = @"Ulasan";
}
- (void)setRateStar:(int)tag withAnimate:(BOOL)isAnimate {
    int nRate1, nRate2, nRate3, nRate4, nRate5;
    float totalCount = 0;
    nRate1 = nRate2 = nRate3 = nRate4 = nRate5 = 0;
    
    
    for(RatingList *tempRatingList in reviewResult.advance_review.rating_list) {
        switch ([tempRatingList.rating_rating_star_point intValue]) {
            case 5:
            {
                nRate5 = [[(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
                totalCount += nRate5;
            }
                break;
            case 4:
            {
                nRate4 = [[(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
                totalCount += nRate4;
            }
                break;
            case 3:
            {
                nRate3 = [[(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
                totalCount += nRate3;
            }
                break;
            case 2:
            {
                nRate2 = [[(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
                totalCount += nRate2;
            }
                break;
            case 1:
            {
                nRate1 = [[(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
                totalCount += nRate1;
            }
                break;
        }
    }
    
    //Set Progress
    if(totalCount == 0) {
        [progress1 setProgress:0 animated:isAnimate];
        [progress2 setProgress:0 animated:isAnimate];
        [progress3 setProgress:0 animated:isAnimate];
        [progress4 setProgress:0 animated:isAnimate];
        [progress5 setProgress:0 animated:isAnimate];
    }
    else {
        [progress1 setProgress:nRate1/totalCount animated:isAnimate];
        [progress2 setProgress:nRate2/totalCount animated:isAnimate];
        [progress3 setProgress:nRate3/totalCount animated:isAnimate];
        [progress4 setProgress:nRate4/totalCount animated:isAnimate];
        [progress5 setProgress:nRate5/totalCount animated:isAnimate];
    }
    
    lblTotal1Rate.text = [NSString stringWithFormat:@"(%d)", nRate1];
    lblTotal2Rate.text = [NSString stringWithFormat:@"(%d)", nRate2];
    lblTotal3Rate.text = [NSString stringWithFormat:@"(%d)", nRate3];
    lblTotal4Rate.text = [NSString stringWithFormat:@"(%d)", nRate4];
    lblTotal5Rate.text = [NSString stringWithFormat:@"(%d)", nRate5];
    
    
    
    //Calculate widht total rate
    float width1 = [lblTotal1Rate sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width2 = [lblTotal2Rate sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width3 = [lblTotal3Rate sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width4 = [lblTotal4Rate sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width5 = [lblTotal5Rate sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    
    width1 = width1>width2? width1: width2;
    width1 = width1>width3? width1: width3;
    width1 = width1>width4? width1: width4;
    width1 = width1>width5? width1: width5;
    constWidthLblRate1.constant = constWidthLblRate2.constant = constWidthLblRate3.constant = constWidthLblRate4.constant = constWidthLblRate5.constant = width1;
    
    NSString *productRating = (tag == 0) ? reviewResult.advance_review.product_rating_point : reviewResult.advance_review.product_rate_accuracy_point;
    
    float productRatingValue = [productRating floatValue];
    
    //Set header rate
    for(int i=0;i<arrImageHeaderRating.count;i++) {
        NSString *imageName = @"";
        
        if (i < roundf(productRatingValue)) {
            imageName = @"icon_star_active";
        } else {
            imageName = @"icon_star";
        }
        
        UIImageView *tempImageView = arrImageHeaderRating[i];
        tempImageView.image = [UIImage imageNamed:imageName];
    }
    
    lblTotalHeaderRating.text = [NSString stringWithFormat:@"%.1f", productRatingValue];
    
    NSString *strReview = @"Review";
    lblDescTotalHeaderRating.text = [NSString stringWithFormat:@"%d Review", [reviewResult.advance_review.product_review intValue]];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:lblDescTotalHeaderRating.font.pointSize];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, lblDescTotalHeaderRating.textColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:lblDescTotalHeaderRating.font, NSFontAttributeName, lblDescTotalHeaderRating.textColor, NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:lblDescTotalHeaderRating.text attributes:attrs];
    [attributedText setAttributes:subAttrs range:NSMakeRange(lblDescTotalHeaderRating.text.length-strReview.length, strReview.length)];
    [lblDescTotalHeaderRating setAttributedText:attributedText];
}
- (void)initTable {
    //Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [tableContent addSubview:refreshControl];
    [tableContent setContentInset:UIEdgeInsetsMake(0, 0, 40, 0)];
    tableContent.tableHeaderView = viewHeader;
}

- (void)doRequestGetProductReview {
    NSNumber *monthRange = @(0);
    NSNumber *shopQuality = @(0);
    NSNumber *shopAccuracy = @(0);
    
    if ((int)segmentedControl.selectedSegmentIndex == 0 && filterStar > 0) {
        shopQuality = @(filterStar);
    } else if (filterStar > 0) {
        shopAccuracy = @(filterStar);
    }
    
    [reviewRequest requestGetProductReviewWithProductID:_strProductID
                                             monthRange:monthRange
                                                   page:@(page)
                                           shopAccuracy:shopAccuracy
                                            shopQuality:shopQuality
                                             shopDomain:_strShopDomain?:@""
                                              onSuccess:^(ReviewResult *result) {
                                                  reviewResult = result;
                                                  NSMutableArray *contentsToAdd = [[NSMutableArray alloc] initWithArray:result.list];
                                                  
                                                  for (DetailReputationReview *review in contentsToAdd) {
                                                      review.product_id = _strProductID;
                                                      review.review_product_id = _strProductID;
                                                  }
                                                  
                                                  if (page == 0 && result.list != nil) {
                                                      arrList = [[NSMutableArray alloc] initWithArray:contentsToAdd];
                                                      
                                                      segmentedControl.enabled = YES;
                                                      [self setRateStar:(int)segmentedControl.selectedSegmentIndex withAnimate:YES];
                                                  } else if (result.list != nil) {
                                                      [arrList addObjectsFromArray:contentsToAdd];
                                                  }
                                                  
                                                  // Check next page
                                                  strUri = result.paging.uri_next;
                                                  page = [reviewRequest requestGetProductReviewNextPageFromUri:strUri];
                                                  
                                                  if (arrList != nil && arrList.count > 0) {
                                                      if (tableContent.delegate == nil) {
                                                          tableContent.delegate = self;
                                                          tableContent.dataSource = self;
                                                      }
                                                      
                                                      [tableContent reloadData];
                                                      [self setLoadingView:NO];
                                                  } else {
                                                      [self setLoadingView:NO];
                                                      
                                                      if (noResultView == nil) {
                                                          noResultView = [NoResultView new];
                                                      }
                                                      
                                                      tableContent.tableFooterView = noResultView.view;
                                                  }
                                                  
                                              }
                                              onFailure:^(NSError *error) {
                                                  
                                              }];
}

#pragma mark - UITableView Delegate and DataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header;
    if(filterStar == 0 && helpfulReviews.count >0 && section == 0){
        header = _helpfulReviewHeader;
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(filterStar == 0 && helpfulReviews.count >0 && section == 0){
        return 50;
    }
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (filterStar == 0 && helpfulReviews.count > 0) ? 2 : 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == arrList.count-1) {
        if(strUri!=nil && ![strUri isEqualToString:@"0"]) {
            [self setLoadingView:YES];
            [self doRequestGetProductReview];
        }
    }
    if(!animationHasShown && helpfulReviews.count > 0 && indexPath.section == 0 && ![self isLastCellInSectionZero:indexPath]){
        [self animate:cell];
        animationHasShown = YES;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (filterStar == 0 && helpfulReviews.count > 0) {
        if(indexPath.section == 1) {
            DetailReputationReview *reviewDetail = arrList[indexPath.row];
            ProductReputationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductReputationTableViewCellIdentifier"];
            cell.viewModel = reviewDetail.viewModel;
            return cell;
        } else {
            NSInteger limit = isShowingMore ? helpfulReviews.count : 1;
            if(indexPath.row < limit){
                DetailReputationReview *reviewDetail = helpfulReviews[indexPath.row];
                ProductReputationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductReputationTableViewCellIdentifier"];
                cell.viewModel = reviewDetail.viewModel;
                return cell;
            } else {
                return _helpfulReviewLoadMoreCell;
            }
        }
    } else {
        DetailReputationReview *reviewDetail = arrList[indexPath.row];
        ProductReputationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductReputationTableViewCellIdentifier"];
        cell.viewModel = reviewDetail.viewModel;
        return cell;
    }
}
- (void)mappingAttribute:(DetailReputationReview *)reputationReview {
    reputationReview.product_rating_point = reputationReview.review_rate_product;
    reputationReview.product_accuracy_point = reputationReview.review_rate_accuracy;
    reputationReview.review_full_name = reputationReview.review_user_name;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(filterStar == 0 && helpfulReviews.count > 0){
        if(indexPath.section == 1){
            DetailReputationReview *detailReputationReview = arrList[indexPath.row];
            [self redirectToProductDetailReputation:detailReputationReview withIndexPath:indexPath];
        }else{
            if([self isLastCellInSectionZero:indexPath]){
                [self showMoreTapped:nil];
            }else{
                DetailReputationReview *detailReputationReview = helpfulReviews[indexPath.row];
                [self redirectToProductDetailReputation:detailReputationReview withIndexPath:indexPath];
            }
        }
    }else{
        DetailReputationReview *detailReputationReview = arrList[indexPath.row];
        [self redirectToProductDetailReputation:detailReputationReview withIndexPath:indexPath];
        
    }
}
- (BOOL)isLastCellInSectionZero:(NSIndexPath *)indexPath{
    if (isShowingMore){
        return indexPath.row == helpfulReviews.count ? YES : NO;
    }else{
        return indexPath.row == 1 ? YES : NO;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(filterStar == 0 && helpfulReviews.count > 0){
        if(section==1){
            return arrList.count;
        }else{
            return isShowingMore ? helpfulReviews.count+1 : 2;
        }
    }else{
        return arrList.count;
    }
}

#pragma mark - TTTAttributeLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point{
    
}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    DetailReputationReview *detailReputationReview = arrList[label.tag];
    [self redirectToProductDetailReputation:detailReputationReview withIndexPath:[NSIndexPath indexPathForRow:label.tag inSection:0]];
}

#pragma mark - Action
- (void)refreshView:(UIRefreshControl*)refresh{
    [refresh endRefreshing];
    
    page = 0;
    strUri = nil;
    [arrList removeAllObjects];
    [tableContent reloadData];
    
    [self unloadRequesting];
    
    [self setLoadingView:YES];
    [self doRequestGetProductReview];
    
    NSNumber *monthRange = @(0);
    NSNumber *shopQuality = @(0);
    NSNumber *shopAccuracy = @(0);
    
    if ((int)segmentedControl.selectedSegmentIndex == 0 && filterStar > 0) {
        shopQuality = @(filterStar);
    } else if (filterStar > 0) {
        shopAccuracy = @(filterStar);
    }
    
    [reviewRequest requestGetProductReviewWithProductID:_strProductID
                                             monthRange:monthRange
                                                   page:@(page)
                                           shopAccuracy:shopAccuracy
                                            shopQuality:shopQuality
                                             shopDomain:_strShopDomain?:@""
                                              onSuccess:^(ReviewResult *result) {
                                                  
                                              }
                                              onFailure:^(NSError *error) {
                                                  
                                              }];
}
- (void)actionResetFilter:(id)sender {
    if(filterStar == 0) {
        return;
    }
    
    switch (filterStar) {
        case 1:
        {
            viewStarOne.layer.borderWidth = 0.0f;
        }
            break;
        case 2:
        {
            viewStarTwo.layer.borderWidth = 0.0f;
        }
            break;
        case 3:
        {
            viewStarThree.layer.borderWidth = 0.0f;
        }
            break;
        case 4:
        {
            viewStarFour.layer.borderWidth = 0.0f;
        }
            break;
        case 5:
        {
            viewStarFive.layer.borderWidth = 0.0f;
        }
            break;
    }
    
    page = 0;
    filterStar = 0;
    strUri = nil;
    [arrList removeAllObjects];
    [tableContent reloadData];
    
    if(helpfulReviews.count > 0){
        [_middleMargin setHidden:NO];
    }
    
    [self setLoadingView:YES];
    [self doRequestGetProductReview];
}

- (IBAction)actionSegmentedValueChange:(id)sender {
    page = 0;
    strUri = nil;
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self setLoadingView:YES];
    [self doRequestGetProductReview];
}
- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}
- (IBAction)showMoreTapped:(id)sender {
    if(isShowingMore){
        isShowingMore = NO;
        [_buttonShowMore setTitle:@"Tampilkan Semua" forState:UIControlStateNormal];
    }else{
        isShowingMore = YES;
        [_buttonShowMore setTitle:@"Sembunyikan" forState:UIControlStateNormal];
    }
    [tableContent reloadData];
}

#pragma mark - Method
- (void)unloadRequesting {
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager = nil;
}
- (void)reloadTable {
    [tableContent reloadData];
}
- (void)gestureViewStar:(UITapGestureRecognizer *)sender {
    switch (filterStar) {
        case 1:
        {
            viewStarOne.layer.borderWidth = 0.0f;
        }
            break;
        case 2:
        {
            viewStarTwo.layer.borderWidth = 0.0f;
        }
            break;
        case 3:
        {
            viewStarThree.layer.borderWidth = 0.0f;
        }
            break;
        case 4:
        {
            viewStarFour.layer.borderWidth = 0.0f;
        }
            break;
        case 5:
        {
            viewStarFive.layer.borderWidth = 0.0f;
        }
            break;
    }
    
    
    switch (sender.view.tag) {
        case 1:
        {
            filterStar = 1;
            viewStarOne.layer.borderColor = [[UIColor colorWithRed:255/255.0f green:152/255.0f blue:0 alpha:1.0f] CGColor];
            viewStarOne.layer.borderWidth = 1.0f;
            viewStarOne.layer.cornerRadius = 5.0f;
            viewStarOne.layer.masksToBounds = YES;
            
        }
            break;
        case 2:
        {
            filterStar = 2;
            viewStarTwo.layer.borderColor = [[UIColor colorWithRed:255/255.0f green:152/255.0f blue:0 alpha:1.0f] CGColor];
            viewStarTwo.layer.borderWidth = 1.0f;
            viewStarTwo.layer.cornerRadius = 5.0f;
            viewStarTwo.layer.masksToBounds = YES;
        }
            break;
        case 3:
        {
            filterStar = 3;
            viewStarThree.layer.borderColor = [[UIColor colorWithRed:255/255.0f green:152/255.0f blue:0 alpha:1.0f] CGColor];
            viewStarThree.layer.borderWidth = 1.0f;
            viewStarThree.layer.cornerRadius = 5.0f;
            viewStarThree.layer.masksToBounds = YES;
        }
            break;
        case 4:
        {
            filterStar = 4;
            viewStarFour.layer.borderColor = [[UIColor colorWithRed:255/255.0f green:152/255.0f blue:0 alpha:1.0f] CGColor];
            viewStarFour.layer.borderWidth = 1.0f;
            viewStarFour.layer.cornerRadius = 5.0f;
            viewStarFour.layer.masksToBounds = YES;
        }
            break;
        case 5:
        {
            filterStar = 5;
            viewStarFive.layer.borderColor = [[UIColor colorWithRed:255/255.0f green:152/255.0f blue:0 alpha:1.0f] CGColor];
            viewStarFive.layer.borderWidth = 1.0f;
            viewStarFive.layer.cornerRadius = 5.0f;
            viewStarFive.layer.masksToBounds = YES;
        }
            break;
    }
    
    [_middleMargin setHidden:YES];
    page = 0;
    strUri = nil;
    [arrList removeAllObjects];
    [tableContent reloadData];
    
    [self setLoadingView:YES];
    [self doRequestGetProductReview];
}
- (void)redirectToProductDetailReputation:(DetailReputationReview *)detailReputationReview withIndexPath:(NSIndexPath *)indexPath {
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    
    [self mappingAttribute:detailReputationReview];
    productDetailReputationViewController.isMyProduct = (auth!=nil && [[userManager getUserId] isEqualToString:detailReputationReview.product_owner.user_id]);
    productDetailReputationViewController.detailReputationReview = detailReputationReview;
    productDetailReputationViewController.indexPathSelected = indexPath;
    productDetailReputationViewController.strProductID = _strProductID;
    productDetailReputationViewController.shopBadgeLevel = detailReputationReview.product_owner.user_shop_reputation.reputation_badge_object;
    productDetailReputationViewController.isShowingProductView = NO;
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}
- (void)showLoginView {
    [AuthenticationService.shared ensureLoggedInFromViewController:self onSuccess:nil];
}

- (ProductReputationCell *)getCell:(UIView *)btn {
    UIView *tempView = btn.superview;
    while(tempView) {
        if([tempView isMemberOfClass:[ProductReputationCell class]]) {
            return (ProductReputationCell *)tempView;
        }
        
        tempView = tempView.superview;
    }
    
    return nil;
}
- (void)setLoadingView:(BOOL)isLoad {
    if(isLoad) {
        tableContent.tableFooterView = viewFooter;
        [footerActIndicator startAnimating];
    }
    else {
        [footerActIndicator stopAnimating];
        tableContent.tableFooterView = nil;
    }
}
- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagGetProductReview) {
        if(tokopediaNetworkManager == nil) {
            tokopediaNetworkManager = [TokopediaNetworkManager new];
            tokopediaNetworkManager.tagRequest = tag;
        }
        
        return tokopediaNetworkManager;
    }
    
    return nil;
}
- (void)dismissAllPopTipViews{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}
- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc {
    lblDesc.backgroundColor = [UIColor clearColor];
    lblDesc.textAlignment = NSTextAlignmentLeft;
    lblDesc.font = [UIFont smallTheme];
    lblDesc.textColor = [UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f];
    lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
    lblDesc.numberOfLines = 0;
}

#pragma mark - ProductReputation Delegate
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription {
    NSString *strLihatSelengkapnya = @"Lihat Selengkapnya";
    
    strDescription = [NSString convertHTML:strDescription];
    if(strDescription.length > 100) {
        strDescription = [NSString stringWithFormat:@"%@... %@", [strDescription substringToIndex:100], strLihatSelengkapnya];
        
        NSRange range = [strDescription rangeOfString:strLihatSelengkapnya];
        lblDesc.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        lblDesc.delegate = self;
        lblDesc.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor lightGrayColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        lblDesc.linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:78/255.0f green:134/255.0f blue:38/255.0f alpha:1.0f] range:NSMakeRange(strDescription.length-strLihatSelengkapnya.length, strLihatSelengkapnya.length)];
        [str addAttribute:NSFontAttributeName value:lblDesc.font range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:range];
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSFontAttributeName value:lblDesc.font range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        lblDesc.delegate = nil;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
    }
}

- (void)actionChat:(id)sender {}
- (void)actionMore:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CStringBatal destructiveButtonTitle:CStringLapor otherButtonTitles:nil, nil];
    actionSheet.tag = ((UIButton *) sender).tag;
    [actionSheet showInView:self.view];
}
- (void)animate:(UITableViewCell *)cell {
    [@[cell] enumerateObjectsUsingBlock:^(UITableViewCell *cell, NSUInteger idx, BOOL *stop) {
        [cell setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             [cell setFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
         }
                         completion:nil];
    }];
    
}
- (void)actionRate:(id)sender {
    DetailReputationReview *tempDetailReputationView = arrList[((UIView *) sender).tag];
    
    if(! (tempDetailReputationView.review_user_reputation.no_reputation!=nil && [tempDetailReputationView.review_user_reputation.no_reputation isEqualToString:@"1"])) {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:tempDetailReputationView.review_user_reputation.neutral withRepSmile:tempDetailReputationView.review_user_reputation.positive withRepSad:tempDetailReputationView.review_user_reputation.negative withDelegate:self];
        
        
        //Init pop up
        popTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
        popTipView.delegate = self;
        popTipView.backgroundColor = [UIColor whiteColor];
        popTipView.animation = CMPopTipAnimationSlide;
        popTipView.dismissTapAnywhere = YES;
        
        UIButton *button = (UIButton *)sender;
        [popTipView presentPointingAtView:button inView:self.view animated:YES];
    }
}

#pragma mark - PopUp
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView{
    [self dismissAllPopTipViews];
}


#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        if(auth) {
            ReportViewController *_reportController = [ReportViewController new];
            _reportController.delegate = self;
            
            DetailReputationReview *detailReputationReview = [arrList objectAtIndex:actionSheet.tag];
            _reportController.strProductID = _strProductID;
            _reportController.strReviewID = detailReputationReview.review_id;
            _reportController.strShopID = detailReputationReview.shop_id;
            [self.navigationController pushViewController:_reportController animated:YES];
        }
        else {
            [self showLoginView];
        }
    }
}

#pragma mark - LoadingView Delegate
- (void)pressRetryButton{
    [self setLoadingView:YES];
    [self doRequestGetProductReview];
}

#pragma mark - LoginView Delegate
- (UIViewController *)didReceiveViewController {
    return self;
}
- (NSDictionary *)getParameter {
    return nil;
}
- (NSString *)getPath {
    return @"action/review.pl";
}
- (void)userDidLogin:(NSNotification*)notification {
    UIViewController *viewController = [self.navigationController.viewControllers lastObject];
    if([viewController isMemberOfClass:[ProductDetailReputationViewController class]]) {
        [((ProductDetailReputationViewController *) viewController) userHasLogin];
    }
    
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    auth = [userManager getUserLoginData];
    [tableContent reloadData];
}

#pragma mark - HelpfulReviewRequestDelegate
- (void) didReceiveHelpfulReview:(NSArray*)helpfulReview{
    [self doRequestGetProductReview];
    
    [helpfulReviews removeAllObjects];
    [helpfulReviews addObjectsFromArray:helpfulReview];
    
    if(helpfulReviews.count == 0){
        [_middleMargin setHidden:YES];
    }
    
}
- (void)showMoreDidTappedInIndexPath:(NSIndexPath*)indexPath{
    if(filterStar == 0 && helpfulReviews.count > 0){
        if(indexPath.section == 1){
            DetailReputationReview *detailReputationReview = arrList[indexPath.row];
            [self redirectToProductDetailReputation:detailReputationReview withIndexPath:indexPath];
        }else{
            if([self isLastCellInSectionZero:indexPath]){
                [self showMoreTapped:nil];
            }else{
                //will show most hr details when jerry team has already STP
                DetailReputationReview *detailReputationReview = helpfulReviews[indexPath.row];
                [self redirectToProductDetailReputation:detailReputationReview withIndexPath:indexPath];
            }
        }
    }else{
        DetailReputationReview *detailReputationReview = arrList[indexPath.row];
        [self redirectToProductDetailReputation:detailReputationReview withIndexPath:indexPath];
    }
}

@end

