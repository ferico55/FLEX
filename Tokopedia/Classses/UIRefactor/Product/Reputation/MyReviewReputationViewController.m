//
//  MyReviewReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "AlertRateView.h"
#import "CMPopTipView.h"
#import "detail.h"
#import "DetailMyReviewReputationViewController.h"
#import "DetailMyInboxReputation.h"
#import "GeneralAction.h"
#import "LoadingView.h"
#import "Paging.h"
#import "SegmentedReviewReputationViewController.h"
#import "MyReviewReputation.h"
#import "MyReviewReputationCell.h"
#import "MyReviewReputationViewModel.h"
#import "MyReviewReputationViewController.h"
#import "NavigateViewController.h"
#import "SplitReputationViewController.h"
#import "string_inbox_message.h"
#import "SmileyAndMedal.h"
#import "String_Reputation.h"
#import "ShopBadgeLevel.h"
#import "ShopContainerViewController.h"
#import "TokopediaNetworkManager.h"
#import "UserContainerViewController.h"
#import "ViewLabelUser.h"
#import "WebViewInvoiceViewController.h"
#import "NoResultReusableView.h"
#import "RequestLDExtension.h"
#import "NavigateViewController.h"
#import "NavigationHelper.h"

#define CFailedGetData @"Proses ambil data gagal"
#define CCellIndetifier @"cell"
#define CActionGetInboxReputation @"get_inbox_reputation"
#define CTagGetInboxReputation 1
#define CTagInsertReputation 2


@interface MyReviewReputationViewController ()<TokopediaNetworkManagerDelegate, LoadingViewDelegate, MyReviewReputationDelegate, AlertRateDelegate, CMPopTipViewDelegate, SmileyDelegate, NoResultDelegate, requestLDExttensionDelegate>
@end

@implementation MyReviewReputationViewController
{
    AlertRateView *alertRateView;
    NoResultReusableView *_noResultView;
    CMPopTipView *cmPopTitpView;
    LoadingView *loadingView;
    NSMutableArray *arrList;
    NSString *strRequestingInsertReputation;
    TokopediaNetworkManager *tokopediaNetworkManager, *tokopediaNetworkInsertReputation;
    NSString *emoticonState, *strInsertReputationRole;
    
    NSString *givenSmileyImageString;
    int page;
    BOOL isRefreshing;
    BOOL hasShownData;
    NSString *strUriNext;
    NSIndexPath *indexPathInsertReputation;
    NSString *currentFilter;
    UIRefreshControl *refreshControl;
    
    //GTM
    TAGContainer *_gtmContainer;
    NSString *baseUrl, *baseActionUrl;
    NSString *postUrl, *postActionUrl;
    
    RequestLDExtension *_requestLD;
    NavigateViewController *_navigate;
}
@synthesize strNav;

- (void)dealloc
{
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
    
    [tokopediaNetworkInsertReputation requestCancel];
    tokopediaNetworkInsertReputation.delegate = nil;
    tokopediaNetworkInsertReputation = nil;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Belum ada ulasan"
                                  desc:@""
                              btnTitle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureGTM];
    _navigate = [NavigateViewController new];
    currentFilter = @"all";
    page = 0;
    tableContent.allowsSelection = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    tableContent.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [tableContent addSubview:refreshControl];
    [self initNoResultView];
    
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagGetInboxReputation] doRequest];
    
//    LuckyDeal *ld = [LuckyDeal new];
//    LuckyDealAttributes *att = [LuckyDealAttributes new];
//    LuckyDealData *data = [LuckyDealData new];
//    att.token = @"Tokopedia Clover:q62yPVXnFRbDr9jh9wdBFhjU/DA=";
//    att.extid = 1;
//    att.code = 12400877;
//    att.ut = 1448420536;
//    data.ld_id = 1299609;
//    data.type = 1;
//    data.attributes = att;
//    ld.data = data;
//    ld.url =@"https://clover-staging.tokopedia.com/badge/member/extend/v1";
//
//
////TODO:: REMOVE THIS
//    _requestLD = [RequestLDExtension new];
//    _requestLD.delegate = self;
//    _requestLD.luckyDeal = ld;
//    [_requestLD doRequestMemberExtendURLString:ld.url];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [tableContent reloadData];
    
    if(arrList.count > 0){
        UITableViewCell *firstCell = [tableContent cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [firstCell setSelected:YES];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Method
- (void)showAlertAfterGiveRate {
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

- (void)alertWarningReviewSmiley {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Anda hanya bisa mengubah nilai reputasi menjadi lebih baik." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
    indexPathInsertReputation = nil;
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
    cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    cmPopTitpView.delegate = self;
    cmPopTitpView.backgroundColor = [UIColor blackColor];
    cmPopTitpView.animation = CMPopTipAnimationSlide;
    cmPopTitpView.dismissTapAnywhere = YES;
    cmPopTitpView.leftPopUp = YES;
    
    UIButton *button = (UIButton *)sender;
    [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
}

- (void)refreshView:(id)sender {
    page = 0;
    strUriNext = @"";
    [refreshControl endRefreshing];
    
    isRefreshing = YES;
    [self pressRetryButton];
}

- (void)loadMoreData:(BOOL)load {
    if(load) {
        tableContent.tableFooterView = viewFooter;
        [activityIndicator startAnimating];
    }
    else {
        tableContent.tableFooterView = nil;
        [activityIndicator stopAnimating];
    }
}

- (LoadingView *)getLoadView {
    if(loadingView == nil) {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagGetInboxReputation) {
        if(tokopediaNetworkManager == nil) {
            tokopediaNetworkManager = [TokopediaNetworkManager new];
            tokopediaNetworkManager.tagRequest = tag;
            tokopediaNetworkManager.delegate = self;
        }

        return tokopediaNetworkManager;
    }
    else if(tag == CTagInsertReputation) {
        if(tokopediaNetworkInsertReputation == nil) {
            tokopediaNetworkInsertReputation = [TokopediaNetworkManager new];
            tokopediaNetworkInsertReputation.tagRequest = tag;
            tokopediaNetworkInsertReputation.delegate = self;
        }
        
        return tokopediaNetworkInsertReputation;
    }
    
    return nil;
}


#pragma mark - UITableView Delegate and DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(arrList!=nil && arrList.count-1 == indexPath.row) {
        if (strUriNext!=nil && ![strUriNext isEqualToString:@"0"]) {
            [self loadMoreData:YES];
            [[self getNetworkManager:CTagGetInboxReputation] doRequest];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyReviewReputationCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIndetifier];
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyReviewReputationCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.delegate = self;
        cell.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    }
    
    cell.getBtnFooter.tag = indexPath.row;
    cell.getBtnInvoice.tag = indexPath.row;
    cell.getBtnReview.tag = indexPath.row;
    cell.getLabelUser.tag = indexPath.row;
    cell.getImageFlagReview.tag = indexPath.row;
    cell.getBtnReputation.tag = indexPath.row;
    DetailMyInboxReputation *tempReputation = arrList[indexPath.row];

    //Check is request give rating or not
    if(strRequestingInsertReputation!=nil && [strRequestingInsertReputation isEqualToString:tempReputation.reputation_id]) {
        [cell isLoadInView:YES withView:cell.getBtnReview];
    }
    else {
        [cell isLoadInView:NO withView:cell.getBtnReview];
    }
    
    [cell setView:tempReputation.viewModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: refactor this nasty hack
    UITableViewCell *firstCell = [tableContent cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [firstCell setSelected:NO];
    }
    
    MyReviewReputationCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [cell setSelected:YES];
    }
    
    [self actionFooter:cell.getBtnFooter];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagGetInboxReputation) {
        NSMutableDictionary *dictParam = [NSMutableDictionary new];
        if(_getDataFromMasterDB) {
            _getDataFromMasterDB = NO;
            [dictParam setObject:@(1) forKey:@"n"];
        }
        
        [dictParam setObject:CActionGetInboxReputation forKey:@"action"];
        [dictParam setObject:strNav forKey:@"nav"];
        [dictParam setObject:@(page) forKey:@"page"];
        [dictParam setObject:_segmentedReviewReputationViewController.getSelectedFilter forKey:@"filter"];
        
        return dictParam;
    }
    else if(tag == CTagInsertReputation) {
        return @{@"action" : CInsertReputation,
                 @"reputation_score" : emoticonState,
                 @"reputation_id" : strRequestingInsertReputation,
                 @"buyer_seller" : strInsertReputationRole};
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagGetInboxReputation) {
        return [postUrl isEqualToString:@""] ? @"inbox-reputation.pl" : postUrl;
    }
    else if(tag == CTagInsertReputation) {
        return [postActionUrl isEqualToString:@""] ? @"action/reputation.pl" : postActionUrl;
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagGetInboxReputation) {
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
        RKObjectMapping *detailReputationMapping = [RKObjectMapping mappingForClass:[DetailMyInboxReputation class]];
        [detailReputationMapping addAttributeMappingsFromArray:@[CUpdatedReputationReview,
                                                                 CReputationInboxID,
                                                                 CReputationScore,
                                                                 CScoreEditTimeFmt,
                                                                 CRevieweeScoreStatus,
                                                                 CShopID,
                                                                 CShowBookmark,
                                                                 CBuyerScrore,
                                                                 CRevieweePicture,
                                                                 CRevieweeName,
                                                                 CCreateTimeFmt,
                                                                 CReputationID,
                                                                 CRevieweeUri,
                                                                 CRevieweeScore,
                                                                 CSellerScore,
                                                                 CInboxID,
                                                                 CInvoiceRefNum,
                                                                 CInvoiceUri,
                                                                 CReadStatus,
                                                                 CCreateTimeAgo,
                                                                 CRevieweeRole,
                                                                 COrderID,
                                                                 @"auto_read",
                                                                 @"reputation_progress",
                                                                 @"my_score_image",
                                                                 @"their_score_image",
                                                                 CUnaccessedReputationReview,
                                                                 CShowRevieweeSCore,
                                                                 CRole]];
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{CUriNext:CUriNext,
                                                            CUriPrevious:CUriPrevious}];
 
        RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
        [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
        
        RKObjectMapping *reputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
        [reputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                     CNegative,
                                                                     CNeutral,
                                                                     CPositif]];
        //relation
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopBadgeLevel toKeyPath:CShopBadgeLevel withMapping:shopBadgeMapping]];
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CUserReputation toKeyPath:CUserReputation withMapping:reputationMapping]];
        
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CList toKeyPath:CList withMapping:detailReputationMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CPaging toKeyPath:CPaging withMapping:pagingMapping]];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    else if(tag == CTagInsertReputation) {
        RKObjectManager *objectManager;
        if([baseActionUrl isEqualToString:kTkpdBaseURLString] || [baseActionUrl isEqualToString:@""]) {
            objectManager = [RKObjectManager sharedClient];
        } else {
            objectManager = [RKObjectManager sharedClient:baseActionUrl];
        }

        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        RKRelationshipMapping *LDRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"ld" toKeyPath:@"ld" withMapping:[LuckyDeal mapping]];
        [resultMapping addPropertyMapping:LDRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagGetInboxReputation) {
        MyReviewReputation *action = stat;
        return action.status;
    }
    else if(tag == CTagInsertReputation) {
        GeneralAction *action = stat;
        return action.status;
    }

    return nil;
}


- (void)showFirstDataOnFirstShowInIpad {
    if (arrList.count && !hasShownData && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        hasShownData = YES;
        MyReviewReputationCell* cell = [tableContent cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self actionFooter:cell.getBtnFooter];
    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagGetInboxReputation) {
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
            if([currentFilter isEqualToString:@"all"]){
                if([strNav isEqualToString:@"inbox-reputation-my-product"]){
                    [_noResultView setNoResultTitle:@"Belum ada ulasan"];
                }else if([strNav isEqualToString:@"inbox-reputation-my-review"]){
                    [_noResultView setNoResultTitle:@"Anda belum memberikan ulasan pada produk apapun"];
                }else{
                    [_noResultView setNoResultTitle:@"Belum ada ulasan"];
                }
            }else if([currentFilter isEqualToString:@"not-read"]){
                [_noResultView setNoResultTitle:@"Anda sudah membaca semua ulasan"];
            }else if([currentFilter isEqualToString:@"not-review"]){
                [_noResultView setNoResultTitle:@"Anda sudah memberikan ulasan"];
            }
            tableContent.tableFooterView = _noResultView;
        }
        else{
            [self loadMoreData:NO];
            [_noResultView removeFromSuperview];
        }
        if(tableContent.delegate == nil) {
            tableContent.delegate = self;
            tableContent.dataSource = self;
        }
        
        [self showFirstDataOnFirstShowInIpad];
        
        [tableContent reloadData];
        
        UITableViewCell *firstCell = [tableContent cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [firstCell setSelected:YES];
    }
    else if(tag == CTagInsertReputation) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"d MMMM yyyy, HH:mm";
        DetailMyInboxReputation *selectedReputation = arrList[indexPathInsertReputation.row];
        GeneralAction *action = [resultDict objectForKey:@""];
        if([action.result.is_success isEqualToString:@"1"]) {
			if (action.result.ld.url && ![action.result.ld.url isEqualToString:@""]) {
            	_requestLD = [RequestLDExtension new];
            	_requestLD.luckyDeal = action.result.ld;
            	_requestLD.delegate = self;
            	[_requestLD doRequestMemberExtendURLString:action.result.ld.url];
        	}

            if([selectedReputation.role isEqualToString:@"2"]) {//Seller
                if(selectedReputation.buyer_score!=nil && ![selectedReputation.buyer_score isEqualToString:@""])
                    selectedReputation.score_edit_time_fmt = selectedReputation.viewModel.score_edit_time_fmt = [formatter stringFromDate:[NSDate date]];
                
                selectedReputation.buyer_score = emoticonState;
                selectedReputation.viewModel.buyer_score = selectedReputation.buyer_score;
            }
            else {
                if(selectedReputation.seller_score!=nil && ![selectedReputation.seller_score isEqualToString:@""])
                    selectedReputation.score_edit_time_fmt = selectedReputation.viewModel.score_edit_time_fmt = [formatter stringFromDate:[NSDate date]];
                
                
                selectedReputation.seller_score = emoticonState;
                selectedReputation.viewModel.seller_score = selectedReputation.seller_score;
            }
            
            selectedReputation.viewModel.just_updated = @"1";
            selectedReputation.viewModel.their_score_image = givenSmileyImageString;
            
            //Get view controller based on device (ipad / iphone)
            UIViewController *tempViewController;
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                UINavigationController *navController = [((SegmentedReviewReputationViewController *) self.parentViewController).splitVC getDetailNavigation];
                if(navController.viewControllers.count > 0) {
                    tempViewController = [navController.viewControllers firstObject];
                }
            }
            else {
                tempViewController = [self.navigationController.viewControllers lastObject];
            }
            
            //Update ui detail reputation
            if([tempViewController isMemberOfClass:[DetailMyReviewReputationViewController class]]) {
                [((DetailMyReviewReputationViewController *) tempViewController) successInsertReputation:selectedReputation.reputation_id withState:emoticonState];
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    [self showAlertAfterGiveRate];
            }
            else {
                [self showAlertAfterGiveRate];
            }
        
        } else {
            //gagal
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:action.message_error delegate:self];
            [stickyAlertView show];
        }
        
        strInsertReputationRole = strRequestingInsertReputation = emoticonState = nil;
        [tableContent reloadRowsAtIndexPaths:@[indexPathInsertReputation] withRowAnimation:UITableViewRowAnimationNone];
        indexPathInsertReputation = nil;
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}

- (void)actionBeforeRequest:(int)tag {
}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag == CTagGetInboxReputation) {
        if(page == 0)
            isRefreshing = NO;
        tableContent.tableFooterView = [self getLoadView].view;
    }
    else if(tag == CTagInsertReputation) {
        //Update ui detail reputation
        UIViewController *tempViewController = [self.navigationController.viewControllers lastObject];
        if([tempViewController isMemberOfClass:[DetailMyReviewReputationViewController class]]) {
            [((DetailMyReviewReputationViewController *) tempViewController) failedInsertReputation:((DetailMyInboxReputation *) arrList[indexPathInsertReputation.row]).reputation_id];
        }
        else {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedInsertReputation] delegate:self];
            [stickyAlertView show];
        }
        
        strInsertReputationRole = strRequestingInsertReputation = emoticonState = nil;
        [tableContent reloadRowsAtIndexPaths:@[indexPathInsertReputation] withRowAnimation:UITableViewRowAnimationNone];
        indexPathInsertReputation = nil;
    }
}


#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagGetInboxReputation] doRequest];
}

#pragma mark - Action
- (void)actionReview:(id)sender {
    page = 0;
    strUriNext = nil;
    currentFilter = @"all";
    
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagGetInboxReputation] doRequest];
}

- (void)actionBelumDibaca:(id)sender {
    page = 0;
    strUriNext = nil;
    currentFilter = @"not-read";

    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagGetInboxReputation] doRequest];
}

- (void)actionBelumDireview:(id)sender {
    page = 0;
    strUriNext = nil;
    currentFilter = @"not-review";
    
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagGetInboxReputation] doRequest];
}


#pragma mark - MyReviewReputation Delegate
- (void)actionReputasi:(id)sender {
    DetailMyInboxReputation *tempReputation = arrList[((UIButton *) sender).tag];
    
    if(((UIButton *) sender).titleLabel.text.length == 0) { //Badge
        NSString *strText = [NSString stringWithFormat:@"%@ %@", tempReputation.reputation_score, CStringPoin];
        [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
    }
    else {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:tempReputation.user_reputation.neutral withRepSmile:tempReputation.user_reputation.positive withRepSad:tempReputation.user_reputation.negative withDelegate:self];
        
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

- (void)actionLabelUser:(id)sender {
    if(! isRefreshing) {
        
        
        DetailMyInboxReputation *tempObj = arrList[((ViewLabelUser *) ((UITapGestureRecognizer *) sender).view).tag];
        UserContainerViewController *container;
        ShopContainerViewController *containerShop;
        
        
        if([tempObj.role isEqualToString:@"2"]) {//2 is seller
            container = [UserContainerViewController new];
            UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
            NSDictionary *auth = [_userManager getUserLoginData];
            
            if(tempObj.reviewee_uri!=nil && tempObj.reviewee_uri.length>0) {
                NSArray *arrUri = [tempObj.reviewee_uri componentsSeparatedByString:@"/"];
                container.data = @{
                                   @"user_id" : [arrUri lastObject],
                                   @"auth" : auth?:[NSNull null]
                                   };
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [((SegmentedReviewReputationViewController *) self.parentViewController).splitVC setDetailViewController:container];
                }
                else {
                    [self.navigationController pushViewController:container animated:YES];
                }
            }
        }
        else {
            containerShop = [[ShopContainerViewController alloc] init];
            TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
            NSDictionary *auth = [secureStorage keychainDictionary];
            
            containerShop.data = @{kTKPDDETAIL_APISHOPIDKEY:tempObj.shop_id,
                               kTKPD_AUTHKEY:auth?:[NSNull null]};
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [((SegmentedReviewReputationViewController *) self.parentViewController).splitVC setDetailViewController:containerShop];
            }
            else {
                [self.navigationController pushViewController:containerShop animated:YES];
            }
        }
    }
}

- (void)actionReviewRate:(id)sender
{
    if(! isRefreshing) {
        DetailMyInboxReputation *tempObj = arrList[((UIButton *) sender).tag];
        
        if([tempObj.reputation_progress isEqualToString:@"2"]) {
            // add some stickey message
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Mohon maaf penilaian ini telah dikunci, Anda telah melewati batas waktu penilaian."] delegate:self];
            [stickyAlertView show];
        } else {
            alertRateView = [[AlertRateView alloc] initViewWithDelegate:self withDefaultScore:[tempObj.role isEqualToString:@"2"]?tempObj.buyer_score:tempObj.seller_score from:[tempObj.viewModel.role isEqualToString:@"1"]? CPembeli:CPenjual];
            alertRateView.tag = ((UIButton *) sender).tag;
            [alertRateView show];
        }
        

    }
}

- (void)actionInvoice:(id)sender
{
    if(! isRefreshing) {
        DetailMyInboxReputation *tempObj = arrList[((UIButton *) sender).tag];

        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UserAuthentificationManager *auth = [UserAuthentificationManager new];
            WebViewInvoiceViewController *VC = [WebViewInvoiceViewController new];
            NSDictionary *invoiceURLDictionary = [NSDictionary dictionaryFromURLString:tempObj.invoice_uri];
            NSString *invoicePDF = [invoiceURLDictionary objectForKey:@"pdf"];
            NSString *invoiceID = [invoiceURLDictionary objectForKey:@"id"];
            NSString *userID = [auth getUserId];
            NSString *invoiceURLforWS = [NSString stringWithFormat:@"%@/invoice.pl?invoice_pdf=%@&id=%@&user_id=%@", kTkpdBaseURLString, invoicePDF, invoiceID, userID];
            VC.urlAddress = invoiceURLforWS?:@"";
            
            [((SegmentedReviewReputationViewController *) self.parentViewController).splitVC setDetailViewController:VC];
        }
        else {
            if(tempObj.invoice_uri!=nil && tempObj.invoice_uri.length>0) {
                [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:tempObj.invoice_uri];
            }
        }
    }
}



- (void)actionFlagReview:(id)sender {
    DetailMyInboxReputation *object = arrList[((UIView *)sender).tag];
    BOOL loggedInUserIsSeller = [object.role isEqualToString:@"2"];

    NSString *img = object.my_score_image;
    NSString *opponentRole;
    NSString *alertString;
    if(!loggedInUserIsSeller) {
        //score given to me as buyer role
        opponentRole = @"Penjual";
    } else {
        //score given to me as seller role
        opponentRole = @"Pembeli";
    }
    
    if([img isEqualToString:@"smiley_neutral"]) {
        alertString = [NSString stringWithFormat:@"Penilaian dari %@ adalah cukup puas", opponentRole];
    } else if([img isEqualToString:@"smiley_bad"]) {
        alertString = [NSString stringWithFormat:@"Penilaian dari %@ adalah tidak puas", opponentRole];
    } else if([img isEqualToString:@"smiley_good"]) {
        alertString = [NSString stringWithFormat:@"Penilaian dari %@ adalah puas", opponentRole];
    } else if([img isEqualToString:@"grey_question_mark"] || [img isEqualToString:@"smiley_none"]) {
        alertString = [NSString stringWithFormat:@"%@ belum memberikan penilaian untuk Anda", opponentRole];
    } else if([img isEqualToString:@"blue_question_mark"]) {
        alertString = [NSString stringWithFormat:@"Penasaran ? \n Isi penilaian untuk %@ dulu ya!", opponentRole];
    }
    
    UIAlertView *alertView;
    alertView = [[UIAlertView alloc] initWithTitle:@"" message:alertString delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];

}

- (void)actionFooter:(id)sender {
    if(! isRefreshing) {
        DetailMyInboxReputation *tempObj = arrList[((UIButton *) sender).tag];
        //Set flag to read -> From unread
        tempObj.read_status = CValueRead;
        tempObj.viewModel.read_status = CValueRead;
        DetailMyReviewReputationViewController *detailMyReviewReputationViewController = [DetailMyReviewReputationViewController new];
        detailMyReviewReputationViewController.tag = (int)((UIButton *) sender).tag;
        detailMyReviewReputationViewController.detailMyInboxReputation = tempObj;
        detailMyReviewReputationViewController.autoRead = tempObj.auto_read;
        [detailMyReviewReputationViewController onReputationIconTapped:^void() {
            [self performSelector:@selector(actionFlagReview:) withObject:detailMyReviewReputationViewController];
        }];

        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [((SegmentedReviewReputationViewController *) self.parentViewController).splitVC setDetailViewController:detailMyReviewReputationViewController];
        }
        else {
            [self.navigationController pushViewController:detailMyReviewReputationViewController animated:YES];
        }
    }
}


#pragma mark - AlertRate Delegate
- (void)closeWindow {
    alertRateView = nil;
}


- (void)submitWithSelected:(int)tag {
    if(strRequestingInsertReputation != nil) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CPleaseWait] delegate:self];
        [stickyAlertView show];
        indexPathInsertReputation = nil;
        
        return;
    }

    DetailMyInboxReputation *tempObj = arrList[alertRateView.tag];
    NSString *strCurrentScore = ([tempObj.viewModel.role isEqualToString:@"2"]?tempObj.viewModel.buyer_score:tempObj.viewModel.seller_score);
    switch (tag) {
        case CTagMerah:
        {
            if([strCurrentScore isEqualToString:CReviewScoreBad]) {
                [self alertWarningReviewSmiley];
                return;
            }
            emoticonState = CReviewScoreBad;
            givenSmileyImageString = @"smiley_bad";
        }
            break;
        case CTagKuning:
        {
            if([strCurrentScore isEqualToString:CReviewScoreNeutral]) {
                [self alertWarningReviewSmiley];
                return;
            }
            emoticonState = CReviewScoreNeutral;
            givenSmileyImageString = @"smiley_neutral";
        }
            break;
        case CTagHijau:
        {
            if([strCurrentScore isEqualToString:CReviewScoreGood]) {
                [self alertWarningReviewSmiley];
                return;
            }
            emoticonState = CReviewScoreGood;
            givenSmileyImageString = @"smiley_good";
        }
            break;
    }

    
    strRequestingInsertReputation = tempObj.reputation_id;
    strInsertReputationRole = tempObj.role;
    
    indexPathInsertReputation = [NSIndexPath indexPathForRow:alertRateView.tag inSection:0];
    [tableContent reloadRowsAtIndexPaths:@[indexPathInsertReputation] withRowAnimation:UITableViewRowAnimationNone];
    alertRateView = nil;
    
    //Update ui detail my review reputation
    UIViewController *tempViewController = [self.navigationController.viewControllers lastObject];
    if([tempViewController isMemberOfClass:[DetailMyReviewReputationViewController class]]) {
        [((DetailMyReviewReputationViewController *) tempViewController) doingActInsertReview:tempObj.reputation_id];
    }
    
    //Request to server
    [[self getNetworkManager:CTagInsertReputation] doRequest];
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


#pragma mark - Badge Extendsion
- (void)showPopUpLuckyDeal:(LuckyDealWord *)words
{
    [_navigate popUpLuckyDeal:words];
}

@end
