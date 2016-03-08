//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "CMPopTipView.h"
#import "string_inbox_message.h"
#import "InboxTalkViewController.h"
#import "ProductTalkDetailViewController.h"
#import "ReportViewController.h"
#import "Talk.h"
#import "GeneralAction.h"
#import "InboxTalk.h"
#import "NoResultView.h"
#import "DetailProductViewController.h"
#import "TalkCell.h"

#import "inbox.h"
#import "SmileyAndMedal.h"
#import "string_home.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "detail.h"
#import "ReputationDetail.h"
#import "TKPDTabViewController.h"
#import "TokopediaNetworkManager.h"

#import "URLCacheController.h"
#import "NoResultReusableView.h"
#import "TAGDataLayer.h"

@interface InboxTalkViewController () <UITableViewDataSource, UITableViewDelegate, TKPDTabViewDelegate, UIAlertViewDelegate, TokopediaNetworkManagerDelegate, TalkCellDelegate>

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *talkList;

@end

@implementation InboxTalkViewController {
    TokopediaNetworkManager *_networkManager;
    
    NSInteger _page;
    NSString *_nextPageURL;
    NSString *_keyword;
    NSString *_readStatus;
    
    UIRefreshControl *_refreshControl;
    UISearchBar *_searchBar;
    
    __weak RKObjectManager *_requestTalkObject;
    
    NSString *_inboxTalkBaseUrl;
    NSString *_inboxTalkPostUrl;
    NSString *_inboxTalkFullUrl;
    
    NSIndexPath *_selectedIndexPath;
    NoResultReusableView *_noResultView;
    TAGContainer *_gtmContainer;
    UserAuthentificationManager *_userManager;
    
    NSIndexPath *_selectedDetailIndexPath;
    
    NSInteger _currentTabMenuIndex;
    NSInteger _currentTabSegmentIndex;
    BOOL isFirstShow;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotalComment:) name:@"UpdateTotalComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource:) name:TKPDTabNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeletedTalk:) name:@"TokopediaDeleteInboxTalk" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadTalk:) name:@"updateUnreadTalk" object:nil];
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:self.view.bounds];
    [_noResultView generateAllElements:nil
                                 title:@"Anda belum mengikuti diskusi produk"
                                  desc:@""
                              btnTitle:nil];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNotification];
    
    // allow table selection only on iPad through didSelectRowAtIndexPath
    // on iPhone, each cell handles its own events currently
    _table.allowsSelection = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    _page = 1;
    isFirstShow = YES;
    _readStatus = @"all";
    
    _userManager = [UserAuthentificationManager new];
    _talkList = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    [self initNoResultView];
    
    _table.delegate = self;
    _table.dataSource = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"TalkCell" bundle:nil];
    [_table registerNib:cellNib forCellReuseIdentifier:@"TalkCellIdentifier"];
    
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    _table.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    
    // GTM
    [self configureGTM];
    
    //load data
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    [_networkManager doRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Inbox Talk";
    [TPAnalytics trackScreenName:@"Inbox Talk"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _talkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TalkList *list = [_talkList objectAtIndex:indexPath.row];
    
    TalkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TalkCellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    cell.selectedTalkShopID = list.talk_shop_id;
    cell.selectedTalkUserID = [NSString stringWithFormat:@"%ld", (long)list.talk_user_id];
    cell.selectedTalkProductID = list.talk_product_id;
    cell.selectedTalkReputation = list.talk_user_reputation;
    cell.detailViewController = _detailViewController;
    cell.marksOpenedTalkAsRead = YES;
    cell.isSplitScreen = YES;
    
    [cell setTalkViewModel:list.viewModel];
    
    //next page if already last cell
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_nextPageURL != NULL && ![_nextPageURL isEqualToString:@"0"] && _nextPageURL != 0) {
            [_networkManager doRequest];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TalkList* list = _talkList[indexPath.row];
    
    NSDictionary *data = @{
                           TKPD_TALK_MESSAGE:list.talk_message?:@0,
                           TKPD_TALK_USER_IMG:list.talk_user_image?:@0,
                           TKPD_TALK_CREATE_TIME:list.talk_create_time?:@0,
                           TKPD_TALK_USER_NAME:list.talk_user_name?:@0,
                           TKPD_TALK_ID:list.talk_id?:@0,
                           TKPD_TALK_USER_ID:[NSString stringWithFormat:@"%zd", list.talk_user_id]?:@0,
                           TKPD_TALK_TOTAL_COMMENT : list.talk_total_comment?:@0,
                           kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id?:@0,
                           TKPD_TALK_SHOP_ID:list.talk_shop_id?:@0,
                           TKPD_TALK_PRODUCT_IMAGE:list.talk_product_image?:@"",
                           kTKPDDETAIL_DATAINDEXKEY : @(indexPath.row)?:@0,
                           TKPD_TALK_PRODUCT_NAME:list.talk_product_name?:@0,
                           TKPD_TALK_PRODUCT_STATUS:list.talk_product_status?:@0,
                           TKPD_TALK_USER_LABEL:list.talk_user_label?:@0,
                           TKPD_TALK_REPUTATION_PERCENTAGE:list.talk_user_reputation?:@0,
                           };
    
    NSDictionary *userInfo = @{kTKPDDETAIL_DATAINDEXKEY:@(indexPath.row)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUnreadTalk" object:nil userInfo:userInfo];
    
    UIViewController* containerViewController = (UIViewController*)_delegate;
    UIViewController* master = containerViewController.splitViewController.viewControllers.firstObject;
    
    ProductTalkDetailViewController* detailVC = [[ProductTalkDetailViewController alloc] initByMarkingOpenedTalkAsRead:YES];
    detailVC.data = data;
    
    UINavigationController *detailNav = [[UINavigationController alloc]initWithRootViewController:detailVC];
    detailNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    detailNav.navigationBar.translucent = NO;
    detailNav.navigationBar.tintColor = [UIColor whiteColor];
    
    containerViewController.splitViewController.viewControllers = @[master, detailNav];
}

#pragma mark - Talk Cell Delegate
- (UITableView *)getTable {
    return self.table;
}

- (NSMutableArray *)getTalkList {
    return _talkList;
}

- (id)getNavigationController:(UITableViewCell *)cell {
    return _delegate;
}

- (NSInteger)getSegmentedIndex {
    return _currentTabSegmentIndex;
}

- (void)updateTalkStatusAtIndexPath:(NSIndexPath *)indexPath following:(BOOL)following {
    TalkList *talk = _talkList[indexPath.row];
    talk.talk_follow_status = following;
    talk.viewModel = nil;
}

#pragma mark - Refresh View 
- (void)refreshView:(UIRefreshControl*)refresh {
    [_networkManager requestCancel];
    _page = 1;
    
    [_talkList removeAllObjects];
    [_table reloadData];
    [_networkManager doRequest];
}

#pragma mark - Notification Handler
- (void)updateTotalComment:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY] integerValue];
    NSString *talkId = [userinfo objectForKey:TKPD_TALK_ID];
    
    if(index > _talkList.count) return;

    TalkList *list = _talkList[index];
    if ([talkId isEqualToString:list.talk_id]) {
        NSString *totalComment = [userinfo objectForKey:TKPD_TALK_TOTAL_COMMENT];
        list.talk_total_comment = [NSString stringWithFormat:@"%@", totalComment];
        list.viewModel = nil;
        [_table reloadData];
    }
}

- (void)updateDeletedTalk:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger index = [[userInfo objectForKey:@"index"] integerValue];
    [_talkList removeObjectAtIndex:index];
    [_table reloadData];
}

- (void)updateUnreadTalk : (NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    if(index >= _talkList.count) return;
    TalkList *list = _talkList[index];
    list.talk_read_status = @"2";
    list.viewModel = nil;
    
    NSIndexPath* updatedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_table reloadRowsAtIndexPaths:@[updatedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_table selectRowAtIndexPath:updatedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)reloadDataSource:(NSNotification *)notification {
    NSInteger currentSegmentedIndex = [[[notification object] objectForKey:TKPDTabViewSegmentedIndex] integerValue];
    _currentTabSegmentIndex = currentSegmentedIndex;
    
    NSInteger currentMenuIndex = [[[notification object] objectForKey:TKPDTabViewNavigationMenuIndex] integerValue];
    if (_currentTabMenuIndex != currentMenuIndex) {
        _currentTabMenuIndex = currentMenuIndex;
        if (_currentTabMenuIndex == 1) {
            _readStatus = @"unread";
        } else {
            _readStatus = @"all";
        }
        _page = 1;
        [_talkList removeAllObjects];
        [_table reloadData];
        [_networkManager requestCancel];
        [_networkManager doRequest];
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - GTM
- (void)configureGTM {
    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _inboxTalkBaseUrl = [_gtmContainer stringForKey:GTMKeyInboxTalkBase];
    _inboxTalkPostUrl = [_gtmContainer stringForKey:GTMKeyInboxTalkPost];
}

#pragma mark - Tokopedia Network Delegate 
- (NSDictionary *)getParameter:(int)tag {
    NSString *nav;
    if (self.inboxTalkType == InboxTalkTypeAll) {
        nav = NAV_TALK;
    } else if (self.inboxTalkType == InboxTalkTypeFollowing) {
        nav = NAV_TALK_FOLLOWING;
    } else {
        nav = NAV_TALK_MYPRODUCT;
    }
    
    NSDictionary* param = @{
                            kTKPDHOME_APIACTIONKEY:KTKPDTALK_ACTIONGET,
                            kTKPDHOME_APILIMITPAGEKEY : @10,
                            kTKPDHOME_APIPAGEKEY:@(_page)?:@1,
                            KTKPDMESSAGE_FILTERKEY:_readStatus?_readStatus:@"",
                            KTKPDMESSAGE_KEYWORDKEY:_keyword?_keyword:@"",
                            KTKPDMESSAGE_NAVKEY:nav
                            };
    return param;
}

- (NSString *)getPath:(int)tag {
    return [_inboxTalkPostUrl isEqualToString:@""] ? KTKPDMESSAGE_TALK : _inboxTalkPostUrl;
}

- (id)getObjectManager:(int)tag {
    if([_inboxTalkBaseUrl isEqualToString:kTkpdBaseURLString] || [_inboxTalkBaseUrl isEqualToString:@""]) {
        _requestTalkObject = [RKObjectManager sharedClient];
    } else {
        _requestTalkObject = [RKObjectManager sharedClient:_inboxTalkBaseUrl];
    }
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Talk class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TalkResult class]];
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TalkList class]];
    
    [listMapping addAttributeMappingsFromArray:@[
                                                 TKPD_TALK_PRODUCT_NAME,
                                                 TKPD_TALK_SHOP_ID,
                                                 TKPD_TALK_USER_IMG,
                                                 TKPD_TALK_PRODUCT_STATUS,
                                                 TKPD_TALK_CREATE_TIME,
                                                 TKPD_TALK_MESSAGE,
                                                 TKPD_TALK_FOLLOW_STATUS,
                                                 TKPD_TALK_READ_STATUS,
                                                 TKPD_TALK_TOTAL_COMMENT,
                                                 TKPD_TALK_USER_NAME,
                                                 TKPD_TALK_PRODUCT_ID,
                                                 TKPD_TALK_ID,
                                                 TKPD_TALK_PRODUCT_IMAGE,
                                                 TKPD_TALK_OWN,
                                                 TKPD_TALK_USER_ID,
                                                 TKPD_TALK_USER_LABEL,
                                                 TKPD_TALK_USER_LABEL_ID
                                                 ]];
    
    
    RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [reviewUserReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                 CNegative,
                                                                 CNoReputation,
                                                                 CNeutral,
                                                                 CPositif]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    // Relationship Mapping
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CTalkUserReputation toKeyPath:CTalkUserReputation withMapping:reviewUserReputationMapping]];
    
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
                                                                                             pathPattern:[_inboxTalkPostUrl isEqualToString:@""] ? KTKPDMESSAGE_TALK : _inboxTalkPostUrl
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_requestTalkObject addResponseDescriptor:responseDescriptorStatus];
    return _requestTalkObject;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    InboxTalk *inboxTalk = [mappingResult.dictionary objectForKey:@""];
    return inboxTalk.status;
}

- (void)actionBeforeRequest:(int)tag {
    if (_page != 1) {
        self.table.tableFooterView = _footer;
    } else {
        [_refreshControl beginRefreshing];
    }
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    [_refreshControl endRefreshing];
    
    InboxTalk *inboxTalk = [mappingResult.dictionary objectForKey:@""];
    
    if (_page == 1) {
        [_talkList removeAllObjects];
    }
    
    [_talkList addObjectsFromArray: inboxTalk.result.list];
    
    if (_talkList.count > 0) {
        _nextPageURL =  inboxTalk.result.paging.uri_next;
        if (![_nextPageURL isEqualToString:@"0"]) {
            _page = [[_networkManager splitUriToPage:_nextPageURL] integerValue];
        }
        self.table.tableFooterView = nil;
        [_noResultView removeFromSuperview];
        
        [self.table reloadData];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (isFirstShow) {
                isFirstShow = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    TalkCell* cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [cell tapToDetailTalk:cell];
                });
            }
        }
    } else {
        NSString *text;
        NSString *desc;
        
        if([_readStatus isEqualToString:@"all"]){
            if (self.inboxTalkType == InboxTalkTypeAll) {
                text = @"Segera ikuti diskusi produk terbaru yang Anda inginkan!";
                desc = @"";
            } else if (self.inboxTalkType == InboxTalkTypeFollowing) {
                text = @"Segera ikuti diskusi produk terbaru yang Anda inginkan!";
                desc = @"";
            } else if (self.inboxTalkType == InboxTalkTypeMyProduct) {
                text = @"Belum ada diskusi produk";
                desc = @"";
            }else{
                text = @"Belum ada diskusi produk";
                desc = @"";
            }
        }else{
            if (self.inboxTalkType == InboxTalkTypeAll) {
                text = @"Anda sudah membaca semua diskusi produk";
                desc = @"";
            } else if (self.inboxTalkType == InboxTalkTypeFollowing) {
                text = @"Anda sudah membaca semua diskusi produk";
                desc = @"";
            } else if (self.inboxTalkType == InboxTalkTypeMyProduct) {
                text = @"Anda sudah membaca semua diskusi produk";
                desc = @"";
            }else{
                text = @"Anda sudah membaca semua diskusi produk";
                desc = @"";
            }
        }
        [_noResultView setNoResultTitle:text];
        [_noResultView setNoResultDesc:desc];
        
        _table.tableFooterView = nil;
        [_table addSubview:_noResultView];
        [self.table reloadData];
    }
    
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

@end
