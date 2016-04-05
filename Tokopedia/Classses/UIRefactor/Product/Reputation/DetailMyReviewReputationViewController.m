//
//  DetailMyReviewReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "CMPopTipView.h"
#import "detail.h"

#import "DetailMyReviewReputationCell.h"
#import "DetailMyInboxReputation.h"
#import "DetailReputationReview.h"
#import "DetailMyReviewReputationViewController.h"
#import "GiveReviewViewController.h"
#import "LoadingView.h"
#import "MyReviewReputationViewController.h"
#import "MyReviewReputation.h"
#import "MyReviewReputationViewModel.h"
#import "MyReviewReputationCell.h"
#import "NavigateViewController.h"
#import "NoResultView.h"
#import "ProductDetailReputationViewController.h"
#import "Paging.h"
#import "ReportViewController.h"
#import "ShopContainerViewController.h"
#import "SegmentedReviewReputationViewController.h"
#import "SkipReview.h"
#import "ShopBadgeLevel.h"
#import "SmileyAndMedal.h"
#import "SplitReputationViewController.h"
#import "string_inbox_message.h"
#import "String_Reputation.h"
#import "SkipReviewResult.h"
#import "TokopediaNetworkManager.h"
#import "UserContainerViewController.h"
#import "ViewLabelUser.h"
#import "GiveReviewRatingViewController.h"

#define CCellIdentifier @"cell"
#define CGetListReputationReview @"get_list_reputation_review"
#define CSkipReputationReview @"skip_reputation_review"
#define CStringGagalLewatiReview @"Anda gagal lewati ulasan"
#define CStringSuccessLewatiReview @"Anda telah berhasil lewati ulasan"
#define CStringSemuaReviewDiLewati @"Semua ulasan telah dilewati"
#define CTagListReputationReview 1
#define CTagSkipReputationReview 2

@interface DetailMyReviewReputationViewController ()<TokopediaNetworkManagerDelegate, LoadingViewDelegate, detailMyReviewReputationCell, UIAlertViewDelegate, ReportViewControllerDelegate, MyReviewReputationDelegate, CMPopTipViewDelegate, SmileyDelegate, TTTAttributedLabelDelegate>

@end

@implementation DetailMyReviewReputationViewController
{
    NSMutableArray *arrList;
    CMPopTipView *cmPopTitpView;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSString *strUriNext;
    BOOL isRefreshing, getDataFromMasterInServer, isEdit;
    int page, tempTagSkip;
    float heightBtnFooter;
    NSMutableParagraphStyle *style;
    
    TAGContainer *_gtmContainer;
    NSString *baseUrl, *baseActionUrl;
    NSString *postUrl, *postActionUrl;
    UIView *shadowBlockUI;
    UIActivityIndicatorView *activityIndicator;
    UIRefreshControl *refreshControl;
    MyReviewReputationCell *myReviewReputationCell;
    DetailReputationReview *tempDetailReputationReview;
    LoadingView *loadingView;
    NoResultView *noResultView;
    
    NavigateViewController *_TKPDNavigator;
    void (^_reputationIconTapCallback)();
}

- (void)dealloc {
    tokopediaNetworkManager.delegate = nil;
    [tokopediaNetworkManager requestCancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureGTM];
    page = 0;
    tempTagSkip = -1;
    
    [self initTable];
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagListReputationReview] doRequest];
    
    _TKPDNavigator = [NavigateViewController new];
    
    style = [NSMutableParagraphStyle new];
    style.lineSpacing = 4.0f;
    tableContent.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    arrList = [[NSMutableArray alloc] init];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];

    tableContent.delegate = self;
    tableContent.dataSource = self;
    [tableContent reloadData];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [tableContent addSubview:refreshControl];
    
    
    if([_detailMyInboxReputation.role isEqualToString:@"1"])//1 is pembeli
        _detailMyInboxReputation.updated_reputation_review = _detailMyInboxReputation.viewModel.updated_reputation_review = @"0";

    lblSubTitle.text = _detailMyInboxReputation.invoice_ref_num;
    viewContentTitle.frame = CGRectMake(0, 0, self.view.bounds.size.width-(72*2), self.navigationController.navigationBar.bounds.size.height);
    viewContentTitle.userInteractionEnabled = YES;
    [viewContentTitle addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionInvoice:)]];
    self.navigationItem.titleView = viewContentTitle;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - UITableView Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailMyReviewReputationCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DetailMyReviewReputationCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        CGRect rectCell = cell.frame;
        rectCell.size.width = tableView.bounds.size.width;
        cell.frame = rectCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setUnClickViewAction];
        
        cell.delegate = self;
        cell.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
        [self setPropertyLabelDesc:cell.getLabelDesc];
    }
    
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    cell.getLabelDesc.tag = indexPath.row;
    cell.getBtnKomentar.tag = indexPath.row;
    cell.getBtnUbah.tag = indexPath.row;
    cell.getBtnProduct.tag = indexPath.row;
    cell.strRole = _detailMyInboxReputation.role;
    [cell setView:detailReputationReview.viewModel];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    int height = CHeightContentStar + CPaddingTopBottom;
    CGSize tempSizeDesc = CGSizeZero;

    if((detailReputationReview.review_message==nil || [detailReputationReview.review_message isEqualToString:@"0"]) && [_detailMyInboxReputation.role isEqualToString:@"1"]) {
        height -= CHeightContentStar;
    }
    else if(detailReputationReview.review_message!=nil && detailReputationReview.review_message.length>0 && ![detailReputationReview.review_message isEqualToString:@"0"]) {
        TTTAttributedLabel *tempLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-(CPaddingTopBottom*4), 0)];
        [self setPropertyLabelDesc:tempLabel];
        [self initLabelDesc:tempLabel withText:detailReputationReview.viewModel.review_message];
        tempSizeDesc = [tempLabel sizeThatFits:CGSizeMake(tempLabel.bounds.size.width, 9999)];
    }
    
    if([detailReputationReview.review_is_skipped isEqualToString:@"1"]) {
        if([_detailMyInboxReputation.role isEqualToString:@"2"]) {
            height -= CHeightContentStar;
        }
    }
    else if(detailReputationReview.review_message==nil || [detailReputationReview.review_message isEqualToString:@"0"]) {
        if([_detailMyInboxReputation.role isEqualToString:@"2"]) {
            height -= CHeightContentStar;
        }
    }
    else {
        height += CPaddingTopBottom + CPaddingTopBottom;
    }
    
    // Later delete the 60
    return (CPaddingTopBottom*4) + height + CHeightContentAction + CDiameterImage + tempSizeDesc.height + 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(isRefreshing)
        return;
    
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    if(detailReputationReview.viewModel==nil || detailReputationReview.viewModel.review_message==nil || [detailReputationReview.viewModel.review_message isEqualToString:@"0"]) {
        if([_detailMyInboxReputation.role isEqualToString:@"2"]) {
            return;
        }
        
        UIView *tempView = [UIView new];
        tempView.tag = indexPath.row;
        
        [self actionBeriReview:tempView];
    }
    else {
        DetailReputationReview *detailReputationReview = arrList[indexPath.row];
        [self redirectToProductDetailReputationReview:detailReputationReview];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(arrList!=nil && arrList.count-1 == indexPath.row) {
        if (strUriNext!=nil && ![strUriNext isEqualToString:@"0"]) {
            [self loadMoreData:YES];
            [[self getNetworkManager:CTagListReputationReview] doRequest];
        }
    }
}


#pragma mark - Method View
- (void)initTable {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyReviewReputationCell" owner:self options:nil];
    myReviewReputationCell = [topLevelObjects objectAtIndex:0];
    myReviewReputationCell.delegate = self;
    
    int topConstraint = [myReviewReputationCell getTopViewContentConstraint].constant;
    int heightBtnInvoce = [myReviewReputationCell getConstHeightBtnInvoce].constant;
    [myReviewReputationCell setLeftViewContentContraint:0];
    [myReviewReputationCell setRightViewContentContraint:0];
    [myReviewReputationCell setTopViewContentContraint:0];
    [myReviewReputationCell setBottomViewContentContraint:0];
    [myReviewReputationCell setView:_detailMyInboxReputation.viewModel];
    myReviewReputationCell.getBtnInvoice.hidden = YES;
    myReviewReputationCell.getConstHeightBtnInvoce.constant = 0;
    
    
    myReviewReputationCell.getBtnFooter.userInteractionEnabled = NO;
    myReviewReputationCell.getViewFlagReadUnread.hidden = myReviewReputationCell.getBtnFooter.hidden = YES;
    [myReviewReputationCell.getBtnFooter setTitle:CStringSemuaReviewDiLewati forState:UIControlStateNormal];
    heightBtnFooter = myReviewReputationCell.getConstHegithBtnFooter.constant;
    myReviewReputationCell.getConstHegithBtnFooter.constant = 0;
    
    CGRect tempRect = myReviewReputationCell.contentView.frame;
    tempRect.size.height -= (topConstraint+topConstraint+heightBtnFooter+heightBtnInvoce+3);
    myReviewReputationCell.contentView.frame = tempRect;
    tableContent.tableHeaderView = myReviewReputationCell.contentView;
}

- (void)setUIAllReviewNotSkipable {
    if(! myReviewReputationCell.getBtnFooter.isHidden) {
        myReviewReputationCell.getBtnFooter.hidden = YES;
        myReviewReputationCell.getConstHegithBtnFooter.constant = 0;
        
        CGRect tempRect = myReviewReputationCell.contentView.frame;
        tempRect.size.height -= heightBtnFooter;
        myReviewReputationCell.contentView.frame = tempRect;
        tableContent.tableHeaderView = myReviewReputationCell.contentView;
    }
}

- (void)setUIAllReviewSkipable {
    if(myReviewReputationCell.getBtnFooter.isHidden) {
        myReviewReputationCell.getBtnFooter.hidden = NO;
        myReviewReputationCell.getConstHegithBtnFooter.constant = heightBtnFooter;
        CGRect tempRect = myReviewReputationCell.contentView.frame;
        tempRect.size.height += heightBtnFooter;
        myReviewReputationCell.contentView.frame = tempRect;
        tableContent.tableHeaderView = myReviewReputationCell.contentView;
    }
}

- (void)blockUI:(BOOL)block {
    if(block){
        shadowBlockUI = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.navigationController.view.bounds.size.height)];
        shadowBlockUI.backgroundColor = [UIColor blackColor];
        shadowBlockUI.alpha = 0.5f;
        [self.navigationController.view addSubview:shadowBlockUI];
        
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        activityIndicator.color = [UIColor whiteColor];
        [activityIndicator startAnimating];
        activityIndicator.center = CGPointMake(self.navigationController.view.bounds.size.width/2.0f, self.navigationController.view.bounds.size.height/2.0f);
        [self.navigationController.view addSubview:activityIndicator];
    }
    else {
        [activityIndicator stopAnimating];
        activityIndicator = nil;
        
        [shadowBlockUI removeFromSuperview];
        shadowBlockUI = nil;
    }
}

#pragma mark - Method
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
    cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    cmPopTitpView.delegate = self;
    cmPopTitpView.backgroundColor = [UIColor blackColor];
    cmPopTitpView.animation = CMPopTipAnimationSlide;
    cmPopTitpView.dismissTapAnywhere = YES;
    cmPopTitpView.leftPopUp = YES;
    
    UIButton *button = (UIButton *)sender;
    [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
}


- (void)successGiveReview {
    [self reloadTable];
    int n = [_detailMyInboxReputation.unassessed_reputation_review intValue];
    n--;
    
    if(n < 0)
        n = 0;
    
    _detailMyInboxReputation.unassessed_reputation_review = _detailMyInboxReputation.viewModel.unassessed_reputation_review = [NSString stringWithFormat:@"%d", n];
    
    TTTAttributedLabel *tempLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-(CPaddingTopBottom*4), 0)];
    [self setPropertyLabelDesc:tempLabel];
    [self initLabelDesc:tempLabel withText:tempDetailReputationReview.viewModel.review_message];
}

- (void)successGiveComment {
    [self successGiveReview];
}

- (void)successHapusComment {
    [self reloadTable];
    int n = [_detailMyInboxReputation.unassessed_reputation_review intValue];
    n++;
    
    if(n < 0)
        n = 0;
    
    _detailMyInboxReputation.unassessed_reputation_review = _detailMyInboxReputation.viewModel.unassessed_reputation_review = [NSString stringWithFormat:@"%d", n];
}

- (void)refreshView:(id)sender {
    page = 0;
    strUriNext = @"";
    [refreshControl endRefreshing];
    
    isRefreshing = YES;
    [self pressRetryButton];
}

- (void)successInsertReputation:(NSString *)reputationID withState:(NSString *)emoticonState {
    if([_detailMyInboxReputation.reputation_id isEqualToString:reputationID]) {
        [myReviewReputationCell setView:_detailMyInboxReputation.viewModel];
        [myReviewReputationCell isLoadInView:NO withView:myReviewReputationCell.getBtnReview];

        if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            NSString *strMessage = @"";
            if([emoticonState isEqualToString:CReviewScoreBad]) {
                strMessage = [NSString stringWithFormat:@"Saya Tidak Puas"];
            }
            else if([emoticonState isEqualToString:CReviewScoreNeutral]) {
                strMessage = [NSString stringWithFormat:@"Saya Cukup Puas"];
            }
            else if([emoticonState isEqualToString:CReviewScoreGood]) {
                strMessage = [NSString stringWithFormat:@"Saya Puas!"];
            }
            
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[strMessage] delegate:self];
            [stickyAlertView show];
        }
    }
}


- (void)failedInsertReputation:(NSString *)reputationID {
    if([_detailMyInboxReputation.reputation_id isEqualToString:reputationID]) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedInsertReputation] delegate:self];
        [stickyAlertView show];
        
        [myReviewReputationCell isLoadInView:NO withView:myReviewReputationCell.getBtnReview];
    }
}

- (void)doingActInsertReview:(NSString *)reputationID {
    if([_detailMyInboxReputation.reputation_id isEqualToString:reputationID]) {
        [myReviewReputationCell isLoadInView:YES withView:myReviewReputationCell.getBtnReview];
    }
}

- (void)redirectToGiveReviewViewController:(int)tag {
//    GiveReviewViewController *giveReviewViewController = [GiveReviewViewController new];
//    DetailReputationReview *detailReputationReview = arrList[tag];
//    
//    giveReviewViewController.delegate = self;
//    giveReviewViewController.detailReputationView = detailReputationReview;
//    [self.navigationController pushViewController:giveReviewViewController animated:YES];
    
    GiveReviewRatingViewController *vc = [GiveReviewRatingViewController new];
//    vc.detailMyReviewReputation = self;
    DetailReputationReview *detailReputationReview = arrList[tag];
    
    vc.review = detailReputationReview;
    vc.isEdit = isEdit;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reloadTable {
    [tableContent reloadData];
}

- (void)redirectToProductDetailReputationReview:(DetailReputationReview *)detailReputationReview {
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    NSDictionary *auth = [_userManager getUserLoginData];
    
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    productDetailReputationViewController.isFromInboxNotification = YES;
    productDetailReputationViewController.isMyProduct = (auth!=nil && [[NSString stringWithFormat:@"%@", [auth objectForKey:@"user_id"]] isEqualToString:detailReputationReview.product_owner.user_id]);
    productDetailReputationViewController.shopBadgeLevel = detailReputationReview.shop_badge_level;
    productDetailReputationViewController.strProductID = detailReputationReview.product_id;
    productDetailReputationViewController.detailReputationReview = detailReputationReview;
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
    
    if(_detailMyInboxReputation.updated_reputation_review!=nil && ![_detailMyInboxReputation.updated_reputation_review isEqualToString:@""] && ![_detailMyInboxReputation.updated_reputation_review isEqualToString:@"0"]) {
        int n = [_detailMyInboxReputation.updated_reputation_review intValue];
        _detailMyInboxReputation.updated_reputation_review = _detailMyInboxReputation.viewModel.updated_reputation_review = [NSString stringWithFormat:@"%d", --n];
        
        if(n == 0) {
            [myReviewReputationCell setView:_detailMyInboxReputation.viewModel];
        }
    }
}


- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc {
    lblDesc.backgroundColor = [UIColor clearColor];
    lblDesc.textAlignment = NSTextAlignmentLeft;
    lblDesc.font = [UIFont fontWithName:@"Gotham Book" size:13.0f];
    lblDesc.textColor = [UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f];
    lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
    lblDesc.numberOfLines = 0;
}


- (LoadingView *)getLoadView {
    if(loadingView == nil) {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tokopediaNetworkManager == nil) {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    tokopediaNetworkManager.tagRequest = tag;
    
    return tokopediaNetworkManager;
}

- (void)loadMoreData:(BOOL)load {
    if(load) {
        tableContent.tableFooterView = viewFooter;
        [actIndicator startAnimating];
    }
    else {
        tableContent.tableFooterView = nil;
        [actIndicator stopAnimating];
    }
}


#pragma mark - Tokopedia Network Manager
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagListReputationReview) {
        NSMutableDictionary *dictResult = [NSMutableDictionary new];
        
        if(getDataFromMasterInServer) {
            getDataFromMasterInServer = NO;
            [dictResult setObject:@(1) forKey:@"n"];
        }
        
        [dictResult setObject:CGetListReputationReview forKey:@"action"];
        [dictResult setObject:_detailMyInboxReputation.reputation_inbox_id forKey:@"reputation_inbox_id"];
        [dictResult setObject:_detailMyInboxReputation.reputation_id forKey:@"reputation_id"];
        [dictResult setObject:self.autoRead forKey:@"auto_read"];
        
        return dictResult;
    }
    else if(tag == CTagSkipReputationReview)
        return @{@"action":CSkipReputationReview,
                 @"reputation_id":tempDetailReputationReview.reputation_id,
                 @"shop_id":tempDetailReputationReview.shop_id,
                 @"product_id":tempDetailReputationReview.product_id};
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagListReputationReview) {
        return [postUrl isEqualToString:@""] ? @"inbox-reputation.pl" : postUrl;
    }
    else if(tag == CTagSkipReputationReview) {
        return [postActionUrl isEqualToString:@""] ? @"action/reputation.pl" : postActionUrl;
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagListReputationReview) {
        RKObjectManager *objectManager;
        if([baseUrl isEqualToString:kTkpdBaseURLString] || [baseUrl isEqualToString:@""]) {
            objectManager = [RKObjectManager sharedClient];
        } else {
            objectManager = [RKObjectManager sharedClient:baseUrl];
        }
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[MyReviewReputation class]];
        [statusMapping addAttributeMappingsFromDictionary:@{CStatus:CStatus,
                                                            CMessageError:CMessageError,
                                                            CMessageStatus:CMessageStatus,
                                                            CServerProcessTime:CServerProcessTime}];
        
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[MyReviewReputationResult class]];
        RKObjectMapping *detailReputationMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
        [detailReputationMapping addAttributeMappingsFromArray:@[CShopID,
                                                                 CProductRatingPoint,
                                                                 CReviewIsSkipable,
                                                                 CReviewIsSkiped,
                                                                 CProductStatus,
                                                                 CReviewFullName,
                                                                 CReviewMessage,
                                                                 CProductSpeedDesc,
                                                                 CReviewReadStatus,
                                                                 CProductUri,
                                                                 CReviewUserID,
                                                                 CReviewUserLabel,
                                                                 CProductServiceDesc,
                                                                 CProductSpeedPoint,
                                                                 CReviewStatus,
                                                                 CReviewUpdateTime,
                                                                 CProductServicePoint,
                                                                 CProductAccuracyPoint,
                                                                 CReputationID,
                                                                 CProductID,
                                                                 CProductRatingDesc,
                                                                 CProductImage,
                                                                 CProductAccuracyDesc,
                                                                 CUserImage,
                                                                 CReputationInboxID,
                                                                 CReviewCreateTime,
                                                                 CUserURL,
                                                                 CShopName,
                                                                 CReviewMessageEdit,
                                                                 CReviewID,
                                                                 CReviewPostTime,
                                                                 CReviewIsAllowEdit,
                                                                 CProductName,
                                                                 CShopDomain
                                                                 ]];
        
        RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
        [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
        
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{CUriNext:CUriNext,
                                                            CUriPrevious:CUriPrevious}];
        
        RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
        [reviewUserReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                     CNoReputation,
                                                                     CNegative,
                                                                     CNeutral,
                                                                     CPositif]];
        
        
        RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
        [productOwnerMapping addAttributeMappingsFromArray:@[CShopID,
                                                             CUserLabelID,
                                                             CUserURL,
                                                             CShopImg,
                                                             CShopUrl,
                                                             CShopName,
                                                             CFullName,
                                                             CShopReputation,
                                                             CUserImg,
                                                             CUserLabel,
                                                             CuserID
                                                             ]];
        
        
        RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
        [reviewResponseMapping addAttributeMappingsFromDictionary:@{CResponseMessage:CResponseMessage,
                                                                    CResponseCreateTime:CResponseCreateTime,
                                                                    CResponseTimeFmt:CResponseTimeFmt}];
        
        
        //relation
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopBadgeLevel toKeyPath:CShopBadgeLevel withMapping:shopBadgeMapping]];
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:reviewUserReputationMapping]];
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CProductOwner toKeyPath:CProductOwner withMapping:productOwnerMapping]];
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewResponse toKeyPath:CReviewResponse withMapping:reviewResponseMapping]];
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CList toKeyPath:CList withMapping:detailReputationMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CPaging toKeyPath:CPaging withMapping:pagingMapping]];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    else if(tag == CTagSkipReputationReview) {
        RKObjectManager *objectManager;
        if([baseActionUrl isEqualToString:kTkpdBaseURLString] || [baseActionUrl isEqualToString:@""]) {
            objectManager = [RKObjectManager sharedClient];
        } else {
            objectManager = [RKObjectManager sharedClient:baseActionUrl];
        }
        
        
        RKObjectMapping *skipReviewMapping = [RKObjectMapping mappingForClass:[SkipReview class]];
        [skipReviewMapping addAttributeMappingsFromArray:@[CStatus,
                                                          CServerProcessTime,
                                                          CMessageError,
                                                          CMessageStatus]];
        
        RKObjectMapping *skipReviewResultMapping = [RKObjectMapping mappingForClass:[SkipReviewResult class]];
        [skipReviewResultMapping addAttributeMappingsFromArray:@[CReputationReviewCounter, CIsSuccess, CShowBookmark]];
        
        //Add Relation
        [skipReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CResult toKeyPath:CResult withMapping:skipReviewResultMapping]];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:skipReviewMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagListReputationReview) {
        MyReviewReputation *reviewReputationn = (MyReviewReputation *)stat;
        return reviewReputationn.status;
    }
    else if(tag == CTagSkipReputationReview) {
        SkipReview *skipReview = (SkipReview *)stat;
        return skipReview.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagListReputationReview) {
        MyReviewReputation *result = (MyReviewReputation *)stat;
        if(page == 0) {
            isRefreshing = NO;
            arrList = [[NSMutableArray alloc] initWithArray:result.result.list];
        }
        else {
            [arrList addObjectsFromArray:result.result.list];
        }
        
        strUriNext = result.result.paging.uri_next;
        page = [[[self getNetworkManager:tag] splitUriToPage:strUriNext] intValue];
        
        
        //Check any data or not
        if(arrList.count == 0) {
            [self loadMoreData:NO];
            [self setUIAllReviewSkipable];
        }
        else {
            if(page == 0)
                [self setUIAllReviewNotSkipable];
            [self loadMoreData:NO];
        }
        if(tableContent.delegate == nil) {
            tableContent.delegate = self;
            tableContent.dataSource = self;
        }
        [tableContent reloadData];
    }
    else if(tag == CTagSkipReputationReview) {
//        [self blockUI:NO];
        tempDetailReputationReview = nil;
        
        StickyAlertView *stickyAlertView;
        SkipReview *skipReview = (SkipReview *)stat;
        if(skipReview.result.is_success!=nil && [skipReview.result.is_success isEqualToString:@"1"]) {
            stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessLewatiReview] delegate:self];
            [stickyAlertView show];
            
            //Load Data again
            page = 0;
            strUriNext = @"";
            [arrList removeAllObjects];
            [tableContent reloadData];
            
            _detailMyInboxReputation.unassessed_reputation_review = _detailMyInboxReputation.viewModel.unassessed_reputation_review = [NSString stringWithFormat:@"%d", [_detailMyInboxReputation.unassessed_reputation_review intValue]-1];
            getDataFromMasterInServer = YES;
            [self loadMoreData:YES];
            [[self getNetworkManager:CTagListReputationReview] doRequest];
        }
        else {
            stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:((skipReview.message_error!=nil && skipReview.message_error.count>0)?skipReview.message_error:@[CStringGagalLewatiReview]) delegate:self];
            [stickyAlertView show];
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    if(tag == CTagListReputationReview) {
        
    }
}

- (void)actionBeforeRequest:(int)tag {
}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag == CTagListReputationReview) {
        if(page == 0)
            isRefreshing = NO;
        tableContent.tableFooterView = [self getLoadView].view;
    }
    else if(tag == CTagSkipReputationReview) {
//        [self blockUI:NO];
        tempDetailReputationReview = nil;
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringGagalLewatiReview] delegate:self];
        [stickyAlertView show];
    }
}

#pragma mark - Loading View Delegate
- (void)pressRetryButton
{
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagListReputationReview] doRequest];
}


#pragma mark - DetailMyReviewReputationCell Delegate
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription {
    NSString *strLihatSelengkapnya = @"Lihat Selengkapnya";
    strDescription = [NSString convertHTML:strDescription];
    
    if(strDescription.length > 100) {
        strDescription = [NSString stringWithFormat:@"%@... %@", [strDescription substringToIndex:100], strLihatSelengkapnya];
        
        NSRange range = [strDescription rangeOfString:strLihatSelengkapnya];
        lblDesc.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        lblDesc.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor lightGrayColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        lblDesc.linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:78/255.0f green:134/255.0f blue:38/255.0f alpha:1.0f] range:NSMakeRange(strDescription.length-strLihatSelengkapnya.length, strLihatSelengkapnya.length)];
        [str addAttribute:NSFontAttributeName value:lblDesc.font range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        lblDesc.delegate = self;
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

- (void)actionBeriReview:(id)sender
{
    if(isRefreshing)
        return;
    
    DetailReputationReview *detailReputationReview = arrList[(int)((UIButton *) sender).tag];
    if(! ((detailReputationReview.viewModel.review_message==nil || [detailReputationReview.viewModel.review_message isEqualToString:@"0"]) && [_detailMyInboxReputation.role isEqualToString:@"1"])) {
        [self tableView:tableContent didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:(int)((UIButton *) sender).tag inSection:0]];
    }
    else
        [self redirectToGiveReviewViewController:(int)((UIButton *) sender).tag];
}

- (void)actionProduct:(id)sender {
    if(isRefreshing)
        return;
    
    DetailReputationReview *detailReputationReview = arrList[((UIButton *) sender).tag];

    [_TKPDNavigator navigateToProductFromViewController:self withName:detailReputationReview.product_name withPrice:nil withId:detailReputationReview.product_id withImageurl:detailReputationReview.product_image withShopName:detailReputationReview.shop_name];
}

- (void)actionUbah:(id)sender {
    if(isRefreshing)
        return;
    
    if(((CustomBtnSkip *) sender).isLewati) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Apakah anda yakin melewati ulasan ini?" delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya", nil];
        alertView.tag = CTagSkipReputationReview;
        [alertView show];
        tempTagSkip = (int)((UIButton *) sender).tag;
    }
    else if(((CustomBtnSkip *) sender).isLapor) {
        ReportViewController *reportViewController = [ReportViewController new];
        DetailReputationReview *detailReputationReview = arrList[((UIButton *) sender).tag];

        reportViewController.delegate = self;
        reportViewController.strProductID = detailReputationReview.product_id;
        reportViewController.strShopID = detailReputationReview.shop_id;
        reportViewController.strReviewID = detailReputationReview.review_id;
        [self.navigationController pushViewController:reportViewController animated:YES];
    }
    else {
        isEdit = YES;
        [self redirectToGiveReviewViewController:(int)((UIButton *) sender).tag];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if(isRefreshing)
        return;
    DetailReputationReview *detailReputationReview = arrList[label.tag];
    [self redirectToProductDetailReputationReview:detailReputationReview];
}

- (void)goToImageViewerImages:(NSArray *)images atIndexImage:(NSInteger)index atIndexPath:(NSIndexPath *)indexPath {
    [_TKPDNavigator navigateToShowImageFromViewController:self withImageDictionaries:images imageDescriptions:@[] indexImage:index];
}


#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == CTagSkipReputationReview) {
        if(buttonIndex == 1) {
            tempDetailReputationReview = arrList[tempTagSkip];
            tempTagSkip = -1;
            [tokopediaNetworkManager requestCancel];
            [self loadMoreData:NO];
//            [self blockUI:YES];
            [[self getNetworkManager:CTagSkipReputationReview] doRequest];
        }
        else {
            tempDetailReputationReview = nil;
            tempTagSkip = -1;
        }
    }
}


#pragma mark - ReportView Delegate
- (NSString *)getPath
{
    return @"action/review.pl";
}

- (NSDictionary *)getParameter {
    return nil;
}

- (UIViewController *)didReceiveViewController {
    return self;
}

#pragma mark - MyReviewReputationCell delegate
- (void)actionInvoice:(id)sender {
    if(_detailMyInboxReputation.invoice_uri!=nil && _detailMyInboxReputation.invoice_uri.length>0) {
        [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:_detailMyInboxReputation.invoice_uri];
    }
}

- (void)actionReputasi:(id)sender {
    if(((UIButton *) sender).titleLabel.text.length == 0) { //Badge
        
        NSString *strText = [NSString stringWithFormat:@"%@ %@", _detailMyInboxReputation.reputation_score, CStringPoin];
        [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
    }
    else {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:_detailMyInboxReputation.user_reputation.neutral withRepSmile:_detailMyInboxReputation.user_reputation.positive withRepSad:_detailMyInboxReputation.user_reputation.negative withDelegate:self];
        
        //Init pop up
        cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
        cmPopTitpView.delegate = self;
        cmPopTitpView.backgroundColor = [UIColor whiteColor];
        cmPopTitpView.animation = CMPopTipAnimationSlide;
        cmPopTitpView.dismissTapAnywhere = YES;
        cmPopTitpView.leftPopUp = YES;
        
        UIButton *button = (UIButton *)sender;
        [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
    }
}

- (void)actionFooter:(id)sender {
}

- (void)actionReviewRate:(id)sender {
    if([_detailMyInboxReputation.reputation_progress isEqualToString:@"2"]) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Mohon maaf penilaian ini telah dikunci, Anda telah melewati batas waktu penilaian."] delegate:self];
        [stickyAlertView show];
        return;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController *navMaster = [((SplitReputationViewController *) self.parentViewController.parentViewController.nextResponder.nextResponder) getMasterNavigation];
        if([[navMaster.viewControllers firstObject] isMemberOfClass:[SegmentedReviewReputationViewController class]]) {
            UIView *tempView = [UIView new];
            tempView.tag = _tag;
            [((MyReviewReputationViewController *)[((SegmentedReviewReputationViewController *) [navMaster.viewControllers firstObject]) getSegmentedViewController]) actionReviewRate:tempView];
        }
    }
    else {
        UIViewController *tempViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        if([tempViewController isMemberOfClass:[SegmentedReviewReputationViewController class]]) {
            UIView *tempView = [UIView new];
            tempView.tag = _tag;
            [((MyReviewReputationViewController *)[((SegmentedReviewReputationViewController *) tempViewController) getSegmentedViewController]) actionReviewRate:tempView];
        }
        
    //    [myReviewReputationCell isLoadInView:NO withView:myReviewReputationCell.getBtnReview];
    }
}

- (void)actionLabelUser:(id)sender {
    if([_detailMyInboxReputation.role isEqualToString:@"2"]) {//2 is seller
        UserContainerViewController *container = [UserContainerViewController new];
        UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
        NSDictionary *auth = [_userManager getUserLoginData];
        
        if(_detailMyInboxReputation.reviewee_uri!=nil && _detailMyInboxReputation.reviewee_uri.length>0) {
            NSArray *arrUri = [_detailMyInboxReputation.reviewee_uri componentsSeparatedByString:@"/"];
            container.data = @{
                               @"user_id" : [arrUri lastObject],
                               @"auth" : auth?:[NSNull null]
                               };
            [self.navigationController pushViewController:container animated:YES];
        }
    }
    else {
        ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
        TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
        NSDictionary *auth = [secureStorage keychainDictionary];
        
        container.data = @{kTKPDDETAIL_APISHOPIDKEY:_detailMyInboxReputation.shop_id,
                           kTKPD_AUTHKEY:auth?:[NSNull null]};
        [self.navigationController pushViewController:container animated:YES];
    }
}

- (void)onReputationIconTapped:(void(^)()) callback {
    _reputationIconTapCallback = callback;
}

- (void)actionFlagReview:(id)sender {
    _reputationIconTapCallback();
}


#pragma mark - GTM
- (void)configureGTM {
    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    baseUrl = [_gtmContainer stringForKey:GTMKeyInboxReputationBase];
    postUrl = [_gtmContainer stringForKey:GTMKeyInboxReputationPost];
    
    baseActionUrl = [_gtmContainer stringForKey:GTMKeyInboxActionReputationBase];
    postActionUrl = [_gtmContainer stringForKey:GTMKeyInboxActionReputationPost];
}


#pragma mark - CMPopTipView Delegate
- (void)dismissAllPopTipViews
{
    [cmPopTitpView dismissAnimated:YES];
    cmPopTitpView = nil;
}


- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}

#pragma mark - Smiley Delegate
- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}


@end
