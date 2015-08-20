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
#import "GeneralTalkCell.h"
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

#import "TalkCell.h"

#define CTagDeleteAlert 12
#define CTagDeleteMessage 13

#pragma mark - Product Talk View Controller
@interface ProductTalkViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, TokopediaNetworkManagerDelegate, TalkCellDelegate>
{
    NSMutableArray *_list;
    NSArray *_headerimages;
    NSInteger _requestcount;
    NSInteger _requestUnfollowCount;
    NSInteger _pageheaderimages;
    NSTimer *_timer;
    BOOL _isnodata;
    
    CMPopTipView *cmPopTitpView;
    NSInteger _page;
    NSInteger _limit;
    NSString *_urinext;
    NSIndexPath *selectedIndexPath;
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    
    Talk *_talk;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    NSTimeInterval _timeinterval;
    NSString *product_id;
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


-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

-(IBAction)tap:(id)sender;

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
    
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _userManager = [UserAuthentificationManager new];
    _noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    
    _table.tableHeaderView = _header;
    
    //UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
//    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
//    barButtonItem.tag = 10;
//    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //right button

    NSString *shopID = [NSString stringWithFormat:@"%@", [_userManager getShopId]];
    NSString *userID = [NSString stringWithFormat:@"%@", [_userManager getUserId]];
    if(![userID isEqualToString:@"0"] && ![shopID isEqual:[_data objectForKey:TKPD_TALK_SHOP_ID]]) {

        UIBarButtonItem *rightbar;
        UIImage *imgadd = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon_shop_addproduct" ofType:@"png"]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
            UIImage * image = [imgadd imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            rightbar = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        }
        else
            rightbar = [[UIBarButtonItem alloc] initWithImage:imgadd style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        [rightbar setTag:11];
        self.navigationItem.rightBarButtonItem = rightbar;
    }
    
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    [self setHeaderData:_data];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    /** init notification*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotalComment:) name:@"UpdateTotalComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTalk:) name:@"UpdateTalk" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeletedTalk:) name:@"TokopediaDeleteInboxTalk" object:nil];
    
    UINib *talkCellNib = [UINib nibWithNibName:@"TalkProductCell" bundle:nil];
    [_table registerNib:talkCellNib forCellReuseIdentifier:@"TalkProductCellIdentifier"];
    
    product_id = [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY]?:0;
    
    [self configureRestKit];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Product - Talk List";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TalkList *list = [_list objectAtIndex:indexPath.row];
    list.talk_product_id = product_id;
    list.talk_product_name = [_data objectForKey:@"product_name"];
    list.talk_product_image = [_data objectForKey:@"talk_product_image"];
    list.talk_product_status = [_data objectForKey:@"talk_product_status"];
    
    TalkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TalkProductCellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    cell.selectedTalkShopID = list.talk_shop_id;
    cell.selectedTalkUserID = [NSString stringWithFormat:@"%ld", (long)list.talk_user_id];
    cell.selectedTalkProductID = list.talk_product_id;
    cell.selectedTalkReputation = list.talk_user_reputation;
    
    [cell setTalkViewModel:list.viewModel];
    
    //next page if already last cell
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            [self configureRestKit];
            [self loadData];
        }
    }
    
    return cell;
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10: {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11 : {
                //add new talk
                ProductTalkFormViewController *vc = [ProductTalkFormViewController new];
                vc.data = @{
                            kTKPDDETAIL_APIPRODUCTIDKEY:[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
                            kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY:[_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY]?:@(0),
                            kTKPDDETAILPRODUCT_APIIMAGESRCKEY:[_data objectForKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY]?:@(0),
                            TKPD_TALK_SHOP_ID:[_data objectForKey:TKPD_TALK_SHOP_ID]?:@(0),
                            
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
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

#pragma mark - Request and Mapping
- (void)cancel {
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Talk class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TalkResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TalkList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 TKPD_TALK_TOTAL_COMMENT,
                                                 TKPD_TALK_USER_IMG,
                                                 TKPD_TALK_USER_NAME,
                                                 TKPD_TALK_ID,
                                                 TKPD_TALK_CREATE_TIME,
                                                 TKPD_TALK_MESSAGE,
                                                 TKPD_TALK_FOLLOW_STATUS,
                                                 TKPD_TALK_SHOP_ID,
                                                 TKPD_TALK_USER_ID,
                                                 TKPD_TALK_USER_LABEL_ID,
                                                 TKPD_TALK_USER_LABEL
                                                 ]];
    
    RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [reviewUserReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                 CNoReputation,
                                                                 CNegative,
                                                                 CNeutral,
                                                                 CPositif]];

    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    // Relationship Mapping
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CTalkUserReputation toKeyPath:CTalkUserReputation withMapping:reviewUserReputationMapping]];

    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY toKeyPath:kTKPDDETAIL_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];

    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)loadData {
    if (_request.isExecuting) return;
    _requestcount++;
    
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
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILPRODUCT_APIPATH parameters:[param encrypt]];
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _table.hidden = NO;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _table.hidden = NO;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [self requestfailure:error];
    }];
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _talk = stats;
    BOOL status = [_talk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestprocess:object];
    }
}

- (void)requesttimeout {
    [self cancel];
}

- (void)requestfailure:(id)object {
    
}

- (void)requestprocess:(id)object {
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            
            _talk = stats;
            BOOL status = [_talk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _talk.result.list;
                [_list addObjectsFromArray:list];
                
                if([_list count] > 0) {
                    _urinext =  _talk.result.paging.uri_next;
                    NSURL *url = [NSURL URLWithString:_urinext];
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
                    
                    
                    _isnodata = NO;
                    [_table reloadData];
                } else {
                    _table.tableFooterView = _noResultView;
                    _isnodata = YES;
                }
                
                
                
            }
        }else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_act stopAnimating];
                    _table.tableFooterView = _noResultView;
                    NSError *error = object;
                    NSString *errorDescription = error.localizedDescription;
                    
                    if(error.code == -1011) {
                        errorDescription = CStringFailedInServer;
                    } else if (error.code==-1009 || error.code==-999) {
                        errorDescription = CStringNoConnection;
                    }
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [errorAlert show];
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = _noResultView;
                NSError *error = object;
                NSString *errorDescription = error.localizedDescription;
                
                if(error.code == -1011) {
                    errorDescription = CStringFailedInServer;
                } else if (error.code==-1009 || error.code==-999) {
                    errorDescription = CStringNoConnection;
                }
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}


#pragma mark - Delegate
- (void)GeneralTalkCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    ProductTalkDetailViewController *vc = [ProductTalkDetailViewController new];
    NSInteger row = indexpath.row;
    TalkList *list = _list[row];
    
    
    ReputationDetail *tempReputationDetail;
    if(list.talk_user_reputation == nil) {
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        NSDictionary* auth = [secureStorage keychainDictionary];
        auth = [auth mutableCopy];
        if(auth) {
            if([[auth objectForKey:@"user_id"] intValue] == list.talk_user_id) {
                NSData *data = [[auth objectForKey:@"user_reputation"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if(tempDict) {
                    tempReputationDetail = [ReputationDetail new];
                    tempReputationDetail.positive_percentage = [tempDict objectForKey:CPositivePercentage];
                    tempReputationDetail.negative = [tempDict objectForKey:CNegative];
                    tempReputationDetail.neutral = [tempDict objectForKey:CNeutral];
                    tempReputationDetail.positive = [tempDict objectForKey:CPositif];
                    tempReputationDetail.no_reputation = [tempDict objectForKey:CNoReputation];
                }
            }
        }
    }
    
    
    NSMutableDictionary *dictData = [NSMutableDictionary new];
    [dictData setObject:list.talk_message?:@0 forKey:TKPD_TALK_MESSAGE];
    [dictData setObject:list.talk_user_image?:@0 forKey:TKPD_TALK_USER_IMG];
    [dictData setObject:list.talk_create_time?:@0 forKey:TKPD_TALK_CREATE_TIME];
    [dictData setObject:list.talk_user_name?:@0 forKey:TKPD_TALK_USER_NAME];
    [dictData setObject:list.talk_id?:@0 forKey:TKPD_TALK_ID];
    [dictData setObject:[NSString stringWithFormat:@"%d", list.talk_user_id] forKey:TKPD_TALK_USER_ID];
    [dictData setObject:list.talk_total_comment?:@0 forKey:TKPD_TALK_TOTAL_COMMENT];
    [dictData setObject:list.talk_shop_id?:@0 forKey:TKPD_TALK_SHOP_ID];
    [dictData setObject:product_id forKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY];
    [dictData setObject:[_data objectForKey:@"talk_product_status"] forKey:TKPD_TALK_PRODUCT_STATUS];
    [dictData setObject:[_data objectForKey:@"talk_product_image"] forKey:TKPD_TALK_PRODUCT_IMAGE];
    [dictData setObject:[_data objectForKey:@"product_name"] forKey:TKPD_TALK_PRODUCT_NAME];
    
    //utk notification, apabila total comment bertambah, maka list ke INDEX akan berubah pula
    [dictData setObject:@(row)?:@0 forKey:kTKPDDETAIL_DATAINDEXKEY];
    
    if(list.talk_user_reputation!=nil && list.talk_user_label!=nil) {
        [dictData setObject:list.talk_user_label forKey:TKPD_TALK_USER_LABEL];
        [dictData setObject:list.talk_user_reputation forKey:TKPD_TALK_REPUTATION_PERCENTAGE];
    }
    else if(tempReputationDetail != nil){
        [dictData setObject:@"Pengguna" forKey:TKPD_TALK_USER_LABEL];
        [dictData setObject:tempReputationDetail forKey:TKPD_TALK_REPUTATION_PERCENTAGE];
    }
    
    vc.data = dictData;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    return self;
}


-(void)setHeaderData:(NSDictionary*)data
{
    _productnamelabel.text = [data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY];
    _productnamelabel.numberOfLines = 1;
    
    _pricelabel.text = [data objectForKey:API_PRODUCT_PRICE_KEY];
    _headerimages = [data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIMAGESKEY];
}

-(void)refreshView:(UIRefreshControl*)refresh {
    /** clear object **/
    [self cancel];
    _requestcount = 0;
    [_list removeAllObjects];
    _page = 1;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Notification Handler
- (void)updateTotalComment:(NSNotification*)notification{
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    if(index > _list.count) return;
    
    TalkList *list = _list[index];
    list.talk_total_comment = [NSString stringWithFormat:@"%@",[userinfo objectForKey:TKPD_TALK_TOTAL_COMMENT]];
    list.viewModel = nil;
    [_table reloadData];
}

- (void)updateDeletedTalk:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger index = [[userInfo objectForKey:@"index"] integerValue];
    
    [_list removeObjectAtIndex:index];
    [_table reloadData];
}

- (void)updateTalk:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    auth = [auth mutableCopy];
   
    
    if([userinfo objectForKey:@"talk_id"]) {
        NSInteger row = 0;
        if(_list.count == 0) {
            [self insertList:userinfo];

            TalkList *list = _list[row];
            list.talk_id = [userinfo objectForKey:TKPD_TALK_ID];
            list.talk_shop_id = [userinfo objectForKey:TKPD_TALK_SHOP_ID];
            list.disable_comment = NO;
            list.talk_user_id = [[auth objectForKey:kTKPD_USERIDKEY] intValue];
        }
        else {
            TalkList *list = _list[row];
            if(list.talk_id!=nil && ![list.talk_id isEqualToString:@""]) {
                [self insertList:userinfo];
                
                list = _list[row];
                list.talk_id = [userinfo objectForKey:TKPD_TALK_ID];
                list.talk_shop_id = [userinfo objectForKey:TKPD_TALK_SHOP_ID];
                list.disable_comment = NO;
                list.talk_user_id = [[auth objectForKey:kTKPD_USERIDKEY] intValue];
            }
            else {
                list.talk_id = [userinfo objectForKey:TKPD_TALK_ID];
                list.talk_shop_id = [userinfo objectForKey:TKPD_TALK_SHOP_ID];
                list.disable_comment = NO;
                list.talk_user_id = [[auth objectForKey:kTKPD_USERIDKEY] intValue];
            }
        }
    } else {
        [self insertList:userinfo];
    }
    
    
    [_table reloadData];
    
}

- (void)insertList:(NSDictionary *)userinfo {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    auth = [auth mutableCopy];
    
    ReputationDetail *repDetail = [ReputationDetail new];
    repDetail.positive_percentage = @"0";
    
    TalkList *list = [TalkList new];
    list.talk_user_name = [auth objectForKey:kTKPD_FULLNAMEKEY];
    list.talk_total_comment = kTKPD_NULLCOMMENTKEY;
    list.talk_user_image = [auth objectForKey:kTKPD_USERIMAGEKEY];
    list.talk_user_id = [[auth objectForKey:kTKPD_USERIDKEY] intValue];
    list.talk_product_id = product_id;
    list.talk_product_name = [_data objectForKey:@"product_name"];
    list.talk_product_image = [_data objectForKey:@"talk_product_image"];
    list.talk_product_status = [_data objectForKey:@"talk_product_status"];
    list.talk_user_label = CPengguna;
    list.talk_user_reputation = repDetail;
    
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

- (NSMutableArray *)getTalkList {
    return _list;
}

@end
