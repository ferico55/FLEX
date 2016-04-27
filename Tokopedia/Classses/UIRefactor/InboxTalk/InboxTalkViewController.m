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
#import "Tokopedia-Swift.h"
#import "NavigationHelper.h"

@interface InboxTalkViewController () <UITableViewDataSource, UITableViewDelegate, TKPDTabViewDelegate, UIAlertViewDelegate, TalkCellDelegate>

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

    NSIndexPath *_selectedIndexPath;
    NoResultReusableView *_noResultView;
    TAGContainer *_gtmContainer;
    UserAuthentificationManager *_userManager;

    NSInteger _currentTabMenuIndex;
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
    [self fetchInboxTalkList];
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
    cell.selectedTalkProductID = list.talk_product_id;
    cell.selectedTalkReputation = list.talk_user_reputation;
    cell.detailViewController = _detailViewController;
    cell.marksOpenedTalkAsRead = YES;
    cell.isSplitScreen = YES;
    cell.enableDeepNavigation = NO;
    
    cell.talk = list;
    
    //next page if already last cell
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_nextPageURL != NULL && ![_nextPageURL isEqualToString:@"0"] && _nextPageURL != 0) {
            [self fetchInboxTalkList];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showTalkCommentsAtIndexPath:indexPath];
}

- (void)showTalkCommentsAtIndexPath:(NSIndexPath *)indexPath {
    TalkList* list = _talkList[indexPath.row];

    NSDictionary *userInfo = @{kTKPDDETAIL_DATAINDEXKEY:@(indexPath.row)};

    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUnreadTalk" object:nil userInfo:userInfo];

    //TODO remove this delegate stuff
    UIViewController* containerViewController = (UIViewController*)_delegate;

    ProductTalkDetailViewController* detailVC = [[ProductTalkDetailViewController alloc] initByMarkingOpenedTalkAsRead:YES];
    detailVC.talk = list;
    detailVC.indexPath = indexPath;
    detailVC.enableDeepNavigation = [NavigationHelper shouldDoDeepNavigation];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController *detailNav = [[UINavigationController alloc]initWithRootViewController:detailVC];
        detailNav.navigationBar.translucent = NO;
        [containerViewController.splitViewController replaceDetailViewController:detailNav];
    } else {
        [containerViewController.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - Talk Cell Delegate
- (UITableView *)getTable {
    return self.table;
}

- (id)getNavigationController:(UITableViewCell *)cell {
    return _delegate;
}

- (void)tapToDeleteTalk:(UITableViewCell *)cell {
    NSInteger index = [_table indexPathForCell:cell].row;
    [_talkList removeObjectAtIndex:index];
    [_table reloadData];
}

#pragma mark - Refresh View 
- (void)refreshView:(UIRefreshControl*)refresh {
    [_networkManager requestCancel];
    _page = 1;
    
    [_talkList removeAllObjects];
    [_table reloadData];
    [self fetchInboxTalkList];
}

- (void)fetchInboxTalkList {
    [self showLoadingIndicator];

    [_networkManager requestWithBaseUrl:[NSString basicUrl]
                                   path:KTKPDMESSAGE_TALK
                                 method:RKRequestMethodPOST
                              parameter:[self requestParameter]
                                mapping:[Talk mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  [self onReceiveTalkList:successResult];
                              }
                              onFailure:^(NSError *errorResult) {

                              }];
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
        [self fetchInboxTalkList];
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
    
    [_gtmContainer stringForKey:GTMKeyInboxTalkBase];
    [_gtmContainer stringForKey:GTMKeyInboxTalkPost];
}

- (NSDictionary *)requestParameter {
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

- (void)showLoadingIndicator {
    if (_page != 1) {
        self.table.tableFooterView = _footer;
    } else {
        [_refreshControl beginRefreshing];
    }
}

- (void)onReceiveTalkList:(RKMappingResult *)mappingResult {
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
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [_table selectRowAtIndexPath:indexPath
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionNone];
                    [self showTalkCommentsAtIndexPath:indexPath];
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

@end
