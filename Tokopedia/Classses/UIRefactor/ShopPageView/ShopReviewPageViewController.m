//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "ViewLabelUser.h"
#import "LikeDislikePostResult.h"
#import "LikeDislikePost.h"
#import "TotalLikeDislike.h"
#import "TotalLikeDislikePost.h"
#import "DetailTotalLikeDislike.h"
#import "TotalLikeDislike.h"
#import "LikeDislike.h"
#import "LoginViewController.h"
#import "LikeDislikeResult.h"
#import "CMPopTipView.h"
#import "ProductDetailReputationViewController.h"
#import "ProductReputationCell.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "ShopReviewPageViewController.h"
#import "DetailReviewViewController.h"
#import "TTTAttributedLabel.h"
//#import "GeneralReviewCell.h"

#import "Review.h"
#import "ReportViewController.h"
#import "GeneralAction.h"
#import "InboxTalk.h"
#import "SmileyAndMedal.h"

#import "inbox.h"
#import "string_home.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "string_inbox_review.h"
#import "detail.h"
#import "ShopPageHeader.h"
#import "TokopediaNetworkManager.h"
#import "NoResultReusableView.h"
#import "URLCacheController.h"
#import "ProductReputationSimpleCell.h"

#define CTagGetTotalLike 1
#define CTagLike 2
#define CTagDislike 3

@interface ShopReviewPageViewController () <
UITableViewDataSource,
UITableViewDelegate,
TKPDTabInboxTalkNavigationControllerDelegate,
TTTAttributedLabelDelegate,
CMPopTipViewDelegate,
TokopediaNetworkManagerDelegate,
LoginViewDelegate,
ReportViewControllerDelegate,
//GeneralReviewCellDelegate,
UIActionSheetDelegate,
productReputationDelegate,
ShopPageHeaderDelegate,
SmileyDelegate,
UIScrollViewDelegate,
UIAlertViewDelegate,
NoResultDelegate,
ProductReputationSimpleDelegate>

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UIView *stickyTab;
@property (strong, nonatomic) IBOutlet UIView *fakeStickyTab;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *list;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation ShopReviewPageViewController
{
    BOOL _isNoData;
    BOOL _isRefreshView;
    BOOL _iseditmode;
    
    NSInteger _page;
    NSInteger _limit;
    NSInteger _viewposition;
    
    NSMutableDictionary *_paging;
    
    NSString *_uriNext;
    NSString *_talkNavigationFlag;
    NSString *_reviewIsOwner;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestCount;
    NSInteger _requestUnfollowCount;
    NSInteger _requestDeleteCount;
    
    NSTimer *_timer;
    UISearchBar *_searchbar;
    NSString *_keyword;
    NSString *_readstatus;
    NSString *_navthatwillrefresh;
    BOOL _isrefreshnav;
    BOOL _isNeedToInsertCache;
    BOOL _isLoadFromCache;
    
    NSMutableParagraphStyle *style;
    __weak RKObjectManager *_objectManager;
    __weak RKObjectManager *_objectUnfollowmanager;
    __weak RKObjectManager *_objectDeletemanager;
    
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestUnfollow;
    __weak RKManagedObjectRequestOperation *_requestDelete;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationUnfollowQueue;
    NSOperationQueue *_operationDeleteQueue, *operationQueueLikeDislike;
    CMPopTipView *popTipView;
    TokopediaNetworkManager *tokopediaGetTotalLikeNManager, *tokopediaLikeNManager, *tokopediaDislikeNManager;
    
    NSString *_cachePath;
    URLCacheController *_cacheController;
    URLCacheConnection *_cacheConnection;
    NSTimeInterval _timeInterval;
    Review *_review;
    NSDictionary *_auth;
    Shop *_shop;
    NoResultReusableView *_noResultView;
}
@synthesize dictLikeDislike, loadingLikeDislike;

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isRefreshView = NO;
        _isNoData = YES;
    }
    
    return self;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Toko ini belum mempunyai ulasan"
                                  desc:@""
                              btnTitle:nil];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalReviewComment:)
                                                 name:@"updateTotalReviewComment" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReviewHeaderPosition:)
                                                 name:@"updateReviewHeaderPosition" object:nil];
}

#pragma mark - Life Cycle
- (void)addBottomInsetWhen14inch {
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 155;
        _table.contentInset = inset;
    }
    else{
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 240;
        _table.contentInset = inset;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    [self addBottomInsetWhen14inch];
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
    
    dictLikeDislike = [NSMutableDictionary new];
    loadingLikeDislike = [NSMutableDictionary new];
    style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    _talkNavigationFlag = [_data objectForKey:@"nav"];
    _page = 1;
    [self initNoResultView];
    
    _operationQueue = [NSOperationQueue new];
    _operationUnfollowQueue = [NSOperationQueue new];
    _operationDeleteQueue = [NSOperationQueue new];
    operationQueueLikeDislike = [NSOperationQueue new];
    _cacheConnection = [URLCacheConnection new];
    _cacheController = [URLCacheController new];
    _list = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    
    
    _table.delegate = self;
    _table.dataSource = self;
    _table.allowsSelection = YES;
    
    _shopPageHeader = [ShopPageHeader new];
    _shopPageHeader.delegate = self;
    _shopPageHeader.data = _data;
    
    _header = _shopPageHeader.view;
    
    CGRect newFrame = _header.frame;
    newFrame.size.height += 5;
    _header.frame = newFrame;
    
    UIView *btmGreenLine = (UIView *)[_header viewWithTag:21];
    [btmGreenLine setHidden:NO];
    _stickyTab = [(UIView *)_header viewWithTag:18];
    
    _table.tableFooterView = _footer;
    //_table.tableHeaderView = _header;
    
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    if (_list.count > 0) {
        _isNoData = NO;
    }
    
    [_fakeStickyTab.layer setShadowOffset:CGSizeMake(0, 0.5)];
    [_fakeStickyTab.layer setShadowColor:[UIColor colorWithWhite:0 alpha:1].CGColor];
    [_fakeStickyTab.layer setShadowRadius:1];
    [_fakeStickyTab.layer setShadowOpacity:0.3];
    
    UINib *cellNib = [UINib nibWithNibName:@"ProductReputationSimpleCell" bundle:nil];
    [_table registerNib:cellNib forCellReuseIdentifier:@"ProductReputationSimpleCellIdentifier"];
    
    [self initNotification];
    [self configureRestKit];
    
    [self loadData];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [TPAnalytics trackScreenName:@"Shop - Review List"];
    self.screenName = @"Shop - Review List";
    
    if (!_isRefreshView) {
        [self configureRestKit];
        if (_isNoData && _page < 1) {
            [self loadData];
        }
    }    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Method
- (void)unloadRequesting {
    for(id obj in [loadingLikeDislike allValues]) {
        if([obj isMemberOfClass:[NSArray class]]) {
            NSArray *tempArr = obj;
            RKManagedObjectRequestOperation *operation = [tempArr firstObject];
            [operation cancel];
            
            NSTimer *timer = [tempArr lastObject];
            [timer invalidate];
        }
    }
    
    [_operationQueue cancelAllOperations];
    [_operationUnfollowQueue cancelAllOperations];
    [_operationDeleteQueue cancelAllOperations];
    [operationQueueLikeDislike cancelAllOperations];
}


- (void)reloadTable {
    [_table reloadData];
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

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagDislike) {
        tokopediaDislikeNManager = [TokopediaNetworkManager new];
        tokopediaDislikeNManager.tagRequest = tag;
        tokopediaDislikeNManager.delegate = self;
        
        return tokopediaDislikeNManager;
    }
    else if(tag == CTagLike) {
        tokopediaLikeNManager = [TokopediaNetworkManager new];
        tokopediaLikeNManager.tagRequest = tag;
        tokopediaLikeNManager.delegate = self;

        return tokopediaLikeNManager;
    }
    else if(tag == CTagGetTotalLike) {
        tokopediaGetTotalLikeNManager = [TokopediaNetworkManager new];
        tokopediaGetTotalLikeNManager.tagRequest = tag;
        tokopediaGetTotalLikeNManager.delegate = self;
        
        return tokopediaGetTotalLikeNManager;
    }
    
    return nil;
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
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    [self configureRestKitLikeDislike:objectManager];
    ReviewList *reviewList = _list[btnLike.tag];
    NSDictionary* param = @{@"action":@"like_dislike_review",
                            @"review_id":reviewList.review_id,
                            @"like_status":@(likeDislikeTag),
                            @"shop_id":reviewList.review_shop_id,
                            @"product_id":reviewList.review_product_id};

    RKObjectRequestOperation *request = [objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:@"action/review.pl" parameters:[param encrypt]];
    __block NSTimer *blockTimer;
    [request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [blockTimer invalidate];
        blockTimer = nil;
        
        //Result
        NSDictionary *result = ((RKMappingResult*) mappingResult).dictionary;
        LikeDislikePost *likeDislikePost = [result objectForKey:@""];
        LikeDislikePostResult *likeDislikePostResult = likeDislikePost.result;
        BOOL status = [likeDislikePostResult.is_success isEqualToString:@"1"];
        
        TotalLikeDislike *totalLikeDislike = [dictLikeDislike objectForKey:reviewList.review_id];
        if(status) {
            if(totalLikeDislike) {
                totalLikeDislike.total_like_dislike.total_like = likeDislikePostResult.content.total_like_dislike.total_like;
                totalLikeDislike.total_like_dislike.total_dislike = likeDislikePostResult.content.total_like_dislike.total_dislike;
                totalLikeDislike.like_status = [NSString stringWithFormat:@"%d", likeDislikeTag];
                
                //Reload UI
                [_table reloadRowsAtIndexPaths:@[[loadingLikeDislike objectForKey:reviewList.review_id]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        else {
            if(likeDislikePost.message_error!=nil && likeDislikePost.message_error.count>0) {
                StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:likeDislikePost.message_error delegate:self];
                [stickyAlertView show];
            }
        }
        
        [loadingLikeDislike removeObjectForKey:reviewList.review_id];        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [blockTimer invalidate];
        blockTimer = nil;
        [loadingLikeDislike removeObjectForKey:reviewList.review_id];
    }];
    [operationQueueLikeDislike addOperation:request];
    
    blockTimer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout:) userInfo:reviewList.review_id repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:blockTimer forMode:NSRunLoopCommonModes];
}

- (void)updateDataInDetailView:(LikeDislike *)likeDislike {
    if([[self.navigationController.viewControllers lastObject] isMemberOfClass:[ProductDetailReputationViewController class]]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [((ProductDetailReputationViewController *) [self.navigationController.viewControllers lastObject]) updateLikeDislike:likeDislike];
        });
    }
}

- (void)actionGetLikeStatus:(NSArray *)arrList {
    if(loadingLikeDislike.count > 10)
        return;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        ReviewList *list = [arrList firstObject];
        RKObjectManager *tempObjectManager = [self getObjectManager:CTagGetTotalLike];
        NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETLIKEDISLIKE,
                                kTKPDDETAIL_REVIEWIDS : list.review_id,
                                kTKPDDETAIL_APISHOPIDKEY : list.review_shop_id};
        RKManagedObjectRequestOperation *tempRequest = [tempObjectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:[self getPath:CTagGetTotalLike] parameters:[param encrypt]];
    
    
        NSTimer *timerLikeDislike = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(timeOutGetLikeDislike:) userInfo:list.review_id repeats:NO];
        [loadingLikeDislike setObject:@[tempRequest, [NSIndexPath indexPathForRow:[[arrList lastObject] intValue] inSection:0], timerLikeDislike] forKey:list.review_id];
    

        [tempRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSTimer *temporaryTimer = [[loadingLikeDislike objectForKey:list.review_id] lastObject];
            [temporaryTimer invalidate];
            
            NSDictionary *result = ((RKMappingResult*) mappingResult).dictionary;
            LikeDislike *obj = [result objectForKey:@""];
            [dictLikeDislike setObject:((TotalLikeDislike *) [obj.result.like_dislike_review firstObject]) forKey:((TotalLikeDislike *) [obj.result.like_dislike_review firstObject]).review_id];
            [self performSelectorInBackground:@selector(updateDataInDetailView:) withObject:obj];
            
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

- (void)timeOutGetLikeDislike:(NSTimer *)temp {
    RKManagedObjectRequestOperation *operation = [[loadingLikeDislike objectForKey:[temp userInfo]] firstObject];
    [operation cancel];
    operation = nil;
    [loadingLikeDislike removeObjectForKey:[temp userInfo]];
}

- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}

- (void)dismissAllPopTipViews
{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}

- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc {
    lblDesc.backgroundColor = [UIColor clearColor];
    lblDesc.textAlignment = NSTextAlignmentLeft;
    lblDesc.font = [UIFont fontWithName:@"Gotham Book" size:13.0f];
    lblDesc.textColor = [UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f];
    lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
    lblDesc.numberOfLines = 0;
}

- (NSString *)convertHTML:(NSString *)html
{
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        [myScanner scanUpToString:@"<" intoString:NULL];
        [myScanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return html;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNoData) {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            [self configureRestKit];
            [self loadData];
        } else {
            _table.tableFooterView = nil;
            [_act stopAnimating];
        }
    }
}


#pragma mark - TableView Source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _header.frame.size.height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isNoData ? 0 : _list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    ReviewList *reputationDetail = _list[indexPath.row];
    UILabel *messageLabel = [[UILabel alloc] init];
    
    [messageLabel setText:reputationDetail.review_message];
    [messageLabel sizeToFit];
    
    CGRect sizeOfMessage = [messageLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10, 0)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                                           context:nil];
    messageLabel.frame = sizeOfMessage;
    
    CGFloat height = 150 + messageLabel.frame.size.height ;
    return height;
     */
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self redirectToProductDetailReputation:_list[indexPath.row] withIndexPath:indexPath];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductReputationSimpleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductReputationSimpleCellIdentifier"];
    
    ReviewList *list = _list[indexPath.row];
    [cell setShopReputationModelView:list];
    cell.isHelpful = NO;
    cell.delegate = self;
    cell.indexPath = indexPath;
    [cell.leftBorderView setHidden:YES];
    
    // this is required to load like info to detail, but was deleted
    if (![dictLikeDislike objectForKey:list.review_id]) {
        if(! [loadingLikeDislike objectForKey:list.review_id]) {
            [loadingLikeDislike setObject:list.review_id forKey:list.review_id];
            [self performSelectorInBackground:@selector(actionGetLikeStatus:) withObject:@[list, @(indexPath.row)]];
        }
    }
    
    return cell;
}

#pragma mark - Request + Mapping
#pragma mark - Request and Mapping

-(void)cancel
{
    [_request cancel];
    _request = nil;
    
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Review class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ReviewResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_owner":@"is_owner"}];
    
    RKObjectMapping *ratinglistMapping = [RKObjectMapping mappingForClass:[RatingList class]];
    [ratinglistMapping addAttributeMappingsFromArray:@[kTKPDREVIEW_APIRATINGSTARPOINTKEY,
                                                       kTKPDREVIEW_APIRATINGACCURACYKEY,
                                                       kTKPDREVIEW_APIRATINGQUALITYKEY
                                                       ]];
    
    RKObjectMapping *reviewUserReputation = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [reviewUserReputation addAttributeMappingsFromDictionary:@{CPositivePercentage:CPositivePercentage,
                                                               CNegative:CNegative,
                                                               CNoReputation:CNoReputation,
                                                               CNeutral:CNeutral,
                                                               CPositif:CPositif}];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ReviewList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDREVIEW_APIREVIEWSHOPIDKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIMAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWCREATETIMEKEY,
                                                 kTKPDREVIEW_APIREVIEWIDKEY,
                                                 CReviewReputationID,
                                                 @"review_shop_name",
                                                 kTKPDREVIEW_APIREVIEWUSERNAMEKEY,
                                                 kTKPDREVIEW_APIREVIEWMESSAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIDKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEQUALITY,
                                                 kTKPDREVIEW_APIREVIEWRATESPEEDKEY,
                                                 kTKPDREVIEW_APIREVIEWRATESERVICEKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEACCURACYKEY,
                                                 kTKPDREVIEW_APIPRODUCTNAMEKEY,
                                                 kTKPDREVIEW_APIPRODUCTIDKEY,
                                                 kTKPDREVIEW_APIPRODUCTIMAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWISOWNERKEY,
                                                 kTKPDREVIEW_APIPRODUCTSTATUSKEY,
                                                 KTKPDREVIEW_APIREVIEWUSERLABELKEY
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    //add relationship mapping
    RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
    [reviewResponseMapping addAttributeMappingsFromDictionary:@{
                                                                REVIEW_RESPONSE_CREATE_TIME:REVIEW_RESPONSE_CREATE_TIME,
                                                                REVIEW_RESPONSE_MESSAGE:REVIEW_RESPONSE_MESSAGE
                                                                }];
    
    RKObjectMapping *reviewProductOwnerMapping = [RKObjectMapping mappingForClass:[ReviewProductOwner class]];
    [reviewProductOwnerMapping addAttributeMappingsFromDictionary:@{
                                                                    REVIEW_PRODUCT_OWNER_USER_ID:REVIEW_PRODUCT_OWNER_USER_ID,
                                                                    REVIEW_PRODUCT_OWNER_USER_IMAGE:REVIEW_PRODUCT_OWNER_USER_IMAGE,
                                                                    REVIEW_PRODUCT_OWNER_USER_NAME:REVIEW_PRODUCT_OWNER_USER_NAME
                                                                    }];

    [ratinglistMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:reviewUserReputation]];

    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:reviewUserReputation]];
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:REVIEW_RESPONSE
                                                                                toKeyPath:REVIEW_RESPONSE
                                                                              withMapping:reviewResponseMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:REVIEW_PRODUCT_OWNER
                                                                                toKeyPath:REVIEW_PRODUCT_OWNER
                                                                              withMapping:reviewProductOwnerMapping]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                 toKeyPath:kTKPD_APILISTKEY
                                                                               withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                                 toKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                               withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:@"shop.pl"
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)loadData
{
    if (_request.isExecuting) return;
    
    _requestCount++;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY    :   kTKPDDETAIL_APIGETSHOPREVIEWKEY,
                            kTKPDDETAIL_APISHOPIDKEY    :   [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0),
                            @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@"",
                            kTKPDDETAIL_APIPAGEKEY      :   @(_page),
                            kTKPDDETAIL_APILIMITKEY     :   @(kTKPDDETAILREVIEW_LIMITPAGE)};
    
    
    
    if (!_isRefreshView) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:@"shop.pl"
                                                                parameters:[param encrypt]];
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _table.hidden = NO;
        _isRefreshView = NO;
        [_refreshControl endRefreshing];
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _isRefreshView = NO;
        [_refreshControl endRefreshing];
        [self requestfailure:error];
    }];
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeout)
                                            userInfo:nil repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _review = stats;
    BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    if (_timeInterval > _cacheController.URLCacheInterval || _page > 1 || _isRefreshView) {
        [self requestprocess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachePath];
        if(data == nil)
            return;
        
        id parsedData = [RKMIMETypeSerialization objectFromData:data
                                                       MIMEType:RKMIMETypeJSON
                                                          error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectManager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stats = [result objectForKey:@""];
            _review = stats;
            BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            
            _review = stats;
            BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _review.result.list;
                _reviewIsOwner = _review.result.is_owner;
                [_list addObjectsFromArray:list];
                _isNoData = NO;
                
                _uriNext =  _review.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:_uriNext];
                NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
                
                NSMutableDictionary *queries = [NSMutableDictionary new];
                [queries removeAllObjects];
                for (NSString *keyValuePair in querry)
                {
                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                    NSString *key = [pairComponents objectAtIndex:0];
                    NSString *value = [pairComponents objectAtIndex:1];
                    
                    [queries setObject:value forKey:key];
                }
                
                _page = [[queries objectForKey:kTKPDDETAIL_APIPAGEKEY] integerValue];
                NSLog(@"next page : %zd",_page);
                
                [_table reloadData];
                if (_list.count == 0) {
                    _act.hidden = YES;
                    _table.tableFooterView = _noResultView;
                }else{
                    [_noResultView removeFromSuperview];
                }
                
            }
            else{
                [self cancel];
                NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
                if ([(NSError*)object code] == NSURLErrorCancelled) {
                    if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                        NSLog(@" ==== REQUESTCOUNT %zd =====",_requestCount);
                        _table.tableFooterView = _footer;
                        [_act startAnimating];
                        [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                        [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    }
                    else
                    {
                        [_act stopAnimating];
                        _table.tableFooterView = nil;
                    }
                }
                else
                {
                    [_act stopAnimating];
                    _table.tableFooterView = nil;
                }
            }
        }
    }
}

- (void)requestTimeout:(NSTimer *)timer {
    [loadingLikeDislike removeObjectForKey:[timer userInfo]];
    
    RKObjectRequestOperation *objectReputation = [operationQueueLikeDislike.operations firstObject];
    [objectReputation cancel];
}

-(void)requestTimeout
{
    [self cancel];
}



#pragma mark - General Talk Delegate
- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    return self;
}

-(void)GeneralReviewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    DetailReviewViewController *vc = [DetailReviewViewController new];
    NSInteger row = indexpath.row;
    vc.data = _list[row];
    vc.index = [NSString stringWithFormat:@"%ld",(long)row];
    vc.shop = _shop;
    vc.is_owner = _reviewIsOwner;
    vc.indexPath = indexpath;
    
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - Refresh View
-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestCount = 0;
    [_list removeAllObjects];
    _page = 1;
    _isRefreshView = YES;
    
    [_table reloadData];
    [self unloadRequesting];
    [dictLikeDislike removeAllObjects];
    [loadingLikeDislike removeAllObjects];
    
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Notification Handler

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [self unloadRequesting];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL isFakeStickyVisible = scrollView.contentOffset.y > (_header.frame.size.height - _stickyTab.frame.size.height);
    
    if(isFakeStickyVisible) {
        _fakeStickyTab.hidden = NO;
    } else {
        _fakeStickyTab.hidden = YES;
    }
    [self determineOtherScrollView:scrollView];
    
}


- (void)determineOtherScrollView:(UIScrollView *)scrollView {
    NSDictionary *userInfo = @{@"y_position" : [NSNumber numberWithFloat:scrollView.contentOffset.y]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTalkHeaderPosition" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNotesHeaderPosition" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProductHeaderPosition" object:nil userInfo:userInfo];
    
}

- (void)updateReviewHeaderPosition:(NSNotification *)notification
{
    id userinfo = notification.userInfo;
    float ypos;
    if([[userinfo objectForKey:@"y_position"] floatValue] < 0) {
        ypos = 0;
    } else {
        ypos = [[userinfo objectForKey:@"y_position"] floatValue];
    }
    
    CGPoint cgpoint = CGPointMake(0, ypos);
    _table.contentOffset = cgpoint;
    
    
}


#pragma mark - Shop header delegate

- (void)didLoadImage:(UIImage *)image
{
    //    _navigationImageView.image = [image applyLightEffect];
}

- (void)didReceiveShop:(Shop *)shop
{
    _shop = shop;
}

- (id)didReceiveNavigationController {
    return self;
}

#pragma mark - Notification Center Action 
- (void)updateTotalReviewComment:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:@"index"]integerValue];
    
    ReviewList *list = _list[index];
    
    list.review_response.response_message = [userinfo objectForKey:@"review_comment"];
    list.review_response.response_create_time = [userinfo objectForKey:@"review_comment_time"];
    
    NSIndexPath *indexPath = [userinfo objectForKey:@"indexPath"];
    [_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [_table reloadData];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Product Reputation Delegate
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
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gotham Book" size:lblDesc.font.pointSize] range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:range];
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gotham Book" size:lblDesc.font.pointSize] range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        lblDesc.delegate = nil;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
    }
}

- (void)actionRate:(id)sender {
    ReviewList *list = _list[((UIView *) sender).tag];
    
    if(! (list.review_user_reputation.no_reputation!=nil && [list.review_user_reputation.no_reputation isEqualToString:@"1"])) {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:list.review_user_reputation.neutral withRepSmile:list.review_user_reputation.positive withRepSad:list.review_user_reputation.negative withDelegate:self];
        
        
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

- (void)actionLike:(id)sender {
    if(_auth) {
        UIButton *btnLike = (UIButton *)sender;
        ProductReputationCell *cell = [self getCell:btnLike];
        ReviewList *reviewList = _list[btnLike.tag];
        UIButton *btnDislike = [cell getBtnDisLike];
        
        int tagRequest = 3;
        if([dictLikeDislike objectForKey:reviewList.review_id] && ([((TotalLikeDislike *)[dictLikeDislike objectForKey:reviewList.review_id]).like_status isEqualToString:@"3"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:reviewList.review_id]).like_status isEqualToString:@"0"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:reviewList.review_id]).like_status isEqualToString:@"2"])) {
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
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like intValue] + 1)];
            if([((TotalLikeDislike *)[dictLikeDislike objectForKey:reviewList.review_id]).like_status isEqualToString:@"2"]) {
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike intValue] - 1)];
            }
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).like_status = @"1";
        }
        else {
            if([((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).like_status isEqualToString:@"1"]) {
                tagRequest = 3;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).like_status = @"0";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like intValue] - 1)];
                [btnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like" ofType:@"png"]] forState:UIControlStateNormal];
            }
            else {
                tagRequest = 1;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).like_status = @"1";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like intValue] + 1)];
                [btnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like_active" ofType:@"png"]] forState:UIControlStateNormal];
            }
        }
        
        [btnLike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like forState:UIControlStateNormal];
        [btnDislike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike forState:UIControlStateNormal];
        [loadingLikeDislike setObject:[NSIndexPath indexPathForRow:btnLike.tag inSection:0] forKey:reviewList.review_id];
        [self doActionLikeDislike:tagRequest withView:btnLike];
    } else {
        [self showLoginView];
    }
}

- (void)actionDisLike:(id)sender {
    if(_auth) {
        UIButton *btnDislike = (UIButton *)sender;
        ProductReputationCell *cell = [self getCell:btnDislike];
        ReviewList *reviewList = _list[btnDislike.tag];
        UIButton *btnLike = [cell getBtnLike];
        
        int tagRequest = 3;
        if([dictLikeDislike objectForKey:reviewList.review_id] && ([((TotalLikeDislike *)[dictLikeDislike objectForKey:reviewList.review_id]).like_status isEqualToString:@"3"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:reviewList.review_id]).like_status isEqualToString:@"0"])) {
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
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike intValue] + 1)];
            if([((TotalLikeDislike *)[dictLikeDislike objectForKey:reviewList.review_id]).like_status isEqualToString:@"1"]) {
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like intValue] - 1)];
            }
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).like_status = @"2";
        }
        else {
            if([((TotalLikeDislike *)[dictLikeDislike objectForKey:reviewList.review_id]).like_status isEqualToString:@"2"]) {
                tagRequest = 3;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).like_status = @"0";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike intValue] - 1)];
                [btnDislike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike" ofType:@"png"]] forState:UIControlStateNormal];
            }
            else {
                tagRequest = 2;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).like_status = @"2";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike intValue] + 1)];
                [btnDislike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike_active" ofType:@"png"]] forState:UIControlStateNormal];
            }
        }
        
        [loadingLikeDislike setObject:[NSIndexPath indexPathForRow:btnDislike.tag inSection:0] forKey:reviewList.review_id];
        
        //Set data
        [btnLike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_like forState:UIControlStateNormal];
        [btnDislike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:reviewList.review_id]).total_like_dislike.total_dislike forState:UIControlStateNormal];
        [self doActionLikeDislike:tagRequest withView:btnDislike];
    }
    else {
        [self showLoginView];
    }
}

- (void)actionChat:(id)sender {
    [self redirectToProductDetailReputation:_list[((UIView *) sender).tag] withIndexPath:[NSIndexPath indexPathForRow:((UIView *) sender).tag inSection:0]];
}

- (void)redirectToProductDetailReputation:(ReviewList *)reviewList withIndexPath:(NSIndexPath *)indexPath {
    if(_shop.result.stats.shop_badge_level == nil) {
        return;
    }
    
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    productDetailReputationViewController.reviewList = reviewList;
    productDetailReputationViewController.isMyProduct = (_auth!=nil && [[NSString stringWithFormat:@"%@", [_auth objectForKey:@"user_id"]] isEqualToString:reviewList.review_product_owner.user_id]);
    productDetailReputationViewController.shopBadgeLevel = _shop.result.stats.shop_badge_level;
    productDetailReputationViewController.dictLikeDislike = dictLikeDislike;
    productDetailReputationViewController.loadingLikeDislike = loadingLikeDislike;
    productDetailReputationViewController.indexPathSelected = indexPath;
    productDetailReputationViewController.strProductID = reviewList.review_product_id;
    
    if([dictLikeDislike objectForKey:productDetailReputationViewController.reviewList.review_id]) {
        TotalLikeDislike *totalLikeDislike = [dictLikeDislike objectForKey:productDetailReputationViewController.reviewList.review_id];
        productDetailReputationViewController.strTotalDisLike = totalLikeDislike.total_like_dislike.total_dislike;
        productDetailReputationViewController.strTotalLike = totalLikeDislike.total_like_dislike.total_like;
        productDetailReputationViewController.strLikeStatus = totalLikeDislike.like_status;
    }
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}

- (void)actionMore:(id)sender {
    if(_auth) {
        ReviewList *list = _list[((UIButton *)sender).tag];
        UIActionSheet *actionSheet;
        if([list.review_is_allow_edit isEqualToString:@"1"] && ![list.review_product_status isEqualToString:STATE_PRODUCT_BANNED] && ![list.review_product_status isEqualToString:STATE_PRODUCT_DELETED]) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Batal" destructiveButtonTitle:@"Lapor" otherButtonTitles:nil, nil];
        }
        else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Batal" destructiveButtonTitle:@"Lapor" otherButtonTitles:nil, nil];
        }
        
        actionSheet.tag = ((UIButton *) sender).tag;
        [actionSheet showInView:self.parentViewController.view];
    }
    else {
        [self showLoginView];
    }
}

#pragma mark - TTTAttributeLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point
{
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [self redirectToProductDetailReputation:_list[label.tag] withIndexPath:[NSIndexPath indexPathForRow:label.tag inSection:0]];
}


#pragma mark - CMPopTipView Delegate
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagDislike) {
    
    }
    else if(tag == CTagLike) {
    
    }
    else if(tag == CTagGetTotalLike) {
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagDislike) {
        
    }
    else if(tag == CTagLike) {
        
    }
    else if(tag == CTagGetTotalLike) {
        return @"shop.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagDislike) {
        
    }
    else if(tag == CTagLike) {
        
    }
    else if(tag == CTagGetTotalLike) {
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
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [tempObjectManager addResponseDescriptor:responseDescriptor];
        
        return tempObjectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    if(tag == CTagDislike) {
        
    }
    else if(tag == CTagLike) {
        
    }
    else if(tag == CTagGetTotalLike) {
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}


- (void)actionBeforeRequest:(int)tag {
}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}


#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            ReportViewController *reportViewController = [ReportViewController new];
            ReviewList *list = _list[actionSheet.tag];
            
            reportViewController.delegate = self;
            reportViewController.strProductID = list.review_product_id;
            reportViewController.strShopID = list.review_shop_id;
            reportViewController.strReviewID = list.review_id;

            [self.navigationController pushViewController:reportViewController animated:YES];
        }
            break;
    }
}

#pragma mark - LoginView Delegate
- (void)userDidLogin:(NSNotification*)notification {
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
    
    UIViewController *viewController = [self.navigationController.viewControllers lastObject];
    if([viewController isMemberOfClass:[ProductDetailReputationViewController class]]) {
        [((ProductDetailReputationViewController *) viewController) userHasLogin];
    }
    
    [dictLikeDislike removeAllObjects];
    [loadingLikeDislike removeAllObjects];
    [_table reloadData];
}

- (void)redirectViewController:(id)viewController{
    
}

- (void)cancelLoginView {

}

#pragma mark - Report Delegate
- (NSDictionary *)getParameter {
    return nil;
}

- (UIViewController *)didReceiveViewController {
    return self;
}

- (NSString *)getPath {
    return @"action/review.pl";
}

- (void)showMoreDidTappedInIndexPath:(NSIndexPath*)indexPath{
    [self redirectToProductDetailReputation:_list[indexPath.row] withIndexPath:indexPath];
}
@end
