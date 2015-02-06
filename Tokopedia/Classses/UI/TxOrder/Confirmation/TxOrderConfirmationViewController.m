//
//  TxOrderConfirmationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderObjectMapping.h"
#import "string_tx_order.h"

#import "TxOrderConfirmationViewController.h"
#import "TxOrderConfirmationDetailViewController.h"
#import "TxOrderConfirmationCell.h"

#import "TransactionAction.h"

@interface TxOrderConfirmationViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate ,TxOrderConfirmationCellDelegate>
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
    
    TxOrderObjectMapping *_mapping;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation TxOrderConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _mapping = [TxOrderObjectMapping new];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    _page = 1;
    
    [self configureRestKitGetTransaction];
    [self requestGetTransaction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    cell.deadlineDateLabel.text = detailOrder.confirmation.pay_due_date;
    cell.transactionDateLabel.text = detailOrder.confirmation.create_time;
    cell.shopNameLabel.text = detailOrder.confirmation.shop_list;
    cell.totalInvoiceLabel.text = detailOrder.confirmation.open_amount;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmationDetailViewController *detailViewController = [TxOrderConfirmationDetailViewController new];
    detailViewController.data = @{DATA_DETAIL_ORDER_CONFIRMATION_KEY:_list[indexPath.row]};
    [self.navigationController pushViewController:detailViewController animated:YES];
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
            [self configureRestKitGetTransaction];
            [self requestGetTransaction];
        }
    }
}


#pragma mark - Delegate
-(void)shouldCancelOrderAtIndexPath:(NSIndexPath *)indexPath
{
    [_dataInput setObject:_list[indexPath.row] forKey:DATA_SELECTED_ORDER_KEY];
    
    UIAlertView *cancelAlert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE_CANCEL_PAYMENT_CONFIRMATION message:ALERT_TITLE_CANCEL_PAYMENT_CONFIRMATION delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya", nil];
    
    [cancelAlert show];
}

-(void)shouldConfirmOrderAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self configureRestKitCancelPayment];
        [self requestCancelPayment:_dataInput];
    }
}

#pragma mark - Request Get Transaction Order Payment Confirmation
-(void)cancelGetTransaction
{
    [_requestGetTransaction cancel];
    _requestGetTransaction = nil;
    [_objectManagerGetTransaction.operationQueue cancelAllOperations];
    _objectManagerGetTransaction = nil;
}

-(void)configureRestKitGetTransaction
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
                                                 API_TOTAL_LOGISTIC_FEE_KEY
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
    
}

-(void)requestGetTransaction
{
    if (_requestGetTransaction.isExecuting) return;
    NSTimer *timer;
    
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_TX_ORDER_PAYMENT_CONFIRMATION};
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
    
    _requestGetTransaction = [_objectManagerGetTransaction appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_TX_ORDER parameters:[param encrypt]];
    
    [_requestGetTransaction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessGetTransaction:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureGetTransaction:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_requestGetTransaction];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutGetTransaction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessGetTransaction:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TxOrderConfirmation *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessGetTransaction:object];
    }
}

-(void)requestFailureGetTransaction:(id)object
{
    [self requestProcessGetTransaction:object];
}

-(void)requestProcessGetTransaction:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TxOrderConfirmation *order = stat;
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
                    
                    [_list addObjectsFromArray:order.result.list];
                    
                    if (_list.count >0) {
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
                    
                    [_tableView reloadData];
                }
            }
        }
        else{
            
            [self cancelGetTransaction];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutGetTransaction
{
    [self cancelGetTransaction];
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

-(void)requestCancelPayment:(id)object
{
    if (_requestCancelPayment.isExecuting) return;
    NSTimer *timer;
    
    TxOrderConfirmationList *detail = [(NSDictionary*)object objectForKey:DATA_SELECTED_ORDER_KEY];
    
    NSString *confirmationID = detail.confirmation.confirmation_id;
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_CANCEL_PAYMENT,
                            API_CONFIRMATION_CONFIRMATION_ID_KEY: confirmationID
                            };
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
    
    _requestCancelPayment = [_objectManagerCancelPayment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_TX_ORDER parameters:[param encrypt]];
    
    [_requestCancelPayment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessCancelPayment:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureCancelPayment:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_requestCancelPayment];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutCancelPayment) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessCancelPayment:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessCancelPayment:object];
    }
}

-(void)requestFailureCancelPayment:(id)object
{
    [self requestProcessCancelPayment:object];
}

-(void)requestProcessCancelPayment:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionAction *order = stat;
            BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(order.message_error)
                {
                    NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (order.result.is_success == 1) {
                    NSArray *array = order.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                    //TODO:: is success
                }
            }
        }
        else{
            
            [self cancelCancelPayment];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutCancelPayment
{
    [self cancelCancelPayment];
}

#pragma mark - Methods

-(void)refreshView
{
    [self configureRestKitGetTransaction];
    [self requestGetTransaction];
}

@end
