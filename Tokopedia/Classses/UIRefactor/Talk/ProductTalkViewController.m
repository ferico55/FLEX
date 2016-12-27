//
//  ProductTalkViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Talk.h"
#import "CMPopTipView.h"
#import "string_product.h"
#import "detail.h"
#import "GeneralAction.h"
#import "ProductTalkViewController.h"
#import "ProductTalkDetailViewController.h"
#import "ProductTalkFormViewController.h"
#import "TKPDSecureStorage.h"
#import "stringrestkit.h"
#import "URLCacheController.h"
#import "GeneralAction.h"
#import "UserAuthentificationManager.h"
#import "ReportViewController.h"
#import "TokopediaNetworkManager.h"
#import "NoResultView.h"
#import "ReputationDetail.h"
#import "SmileyAndMedal.h"
#import "string_inbox_talk.h"
#import "string_inbox_message.h"
#import "stringrestkit.h"
#import "inbox.h"
#import "string.h"

#import "TalkCell.h"

#pragma mark - Product Talk View Controller
@interface ProductTalkViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, TalkCellDelegate>
{
    NSMutableArray *_list;
    BOOL _isnodata;

    NSInteger _page;
    NSString *_urinext;
    NSIndexPath *selectedIndexPath;
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    
    Talk *_talk;

    NSString *_product_id;
    UserAuthentificationManager *_userManager;
    ReportViewController *_reportController;
    NoResultView *_noResultView;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *header;

@property (weak, nonatomic) IBOutlet UILabel *productnamelabel;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@end

@implementation ProductTalkViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        self.title = kTKPDTITLE_TALK;
    }
    
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    _page = 1;

    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;

    _list = [NSMutableArray new];
    _userManager = [UserAuthentificationManager new];
    _noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    _product_id = [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY]?:0;

    if (_list.count > 2) {
        _isnodata = NO;
    }

    _table.tableHeaderView = _header;

    UINib *talkCellNib = [UINib nibWithNibName:@"TalkProductCell" bundle:nil];
    [_table registerNib:talkCellNib forCellReuseIdentifier:@"TalkProductCellIdentifier"];
    
    _table.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    
    [self setRightBarButton];
    
    [self setHeaderData:_data];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    /** init notification*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotalComment:) name:@"UpdateTotalComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTalk:) name:@"UpdateTalk" object:nil];

    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // UA
    [AnalyticsManager trackScreenName:@"Product - Talk List"];
}

- (void)setRightBarButton {
    NSString *shopID = [NSString stringWithFormat:@"%@", [_userManager getShopId]];
    BOOL isLogin = [_userManager isLogin];
    if(isLogin && ![shopID isEqual:[_data objectForKey:TKPD_TALK_SHOP_ID]]) {
        NSBundle *bundle = [NSBundle mainBundle];
        UIBarButtonItem *addButton;
        UIImage *imgadd = [UIImage imageNamed:@"icon_shop_addproduct"];

        UIImage * image = [imgadd imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        addButton = [[UIBarButtonItem alloc] initWithImage:image
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(createNewDiscussion)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
}

- (void)createNewDiscussion {
    ProductTalkFormViewController *vc = [ProductTalkFormViewController new];
    vc.data = @{
            kTKPDDETAIL_APIPRODUCTIDKEY:[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
            kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY:[_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY]?:@(0),
            kTKPDDETAILPRODUCT_APIIMAGESRCKEY:[_data objectForKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY]?:@(0),
            TKPD_TALK_SHOP_ID:[_data objectForKey:TKPD_TALK_SHOP_ID]?:@(0),

    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TalkList* list = _list[indexPath.row];

    ProductTalkDetailViewController *controller = [ProductTalkDetailViewController new];
    controller.indexPath = indexPath;
    controller.talk = list;

    [self.navigationController pushViewController:controller animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TalkList *list = [_list objectAtIndex:indexPath.row];
    list.talk_product_id = _product_id;
    list.talk_product_name = [_data objectForKey:@"product_name"];
    list.talk_product_image = [_data objectForKey:@"talk_product_image"];
    list.talk_product_status = [_data objectForKey:@"talk_product_status"];
    
    TalkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TalkProductCellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    cell.talk = list;
    
    //next page if already last cell
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            [self loadData];
        }
    }
    
    return cell;
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    NSDictionary* param = @{
            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETPRODUCTTALKKEY,
            kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
            kTKPDDETAIL_APIPAGEKEY : @(_page)?:@1,
            kTKPDDETAIL_APILIMITKEY : @kTKPDDETAILDEFAULT_LIMITPAGE
    };

    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }

    [_networkManager requestWithBaseUrl:[NSString kunyitUrl]
                                   path:@"/v2/talk"
                                 method:RKRequestMethodGET
                              parameter:param
                                mapping:[Talk mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  [_act stopAnimating];
                                  _table.hidden = NO;
                                  _isrefreshview = NO;
                                  [_refreshControl endRefreshing];

                                  NSDictionary *result = successResult.dictionary;
                                  _talk = result[@""];
                                  [self onReceiveTalkList:_talk.result.list];
                              }
                              onFailure:^(NSError *errorResult) {
                                  [_act stopAnimating];
                                  _table.hidden = NO;
                                  _isrefreshview = NO;
                                  [_refreshControl endRefreshing];
                              }];
}

- (void)onReceiveTalkList:(NSArray<TalkList *> *)talkList {
    [_list addObjectsFromArray:talkList];

    if([_list count] > 0) {
        _urinext =  _talk.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_urinext] integerValue];

        _isnodata = NO;
        [_table reloadData];
    } else {
        _table.tableFooterView = _noResultView;
        _isnodata = YES;
    }
}

#pragma mark - Delegate

- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    return self;
}


-(void)setHeaderData:(NSDictionary*)data
{
    _productnamelabel.text = [data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY];
    _productnamelabel.numberOfLines = 1;
    
    _pricelabel.text = [data objectForKey:API_PRODUCT_PRICE_KEY];
}

-(void)refreshView:(UIRefreshControl*)refresh {
    [_list removeAllObjects];
    _page = 1;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self loadData];
}

#pragma mark - Notification Handler
- (void)updateTotalComment:(NSNotification*)notification{
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY] integerValue];
    NSString *talkId = [userinfo objectForKey:TKPD_TALK_ID];

    if(index > _list.count) return;
    
    TalkList *list = _list[index];
    if ([talkId isEqualToString:list.talk_id]) {
        NSString *totalComment = [userinfo objectForKey:TKPD_TALK_TOTAL_COMMENT];
        list.talk_total_comment = [NSString stringWithFormat:@"%@", totalComment];
        list.viewModel = nil;
        [_table reloadData];
    }
}

- (void)tapToDeleteTalk:(UITableViewCell *)cell {
    NSInteger index = [_table indexPathForCell:cell].row;
    [_list removeObjectAtIndex:index];
    [_table reloadData];
}

- (void)updateTalk:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    UserAuthentificationManager *user = [UserAuthentificationManager new];
    NSDictionary *auth = [user getUserLoginData];
    auth = [auth mutableCopy];
    if([userinfo objectForKey:@"talk_id"]) {
        NSInteger row = 0;
        if (_list.count == 0) {
            [self insertList:userinfo];
            TalkList *list = _list[row];
            list.talk_id = [userinfo objectForKey:TKPD_TALK_ID];
            list.talk_shop_id = [userinfo objectForKey:TKPD_TALK_SHOP_ID];
            list.disable_comment = NO;
            list.talk_user_id = [user.getUserId integerValue];
            list.talk_user_reputation = user.reputation;
        } else {
            TalkList *list = _list[row];
            if(list.talk_id !=nil && ![list.talk_id isEqualToString:@""]) {
                [self insertList:userinfo];
                list = _list[row];
                list.talk_id = [userinfo objectForKey:TKPD_TALK_ID];
                list.talk_shop_id = [userinfo objectForKey:TKPD_TALK_SHOP_ID];
                list.disable_comment = NO;
                list.talk_user_id = [user.getUserId integerValue];
            } else {
                list.talk_id = [userinfo objectForKey:TKPD_TALK_ID];
                list.talk_shop_id = [userinfo objectForKey:TKPD_TALK_SHOP_ID];
                list.disable_comment = NO;
                list.talk_user_id = [user.getUserId integerValue];
            }
        }
    } else {
        [self insertList:userinfo];
    }
    [_table reloadData];
}

- (void)insertList:(NSDictionary *)userinfo {
    UserAuthentificationManager *user = [UserAuthentificationManager new];
    NSDictionary *auth = [user getUserLoginData];
    
    ReputationDetail *reputation;
    if (user.reputation) {
        reputation = user.reputation;
    } else {
        reputation = [ReputationDetail new];
        reputation.positive_percentage = @"0";
    }
    
    TalkList *list = [TalkList new];
    list.talk_user_name = [auth objectForKey:kTKPD_FULLNAMEKEY];
    list.talk_total_comment = kTKPD_NULLCOMMENTKEY;
    list.talk_user_image = [auth objectForKey:kTKPD_USERIMAGEKEY];
    list.talk_user_id = [[auth objectForKey:kTKPD_USERIDKEY] intValue];
    list.talk_product_id = _product_id;
    list.talk_product_name = [_data objectForKey:@"product_name"];
    list.talk_product_image = [_data objectForKey:@"talk_product_image"];
    list.talk_product_status = [_data objectForKey:@"talk_product_status"];
    list.talk_user_label = CPengguna;
    list.talk_user_reputation = reputation;
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMMM yyyy, HH:mm"];
    
    list.talk_create_time = [dateFormat stringFromDate:today];
    list.talk_message = [userinfo objectForKey:TKPD_TALK_MESSAGE];
    
    list.disable_comment = YES;
    [_list insertObject:list atIndex:0];
    _isnodata = NO;
    _table.tableFooterView = nil;
}

#pragma mark - Talk Cell Delegate
- (id)getNavigationController:(UITableViewCell *)cell {
    return self;
}

- (UITableView *)getTable {
    return _table;
}

@end
