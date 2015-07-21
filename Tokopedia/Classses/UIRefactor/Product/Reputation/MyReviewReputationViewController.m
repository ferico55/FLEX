//
//  MyReviewReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "AlertRateView.h"
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
#import "String_Reputation.h"
#import "ShopContainerViewController.h"
#import "TokopediaNetworkManager.h"
#import "ViewLabelUser.h"
#import "WebViewController.h"
#define CFailedGetData @"Process ambil data gagal"
#define CCellIndetifier @"cell"
#define CActionGetInboxReputation @"get_inbox_reputation"
#define CTagGetInboxReputation 1
#define CTagInsertReputation 2


@interface MyReviewReputationViewController ()<TokopediaNetworkManagerDelegate, LoadingViewDelegate, MyReviewReputationDelegate, AlertRateDelegate>
@end

@implementation MyReviewReputationViewController
{
    AlertRateView *alertRateView;
    NoResultView *noResultView;
    LoadingView *loadingView;
    NSMutableArray *arrList;
    NSString *strRequestingInsertReputation;
    TokopediaNetworkManager *tokopediaNetworkManager, *tokopediaNetworkInsertReputation;
    NSString *filterNav, *filter, *emoticonState, *strInsertReputationRole;
    int page;
    NSString *strUriNext;
    NSIndexPath *indexPathInsertReputation;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    filter = CTagSemuaReview;
    page = 0;
    tableContent.allowsSelection = NO;
    tableContent.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagGetInboxReputation] doRequest];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [tableContent reloadData];
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
    }
    
    cell.getBtnFooter.tag = indexPath.row;
    cell.getBtnInvoice.tag = indexPath.row;
    cell.getBtnReview.tag = indexPath.row;
    cell.getLabelUser.tag = indexPath.row;
    cell.getImageFlagReview.tag = indexPath.row;
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


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagGetInboxReputation) {
        return @{@"action":CActionGetInboxReputation,
                 @"nav":strNav,
                 @"page":@(page),
                 @"filter":filter};
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
        return @"inbox-reputation.pl";
    }
    else if(tag == CTagInsertReputation) {
        return @"action/reputation.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagGetInboxReputation) {
        RKObjectManager *objectManager = [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[MyReviewReputation class]];
        [statusMapping addAttributeMappingsFromDictionary:@{CStatus:CStatus,
                                                            CMessageError:CMessageError,
                                                            CMessageStatus:CMessageStatus,
                                                            CServerProcessTime:CServerProcessTime}];
        
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[MyReviewReputationResult class]];
        RKObjectMapping *detailReputationMapping = [RKObjectMapping mappingForClass:[DetailMyInboxReputation class]];
        [detailReputationMapping addAttributeMappingsFromArray:@[CRevieweeScoreStatus,
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
                                                                 CUnaccessedReputationReview,
                                                                 CShowRevieweeSCore,
                                                                 CRole]];
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{CUriNext:CUriNext,
                                                            CUriPrevious:CUriPrevious}];
 
        
        //relation
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CList toKeyPath:CList withMapping:detailReputationMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CPaging toKeyPath:CPaging withMapping:pagingMapping]];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    else if(tag == CTagInsertReputation) {
        RKObjectManager *objectManager = [RKObjectManager sharedClient];

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


- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagGetInboxReputation) {
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
    else if(tag == CTagInsertReputation) {
        ((DetailMyInboxReputation *) arrList[indexPathInsertReputation.row]).reviewee_score = emoticonState;
        ((DetailMyInboxReputation *) arrList[indexPathInsertReputation.row]).viewModel.reviewee_score = ((DetailMyInboxReputation *) arrList[indexPathInsertReputation.row]).reviewee_score;
        
        //Update ui detail reputation
        UIViewController *tempViewController = [self.navigationController.viewControllers lastObject];
        if([tempViewController isMemberOfClass:[DetailMyReviewReputationViewController class]]) {
            [((DetailMyReviewReputationViewController *) tempViewController) successInsertReputation:((DetailMyInboxReputation *) arrList[indexPathInsertReputation.row]).reputation_id withState:emoticonState];
        }
        else {
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
    filter = CTagSemuaReview;
    page = 0;
    strUriNext = nil;
    
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagGetInboxReputation] doRequest];
}

- (void)actionBelumDibaca:(id)sender {
    filter = CTagBelumDibaca;
    page = 0;
    strUriNext = nil;

    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagGetInboxReputation] doRequest];
}

- (void)actionBelumDireview:(id)sender {
    filter = CtagBelumDireviw;
    page = 0;
    strUriNext = nil;
    
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagGetInboxReputation] doRequest];
}


#pragma mark - MyReviewReputation Delegate
- (void)actionLabelUser:(id)sender {
    DetailMyInboxReputation *tempObj = arrList[((ViewLabelUser *) ((UITapGestureRecognizer *) sender).view).tag];
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    container.data = @{kTKPDDETAIL_APISHOPIDKEY:tempObj.shop_id,
                       kTKPD_AUTHKEY:auth?:[NSNull null]};
    [self.navigationController pushViewController:container animated:YES];
}

- (void)actionReviewRate:(id)sender
{
    DetailMyInboxReputation *tempObj = arrList[((UIButton *) sender).tag];
    alertRateView = [[AlertRateView alloc] initViewWithDelegate:self withDefaultScore:tempObj.reviewee_score];
    alertRateView.tag = ((UIButton *) sender).tag;
    [alertRateView show];
}

- (void)actionInvoice:(id)sender
{
    DetailMyInboxReputation *tempObj = arrList[((UIButton *) sender).tag];
    
    if(tempObj.invoice_uri!=nil && tempObj.invoice_uri.length>0) {
        WebViewController *webViewController = [WebViewController new];
        webViewController.strURL = tempObj.invoice_uri;
        webViewController.strTitle = @"";
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)actionFlagReview:(id)sender {
    DetailMyInboxReputation *object = arrList[((UIView *)sender).tag];
//    1 buyer & seller sudah mengisi
//    2 buyer sudah mengisi
//    3 buyer belum mengisi
//    4 seller & buyer sudah mengisi
//    5 seller sudah mengisi
//    6 seller belum mengisi

    UIAlertView *alertView;
    if([object.reviewee_score_status isEqualToString:@"6"] || [object.reviewee_score_status isEqualToString:@"3"]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@ belum memberikan Feedback untuk anda", ([object.role isEqualToString:@"2"]? @"Pembeli":@"Penjual")] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else if([object.reviewee_score_status isEqualToString:@"2"] || [object.reviewee_score_status isEqualToString:@"5"]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Penasaran\nIsi Feedback %@ dulu ya!", ([object.role isEqualToString:@"2"]? @"pembeli":@"penjual")] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else if([object.reviewee_score_status isEqualToString:@"1"] || [object.reviewee_score_status isEqualToString:@"4"]) {
        NSString *strRespond = @"Tidak Puas";
        NSString *score = ([object.role isEqualToString:@"2"]? object.buyer_score:object.seller_score);
        
        if(score!=nil && ![score isEqualToString:@""]) {
            if([score isEqualToString:CRevieweeScroreNetral]) {
                strRespond = @"Cukup Puas";
            }
            else if([score isEqualToString:CRevieweeScroreGood]) {
                strRespond = @"Puas";
            }
        }
        else {
            return;
        }
        
        alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Wow!\nReview dari %@:\"%@\"", ([object.role isEqualToString:@"2"]? @"Pembeli":@"Penjual"), strRespond] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    } 
}

- (void)actionFooter:(id)sender {
    DetailMyInboxReputation *tempObj = arrList[((UIButton *) sender).tag];
    //Set flag to read -> From unread
    tempObj.read_status = CValueRead;
    tempObj.viewModel.read_status = CValueRead;
    DetailMyReviewReputationViewController *detailMyReviewReputationViewController = [DetailMyReviewReputationViewController new];
    detailMyReviewReputationViewController.tag = ((UIButton *) sender).tag;
    detailMyReviewReputationViewController.detailMyInboxReputation = tempObj;
    [self.navigationController pushViewController:detailMyReviewReputationViewController animated:YES];
}


#pragma mark - AlertRate Delegate
- (void)closeWindow {
    alertRateView = nil;
}

- (void)submitWithSelected:(int)tag {
    if(strRequestingInsertReputation != nil) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CPleaseWait] delegate:self];
        [stickyAlertView show];
        
        return;
    }
    
    switch (tag) {
        case CTagMerah:
        {
            emoticonState = CRevieweeScroreBad;
        }
            break;
        case CTagKuning:
        {
            emoticonState = CRevieweeScroreNetral;
        }
            break;
        case CTagHijau:
        {
            emoticonState = CRevieweeScroreGood;
        }
            break;
    }

    DetailMyInboxReputation *tempObj = arrList[alertRateView.tag];
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
@end
