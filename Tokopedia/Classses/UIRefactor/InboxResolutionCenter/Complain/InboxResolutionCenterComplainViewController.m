//
//  InboxResolutionCenterComplainViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NavigateViewController.h"

#import "InboxResolutionCenterComplainViewController.h"
#import "InboxResolutionCenterComplainCell.h"
#import "InboxResolutionCenterObjectMapping.h"
#import "FilterComplainViewController.h"

#import "ResolutionCenterDetailViewController.h"
#import "TxOrderStatusViewController.h"

#import "GeneralTableViewController.h"

#import "ResolutionAction.h"

#import "TokopediaNetworkManager.h"

#define DATA_FILTER_PROCESS_KEY @"filter_process"
#define DATA_FILTER_READ_KEY @"filter_read"
#define DATA_FILTER_SORTING_KEY @"filter_sorting"

#define DATA_SELECTED_RESOLUTION_KEY @"selected_resolution"
#define DATA_SELECTED_INDEXPATH_RESOLUTION_KEY @"seleted_indexpath_resolution"

@interface InboxResolutionCenterComplainViewController ()<UITabBarControllerDelegate, UITableViewDataSource, GeneralTableViewControllerDelegate,FilterComplainViewControllerDelegate, ResolutionCenterDetailViewControllerDelegate, InboxResolutionCenterComplainCellDelegate, TokopediaNetworkManagerDelegate>
{
    NavigateViewController *_navigate;
    NSMutableArray *_list;
    NSString *_URINext;
    BOOL _isNodata;
    UIRefreshControl *_refreshControl;
    NSInteger _page;
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_dataInput;
    
    InboxResolutionCenterObjectMapping *_mapping;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectManagerCancelComplain;
    __weak RKManagedObjectRequestOperation *_requestCancelComplain;
    
    NSMutableArray *_objectCancelComplain;
    
    BOOL _isFirstAppear;
    
    TokopediaNetworkManager *_networkManager;
}
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation InboxResolutionCenterComplainViewController

-(instancetype)init{
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _navigate = [NavigateViewController new];
    _operationQueue = [NSOperationQueue new];
    _mapping = [InboxResolutionCenterObjectMapping new];
    _objectCancelComplain = [NSMutableArray new];
    
    _networkManager = [TokopediaNetworkManager new];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _networkManager.delegate = self;

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kembali" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = 10;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    if (_isMyComplain) {
        _tableView.tableHeaderView = _headerView;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    _tableView.estimatedRowHeight = 70.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self refreshRequest];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _networkManager.delegate = self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
}


- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

-(void)setFilterReadIndex:(NSInteger)filterReadIndex
{
    [_dataInput setObject:ARRAY_FILTER_UNREAD[filterReadIndex] forKey:DATA_FILTER_READ_KEY];
    if (_filterReadIndex != filterReadIndex) {
        _filterReadIndex = filterReadIndex;
        [self refreshRequest];
   }
}

-(IBAction)tap:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    NSString *filterProcess = [_dataInput objectForKey:DATA_FILTER_PROCESS_KEY];
    NSString *filterSort = [_dataInput objectForKey:DATA_FILTER_SORTING_KEY];
    
    if (button.tag == 10) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.title = @"Urutkan";
        controller.delegate = self;
        controller.senderIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        controller.objects = ARRAY_FILTER_SORT;
        controller.selectedObject = filterSort ?: ARRAY_FILTER_SORT[0];
        [self.navigationController pushViewController:controller animated:YES];
    }
    if (button.tag == 11) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.title = @"Filter";
        controller.delegate = self;
        controller.senderIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        controller.objects = ARRAY_FILTER_PROCESS;
        controller.selectedObject = filterProcess?:ARRAY_FILTER_PROCESS[0];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (button.tag == 12) {
        //Status Pemesanan
        TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
        vc.action = @"get_tx_order_status";
        vc.viewControllerTitle = @"Status Pemesanan";
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (button.tag == 13) {
        //Daftar Transaksi
        TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
        vc.action = @"get_tx_order_list";
        vc.viewControllerTitle = @"Daftar Transaksi";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate General View Controller
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 10) {
        [_dataInput setObject:object forKey:DATA_FILTER_SORTING_KEY];
    }
    if (indexPath.row == 11) {
        [_dataInput setObject:object forKey:DATA_FILTER_PROCESS_KEY];
    }
    
    [self refreshRequest];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isNodata ? 0 : _list.count;
}

-(void)finishComplain:(InboxResolutionCenterList *)resolution atIndexPath:(NSIndexPath *)indexPath
{
    [self refreshRequest];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //TODO:: add counter_30_days
    InboxResolutionCenterComplainCell* cell = nil;
    NSString *cellID = INBOX_RESOLUTION_CENTER_MY_COMPLAIN_CELL_IDENTIFIER;
    
    cell = (InboxResolutionCenterComplainCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [InboxResolutionCenterComplainCell newCell];
        cell.delegate = self;
    }
    
    ResolutionDetail *resolution = ((InboxResolutionCenterList*)_list[indexPath.row]).resolution_detail;
    cell.buyerNameLabel.text = _isMyComplain?resolution.resolution_shop.shop_name:resolution.resolution_customer.customer_name;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_isMyComplain?resolution.resolution_shop.shop_image:resolution.resolution_customer.customer_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.buyerProfileImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request
                 placeholderImage:_isMyComplain?[UIImage imageNamed:@"icon_default_shop.jpg"]:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    NSInteger lastSolutionType = [resolution.resolution_last.last_solution integerValue];
    NSString *lastSolution;
    
    if (lastSolutionType == SOLUTION_REFUND) {
        lastSolution = [NSString stringWithFormat:@"Pembelian dana kepada pembeli sebesar %@",resolution.resolution_last.last_refund_amt_idr];
    }
    else if (lastSolutionType == SOLUTION_RETUR) {
        lastSolution = [NSString stringWithFormat:@"Tukar barang sesuai pesanan"];
    }
    else if (lastSolutionType == SOLUTION_RETUR_REFUND) {
        lastSolution = [NSString stringWithFormat:@"Pembelian barang dan dana sebesar %@",resolution.resolution_last.last_refund_amt_idr];
    }
    else if (lastSolutionType == SOLUTION_SELLER_WIN) {
        lastSolution = [NSString stringWithFormat:@"Pengembalian dana penuh"];
    }
    else if (lastSolutionType == SOLUTION_SEND_REMAINING) {
        lastSolution = [NSString stringWithFormat:@"Kirimkan sisanya"];
    }
    else
        lastSolution = @"";
    
    cell.invoiceDateLabel.text = resolution.resolution_dispute.dispute_update_time;
    cell.invoiceNumberLabel.text = resolution.resolution_order.order_invoice_ref_num;
    [cell.lastStatusLabel setCustomAttributedText:lastSolution];
    cell.disputeStatus = resolution.resolution_dispute.dispute_status;
    cell.buyerOrSellerLabel.text = _isMyComplain?@"Pembelian dari":@"Pembelian oleh";
    cell.indexPath = indexPath;
    
    cell.warningLabel.hidden = !(resolution.resolution_dispute.dispute_30_days == 1);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        return 227;
    }
    return UITableViewAutomaticDimension;

}


#pragma mark - Cell Delegate
-(void)goToInvoiceAtIndexPath:(NSIndexPath *)indexPath
{
    InboxResolutionCenterList *resolution = _list[indexPath.row];
    [_navigate navigateToInvoiceFromViewController:self withInvoiceURL:resolution.resolution_detail.resolution_order.order_pdf_url];
}

-(void)goToShopOrProfileAtIndexPath:(NSIndexPath *)indexPath
{
    InboxResolutionCenterList *resolution = _list[indexPath.row];
    if (_isMyComplain)
    {
        //gotoshop
        [_navigate navigateToShopFromViewController:self withShopID:(resolution.resolution_detail.resolution_shop.shop_id)?:@""];
    }
    else
    {
        //gotoProfile
        [_navigate navigateToProfileFromViewController:self withUserID:(resolution.resolution_detail.resolution_customer.customer_id)?:@""];
        
    }
}


-(void)showImageAtIndexPath:(NSIndexPath *)indexPath
{
    InboxResolutionCenterList *resolution = _list[indexPath.row];

    NSString *imageURLString = @"";
    if (_isMyComplain)
        imageURLString = resolution.resolution_detail.resolution_shop.shop_image;
    else
        imageURLString = resolution.resolution_detail.resolution_customer.customer_image;

    [_navigate navigateToShowImageFromViewController:self withImageURLStrings:@[imageURLString] indexImage:0];
}

-(void)goToResolutionDetailAtIndexPath:(NSIndexPath *)indexPath
{
    ResolutionCenterDetailViewController *vc = [ResolutionCenterDetailViewController new];
    InboxResolutionCenterList *resolution = _list[indexPath.row];
    vc.indexPath = indexPath;
    vc.resolution = resolution;
    vc.resolutionID = [resolution.resolution_detail.resolution_last.last_resolution_id stringValue];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResolutionCenterDetailViewController *vc = [ResolutionCenterDetailViewController new];
    InboxResolutionCenterList *resolution = _list[indexPath.row];
    vc.indexPath = indexPath;
    vc.resolution = resolution;
    vc.resolutionID = [resolution.resolution_detail.resolution_last.last_resolution_id stringValue];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"%ld", (long)row);
        
        if (_URINext != NULL && ![_URINext isEqualToString:@"0"] && _URINext != 0) {
            [_networkManager doRequest];
        }
    }
}

#pragma mark - Cell Delegate

-(void)refreshRequest
{
    _page = 1;
    [_networkManager doRequest];
}

#pragma mark - Delegate
-(void)shouldCancelComplain:(InboxResolutionCenterList *)resolution atIndexPath:(NSIndexPath*)indexPath
{
    [self configureRestKitCancelComplain];
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:resolution forKey:DATA_SELECTED_RESOLUTION_KEY];
    [object setObject:indexPath forKey:DATA_SELECTED_INDEXPATH_RESOLUTION_KEY];
    [self requestCancelComplain:object];
}

#pragma mark - Request List

-(id)getObjectManager:(int)tag
{
    _objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[InboxResolutionCenter class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxResolutionCenterResult class]];
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[InboxResolutionCenterList class]];
    [listMapping addAttributeMappingsFromArray:@[API_RESOLUTION_READ_STATUS_KEY]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIURINEXTKEY:kTKPD_APIURINEXTKEY,
                                                        }];
    RKObjectMapping *resolutionDetailMapping = [RKObjectMapping mappingForClass:[ResolutionDetail class]];
    
    RKObjectMapping *resolutionLastMapping = [_mapping resolutionLastMapping];
    RKObjectMapping *resolutionOrderMapping = [_mapping resolutionOrderMapping];
    RKObjectMapping *resolutionByMapping = [_mapping resolutionByMapping];
    RKObjectMapping *resolutionShopMapping = [_mapping resolutionShopMapping];
    RKObjectMapping *resolutionCustomerMapping = [_mapping resolutionCustomerMapping];
    RKObjectMapping *resolutionDisputeMapping = [_mapping resolutionDisputeMapping];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    RKRelationshipMapping *listRel =[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                toKeyPath:kTKPD_APILISTKEY
                                                                              withMapping:listMapping];
    
    RKRelationshipMapping *pagingRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY
                                                                                   toKeyPath:kTKPD_APIPAGINGKEY
                                                                                 withMapping:pagingMapping];
    
    RKRelationshipMapping *resolutionDetailRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_DETAIL_KEY
                                                                                              toKeyPath:API_RESOLUTION_DETAIL_KEY
                                                                                            withMapping:resolutionDetailMapping];
    
    RKRelationshipMapping *resolutionLastRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_LAST_KEY
                                                                                      toKeyPath:API_RESOLUTION_LAST_KEY
                                                                                    withMapping:resolutionLastMapping];
    
    RKRelationshipMapping *resolutionOrderRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_ORDER_KEY
                                                                                          toKeyPath:API_RESOLUTION_ORDER_KEY
                                                                                        withMapping:resolutionOrderMapping];
    
    RKRelationshipMapping *resolutionByRel= [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_BY_KEY
                                                                                          toKeyPath:API_RESOLUTION_BY_KEY
                                                                                        withMapping:resolutionByMapping];
    
    RKRelationshipMapping *resolutionShopRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_SHOP_KEY
                                                                                      toKeyPath:API_RESOLUTION_SHOP_KEY
                                                                                    withMapping:resolutionShopMapping];
    
    RKRelationshipMapping *resolutionCustomerRel= [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_CUSTOMER_KEY
                                                                                          toKeyPath:API_RESOLUTION_CUSTOMER_KEY
                                                                                        withMapping:resolutionCustomerMapping];
    
    RKRelationshipMapping *resolutionDisputeRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_DISPUTE_KEY
                                                                                          toKeyPath:API_RESOLUTION_DISPUTE_KEY
                                                                                        withMapping:resolutionDisputeMapping];
    
    
    [statusMapping addPropertyMapping:resultRel];
    
    [resultMapping addPropertyMapping:listRel];
    [resultMapping addPropertyMapping:pagingRel];
    
    [listMapping addPropertyMapping:resolutionDetailRel];
    
    [resolutionDetailMapping addPropertyMapping:resolutionLastRel];
    [resolutionDetailMapping addPropertyMapping:resolutionOrderRel];
    [resolutionDetailMapping addPropertyMapping:resolutionByRel];
    [resolutionDetailMapping addPropertyMapping:resolutionShopRel];
    [resolutionDetailMapping addPropertyMapping:resolutionCustomerRel];
    [resolutionDetailMapping addPropertyMapping:resolutionDisputeRel];
 
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_INBOX_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

-(NSDictionary *)getParameter:(int)tag
{
    NSString *filterProcess = [_dataInput objectForKey:DATA_FILTER_PROCESS_KEY];
    NSString *filterRead = ARRAY_FILTER_UNREAD[_filterReadIndex];
    NSString *filterSort = [_dataInput objectForKey:DATA_FILTER_SORTING_KEY];
    
    NSString *status = @"";
    NSString *unread = @"";
    NSString *sortType = @"";
    
    if ([filterProcess isEqualToString:ARRAY_FILTER_PROCESS[0]])
        status = @"0";
    else if([filterProcess isEqualToString:ARRAY_FILTER_PROCESS[1]])
        status = @"1";
    else if ([filterProcess isEqualToString:ARRAY_FILTER_PROCESS[2]])
        status = @"2";
    
    if ([filterRead isEqualToString:ARRAY_FILTER_UNREAD[0]])
        unread = @"0";
    else if([filterRead isEqualToString:ARRAY_FILTER_UNREAD[1]])
        unread = @"1";
    else if ([filterRead isEqualToString:ARRAY_FILTER_UNREAD[2]])
        unread = @"2";
    
    if ([filterSort isEqualToString:ARRAY_FILTER_SORT[0]])
        sortType = @"2";
    else if([filterSort isEqualToString:ARRAY_FILTER_SORT[1]])
        sortType = @"1";
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_RESOLUTION_CENTER,
                            API_COMPLAIN_TYPE_KEY : _isMyComplain?@(0):@(1),
                            API_STATUS_KEY : status,
                            API_UNREAD_KEY : unread,
                            API_SORT_KEY :sortType,
                            API_PAGE_KEY :@(_page)
                            };
    return param;
}

-(NSString *)getPath:(int)tag
{
    return API_PATH_INBOX_RESOLUTION_CENTER;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    InboxResolutionCenter *order = stat;
    
    return order.status;
}

-(void)actionBeforeRequest:(int)tag
{
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id stat = [result objectForKey:@""];
    InboxResolutionCenter *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(order.message_error)
        {
            NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
        }
        else{
            if (_page == 1) {
                [_list removeAllObjects];
            }
            
            if (order.result.list.count >0) {
                [_list addObjectsFromArray:order.result.list];
                _isNodata = NO;
                _URINext =  order.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:_URINext];
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
                
                _page = [[queries objectForKey:API_PAGE_KEY] integerValue];
            }
            else
            {
                NoResultView *noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 103)];
                _tableView.tableFooterView = noResultView;
            }
            
            [_tableView reloadData];
        }
    }
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    [_refreshControl endRefreshing];
    [_act stopAnimating];
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    [_refreshControl endRefreshing];
    [_act stopAnimating];
}

#pragma mark - Request Cancel Complain
-(void)cancelRequestCancelComplain
{
    [_requestCancelComplain cancel];
    //_requestCancelComplain = nil;
    [_objectManagerCancelComplain.operationQueue cancelAllOperations];
    _objectManagerCancelComplain = nil;
}

-(void)configureRestKitCancelComplain
{
    _objectManagerCancelComplain = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ResolutionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ResolutionActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    
    [statusMapping addPropertyMapping:resultRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerCancelComplain addResponseDescriptor:responseDescriptor];
}

-(void)requestCancelComplain:(NSDictionary *)object
{
    if (_requestCancelComplain.isExecuting) return;
    
    InboxResolutionCenterList *resolution = [object objectForKey:DATA_SELECTED_RESOLUTION_KEY];
    [_list removeObject:resolution];
    [_tableView reloadData];
    [_objectCancelComplain addObject:object];
    
    NSTimer *timer;
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_CANCEL_RESOLUTION,
                            API_RESOLUTION_ID_KEY : resolution.resolution_detail.resolution_last.last_resolution_id?:@"",
                            };
    
//#if DEBUG
//    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
//    NSDictionary* auth = [secureStorage keychainDictionary];
//    
//    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
//    
//    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
//    [paramDictionary addEntriesFromDictionary:param];
//    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
//    [paramDictionary setObject:userID forKey:kTKPD_USERIDKEY];
//    
//    _requestCancelComplain = [_objectManagerCancelComplain appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_RESOLUTION_CENTER parameters:paramDictionary];
//#else
    _requestCancelComplain = [_objectManagerCancelComplain appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_RESOLUTION_CENTER parameters:[param encrypt]];
//#endif
    
    [_requestCancelComplain setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessCancelComplain:object withOperation:operation withMappingResult:mappingResult];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureCancelComplain:object withErrorMessage:@[error.localizedDescription]];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestCancelComplain];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessCancelComplain:(NSDictionary*)object withOperation:(RKObjectRequestOperation *)operation withMappingResult:(RKMappingResult*)mappingResult
{
    NSDictionary *result = mappingResult.dictionary;
    id stat = [result objectForKey:@""];
    ResolutionAction *resolution = stat;
    BOOL status = [resolution.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(resolution.message_error)
        {
            [self requestFailureCancelComplain:object withErrorMessage:resolution.message_error];
        }
        else if (resolution.result.is_success == 1) {
            StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:resolution.message_status?:@[@"Sukses"] delegate:self];
            [alert show];
            [_objectCancelComplain removeObject:object];
        }
        else
        {
            [self requestFailureCancelComplain:object withErrorMessage:@[@"Error"]];
        }
    }
    else
    {
        [self requestFailureCancelComplain:object withErrorMessage:@[resolution.status]];
    }
    
    [self requestProcessCancelComplain];
}

-(void)requestFailureCancelComplain:(NSDictionary*)object withErrorMessage:(NSArray*)error
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:error delegate:self];
    [alert show];
        
    InboxResolutionCenterList *resolution = [object objectForKey:DATA_SELECTED_RESOLUTION_KEY];
    NSIndexPath *indexPathResolution = [object objectForKey:DATA_SELECTED_INDEXPATH_RESOLUTION_KEY];
    [_list insertObject:resolution atIndex:indexPathResolution.row];
    [_objectCancelComplain removeObject:object];
    [_tableView reloadData];
}

-(void)requestProcessCancelComplain
{
    if (_objectCancelComplain.count>0) {
        [self configureRestKitCancelComplain];
        [self requestCancelComplain:[_objectCancelComplain firstObject]];
    }
}

-(void)requestTimeoutCancelComplain
{
    //[self cancelRequestCancelComplain];
}


@end
