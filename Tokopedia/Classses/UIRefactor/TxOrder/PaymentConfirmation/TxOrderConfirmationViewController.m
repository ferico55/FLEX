//
//  TxOrderConfirmationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderObjectMapping.h"
#import "TxOrderConfirmPaymentForm.h"
#import "TxOrderCancelPaymentForm.h"

#import "NoResult.h"
#import "string_tx_order.h"

#import "TxOrderConfirmationViewController.h"
#import "TxOrderConfirmationDetailViewController.h"
#import "TxOrderConfirmationCell.h"
#import "TxOrderPaymentViewController.h"

#import "TxOrderPaymentViewController.h"

#import "TransactionAction.h"

#import "TokopediaNetworkManager.h"

@interface TxOrderConfirmationViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate ,TxOrderConfirmationCellDelegate, TxOrderConfirmationDetailViewControllerDelegate, TokopediaNetworkManagerDelegate, TxOrderPaymentViewControllerDelegate>
{
    NSInteger _page;
    NSMutableArray *_list;
    
    NSMutableDictionary *_dataInput;
    BOOL _isNodata;
    UIRefreshControl *_refreshControl;
    
    NSString *_URINext;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerGetTransaction;
    __weak RKManagedObjectRequestOperation *_requestGetTransaction;
    
    __weak RKObjectManager *_objectManagerCancelPayment;
    __weak RKManagedObjectRequestOperation *_requestCancelPayment;
    
    __weak RKObjectManager *_objectManagerCancelPaymentForm;
    __weak RKManagedObjectRequestOperation *_requestCancelPaymentForm;
    
    TxOrderObjectMapping *_mapping;
    
    NSMutableArray *_isSelectedOrders;
    NSMutableArray *_selectedOrders;
    NSMutableArray *_selectedIndextPath;
    NSMutableArray *_objectProcessingCancel;
    
    TokopediaNetworkManager *_networkManager;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *multipleSelectFooter;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmationButton;

@end

@implementation TxOrderConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _mapping = [TxOrderObjectMapping new];
    _isSelectedOrders = [NSMutableArray new];
    _selectedOrders = [NSMutableArray new];
    _selectedIndextPath = [NSMutableArray new];
    _objectProcessingCancel = [NSMutableArray new];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    _page = 1;
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    [_networkManager doRequest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRequest)
                                                 name:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     _networkManager.delegate = self;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _networkManager.delegate = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.title = @"";
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 10:
        {
            if ([_selectedOrders count]>0) {
                NSMutableArray *objects = [NSMutableArray new];
                for (int i = 0; i<_selectedOrders.count;i++) {
                    NSMutableDictionary *object = [NSMutableDictionary new];
                    [object setObject:_selectedOrders[i] forKey:DATA_SELECTED_ORDER_KEY];
                    [object setObject:_selectedIndextPath[i] forKey:DATA_INDEXPATH_SELECTED_ORDER];
                    [objects addObject:object];
                }
                if (![_objectProcessingCancel isEqualToArray:objects]) {
                    [_objectProcessingCancel addObjectsFromArray:objects];
                }
                
                [self configureRestKitCancelPaymentForm];
                [self requestCancelPaymentForm:objects alertDelegate:self];
            }
            else{
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"Pilih Payment terlebih dahulu" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }
            break;
        case 11:
        {
            if ([_selectedOrders count]>0) {
                TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
                vc.delegate = self;
                vc.data = @{DATA_SELECTED_ORDER_KEY : _selectedOrders};
                [self.navigationController pushViewController:vc animated:YES];
            }
            else{
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"Pilih Payment terlebih dahulu" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setIsMultipleSelection:(BOOL)isMultipleSelection
{
    _isMultipleSelection = isMultipleSelection;
    _multipleSelectFooter.hidden = !(_isMultipleSelection);
    if (!_isMultipleSelection) {
        _tableView.contentInset = UIEdgeInsetsZero;
        [_selectedOrders removeAllObjects];
        [_selectedIndextPath removeAllObjects];
        [_isSelectedOrders removeAllObjects];
        for (id selected in _list) {
            [_isSelectedOrders addObject:@(NO)];
        }
    }
    else _tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    [_tableView reloadData];
}

//-(void)setIsSelectAll:(BOOL)isSelectAll
//{
//    _isSelectAll = isSelectAll;
//    [_selectedOrders removeAllObjects];
//    [_isSelectedOrders removeAllObjects];
//    [_selectedOrders addObjectsFromArray:_list];
//    for (id selected in _list) {
//        [_isSelectedOrders addObject:@(isSelectAll)];
//    }
//    [_tableView reloadData];
//}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef TRANSACTION_SHIPMENT_ISNODATA_ENABLE
    return _isNodata ? 1 : _list.count;
#else
    return _isNodata ? 0 : _list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TxOrderConfirmationCell* cell = nil;
    NSString *cellid = TRANSACTION_ORDER_CONFIRMATION_CELL_IDENTIFIER;
    
    cell = (TxOrderConfirmationCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmationCell newcell];
        cell.delegate = self;
    }
    TxOrderConfirmationList *detailOrder = _list[indexPath.row];
    cell.deadlineDateLabel.text = detailOrder.confirmation.pay_due_date?:@"";
    cell.transactionDateLabel.text = detailOrder.confirmation.create_time?:@"";
    cell.shopNameLabel.text = detailOrder.confirmation.shop_list?:@"";
    cell.totalInvoiceLabel.text = detailOrder.confirmation.left_amount?:@"";
    cell.indexPath = indexPath;
    cell.selectionButton.hidden = !(_isMultipleSelection);
    cell.frameView.hidden = !(_isMultipleSelection);
    cell.selectionButton.selected = (([_isSelectedOrders count]-1)==indexPath.row)?[_isSelectedOrders[indexPath.row] boolValue]:NO;
    
    UIColor *selectedColor =[UIColor colorWithRed:18.0f/255.0f green:199.0f/255.0f blue:0.0f/255.0f alpha:1];
    UIColor *unSelectColor = [UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:1];
    UIColor *enableColor = [UIColor colorWithRed:117.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1];
    
    cell.cancelConfirmationButton.enabled = !(_isMultipleSelection);
    if (!cell.cancelConfirmationButton.enabled)
        [cell.cancelConfirmationButton setTitleColor:unSelectColor forState:UIControlStateNormal];
    else [cell.cancelConfirmationButton setTitleColor:enableColor forState:UIControlStateNormal];
    
    cell.confirmationButton.enabled = !(_isMultipleSelection);
    if (!cell.confirmationButton.enabled)
        [cell.confirmationButton setTitleColor:unSelectColor forState:UIControlStateNormal];
    else [cell.confirmationButton setTitleColor:enableColor forState:UIControlStateNormal];
    
    if (_isMultipleSelection)
    {
        [cell.cancelConfirmationButton setTintColor:unSelectColor];
        [cell.frameView setBackgroundColor:[_isSelectedOrders[indexPath.row] boolValue]?selectedColor:unSelectColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isMultipleSelection) {
        [_isSelectedOrders replaceObjectAtIndex:indexPath.row withObject:@(![_isSelectedOrders[indexPath.row] boolValue])];
        if ([_isSelectedOrders[indexPath.row] boolValue])
        {
            [_selectedOrders addObject:_list[indexPath.row]];
            [_selectedIndextPath addObject:indexPath];
        }
        else
        {
            [_selectedOrders removeObject:_list[indexPath.row]];
            [_selectedIndextPath removeObject:indexPath];
        }
        [_tableView reloadData];
    }
    else {
        TxOrderConfirmationDetailViewController *detailViewController = [TxOrderConfirmationDetailViewController new];
        detailViewController.indexPath = indexPath;
        detailViewController.data = @{DATA_SELECTED_ORDER_KEY:_list[indexPath.row]};
        detailViewController.delegate = self;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
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
            //[self configureRestKitGetTransaction];
            //[self requestGetTransaction];
        }
    }
}


#pragma mark - Cell delegate

- (void)selectCellConfirmationAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Delegate
-(void)shouldCancelOrderAtIndexPath:(NSIndexPath *)indexPath viewController:(TxOrderConfirmationDetailViewController*)viewController
{
    if (!_isMultipleSelection && !_requestCancelPayment.isExecuting) {
        [_selectedOrders addObject:_list[indexPath.row]];
        [_selectedIndextPath addObject:indexPath];
        
        NSMutableDictionary *object = [NSMutableDictionary new];
        [object setObject:_list[indexPath.row] forKey:DATA_SELECTED_ORDER_KEY];
        [object setObject:indexPath forKey:DATA_INDEXPATH_SELECTED_ORDER];
        
        if (![_objectProcessingCancel containsObject:object]) {
            [_objectProcessingCancel addObject:object];
        }
        
        [self configureRestKitCancelPaymentForm];
        [self requestCancelPaymentForm:@[object] alertDelegate:viewController];
    }
}

-(void)shouldCancelOrderAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isMultipleSelection && !_requestCancelPayment.isExecuting) {
        [_selectedOrders addObject:_list[indexPath.row]];
        [_selectedIndextPath addObject:indexPath];
        NSMutableDictionary *object = [NSMutableDictionary new];
        [object setObject:_list[indexPath.row] forKey:DATA_SELECTED_ORDER_KEY];
        [object setObject:indexPath forKey:DATA_INDEXPATH_SELECTED_ORDER];
        
        if (![_objectProcessingCancel containsObject:object]) {
            [_objectProcessingCancel addObject:object];
        }
        
        
        [self configureRestKitCancelPaymentForm];
        [self requestCancelPaymentForm:@[object] alertDelegate:self];
    }
}

-(void)didTapAlertCancelOrder
{
    [self actionCancelConfirmationObject:_objectProcessingCancel];
}

-(void)shouldConfirmOrderAtIndexPath:(NSIndexPath *)indexPath
{
    _confirmationButton.enabled = YES;
    if (!_isMultipleSelection && !_requestCancelPayment.isExecuting && !_requestCancelPaymentForm.isExecuting) {
        TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
        vc.data = @{DATA_SELECTED_ORDER_KEY : @[_list[indexPath.row]]};
        vc.delegate  = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self actionCancelConfirmationObject:_objectProcessingCancel];
    }
    //[_objectProcessingCancel removeAllObjects];
}

#pragma mark - Request Get Transaction Order Payment Confirmation

-(id)getObjectManager:(int)tag
{
    _objectManagerGetTransaction = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmation class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmationResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmationList class]];
    [listMapping addAttributeMappingsFromArray:@[API_TOTAL_EXTRA_FEE_PLAIN,
                                                 API_TOTAL_LOGISTIC_FEE_KEY,
                                                 API_TOTAL_EXTRA_FEE
                                                ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIURINEXTKEY:kTKPD_APIURINEXTKEY,
                                                        }];

    
    RKObjectMapping *confirmationMapping = [_mapping confirmationDetailMapping];
    RKObjectMapping *orderListMapping = [_mapping orderListMapping];
    RKObjectMapping *orderextraFeeMapping = [_mapping orderExtraFeeMapping];
    RKObjectMapping *orderProductMapping = [_mapping orderProductsMapping];
    RKObjectMapping *orderShopMapping = [_mapping orderShopMapping];
    RKObjectMapping *orderShipmentMapping = [_mapping orderShipmentsMapping];
    RKObjectMapping *orderDestinationMapping = [_mapping orderDestinationMapping];
    RKObjectMapping *orderDetailMapping = [_mapping orderDetailMapping];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    RKRelationshipMapping *listRel =[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                toKeyPath:kTKPD_APILISTKEY
                                                                              withMapping:listMapping];
    
    RKRelationshipMapping *pagingRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY
                                                                                   toKeyPath:kTKPD_APIPAGINGKEY
                                                                                 withMapping:pagingMapping];
    
    RKRelationshipMapping *orderConfirmationRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CONFIRMATION_KEY
                                                                                              toKeyPath:API_CONFIRMATION_KEY
                                                                                            withMapping:confirmationMapping];
    
    RKRelationshipMapping *orderListRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_LIST_KEY
                                                                                      toKeyPath:API_ORDER_LIST_KEY
                                                                                    withMapping:orderListMapping];
    
    RKRelationshipMapping *orderExtraFeeRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_EXTRA_FEE_KEY
                                                                                          toKeyPath:API_EXTRA_FEE_KEY
                                                                                        withMapping:orderextraFeeMapping];
    
    RKRelationshipMapping *orderproductsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_LIST_PRODUCTS_KEY
                                                                                          toKeyPath:API_ORDER_LIST_PRODUCTS_KEY
                                                                                        withMapping:orderProductMapping];
    
    RKRelationshipMapping *orderShopRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_LIST_SHOP_KEY
                                                                                      toKeyPath:API_ORDER_LIST_SHOP_KEY
                                                                                    withMapping:orderShopMapping];
    
    RKRelationshipMapping *orderShipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_LIST_SHIPMENT_KEY
                                                                                          toKeyPath:API_ORDER_LIST_SHIPMENT_KEY
                                                                                        withMapping:orderShipmentMapping];
    
    RKRelationshipMapping *orderDestinationRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_LIST_DESTINATION_KEY
                                                                                          toKeyPath:API_ORDER_LIST_DESTINATION_KEY
                                                                                        withMapping:orderDestinationMapping];
    
    RKRelationshipMapping *orderDetailRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_LIST_DETAIL_KEY
                                                                                          toKeyPath:API_ORDER_LIST_DETAIL_KEY
                                                                                        withMapping:orderDetailMapping];
    
    [statusMapping addPropertyMapping:resultRel];
    
    [resultMapping addPropertyMapping:listRel];
    [resultMapping addPropertyMapping:pagingRel];
    
    [listMapping addPropertyMapping:orderConfirmationRel];
    [listMapping addPropertyMapping:orderListRel];
    [listMapping addPropertyMapping:orderExtraFeeRel];
    
    [orderListMapping addPropertyMapping:orderproductsRel];
    [orderListMapping addPropertyMapping:orderShopRel];
    [orderListMapping addPropertyMapping:orderShipmentRel];
    [orderListMapping addPropertyMapping:orderDestinationRel];
    [orderListMapping addPropertyMapping:orderDetailRel];
 
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerGetTransaction addResponseDescriptor:responseDescriptor];
    
    return _objectManagerGetTransaction;
}

-(NSDictionary *)getParameter:(int)tag
{
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_TX_ORDER_PAYMENT_CONFIRMATION,
                            API_PAGE_KEY : @(_page)
                            };
    return param;
}

-(NSString *)getPath:(int)tag
{
    return API_PATH_TX_ORDER;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    TxOrderConfirmation *order = stat;
    return order.status;
}

- (void)actionBeforeRequest:(int)tag {
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    TxOrderConfirmed *order = [result objectForKey:@""];
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
    }
    
    if (_page == 1) {
        [_list removeAllObjects];
        [_isSelectedOrders removeAllObjects];
    }
    
    [_list addObjectsFromArray:order.result.list];
    
    if (_list.count >0) {
        _isNodata = NO;
        _URINext =  order.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_URINext] integerValue];
        
        for (int i = 0; i<_list.count; i++) {
            [_isSelectedOrders addObject:@(NO)];
        }
    }
    else
    {
        _isNodata = YES;
        NoResultView *noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        _tableView.tableFooterView = noResultView;
    }
    
    [_act stopAnimating];
    [_delegate isNodata:_isNodata];
    
    [_tableView reloadData];
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    [_refreshControl endRefreshing];
    _tableView.tableFooterView = _act;
}

#pragma mark - Request Cancel Payment Confirmation
-(void)cancelCancelPayment
{
    [_requestCancelPayment cancel];
    _requestCancelPayment = nil;
    [_objectManagerCancelPayment.operationQueue cancelAllOperations];
    _objectManagerCancelPayment = nil;
}

-(void)configureRestKitCancelPayment
{
    _objectManagerCancelPayment = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    [statusMapping addPropertyMapping:resultRel];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerCancelPayment addResponseDescriptor:responseDescriptor];
    
}

-(void)requestCancelPayment:(NSArray*)objects
{
    if (_requestCancelPayment.isExecuting) return;
    NSTimer *timer;
    
    NSMutableArray *confirmationIDs = [NSMutableArray new];

    for (NSDictionary *object in objects) {
        TxOrderConfirmationList *order =[object objectForKey:DATA_SELECTED_ORDER_KEY];
        [confirmationIDs addObject:order.confirmation.confirmation_id];
    }
    
    [_isSelectedOrders removeObject:@(YES)];
    [_tableView reloadData];
    
    NSString * confirmationID = [[confirmationIDs valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
   
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_CANCEL_PAYMENT,
                            API_CONFIRMATION_CONFIRMATION_ID_KEY: confirmationID,
                            };
    
//#if DEBUG
//    
//    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
//    NSDictionary* auth = [secureStorage keychainDictionary];
//    
//    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
//    
//    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
//    [paramDictionary addEntriesFromDictionary:param];
//    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
//    [paramDictionary setObject:userID?:@"" forKey:kTKPD_USERIDKEY];
//    
//    _requestCancelPayment = [_objectManagerCancelPayment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_TX_ORDER parameters:paramDictionary];//API_PATH_ACTION_TX_ORDER
//#else
    _requestCancelPayment = [_objectManagerCancelPayment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_TX_ORDER parameters:[param encrypt]];
//#endif
    
    [_requestCancelPayment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        [self requestSuccessCancelPayment:_objectProcessingCancel withOperation:operation withMappingResult:mappingResult];
        [_refreshControl endRefreshing];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureCancelPayment:_objectProcessingCancel withError:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        [_tableView reloadData];
        
    }];
    
    [_operationQueue addOperation:_requestCancelPayment];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutCancelPayment) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessCancelPayment:(NSArray*)objects withOperation:(RKObjectRequestOperation *)operation withMappingResult:(RKMappingResult*)mappingResult
{
    NSDictionary *result = mappingResult.dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (order.result.is_success == 1) {
            NSArray *array = order.message_status?:[[NSArray alloc] initWithObjects:@"Anda telah berhasil membatalkan konfirmasi pembayaran", nil];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
            
            NSDictionary *userInfo = @{DATA_PAYMENT_CONFIRMATION_COUNT_KEY:@(objects.count)};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:userInfo];
            [_delegate successCancelOrConfirmPayment];
            [self refreshRequest];
        }
        else
        {
            for (NSDictionary *object in objects) {
                TxOrderConfirmationList *order =[object objectForKey:DATA_SELECTED_ORDER_KEY];
                NSIndexPath *indexPath = [object objectForKey:DATA_INDEXPATH_SELECTED_ORDER];
                [_list insertObject:order atIndex:indexPath.row];
                [_isSelectedOrders addObject:@(NO)];
            }
            
            NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            [self showStickyAlertErrorMessage:array];
            
            [_isSelectedOrders addObject:@(NO)];
            [_tableView reloadData];
        }
    }
    else
    {
        for (NSDictionary *object in objects) {
            TxOrderConfirmationList *order =[object objectForKey:DATA_SELECTED_ORDER_KEY];
            NSIndexPath *indexPath = [object objectForKey:DATA_INDEXPATH_SELECTED_ORDER];
            [_list insertObject:order atIndex:indexPath.row];
            [_isSelectedOrders addObject:@(NO)];
        }
        [_tableView reloadData];
    }
    [self requestProcessCancelPayment];
}

-(void)requestFailureCancelPayment:(NSArray*)objects withError:(NSError*)error
{
    if (error && [error code] != NSURLErrorCancelled) {
        NSString *errorDescription = error.localizedDescription;
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
        [errorAlert show];
    }
    
    for (NSDictionary *object in objects) {
        TxOrderConfirmationList *order =[object objectForKey:DATA_SELECTED_ORDER_KEY];
        NSIndexPath *indexPath = [object objectForKey:DATA_INDEXPATH_SELECTED_ORDER];
        [_list insertObject:order atIndex:indexPath.row];
        [_isSelectedOrders addObject:@(NO)];
    }
    [_tableView reloadData];
    
    [self requestProcessCancelPayment];
}

-(void)requestProcessCancelPayment
{
    [_objectProcessingCancel removeAllObjects];
    
}

-(void)requestTimeoutCancelPayment
{
    [self cancelCancelPayment];
}

#pragma mark - Request Cancel Payment Form
-(void)cancelCancelPaymentForm
{
    [_requestCancelPaymentForm cancel];
    _requestCancelPaymentForm = nil;
    [_objectManagerCancelPaymentForm.operationQueue cancelAllOperations];
    _objectManagerCancelPaymentForm = nil;
}

-(void)configureRestKitCancelPaymentForm
{
    _objectManagerCancelPaymentForm = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TxOrderCancelPaymentForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TxOrderCancelPaymentResult class]];


    RKObjectMapping *formMapping = [RKObjectMapping mappingForClass:[TxOrderCancelPaymentFormForm class]];
    [formMapping addAttributeMappingsFromArray:@[API_CANCEL_FORM_VOUCHER_USED_KEY,
                                                 API_CANCEL_FORM_REFUND_KEY,
                                                 API_CANCEL_FORM_VOUCHERS_KEY,
                                                 API_CANCEL_FORM_TOTAL_REFUND_KEY
                                                 ]];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    RKRelationshipMapping *formRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"form" toKeyPath:@"form" withMapping:formMapping];
    
    [statusMapping addPropertyMapping:resultRel];
    [resultMapping addPropertyMapping:formRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerCancelPaymentForm addResponseDescriptor:responseDescriptor];
    
}

-(void)requestCancelPaymentForm:(NSArray*)objects alertDelegate:(UIViewController*)viewController
{
    if (_requestCancelPaymentForm.isExecuting) return;
    NSTimer *timer;
    
    NSMutableArray *confirmationIDs = [NSMutableArray new];
    
    for (NSDictionary *object in objects) {
        TxOrderConfirmationList *order =[object objectForKey:DATA_SELECTED_ORDER_KEY];
        [confirmationIDs addObject:order.confirmation.confirmation_id];
    }
    
    NSString * confirmationID = [[confirmationIDs valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_CANCEL_PAYMENT_FORM,
                            API_CONFIRMATION_CONFIRMATION_ID_KEY: confirmationID,
                            };
//#if DEBUG
//    
//    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
//    NSDictionary* auth = [secureStorage keychainDictionary];
//    
//    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
//    
//    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
//    [paramDictionary addEntriesFromDictionary:param];
//    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
//    [paramDictionary setObject:userID?:@"" forKey:kTKPD_USERIDKEY];
//    
//    _requestCancelPaymentForm = [_objectManagerCancelPaymentForm appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_TX_ORDER parameters:paramDictionary];
//#else
    _requestCancelPaymentForm = [_objectManagerCancelPaymentForm appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_TX_ORDER parameters:[param encrypt]];
//#endif
    
    [_requestCancelPaymentForm setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessCancelPaymentForm:_objectProcessingCancel
                                withOperation:operation
                            withMappingResult:mappingResult
                                alertDelegate:viewController];
        [_refreshControl endRefreshing];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureCancelPaymentForm:_objectProcessingCancel withError:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestCancelPaymentForm];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutCancelPaymentForm) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessCancelPaymentForm:(NSArray*)objects withOperation:(RKObjectRequestOperation *)operation withMappingResult:(RKMappingResult*)mappingResult alertDelegate:(UIViewController*)viewController
{
    NSDictionary *result = mappingResult.dictionary;
    id stat = [result objectForKey:@""];
    TxOrderCancelPaymentForm *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(order.message_error)
        {
            NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            [self showStickyAlertErrorMessage:array];
            
            [self requestProcessCancelPaymentForm];
        }
        else
        {
            NSString *cancelAlertDesc;
            NSString *totalRefund = [order.result.form.total_refund stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
            totalRefund = [totalRefund stringByReplacingOccurrencesOfString:@",-" withString:@""];
            totalRefund = [totalRefund stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([totalRefund isEqualToString:@"0"])
                cancelAlertDesc = @"Apakah anda yakin membatalkan transaksi ini?";
            else
                cancelAlertDesc = [NSString stringWithFormat:ALERT_DESCRIPTION_CANCEL_PAYMENT_CONFIRMATION,order.result.form.total_refund];
            
            UIAlertView *cancelAlert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE_CANCEL_PAYMENT_CONFIRMATION
                                                                 message:cancelAlertDesc
                                                                delegate:viewController
                                                       cancelButtonTitle:@"Tidak"
                                                       otherButtonTitles:@"Ya", nil];
            [cancelAlert show];
            NSDictionary *userInfo = @{DATA_PAYMENT_CONFIRMATION_COUNT_KEY:@(objects.count)};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:userInfo];
        }
    }
    else
    {
        [self requestProcessCancelPaymentForm];
    }
    [self requestProcessCancelPaymentForm];
}

-(void)requestFailureCancelPaymentForm:(NSArray*)objects withError:(NSError*)error
{
    //[self cancelCancelPaymentForm];
    if ([error code] != NSURLErrorCancelled) {
        NSString *errorDescription = error.localizedDescription;
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
        [errorAlert show];
    }
    [self requestProcessCancelPaymentForm];
}

-(void)requestProcessCancelPaymentForm
{
    
}

-(void)requestTimeoutCancelPaymentForm
{
    //[self cancelCancelPaymentForm];
}

#pragma mark - Methods

-(void)showStickyAlertErrorMessage:(NSArray *)messages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:messages delegate:self];
    [alert show];
}

-(void)actionCancelConfirmationObject:(NSArray*)objects
{
    for (NSDictionary *object in objects) {
        TxOrderConfirmationList *order =[object objectForKey:DATA_SELECTED_ORDER_KEY];
        [_list removeObject:order];
        [_selectedOrders removeAllObjects];
        [_selectedIndextPath removeAllObjects];
    }
    [_tableView reloadData];
    
    [self configureRestKitCancelPayment];
    [self requestCancelPayment:objects];
}

-(void)refreshRequest
{
    _page = 1;
    
    [_networkManager doRequest];
    //[self configureRestKitGetTransaction];
    //[self requestGetTransaction];
}

-(void)successConfirmPayment:(NSArray *)payment
{
    [_list removeObjectsInArray:payment];
    [_tableView reloadData];
    [_delegate successCancelOrConfirmPayment];
}

-(void)failedOrCancelConfirmPayment:(NSArray *)payment
{
    if (_isMultipleSelection) {
        [_list addObjectsFromArray:payment];
        [_tableView reloadData];
    }
}

@end
