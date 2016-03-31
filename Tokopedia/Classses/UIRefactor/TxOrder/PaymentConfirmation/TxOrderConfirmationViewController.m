//
//  TxOrderConfirmationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

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
#import "LoadingView.h"
#import "RequestOrderData.h"

@interface TxOrderConfirmationViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate ,TxOrderConfirmationCellDelegate, TxOrderConfirmationDetailViewControllerDelegate, TokopediaNetworkManagerDelegate, TxOrderPaymentViewControllerDelegate, LoadingViewDelegate>
{
    NSInteger _page;
    NSMutableArray *_list;
    
    NSMutableDictionary *_dataInput;
    BOOL _isNodata;
    UIRefreshControl *_refreshControl;
    
    NSString *_URINext;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerCancelPayment;
    __weak RKManagedObjectRequestOperation *_requestCancelPayment;
    
    NSMutableArray *_isSelectedOrders;
    NSMutableArray *_selectedOrders;
    NSMutableArray *_selectedIndextPath;
    NSMutableArray *_objectProcessingCancel;
    
    LoadingView *_loadingView;
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
    _isSelectedOrders = [NSMutableArray new];
    _selectedOrders = [NSMutableArray new];
    _selectedIndextPath = [NSMutableArray new];
    _objectProcessingCancel = [NSMutableArray new];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    _page = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRequest)
                                                 name:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME
                                               object:nil];
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    [self doRequestListconfirmation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.title = @"";
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
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
                
                [self doRequestGetDataCancelConfirmation:objects];
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
        cell.selectionButton.selected = [_isSelectedOrders[indexPath.row] boolValue];
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
    [cell setBackgroundColor:[UIColor clearColor]];
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"%ld", (long)row);
        
        if (_URINext != NULL && ![_URINext isEqualToString:@"0"] && _URINext != 0) {
            [self doRequestListconfirmation];
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
        
        [self doRequestGetDataCancelConfirmation:@[object]];
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
        
        [self doRequestGetDataCancelConfirmation:@[object]];
    }
}

-(void)didTapAlertCancelOrder
{
    [self actionCancelConfirmationObject:_objectProcessingCancel];
}

-(void)shouldConfirmOrderAtIndexPath:(NSIndexPath *)indexPath
{
    _confirmationButton.enabled = YES;
    if (!_isMultipleSelection) {
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
-(void)doRequestListconfirmation{
    
    if(!_refreshControl.isRefreshing) {
        _tableView.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    [RequestOrderData fetchListPaymentConfirmationPage:_page success:^(NSArray *list, NSInteger nextPage, NSString *uriNext) {
        [_act stopAnimating];

        if(_refreshControl.isRefreshing) {
            [_refreshControl endRefreshing];
        }
        
        if (_page == 1) {
            [_list removeAllObjects];
            [_isSelectedOrders removeAllObjects];
        }
        
        [_list addObjectsFromArray:list];
        
        if (_list.count >0) {
            _isNodata = NO;
            _URINext =  uriNext;
            _page = nextPage;
            
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
    } failure:^(NSError *error) {
        if(_refreshControl.isRefreshing) {
            [_refreshControl endRefreshing];
        }
        [_act stopAnimating];
        _tableView.tableFooterView = _loadingView.view;
    }];
}

#pragma loading view delegate
-(void)pressRetryButton
{
    [_act startAnimating];
    _tableView.tableFooterView = _footer;
    [self doRequestListconfirmation];
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
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:array delegate:self];
            [stickyAlertView show];
            
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
-(void)doRequestGetDataCancelConfirmation:(NSArray*)objects{
    
    NSMutableArray *confirmationIDs = [NSMutableArray new];
    
    for (NSDictionary *object in objects) {
        TxOrderConfirmationList *order =[object objectForKey:DATA_SELECTED_ORDER_KEY];
        [confirmationIDs addObject:order.confirmation.confirmation_id];
    }
    
    [_isSelectedOrders removeObject:@(YES)];
    [_tableView reloadData];
    
    NSString * confirmationID = [[confirmationIDs valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
    
    [RequestOrderData fetchDataCancelConfirmationID:confirmationID Success:^(TxOrderCancelPaymentFormForm *data) {
        
        NSString *cancelAlertDesc;
        NSString *totalRefund = [data.total_refund stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
        totalRefund = [totalRefund stringByReplacingOccurrencesOfString:@",-" withString:@""];
        totalRefund = [totalRefund stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([totalRefund isEqualToString:@"0"])
            cancelAlertDesc = @"Apakah anda yakin membatalkan transaksi ini?";
        else
            cancelAlertDesc = [NSString stringWithFormat:ALERT_DESCRIPTION_CANCEL_PAYMENT_CONFIRMATION,data.total_refund];
        
        UIAlertView *cancelAlert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE_CANCEL_PAYMENT_CONFIRMATION
                                                             message:cancelAlertDesc
                                                            delegate:self
                                                   cancelButtonTitle:@"Tidak"
                                                   otherButtonTitles:@"Ya", nil];
        [cancelAlert show];
        NSDictionary *userInfo = @{DATA_PAYMENT_CONFIRMATION_COUNT_KEY:@(objects.count)};
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:userInfo];

        [_refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [_refreshControl endRefreshing];
    }];
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
    
    [self doRequestListconfirmation];
    [_act stopAnimating];
}

-(void)successConfirmPayment:(NSArray *)payment
{
    [_list removeObjectsInArray:payment];
    [_tableView reloadData];
    [_delegate successCancelOrConfirmPayment];
}

- (void)shouldPopViewController {
    
}

-(void)failedOrCancelConfirmPayment:(NSArray *)payment
{

}

@end
