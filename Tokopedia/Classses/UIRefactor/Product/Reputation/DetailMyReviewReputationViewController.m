//
//  DetailMyReviewReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "detail.h"
#import "DetailProductViewController.h"
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
#import "NoResultView.h"
#import "ProductDetailReputationViewController.h"
#import "Paging.h"
#import "ReportViewController.h"
#import "ShopContainerViewController.h"
#import "SegmentedReviewReputationViewController.h"
#import "SkipReview.h"
#import "String_Reputation.h"
#import "SkipReviewResult.h"
#import "TokopediaNetworkManager.h"
#import "ViewLabelUser.h"
#import "WebViewController.h"

#define CCellIdentifier @"cell"
#define CGetListReputationReview @"get_list_reputation_review"
#define CSkipReputationReview @"skip_reputation_review"
#define CStringGagalLewatiReview @"Gagal lewati review"
#define CStringSuccessLewatiReview @"Berhasil lewati review"
#define CTagListReputationReview 1
#define CTagSkipReputationReview 2

@interface DetailMyReviewReputationViewController ()<TokopediaNetworkManagerDelegate, LoadingViewDelegate, detailMyReviewReputationCell, UIAlertViewDelegate, ReportViewControllerDelegate, MyReviewReputationDelegate>

@end

@implementation DetailMyReviewReputationViewController
{
    NSMutableArray *arrList;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSString *strUriNext;
    int page, tempTagSkip;
    NSMutableParagraphStyle *style;
    
    UIView *shadowBlockUI;
    UIActivityIndicatorView *activityIndicator;
    MyReviewReputationCell *myReviewReputationCell;
    DetailReputationReview *tempDetailReputationReview;
    LoadingView *loadingView;
    NoResultView *noResultView;
}

- (void)dealloc {
    tokopediaNetworkManager.delegate = nil;
    [tokopediaNetworkManager requestCancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    page = 0;
    tempTagSkip = -1;
    
    [self initTable];
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagListReputationReview] doRequest];
    
    style = [NSMutableParagraphStyle new];
    style.lineSpacing = 4.0f;
    tableContent.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    arrList = [[NSMutableArray alloc] init];
    
    tableContent.delegate = self;
    tableContent.dataSource = self;
    [tableContent reloadData];
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
        cell.delegate = self;
        [self setPropertyLabelDesc:cell.getLabelDesc];
    }
    
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    cell.getLabelDesc.tag = indexPath.row;
    cell.getBtnKomentar.tag = indexPath.row;
    cell.getBtnUbah.tag = indexPath.row;
    cell.strRole = _detailMyInboxReputation.role;
    [cell setView:detailReputationReview.viewModel];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    int height = 0;
    
    if(detailReputationReview.review_message!=nil && detailReputationReview.review_message.length>0 && ![detailReputationReview.review_message isEqualToString:@"0"]) {
        height = CHeightContentStar;
    }
    
    TTTAttributedLabel *tempLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-(CPaddingTopBottom*4), 0)];
    [self setPropertyLabelDesc:tempLabel];
    [self initLabelDesc:tempLabel withText:detailReputationReview.viewModel.review_message];
    CGSize tempSizeDesc = [tempLabel sizeThatFits:CGSizeMake(tempLabel.bounds.size.width, 9999)];
    return (CPaddingTopBottom*5) + height + CHeightContentAction + CDiameterImage + tempSizeDesc.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    if(detailReputationReview.viewModel==nil || detailReputationReview.viewModel.review_message==nil || [detailReputationReview.viewModel.review_message isEqualToString:@"0"]) {
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
    [myReviewReputationCell setLeftViewContentContraint:0];
    [myReviewReputationCell setRightViewContentContraint:0];
    [myReviewReputationCell setTopViewContentContraint:0];
    [myReviewReputationCell setBottomViewContentContraint:0];
    [myReviewReputationCell setView:_detailMyInboxReputation.viewModel];
    [myReviewReputationCell.getBtnFooter removeFromSuperview];
    
    CGRect tempRect = myReviewReputationCell.contentView.frame;
    tempRect.size.height -= (myReviewReputationCell.getBtnFooter.bounds.size.height+topConstraint+topConstraint);
    myReviewReputationCell.contentView.frame = tempRect;
    tableContent.tableHeaderView = myReviewReputationCell.contentView;
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
- (void)successInsertReputation:(NSString *)reputationID withState:(NSString *)emoticonState {
    if([_detailMyInboxReputation.reputation_id isEqualToString:reputationID]) {
        [myReviewReputationCell setView:_detailMyInboxReputation.viewModel];
        [myReviewReputationCell isLoadInView:NO withView:myReviewReputationCell.getBtnReview];

        NSString *strMessage = @"";
        if([emoticonState isEqualToString:CRevieweeScroreBad]) {
            strMessage = [NSString stringWithFormat:@"Saya Tidak Puas"];
        }
        else if([emoticonState isEqualToString:CRevieweeScroreNetral]) {
            strMessage = [NSString stringWithFormat:@"Saya Cukup Puas"];
        }
        else if([emoticonState isEqualToString:CRevieweeScroreGood]) {
            strMessage = [NSString stringWithFormat:@"Saya Puas!"];
        }

        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[strMessage] delegate:self];
        [stickyAlertView show];
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
    GiveReviewViewController *giveReviewViewController = [GiveReviewViewController new];
    DetailReputationReview *detailReputationReview = arrList[tag];
    
    giveReviewViewController.delegate = self;
    giveReviewViewController.detailReputationView = detailReputationReview;
    [self.navigationController pushViewController:giveReviewViewController animated:YES];
}

- (void)reloadTable {
    [tableContent reloadData];
}

- (void)redirectToProductDetailReputationReview:(DetailReputationReview *)detailReputationReview {
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    NSDictionary *auth = [_userManager getUserLoginData];
    
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    productDetailReputationViewController.isMyProduct = (auth!=nil && [[NSString stringWithFormat:@"%@", [auth objectForKey:@"user_id"]] isEqualToString:detailReputationReview.product_owner.user_id]);
    productDetailReputationViewController.detailReputaitonReview = detailReputationReview;
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}


- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc {
    lblDesc.backgroundColor = [UIColor clearColor];
    lblDesc.textAlignment = NSTextAlignmentLeft;
    lblDesc.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
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
        return @{@"action":CGetListReputationReview,
                 @"reputation_id":_detailMyInboxReputation.reputation_id};
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
        return @"inbox-reputation.pl";
    }
    else if(tag == CTagSkipReputationReview) {
        return @"action/reputation.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagListReputationReview) {
        RKObjectManager *objectManager = [RKObjectManager sharedClient];
        
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
                                                                 CProductStatus,
                                                                 CReviewFullName,
                                                                 CReviewMessage,
                                                                 CProductSpeedDesc,
                                                                 CReviewReadStatus,
                                                                 CProductUri,
                                                                 CReviewUserID,
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
        
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{CUriNext:CUriNext,
                                                            CUriPrevious:CUriPrevious}];
        
        RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
        [reviewUserReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
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
        RKObjectManager *objectManager = [RKObjectManager sharedClient];
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
            arrList = [[NSMutableArray alloc] initWithArray:result.result.list];
        }
        else {
            [arrList addObjectsFromArray:result.result.list];
        }
        
        strUriNext = result.result.paging.uri_next;
        page = [[[self getNetworkManager:tag] splitUriToPage:strUriNext] intValue];
        
        
        //Check any data or not
        if(arrList.count == 0) {
            if(noResultView == nil) {
                noResultView = [NoResultView new];
            }
            
            tableContent.tableFooterView = noResultView.view;
        }
        else
            [self loadMoreData:NO];
        if(tableContent.delegate == nil) {
            tableContent.delegate = self;
            tableContent.dataSource = self;
        }
        [tableContent reloadData];
    }
    else if(tag == CTagSkipReputationReview) {
        [self blockUI:NO];
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
        tableContent.tableFooterView = [self getLoadView].view;
    }
    else if(tag == CTagSkipReputationReview) {
        [self blockUI:NO];
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
    if(strDescription.length > 100) {
        strDescription = [NSString stringWithFormat:@"%@... %@", [strDescription substringToIndex:100], strLihatSelengkapnya];
        
        NSRange range = [strDescription rangeOfString:strLihatSelengkapnya];
        lblDesc.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        lblDesc.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor lightGrayColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        lblDesc.linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:range];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:78/255.0f green:134/255.0f blue:38/255.0f alpha:1.0f] range:NSMakeRange(strDescription.length-strLihatSelengkapnya.length, strLihatSelengkapnya.length)];
        lblDesc.attributedText = str;
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        lblDesc.delegate = nil;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
    }
}

- (void)actionBeriReview:(id)sender
{
    [self redirectToGiveReviewViewController:(int)((UIButton *) sender).tag];
}

- (void)actionProduct:(id)sender {
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    DetailReputationReview *detailReputationReview = arrList[((UIButton *) sender).tag];
    
    DetailProductViewController *detailProductViewController = [DetailProductViewController new];
    detailProductViewController.data = @{@"product_id" : detailReputationReview.product_id, kTKPD_AUTHKEY:auth?:[NSNull null]};
    [self.navigationController pushViewController:detailProductViewController animated:YES];
}

- (void)actionUbah:(id)sender {
    if(((CustomBtnSkip *) sender).isLewati) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Apakah anda yakin melewati review ini?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
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
        [self redirectToGiveReviewViewController:(int)((UIButton *) sender).tag];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    DetailReputationReview *detailReputationReview = arrList[label.tag];
    [self redirectToProductDetailReputationReview:detailReputationReview];
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
            [self blockUI:YES];
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

#pragma mark - MyReviewReputationCell delegate
- (void)actionInvoice:(id)sender {
    if(_detailMyInboxReputation.invoice_uri!=nil && _detailMyInboxReputation.invoice_uri.length>0) {
        WebViewController *webViewController = [WebViewController new];
        webViewController.strURL = _detailMyInboxReputation.invoice_uri;
        webViewController.strTitle = @"";
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)actionFooter:(id)sender {
}

- (void)actionReviewRate:(id)sender {
    UIViewController *tempViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    if([tempViewController isMemberOfClass:[SegmentedReviewReputationViewController class]]) {
        UIView *tempView = [UIView new];
        tempView.tag = _tag;
        [((MyReviewReputationViewController *)[((SegmentedReviewReputationViewController *) tempViewController) getSegmentedViewController]) actionReviewRate:tempView];
    }
    
//    [myReviewReputationCell isLoadInView:NO withView:myReviewReputationCell.getBtnReview];

}

- (void)actionLabelUser:(id)sender {
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    container.data = @{kTKPDDETAIL_APISHOPIDKEY:_detailMyInboxReputation.shop_id,
                       kTKPD_AUTHKEY:auth?:[NSNull null]};
    [self.navigationController pushViewController:container animated:YES];
}

- (void)actionFlagReview:(id)sender {
    
}
@end
