//
//  ProductReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "AdvanceReview.h"
#import "CMPopTipView.h"
#import "detail.h"
#import "DetailReputationReview.h"
#import "LoadingView.h"
#import "LikeDislike.h"
#import "LoginViewController.h"
#import "LikeDislikePost.h"
#import "LikeDislikePostResult.h"
#import "NoResultView.h"
#import "ProductReputationCell.h"
#import "ProductOwner.h"
#import "ProductDetailReputationViewController.h"
#import "ProductReputationViewController.h"
#import "Paging.h"
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
#define CCellIdentifier @"cell"
#define CTagGetProductReview 1

static NSInteger userViewHeight = 70;

@interface ProductReputationViewController ()<TTTAttributedLabelDelegate, UIActionSheetDelegate, TokopediaNetworkManagerDelegate, LoadingViewDelegate, LoginViewDelegate, ReportViewControllerDelegate, HelpfulReviewRequestDelegate, ProductReputationSimpleDelegate>
@end

@implementation ProductReputationViewController
{
    TAGContainer *_gtmContainer;
    NSString *productBaseUrl, *reviewActionBaseUrl;
    NSString *productPostUrl, *reviewActionPostUrl;
    
    NSMutableParagraphStyle *style;
    CMPopTipView *popTipView;
    UIRefreshControl *refreshControl;
    LoadingView *loadingView;
    NoResultView *noResultView;
    NSOperationQueue *_operationQueue, *operationQueueLikeDislike;

    int page, filterStar;
    NSString *strUri;
    Review *review;
    NSMutableArray *arrList;
    NSMutableArray<DetailReputationReview*> *helpfulReviews;
    NSDictionary *auth;
    NSMutableDictionary *loadingLikeDislike, *dictLikeDislike;
    TokopediaNetworkManager *tokopediaNetworkManager;
    
    HelpfulReviewRequest *helpfulReviewRequest;
    BOOL isShowingMore, animationHasShown;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureGTM];
    [self initNavigation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    page = 0;
    
    [self initTable];
    tableContent.backgroundColor = [UIColor clearColor];

    _operationQueue = [NSOperationQueue new];
    operationQueueLikeDislike = [NSOperationQueue new];
    loadingLikeDislike = [NSMutableDictionary new];
    dictLikeDislike = [NSMutableDictionary new];
    [btnFilterAllTime setTitleColor:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] forState:UIControlStateNormal];
    btnFilter6Month.tag = 0;
    btnFilterAllTime.tag = 1;
    
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    auth = [_userManager getUserLoginData];
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
    
    UINib *cellNib = [UINib nibWithNibName:@"ProductReputationSimpleCell" bundle:nil];
    [tableContent registerNib:cellNib forCellReuseIdentifier:@"ProductReputationSimpleCellIdentifier"];
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    animationHasShown = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unloadRequesting];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Method View
- (void)initNavigation {
    self.title = @"Ulasan";
}

- (void)setRateStar:(int)tag withAnimate:(BOOL)isAnimate {
    int nRate1, nRate2, nRate3, nRate4, nRate5;
    float totalCount = 0;
    nRate1 = nRate2 = nRate3 = nRate4 = nRate5 = 0;
    
    
    for(RatingList *tempRatingList in review.result.advance_review.rating_list) {
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
    
    
    
    //Set header rate
    for(int i=0;i<arrImageHeaderRating.count;i++) {
        UIImageView *tempImageView = arrImageHeaderRating[i];
        tempImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<ceilf([review.result.advance_review.product_rating_point floatValue]))?@"icon_star_active":@"icon_star" ofType:@"png"]];
    }
    
    lblTotalHeaderRating.text = [NSString stringWithFormat:@"%.1f", [review.result.advance_review.product_rating_point floatValue]];
    
    
    NSString *strReview = @"Review";
    lblDescTotalHeaderRating.text = [NSString stringWithFormat:@"%d Review", [review.result.advance_review.product_review intValue]];
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



#pragma mark - UITableView Delegate and DataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header;
    if(filterStar == 0 && helpfulReviews.count >0 && section == 0){
        header = _helpfulReviewHeader;
    }
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer;
    if(filterStar == 0 && helpfulReviews.count >0 && section == 0){
        footer = _helpfulReviewFooter;
    }
    return footer;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(filterStar == 0 && helpfulReviews.count >0 && section == 0){
        return 50;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(filterStar == 0 && helpfulReviews.count >0 && section == 0){
        return 10;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (filterStar == 0 && helpfulReviews.count > 0) ? 2 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(filterStar == 0 && helpfulReviews.count > 0){
        if(indexPath.section == 1){
            return [self calculateCellHeightAtIndexPath:indexPath withArrayContent:arrList];
        }else{
            if(!isShowingMore && indexPath.row == 1){
                //"load more" cell
                if(helpfulReviews.count > 1){
                    return 30;
                }else{
                    return 0;
                }
            }else if(isShowingMore && indexPath.row == helpfulReviews.count){
                return 30;
            }else{
                return [self calculateCellHeightAtIndexPath:indexPath withArrayContent:helpfulReviews];
            }
            
        }
    }else{
        return [self calculateCellHeightAtIndexPath:indexPath withArrayContent:arrList];
    }
    return 0;
}

- (CGFloat) calculateCellHeightAtIndexPath:(NSIndexPath*)indexPath withArrayContent:(NSMutableArray*)arr{
    //don't auto calculate cell for performance in iOS 7
    /*
    DetailReputationReview *reputationDetail = arr[indexPath.row];
    UILabel *messageLabel = [[UILabel alloc] init];
    
    [messageLabel setText:reputationDetail.review_message];
    [messageLabel sizeToFit];
    
    CGRect sizeOfMessage = [messageLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10, 0)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                                           context:nil];
    messageLabel.frame = sizeOfMessage;
    
    CGFloat height = userViewHeight + 40 + messageLabel.frame.size.height ;
    return height;
     */
    
    
    return 150;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == arrList.count-1) {
        if(strUri!=nil && ![strUri isEqualToString:@"0"]) {
            [self setLoadingView:YES];
            [[self getNetworkManager:CTagGetProductReview] doRequest];
        }
    }
    if(!animationHasShown && helpfulReviews.count > 0 && indexPath.section == 0 && ![self isLastCellInSectionZero:indexPath]){
        [self animate:cell];
        animationHasShown = YES;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(filterStar == 0 && helpfulReviews.count > 0){
        if(indexPath.section == 1){
            ProductReputationSimpleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductReputationSimpleCellIdentifier"];
            cell.isHelpful = NO;
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            DetailReputationReview *reputationDetail = arrList[indexPath.row];
            [cell setReputationModelView:reputationDetail.viewModel];
            
            if (![dictLikeDislike objectForKey:reputationDetail.review_id]) {
                if(! [loadingLikeDislike objectForKey:reputationDetail.review_id]) {
                    [loadingLikeDislike setObject:reputationDetail.review_id forKey:reputationDetail.review_id];
                    [self performSelectorInBackground:@selector(actionGetLikeStatus:) withObject:@[reputationDetail, indexPath]];
                }
            }
            return cell;
        }else{
            NSInteger limit = isShowingMore ? helpfulReviews.count : 1;
            if(indexPath.row < limit){
                ProductReputationSimpleCell *helpfulCell = [tableView dequeueReusableCellWithIdentifier:@"ProductReputationSimpleCellIdentifier"];
                helpfulCell.isHelpful = YES;
                helpfulCell.delegate = self;
                helpfulCell.indexPath = indexPath;
                
                DetailReputationReview *reputationDetail = helpfulReviews[indexPath.row];
                [helpfulCell setReputationModelView:reputationDetail.viewModel];
                
                CGRect newFrame = helpfulCell.leftBorderView.frame;
                newFrame.size.width = helpfulCell.leftBorderView.frame.size.width;
                newFrame.size.height = [self calculateCellHeightAtIndexPath:indexPath withArrayContent:helpfulReviews] - userViewHeight;
                [helpfulCell.leftBorderView setFrame:newFrame];
                
                if (![dictLikeDislike objectForKey:reputationDetail.review_id]) {
                    if(! [loadingLikeDislike objectForKey:reputationDetail.review_id]) {
                        [loadingLikeDislike setObject:reputationDetail.review_id forKey:reputationDetail.review_id];
                        [self performSelectorInBackground:@selector(actionGetLikeStatus:) withObject:@[reputationDetail, indexPath]];
                    }
                }
                return helpfulCell;
            }else{
                return _helpfulReviewLoadMoreCell;
            }
        }
    }else{
        ProductReputationSimpleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductReputationSimpleCellIdentifier"];
        cell.isHelpful = NO;
        cell.delegate = self;
        cell.indexPath = indexPath;
        
        DetailReputationReview *reputationDetail = arrList[indexPath.row];
        [cell setReputationModelView:reputationDetail.viewModel];
        
        if (![dictLikeDislike objectForKey:reputationDetail.review_id]) {
            if(! [loadingLikeDislike objectForKey:reputationDetail.review_id]) {
                [loadingLikeDislike setObject:reputationDetail.review_id forKey:reputationDetail.review_id];
                [self performSelectorInBackground:@selector(actionGetLikeStatus:) withObject:@[reputationDetail, indexPath]];
            }
        }

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

- (BOOL) isLastCellInSectionZero:(NSIndexPath *)indexPath{
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
- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point
{
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    DetailReputationReview *detailReputationReview = arrList[label.tag];
    [self redirectToProductDetailReputation:detailReputationReview withIndexPath:[NSIndexPath indexPathForRow:label.tag inSection:0]];
}


#pragma mark - Action
- (void)refreshView:(UIRefreshControl*)refresh
{
    [refresh endRefreshing];
    
    [operationQueueLikeDislike cancelAllOperations];
    [_operationQueue cancelAllOperations];
    
    page = 0;
    strUri = nil;
    [arrList removeAllObjects];
    [tableContent reloadData];
    
    [self unloadRequesting];
    [loadingLikeDislike removeAllObjects];
    [dictLikeDislike removeAllObjects];
    
    [self setLoadingView:YES];
    [[self getNetworkManager:CTagGetProductReview] doRequest];
}

- (void)actionResetFilter:(id)sender {
    if(filterStar == 0) {
        return;
    }
     
    [operationQueueLikeDislike cancelAllOperations];
    [_operationQueue cancelAllOperations];

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
    [[self getNetworkManager:CTagGetProductReview] doRequest];
}

- (IBAction)actionFilter6Month:(id)sender {
    [operationQueueLikeDislike cancelAllOperations];
    [_operationQueue cancelAllOperations];
    [btnFilterAllTime setTitleColor:[UIColor colorWithRed:111/255.0f green:113/255.0f blue:121/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [btnFilter6Month setTitleColor:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    page = 0;
    strUri = nil;
    [arrList removeAllObjects];
    [tableContent reloadData];
    btnFilter6Month.tag = 1;
    btnFilterAllTime.tag = 0;
    animationHasShown = NO;
    
    [self setLoadingView:YES];
    [[self getNetworkManager:CTagGetProductReview] doRequest];
}

- (IBAction)actionFilterAllTime:(id)sender {
    [operationQueueLikeDislike cancelAllOperations];
    [_operationQueue cancelAllOperations];
    [btnFilter6Month setTitleColor:[UIColor colorWithRed:111/255.0f green:113/255.0f blue:121/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [btnFilterAllTime setTitleColor:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    
    page = 0;
    strUri = nil;
    [arrList removeAllObjects];
    [tableContent reloadData];
    btnFilter6Month.tag = 0;
    btnFilterAllTime.tag = 1;
    animationHasShown = NO;
    
    [self setLoadingView:YES];
    [[self getNetworkManager:CTagGetProductReview] doRequest];
}

- (IBAction)actionSegmentedValueChange:(id)sender {
    /*switch (((UISegmentedControl *) sender).selectedSegmentIndex) {
        case 0:
        {
            [self setRateStar:0 withAnimate:YES];
        }
            break;
        case 1:
        {
            [self setRateStar:1 withAnimate:YES];
        }
            break;
    }
    */
    
    page = 0;
    strUri = nil;
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self setLoadingView:YES];
    [[self getNetworkManager:CTagGetProductReview] doRequest];
}

- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}

- (IBAction)showMoreTapped:(id)sender {
    if(isShowingMore){
        isShowingMore = NO;
        [_buttonShowMore setTitle:@"tampilkan semua" forState:UIControlStateNormal];
    }else{
        isShowingMore = YES;
        [_buttonShowMore setTitle:@"sembunyikan" forState:UIControlStateNormal];
    }
    [tableContent reloadData];
}

#pragma mark - Method
- (void)unloadRequesting {
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
    
    for(id obj in [loadingLikeDislike allValues]) {
        if([obj isMemberOfClass:[NSArray class]]) {
            NSArray *tempArr = (NSArray *)obj;
            RKManagedObjectRequestOperation *operation = [tempArr firstObject];
            [operation cancel];
            
            NSTimer *timer = [tempArr lastObject];
            [timer invalidate];
        }
    }
    
    [operationQueueLikeDislike cancelAllOperations];
}


- (void)requestLikeStatusAgain:(NSIndexPath *)indexPath {
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    [loadingLikeDislike setObject:detailReputationReview.review_id forKey:detailReputationReview.review_id];
    [self performSelectorInBackground:@selector(actionGetLikeStatus:) withObject:@[detailReputationReview, [NSNumber numberWithInt:(int)indexPath.row]]];
}


- (void)updateDataInDetailView:(LikeDislike *)likeDislike {
    if([[self.navigationController.viewControllers lastObject] isMemberOfClass:[ProductDetailReputationViewController class]]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [((ProductDetailReputationViewController *) [self.navigationController.viewControllers lastObject]) updateLikeDislike:likeDislike];
        });
    }
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
    
    //Load data
    [operationQueueLikeDislike cancelAllOperations];
    [_operationQueue cancelAllOperations];
    
    page = 0;
    strUri = nil;
    [arrList removeAllObjects];
    [tableContent reloadData];
    
    [self setLoadingView:YES];
    [[self getNetworkManager:CTagGetProductReview] doRequest];
}


- (void)redirectToProductDetailReputation:(DetailReputationReview *)detailReputationReview withIndexPath:(NSIndexPath *)indexPath {
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    
    [self mappingAttribute:detailReputationReview];
    productDetailReputationViewController.isMyProduct = (auth!=nil && [[NSString stringWithFormat:@"%@", [auth objectForKey:@"user_id"]] isEqualToString:detailReputationReview.product_owner.user_id]);
    productDetailReputationViewController.detailReputaitonReview = detailReputationReview;
    productDetailReputationViewController.dictLikeDislike = dictLikeDislike;
    productDetailReputationViewController.loadingLikeDislike = loadingLikeDislike;
    productDetailReputationViewController.indexPathSelected = indexPath;
    productDetailReputationViewController.strProductID = _strProductID;
    productDetailReputationViewController.shopBadgeLevel = detailReputationReview.product_owner.user_shop_reputation.reputation_badge_object;

    if([dictLikeDislike objectForKey:productDetailReputationViewController.detailReputaitonReview.review_id]) {
        TotalLikeDislike *totalLikeDislike = [dictLikeDislike objectForKey:productDetailReputationViewController.detailReputaitonReview.review_id];
        productDetailReputationViewController.strTotalDisLike = totalLikeDislike.total_like_dislike.total_dislike;
        productDetailReputationViewController.strTotalLike = totalLikeDislike.total_like_dislike.total_like;
        productDetailReputationViewController.strLikeStatus = totalLikeDislike.like_status;
    }

    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}

- (void)showLoginView {
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    LoginViewController *controller = [LoginViewController new];
    controller.delegate = self;
    controller.isPresentedViewController = YES;
    controller.redirectViewController = self;
    navigationController.viewControllers = @[controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)configureRestKitLikeDislike:(RKObjectManager *)objectManager {
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[LikeDislikePost class]];
    [statusMapping addAttributeMappingsFromDictionary:@{CLStatus:CLStatus,
                                                        CLServerProcessTime:CLServerProcessTime,
                                                        CLMessageError:CLMessageError}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LikeDislikePostResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{CIsSuccess:CIsSuccess}];
    
    RKObjectMapping *totalLikeDislikePostMapping = [RKObjectMapping mappingForClass:[TotalLikeDislikePost class]];
    RKObjectMapping *detailTotalLikeMapping = [RKObjectMapping mappingForClass:[DetailTotalLikeDislike class]];
    [detailTotalLikeMapping addAttributeMappingsFromDictionary:@{CTotalLike:CTotalLike,
                                                                 CTotalDislike:CTotalDislike}];
    
    
    //add relationship mapping
    [totalLikeDislikePostMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CTotalLikeDislike toKeyPath:CTotalLikeDislike withMapping:detailTotalLikeMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CContent toKeyPath:CContent withMapping:totalLikeDislikePostMapping]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:@"action/review.pl"
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)doActionLikeDislike:(int)likeDislikeTag withView:(UIView *)btnLike {
    //1 is like
    //2 is dislike
    //3 is unlike or undislike
    RKObjectManager *objectManager;
    if([reviewActionBaseUrl isEqualToString:kTkpdBaseURLString] || [reviewActionBaseUrl isEqualToString:@""]) {
        objectManager = [RKObjectManager sharedClient];
    } else {
        objectManager = [RKObjectManager sharedClient:reviewActionBaseUrl];
    }
    
    [self configureRestKitLikeDislike:objectManager];
    DetailReputationReview *detailReputationReview = arrList[btnLike.tag];
    NSDictionary* param = @{@"action":@"like_dislike_review",
                            @"review_id":detailReputationReview.review_id,
                            @"like_status":@(likeDislikeTag),
                            @"shop_id":detailReputationReview.shop_id,
                            @"product_id":_strProductID};

    RKObjectRequestOperation *request = [objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:[reviewActionPostUrl isEqualToString:@""] ? @"action/review.pl" : reviewActionPostUrl parameters:[param encrypt]];
    __block NSTimer *_timer;
    [request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [_timer invalidate];
        _timer = nil;
        
        //Result
        NSDictionary *result = ((RKMappingResult*) mappingResult).dictionary;
        LikeDislikePost *likeDislikePost = [result objectForKey:@""];
        LikeDislikePostResult *likeDislikePostResult = likeDislikePost.result;
        BOOL status = [likeDislikePostResult.is_success isEqualToString:@"1"];
        
        TotalLikeDislike *totalLikeDislike = [dictLikeDislike objectForKey:detailReputationReview.review_id];
        if(status) {
            if(totalLikeDislike) {
                totalLikeDislike.total_like_dislike.total_like = likeDislikePostResult.content.total_like_dislike.total_like;
                totalLikeDislike.total_like_dislike.total_dislike = likeDislikePostResult.content.total_like_dislike.total_dislike;
                totalLikeDislike.like_status = [NSString stringWithFormat:@"%d", likeDislikeTag];

                //Reload UI
                if([loadingLikeDislike objectForKey:detailReputationReview.review_id])
                    [tableContent reloadRowsAtIndexPaths:@[[loadingLikeDislike objectForKey:detailReputationReview.review_id]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        else {
            if(likeDislikePost.message_error!=nil && likeDislikePost.message_error.count>0) {
                StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:likeDislikePost.message_error delegate:self];
                [stickyAlertView show];
            }
        }
        
        [loadingLikeDislike removeObjectForKey:detailReputationReview.review_id];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [_timer invalidate];
        _timer = nil;
        [loadingLikeDislike removeObjectForKey:detailReputationReview.review_id];
    }];
    [operationQueueLikeDislike addOperation:request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout:) userInfo:detailReputationReview.review_id repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)timeOutGetLikeDislike:(NSTimer *)temp {
    RKManagedObjectRequestOperation *operation = [[loadingLikeDislike objectForKey:[temp userInfo]] firstObject];
    [operation cancel];
    operation = nil;
    [loadingLikeDislike removeObjectForKey:[temp userInfo]];
}

- (RKObjectManager *)getObjectManagerTotalLike
{
    // initialize RestKit
    RKObjectManager *tempObjectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[LikeDislike class]];
    [productMapping addAttributeMappingsFromDictionary:@{CLStatus:CLStatus,
                                                         CLServerProcessTime:CLServerProcessTime,
                                                         CLStatus:CLStatus,
                                                         CLMessageError:CLMessageError}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LikeDislikeResult class]];
    RKObjectMapping *totalLikeDislikeMapping = [RKObjectMapping mappingForClass:[TotalLikeDislike class]];
    [totalLikeDislikeMapping addAttributeMappingsFromArray:@[CLikeStatus,
                                                             CReviewID]];
    
    RKObjectMapping *detailTotalLikeMapping = [RKObjectMapping mappingForClass:[DetailTotalLikeDislike class]];
    [detailTotalLikeMapping addAttributeMappingsFromDictionary:@{CTotalLike:CTotalLike,
                                                                 CTotalDislike:CTotalDislike}];
    
    
    
    //Relation Mapping
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CLikeDislikeReview toKeyPath:CLikeDislikeReview withMapping:totalLikeDislikeMapping]];
    [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CLResult toKeyPath:CLResult withMapping:resultMapping]];
    [totalLikeDislikeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CTotalLikeDislike toKeyPath:CTotalLikeDislike withMapping:detailTotalLikeMapping]];
    // Response Descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodPOST pathPattern:[self getPathLikeDislike] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    [tempObjectManager addResponseDescriptor:responseDescriptor];
    
    return tempObjectManager;
}

- (NSString *)getPathLikeDislike {
    return @"shop.pl";
}

- (void)actionGetLikeStatus:(NSArray *)arrayList {
    if(loadingLikeDislike.count > 10)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        DetailReputationReview *list = (DetailReputationReview *)[arrayList firstObject];
        NSIndexPath* indexPath = (NSIndexPath*) [arrayList lastObject];
        RKObjectManager *tempObjectManager = [self getObjectManagerTotalLike];
        NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETLIKEDISLIKE,
                                kTKPDDETAIL_REVIEWIDS : list.review_id,
                                kTKPDDETAIL_APISHOPIDKEY : list.shop_id};
        RKManagedObjectRequestOperation *tempRequest = [tempObjectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:[self getPathLikeDislike] parameters:[param encrypt]];

        
        NSTimer *timerLikeDislike = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(timeOutGetLikeDislike:) userInfo:list.review_id repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timerLikeDislike forMode:NSRunLoopCommonModes];
        [loadingLikeDislike setObject:@[tempRequest, indexPath, timerLikeDislike] forKey:list.review_id];
        
        
        [tempRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"%@", operation.HTTPRequestOperation.responseString);
            NSTimer *temporaryTimer = [[loadingLikeDislike objectForKey:list.review_id] lastObject];
            [temporaryTimer invalidate];
            
            NSDictionary *result = ((RKMappingResult*) mappingResult).dictionary;
            LikeDislike *obj = [result objectForKey:@""];
            [dictLikeDislike setObject:((TotalLikeDislike *) [obj.result.like_dislike_review firstObject]) forKey:((TotalLikeDislike *) [obj.result.like_dislike_review firstObject]).review_id];
            [self performSelectorInBackground:@selector(updateDataInDetailView:) withObject:obj];
            
            //Update UI
            if([loadingLikeDislike objectForKey:list.review_id])
                [tableContent reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [loadingLikeDislike removeObjectForKey:list.review_id];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            NSTimer *temporaryTimer = [[loadingLikeDislike objectForKey:list.review_id] lastObject];
            [temporaryTimer invalidate];
            [loadingLikeDislike removeObjectForKey:list.review_id];
        }];
        [_operationQueue addOperation:tempRequest];
    });
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
            tokopediaNetworkManager.delegate = self;
        }
        
        return tokopediaNetworkManager;
    }
    
    return nil;
}

- (void)dismissAllPopTipViews
{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}

- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc {
    lblDesc.backgroundColor = [UIColor clearColor];
    lblDesc.textAlignment = NSTextAlignmentLeft;
    lblDesc.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
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

- (void)actionLike:(id)sender {
    if(auth) {
        UIButton *btnLike = (UIButton *)sender;
        ProductReputationCell *cell = [self getCell:btnLike];
        DetailReputationReview *detailReputationReview = arrList[btnLike.tag];
        UIButton *btnDislike = [cell getBtnDisLike];
        
        int tagRequest = 3;
        if([dictLikeDislike objectForKey:detailReputationReview.review_id] && ([((TotalLikeDislike *)[dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"3"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"0"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"2"])) {
            tagRequest = 1;
            
            [btnDislike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike" ofType:@"png"]] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5 animations:^{
                btnLike.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [btnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like_active" ofType:@"png"]] forState:UIControlStateNormal];
                [UIView animateWithDuration:0.5 animations:^{
                    btnLike.alpha = 1.0f;
                }];
            }];
            
            
            //Set data total
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like intValue] + 1)];
            if([((TotalLikeDislike *)[dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"2"]) {
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike intValue] - 1)];
            }
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status = @"1";            
        }
        else {
            if([((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"1"]) {
                tagRequest = 3;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status = @"0";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like intValue] - 1)];
                [btnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like" ofType:@"png"]] forState:UIControlStateNormal];
            }
            else {
                tagRequest = 1;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status = @"1";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like intValue] + 1)];
                [btnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like_active" ofType:@"png"]] forState:UIControlStateNormal];
            }
        }

        
        [btnLike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like forState:UIControlStateNormal];
        [btnDislike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike forState:UIControlStateNormal];
        [loadingLikeDislike setObject:[NSIndexPath indexPathForRow:btnLike.tag inSection:0] forKey:detailReputationReview.review_id];
        [self doActionLikeDislike:tagRequest withView:btnLike];
    }
    else {
        [self showLoginView];
    }
}

- (void)requestTimeout:(NSTimer *)timer {
    [loadingLikeDislike removeObjectForKey:[timer userInfo]];
    
    RKObjectRequestOperation *objectReputation = [operationQueueLikeDislike.operations firstObject];
    [objectReputation cancel];
}

- (void)actionDisLike:(id)sender {
    if(auth) {
        UIButton *btnDislike = (UIButton *)sender;
        ProductReputationCell *cell = [self getCell:btnDislike];
        DetailReputationReview *detailReputationReview = arrList[btnDislike.tag];
        UIButton *btnLike = [cell getBtnLike];

        int tagRequest = 3;
        if([dictLikeDislike objectForKey:detailReputationReview.review_id] && ([((TotalLikeDislike *)[dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"3"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"0"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"1"])) {
            tagRequest = 2;
            [btnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like" ofType:@"png"]] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5 animations:^{
                btnDislike.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [btnDislike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike_active" ofType:@"png"]] forState:UIControlStateNormal];
                [UIView animateWithDuration:0.5 animations:^{
                    btnDislike.alpha = 1.0f;
                }];
            }];
            
            
            //Set data total
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike intValue] + 1)];
            if([((TotalLikeDislike *)[dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"1"]) {
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like intValue] - 1)];
            }
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status = @"2";
        }
        else {
            if([((TotalLikeDislike *)[dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status isEqualToString:@"2"]) {
                tagRequest = 3;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status = @"0";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike intValue] - 1)];
                [btnDislike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike" ofType:@"png"]] forState:UIControlStateNormal];
            }
            else {
                tagRequest = 2;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).like_status = @"2";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike intValue] + 1)];
                [btnDislike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike_active" ofType:@"png"]] forState:UIControlStateNormal];
            }
        }

        [btnLike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_like forState:UIControlStateNormal];
        [btnDislike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:detailReputationReview.review_id]).total_like_dislike.total_dislike forState:UIControlStateNormal];
        [loadingLikeDislike setObject:[NSIndexPath indexPathForRow:btnDislike.tag inSection:0] forKey:detailReputationReview.review_id];
        [self doActionLikeDislike:tagRequest withView:btnDislike];
    }
    else {
        [self showLoginView];
    }
}

- (void)actionChat:(id)sender {
//    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
//    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}

- (void)actionMore:(id)sender {
//    if(auth) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CStringBatal destructiveButtonTitle:CStringLapor otherButtonTitles:nil, nil];
        actionSheet.tag = ((UIButton *) sender).tag;
        [actionSheet showInView:self.view];
//    }
//    else {
//        [self showLoginView];
//    }
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
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
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


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagGetProductReview) {
        NSMutableDictionary *dictFilter = [NSMutableDictionary new];
        [dictFilter setObject:@"get_product_review" forKey:@"action"];
        [dictFilter setObject:_strShopDomain forKey:@"shop_domain"];
        [dictFilter setObject:_strProductID forKey:@"product_id"];
        
        if(btnFilter6Month.tag == 1) {
            [dictFilter setObject:@(6) forKey:@"month_range"];
        }
        [dictFilter setObject:@(page) forKey:@"page"];
        
        if((int)segmentedControl.selectedSegmentIndex==0 && filterStar>0) {//Quality
            [dictFilter setObject:@(filterStar) forKey:@"shop_quality"];
        }
        else if(filterStar > 0){
            [dictFilter setObject:@(filterStar) forKey:@"shop_accuracy"];
        }
        
        return dictFilter;
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagGetProductReview) {
        return [productPostUrl isEqualToString:@""] ? @"product.pl" : productPostUrl;
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagGetProductReview) {
        RKObjectManager *objectManager;
        if([productBaseUrl isEqualToString:kTkpdBaseURLString] || [productBaseUrl isEqualToString:@""]) {
            objectManager = [RKObjectManager sharedClient];
        } else {
            objectManager = [RKObjectManager sharedClient:productBaseUrl];
        }
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Review class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ReviewResult class]];
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromArray:@[CUriNext,
                                                       CUriPrevious]];
        
        
        RKObjectMapping *advreviewMapping = [RKObjectMapping mappingForClass:[AdvanceReview class]];
        [advreviewMapping addAttributeMappingsFromDictionary:@{CProductRatingPoint:CProductRatingPoint,
                                                          CProductRateAccuracyPoint:CProductRateAccuracyPoint,
                                                          CProductPositiveReviewRating:CProductPositiveReviewRating,
                                                          CProductNetralReviewRating:CProductNetralReviewRating,
                                                          CProductRatingStarPoint:CProductRatingStarPoint,
                                                          CProductRatingStarDesc:CProductRatingStarDesc,
                                                          CProductNegativeReviewRating:CProductNegativeReviewRating,
                                                          CProductReview:CProductReview,
                                                          CProductRateAccuracy:CProductRateAccuracy,
                                                          CProductAccuracyStarDesc:CProductAccuracyStarDesc,
                                                          CProductRating:CProductRating,
                                                          CProductNetralReviewRateAccuray:CProductNetralReviewRateAccuray,
                                                          CProductAccuacyStarRate:CProductAccuacyStarRate,
                                                          CProductPositiveReviewRateAccuracy:CProductPositiveReviewRateAccuracy,
                                                          CProductNegativeReviewRateAccuracy:CProductNegativeReviewRateAccuracy
                                                        }];
        
        RKObjectMapping *detailReputationReviewMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
        [detailReputationReviewMapping addAttributeMappingsFromDictionary:@{CReviewUpdateTime:CReviewUpdateTime,
                                                                       CReviewRateAccuracyDesc:CReviewRateAccuracyDesc,
                                                                       CReviewUserLabelID:CReviewUserLabelID,
                                                                       CReviewUserName:CReviewUserName,
                                                                       CReviewRateAccuracy:CReviewRateAccuracy,
                                                                       CReviewMessage:CReviewMessage,
                                                                       CReviewRateProductDesc:CReviewRateProductDesc,
                                                                       CReviewRateSpeedDesc:CReviewRateSpeedDesc,
                                                                       CReviewShopID:CShopID,
                                                                        @"review_reputation_id":CReputationID,
                                                                       CReviewUserImage:CReviewUserImage,
                                                                       CReviewUserLabel:CReviewUserLabel,
                                                                       CReviewCreateTime:CReviewCreateTime,
                                                                       CReviewID:CReviewID,
                                                                       CReviewRateServiceDesc:CReviewRateServiceDesc,
                                                                       CReviewRateProduct:CReviewRateProduct,
                                                                       CReviewRateSpeed:CReviewRateSpeed,
                                                                       CReviewRateService:CReviewRateService,
                                                                       CReviewUserID:CReviewUserID
                                                                            }];
        
        RKObjectMapping *reviewReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
        [reviewReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                 CNoReputation,
                                                                CNegative,
                                                                CNeutral,
                                                                CPositif]];
        
        RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
        [reviewResponseMapping addAttributeMappingsFromArray:@[CResponseCreateTime,
                                                                CResponseMessage]];
        
        
        RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
        [productOwnerMapping addAttributeMappingsFromDictionary:@{CUserLabelID:CUserLabelID,
                                                                CUserLabel:CUserLabel,
                                                                CuserID:CuserID,
                                                                  @"user_shop_name":CShopName,
                                                                  @"user_shop_image":CShopImg,
                                                                CUserImage:CUserImg,
                                                                CUserName:CFullName,
                                                                CFullName:CUserName}];
        
        RKObjectMapping *shopReputationMapping = [RKObjectMapping mappingForClass:[ShopReputation class]];
        [shopReputationMapping addAttributeMappingsFromArray:@[CToolTip,
                                                               CReputationBadge,
                                                               CReputationScore,
                                                               CScore,
                                                               CMinBadgeScore]];        
        
        RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
        [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
        

        RKObjectMapping *ratingListMapping = [RKObjectMapping mappingForClass:[RatingList class]];
        [ratingListMapping addAttributeMappingsFromArray:@[CRatingRatingStarPoint,
                                                           CRatingTotalRateAccuracyPersen,
                                                           CRatingRateService,
                                                           CRatingRatingStarDesc,
                                                           CRatingRatingFmt,
                                                           CRatingTotalRatingPersen,
                                                           CRatingUrlFilterRateAccuracy,
                                                           CRatingRating,
                                                           CRatingUrlFilterRating,
                                                           CRatingRateSpeed,
                                                           CRatingRateAccuracy,
                                                           CRatingRateAccuracyFmt,
                                                           CRatingRatingPoint]];
        
                                                                
        //add relationship mapping
        [productOwnerMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CUserShopReputation toKeyPath:CUserShopReputation withMapping:shopReputationMapping]];
        [shopReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReputationBadge toKeyPath:CReputationBadgeObject withMapping:shopBadgeMapping]];
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CPaging toKeyPath:CPaging withMapping:pagingMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CAdvanceReview toKeyPath:CAdvanceReview withMapping:advreviewMapping]];
        
        [advreviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CProductRatingList toKeyPath:CRating_List withMapping:ratingListMapping]];
        
        [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:reviewReputationMapping]];
        [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewResponse toKeyPath:CReviewResponse withMapping:reviewResponseMapping]];
        [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewProductOwner toKeyPath:CProductOwner withMapping:productOwnerMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CList toKeyPath:CList withMapping:detailReputationReviewMapping]];

        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagGetProductReview) {
        Review *tempReview = stat;
        return tempReview.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagGetProductReview) {
        review = stat;
        
        if(page==0 && review.result.list!=nil) {
            arrList = [[NSMutableArray alloc] initWithArray:review.result.list];
            
            segmentedControl.enabled = YES;
            btnFilter6Month.enabled = btnFilterAllTime.enabled = YES;
            [self setRateStar:(int)segmentedControl.selectedSegmentIndex withAnimate:YES];
        }
        else if(review.result.list != nil) {
            [arrList addObjectsFromArray:review.result.list];
        }
        
        //Check next page
        strUri = review.result.paging.uri_next;
        page = (int)[[[self getNetworkManager:CTagGetProductReview] splitUriToPage:strUri] integerValue];
        

        //Add delegate to talbe view
        if(arrList!=nil && arrList.count>0) {
            if(tableContent.delegate == nil) {
                tableContent.delegate = self;
                tableContent.dataSource = self;
            }
            
            [tableContent reloadData];
            [self setLoadingView:NO];
        }
        else  {
            [self setLoadingView:NO];
            
            if(noResultView == nil) {
                noResultView = [NoResultView new];
            }
            tableContent.tableFooterView = noResultView.view;
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    if(tag == CTagGetProductReview) {
        
    }
}

- (void)actionBeforeRequest:(int)tag {
}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag == CTagGetProductReview) {
        [self setLoadingView:NO];
        
        
        if(loadingView == nil) {
            loadingView = [LoadingView new];
            loadingView.delegate = self;
        }
        
        tableContent.tableFooterView = loadingView.view;
    }
}


#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    [self setLoadingView:YES];
    [[self getNetworkManager:CTagGetProductReview] doRequest];
}

#pragma mark - LoginView Delegate
- (void)redirectViewController:(id)viewController{
    
}

- (void)cancelLoginView {
    
}

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
    
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    auth = [_userManager getUserLoginData];
    [dictLikeDislike removeAllObjects];
    [loadingLikeDislike removeAllObjects];
    [tableContent reloadData];
}

#pragma mark - HelpfulReviewRequestDelegate

- (void) didReceiveHelpfulReview:(NSArray*)helpfulReview{
    [[self getNetworkManager:CTagGetProductReview] doRequest];
    
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


#pragma mark - GTM
- (void)configureGTM {
    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    productBaseUrl = [_gtmContainer stringForKey:GTMKeyProductBase];
    productPostUrl = [_gtmContainer stringForKey:GTMKeyProductPost];
    reviewActionBaseUrl = [_gtmContainer stringForKey:GTMKeyActionReviewBase];
    reviewActionPostUrl = [_gtmContainer stringForKey:GTMKeyActionReviewPost];
}
@end

