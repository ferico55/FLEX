//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopTalkPageViewController.h"

#import "Talk.h"
#import "GeneralAction.h"
#import "InboxTalk.h"

#import "string_home.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "detail.h"

#import "ReputationDetail.h"
#import "NoResultReusableView.h"
#import "NSString+HTML.h"
#import "UserAuthentificationManager.h"
#import "TalkCell.h"
#import "ShopPageRequest.h"
#import "ProductTalkDetailViewController.h"

#import "Tokopedia-Swift.h"

@interface ShopTalkPageViewController () <UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
TalkCellDelegate,
UIAlertViewDelegate,
ShopTabChild>

@property (strong, nonatomic) IBOutlet UIView *footer;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *list;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;


@end

@implementation ShopTalkPageViewController
{
    BOOL _isNoData;
    BOOL _isrefreshview;
    BOOL _iseditmode;

    NSInteger _page;
    NSInteger _limit;
    NSInteger _viewposition;

    NSMutableDictionary *_paging;

    NSString *_uriNext;
    NSString *_talkNavigationFlag;

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
    NoResultReusableView *_noResultView;
    UserAuthentificationManager *_userManager;
    ShopPageRequest *_shopPageRequest;


    __weak RKObjectManager *_objectManager;

    __weak RKManagedObjectRequestOperation *_request;

    NSOperationQueue *_operationQueue;


    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    Talk *_talk;
    Shop *_shop;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isNoData = YES;
    }

    return self;
}
- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    [_noResultView generateAllElements:nil
                                 title:@"Toko ini belum mempunyai diskusi produk"
                                  desc:@""
                              btnTitle:nil];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalComment:)
                                                 name:@"UpdateTotalComment" object:nil];

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

    [self addBottomInsetWhen14inch];

    _talkNavigationFlag = [_data objectForKey:@"nav"];

    _page = 1;

    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _list = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    [self initNoResultView];

    _table.delegate = self;
    _table.dataSource = self;

    _shopPageRequest = [[ShopPageRequest alloc]init];

    _table.tableFooterView = _footer;

    // hack to fix y offset
    UIView *dummy = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _table.tableHeaderView = dummy;

    [_refreshControl addTarget:self
                        action:@selector(refreshView:)
              forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];

    _table.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);

    if (_list.count > 0) {
        _isNoData = NO;
    }

    UINib *cellNib = [UINib nibWithNibName:@"TalkCell" bundle:nil];
    [_table registerNib:cellNib forCellReuseIdentifier:@"TalkCellIdentifier"];

    [self initNotification];
    [self requestTalk];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _userManager = [UserAuthentificationManager new];

    [AnalyticsManager trackScreenName:@"Shop - Talk List"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isNoData ? 0 : _list.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TalkList *list = [_list objectAtIndex:indexPath.row];

    ProductTalkDetailViewController *viewController = [ProductTalkDetailViewController new];
    viewController.indexPath = indexPath;
    viewController.talk = list;

    [self.navigationController pushViewController:viewController animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TalkList *list = [_list objectAtIndex:indexPath.row];

    TalkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TalkCellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    cell.talk = list;

    //next page if already last cell
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            [self requestTalk];
        }
    }

    return cell;
}

#pragma mark - Request

-(void)requestTalk{
    [_noResultView removeFromSuperview];

    [_shopPageRequest requestForShopTalkPageListingWithShopId:[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0)
                                                         page:_page
                                                  shop_domain:[_data objectForKey:@"shop_domain"]?:@""
                                                    onSuccess:^(Talk *talk) {
                                                        _talk = talk;
                                                        NSArray *list = _talk.result.list;
                                                        if(_page == 1)
                                                            [_list removeAllObjects];

                                                        [_list addObjectsFromArray:list];

                                                        _uriNext =  _talk.result.paging.uri_next;

                                                        if(_uriNext == nil || [_uriNext isEqualToString:@""]){
                                                            [_footer setHidden:YES];
                                                        }else{
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
                                                        }

                                                        _isNoData = NO;

                                                        [_table reloadData];
                                                        if (_list.count == 0) {
                                                            _act.hidden = YES;
                                                            [self.view addSubview:_noResultView];
                                                        }
                                                        [_refreshControl endRefreshing];
                                                    } onFailure:^(NSError *error) {
                                                        [_act stopAnimating];
                                                        self.table.tableFooterView = nil;
                                                        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Kendala koneksi internet"] delegate:self];
                                                        [alert show];

                                                        [_refreshControl endRefreshing];
                                                    }];
}



#pragma mark - Refresh View
-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    _requestCount = 0;
    [_list removeAllObjects];
    _page = 1;
    _isrefreshview = YES;

    [_table reloadData];
    /** request data **/
    [self requestTalk];
}

- (void)refreshContent {
    [self refreshView:nil];
}

#pragma mark - Notification Handler
- (void)updateTotalComment:(NSNotification*)notification{
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    NSString *talkId = [userinfo objectForKey:TKPD_TALK_ID];

    if(index > _list.count) return;

    TalkList *list = _list[index];
    if ([talkId isEqualToString:list.talk_id]) {
        NSString *totalComment = [userinfo objectForKey:TKPD_TALK_TOTAL_COMMENT];
        list.talk_total_comment = [NSString stringWithFormat:@"%@", totalComment];
        [_table reloadData];
    }
}

- (void)tapToDeleteTalk:(UITableViewCell *)cell {
    NSInteger index = [_table indexPathForCell:cell].row;
    [_list removeObjectAtIndex:index];
    [_table reloadData];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - Shop Header Delegate

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
#pragma mark - Talk Cell Delegate
- (id)getNavigationController:(UITableViewCell *)cell {
    return self;
}

- (UITableView *)getTable {
    return _table;
}

- (void)refreshTalks {
    _page = 1;
    [self requestTalk];
}

@end
