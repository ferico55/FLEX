//
//  TxOrderConfirmedViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedViewController.h"

#import "TxOrderObjectMapping.h"
#import "TxOrderConfirmedDetail.h"
#import "UploadImage.h"
#import "GenerateHost.h"
#import "TransactionAction.h"

#import "TxOrderConfirmedCell.h"
#import "TxOrderConfirmedBankCell.h"
#import "TxOrderConfirmedButtonArrowCell.h"
#import "TxOrderConfirmedButtonCell.h"

#import "TxOrderPaymentViewController.h"

#import "TxOrderInvoiceViewController.h"

#import "CameraController.h"

#import "string_tx_order.h"
#import "detail.h"
#import "string_product.h"
#import "camera.h"

#import "StickyAlertView.h"

@interface TxOrderConfirmedViewController ()<UITableViewDelegate, UITableViewDataSource,TxOrderConfirmedButtonCellDelegate,TxOrderConfirmedCellDelegate, UIAlertViewDelegate, CameraControllerDelegate>
{
    BOOL _isNodata;
    NSMutableArray *_list;
    NSMutableArray *_isExpandedCell;
    NSString *_URINext;
    
    NSInteger _page;
    UIRefreshControl *_refreshControl;
    
    NSMutableDictionary *_dataInput;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectManagerDetail;
    __weak RKManagedObjectRequestOperation *_requestDetail;
    
    __weak RKObjectManager *_objectManagerUploadPhoto;
    __weak NSMutableURLRequest *_requestActionUploadPhoto;

    __weak RKObjectManager *_objectManagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
    
    __weak RKObjectManager *_objectManagerProof;
    __weak RKManagedObjectRequestOperation *_requestProof;
    
    TxOrderObjectMapping *_mapping;
    
    TxOrderConfirmedDetailOrder *_orderDetail;
    GenerateHost *_generateHost;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation TxOrderConfirmedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _isNodata = NO;
    _list = [NSMutableArray new];
    _mapping = [TxOrderObjectMapping new];
    _isExpandedCell = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _orderDetail = [TxOrderConfirmedDetailOrder new];
    _dataInput = [NSMutableDictionary new];
    
    [self configureRestKit];
    [self request];

    [self configureRestkitGenerateHost];
    [self requestGenerateHost];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
}

-(void)refreshRequest
{
    _page = 1;
    [self configureRestKit];
    [self request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isNodata ? 0 : _list.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    BOOL isShowBank = [_isExpandedCell[indexPath.section] boolValue];
    switch (indexPath.row) {
        case 0:
            cell = [self cellConfirmedAtIndexPath:indexPath];
            break;
        case 1:
            cell = (isShowBank)?[self cellConfirmedBankAtIndexPath:indexPath]:[self cellButtonArrowAtIndexPath:indexPath];
            break;
        case 2:
            cell = [self cellButtonAtIndexPath:indexPath];
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isShowBank = [_isExpandedCell[indexPath.section] boolValue];
    if (indexPath.row == 0) {
        return 124;
    }
    else if (indexPath.row == 1)
        return isShowBank?181:44;
    else
        return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isShowBank = [_isExpandedCell[indexPath.section] boolValue];
    switch (indexPath.row) {
        case 1:
            isShowBank = !isShowBank;
            [_isExpandedCell replaceObjectAtIndex:indexPath.section withObject:@(isShowBank)];
            break;
            
        default:
            break;
    }
    [_tableView reloadData];
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
            [self configureRestKit];
            [self request];
        }
    }
}

#pragma mark - Cell Delegate
-(void)editConfirmation:(NSIndexPath *)indexPath
{
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    
    if (detailOrder.has_user_bank ==1) {
        TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
        vc.isConfirmed = YES;
        vc.paymentID = detailOrder.payment_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)uploadProofAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate uploadProof];
    
    [_dataInput setObject:_list[indexPath.row] forKey:DATA_SELECTED_ORDER_KEY];
}

-(void)didTapInvoiceButton:(UIButton *)button atIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    //TODO:: Invoice
    [self configureRestKitDetail];
    [self requestDetail:detailOrder];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        TxOrderInvoiceViewController *VC = [TxOrderInvoiceViewController new];
        TxOrderConfirmedDetailInvoice *invoice = _orderDetail.detail[buttonIndex-1];
        VC.urlAddress = invoice.url;
        [self.navigationController pushViewController:VC animated:YES];
    }
}
#pragma mark - Camera Controller Delegate
-(void)didDismissCameraController:(CameraController *)controller withUserInfo:(NSDictionary *)userinfo
{
    NSDictionary* photo = [userinfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    NSString* imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME]?:@"";
    
    [_dataInput setObject:imageName forKey:API_FILE_NAME_KEY];
    [self configureRestkitUploadPhoto];
    [self requestActionUploadPhoto:userinfo];
}

#pragma mark - Cell
-(UITableViewCell*)cellConfirmedAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = CONFIRMED_CELL_IDENTIFIER;
    
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    
    TxOrderConfirmedCell *cell = (TxOrderConfirmedCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmedCell newCell];
        cell.delegate = self;
    }
    
    [cell.dateLabel setText:detailOrder.payment_date animated:YES];
    [cell.totalPaymentLabel setText:detailOrder.payment_amount animated:YES];
    [cell.totalInvoiceButton setTitle:[NSString stringWithFormat:@"%@ Invoice", detailOrder.order_count] forState:UIControlStateNormal];
    
    return cell;
}

-(UITableViewCell*)cellConfirmedBankAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = BANK_CELL_IDENTIFIER;
 
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    
    TxOrderConfirmedBankCell *cell = (TxOrderConfirmedBankCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmedBankCell newCell];
    }
    [cell.userNameLabel setText:detailOrder.user_account_name animated:YES];
    [cell.bankNameLabel setText:detailOrder.user_bank_name animated:YES];
    [cell.nomorRekLabel setText:detailOrder.user_account_no animated:YES];
    [cell.recieverNomorRekLabel setText:[NSString stringWithFormat:@"%@ - %@",detailOrder.bank_name,detailOrder.system_account_no] animated:YES];
    
    return cell;
}

-(UITableViewCell*)cellButtonAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = BUTTON_CELL_IDENTIFIER;
    
    TxOrderConfirmedButtonCell *cell = (TxOrderConfirmedButtonCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmedButtonCell newCell];
        cell.delegate = self;
    }
    
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    cell.editButton.hidden = (detailOrder.has_user_bank != 1);
    cell.indexPath = indexPath;
    
    return cell;
}

-(UITableViewCell*)cellButtonArrowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = BUTTON_ARROW_CELL_IDENTIFIER;
    
    TxOrderConfirmedButtonArrowCell *cell = (TxOrderConfirmedButtonArrowCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmedButtonArrowCell newCell];
    }
    
    return cell;
}

#pragma mark - Request
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

-(void)configureRestKit
{
    _objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmed class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmedResult class]];
    RKObjectMapping *listMapping = [_mapping confirmedListMapping];
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    RKRelationshipMapping *listRel =[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                toKeyPath:kTKPD_APILISTKEY
                                                                              withMapping:listMapping];
    
    [statusMapping addPropertyMapping:resultRel];
    [resultMapping addPropertyMapping:listRel];
 
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
}

-(void)request
{
    if (_request.isExecuting) return;
    NSTimer *timer;
    
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_TX_ORDER_PAYMENT_CONFIRMED};
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_TX_ORDER parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailure:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_request];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TxOrderConfirmed *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    [self requestProcess:object];
}

-(void)requestProcess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TxOrderConfirmed *order = stat;
            BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(order.message_error)
                {
                    NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
                    [alert show];
                }
                else{
                    if (_page == 1) {
                        [_list removeAllObjects];
                        [_isExpandedCell removeAllObjects];
                    }
                    
                    [_list addObjectsFromArray:order.result.list];
                    
                    if (_list.count >0) {
                        _isNodata = NO;
                        
                        for (int i =0; i<_list.count; i++) {
                            [_isExpandedCell addObject:@(NO)];
                        }
                    }
                    
                    [_tableView reloadData];
                }
            }
        }
        else{
            
            [self cancel];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}

#pragma mark - Request Detail
-(void)cancelDetail
{
    [_request cancel];
    _request = nil;
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

-(void)configureRestKitDetail
{
    _objectManagerDetail = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmedDetail class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmedDetailResult class]];
    RKObjectMapping *formMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmedDetailOrder class]];
    RKObjectMapping *invoiceMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmedDetailInvoice class]];
    [invoiceMapping addAttributeMappingsFromArray:@[API_INVOICE_KEY,
                                                    API_URL_KEY
                                                    ]];
    
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmedDetailPayment class]];
    [paymentMapping addAttributeMappingsFromArray:@[API_PAYMENT_ID_KEY,
                                                    API_PAYMENT_REF_KEY,
                                                    API_PAYMENT_DATE_KEY
                                                    ]];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    RKRelationshipMapping *formRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_DETAIL_KEY
                                                                                toKeyPath:API_ORDER_DETAIL_KEY
                                                                              withMapping:formMapping];
    
    RKRelationshipMapping *invoiceRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_DETAIL_KEY
                                                                                 toKeyPath:API_DETAIL_KEY
                                                                               withMapping:invoiceMapping];
    
    
    RKRelationshipMapping *paymentRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_PAYMENT_KEY
                                                                                 toKeyPath:API_PAYMENT_KEY
                                                                               withMapping:paymentMapping];
    
    [statusMapping addPropertyMapping:resultRel];
    [resultMapping addPropertyMapping:formRel];
    [formMapping addPropertyMapping:invoiceRel];
    [formMapping addPropertyMapping:paymentRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerDetail addResponseDescriptor:responseDescriptor];
    
}

-(void)requestDetail:(id)object
{
    if (_request.isExecuting) return;
    NSTimer *timer;
    
    TxOrderConfirmedList *order = object;
    
    NSString *paymentID = order.payment_id;
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_TX_ORDER_PAYMENT_CONFIRMED_DETAIL,
                            API_ORDER_PAYMENT_ID_KEY: paymentID};
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
        
#if DEBUG
    
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:@"1176" forKey:@"user_id"];
    
    _requestDetail = [_objectManagerDetail appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_TX_ORDER parameters:paramDictionary];
#else
    _requestDetail = [_objectManagerDetail appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_TX_ORDER parameters:[param encrypt]];
#endif
    
    [_requestDetail setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessDetail:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureDetail:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_requestDetail];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessDetail:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TxOrderConfirmedDetail *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessDetail:object];
    }
}

-(void)requestFailureDetail:(id)object
{
    [self requestProcessDetail:object];
}

-(void)requestProcessDetail:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TxOrderConfirmedDetail *order = stat;
            BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(order.message_error)
                {
                    NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else{
                    
                    _orderDetail = order.result.tx_order_detail;
                    
                    NSMutableArray *invoices = [NSMutableArray new];
                    for (TxOrderConfirmedDetailInvoice *detailInvoice in order.result.tx_order_detail.detail) {
                        [invoices addObject: detailInvoice.invoice];
                    }
                    
                    
                    UIAlertView *invoiceAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat: ALERT_TITLE_INVOICE_LIST,order.result.tx_order_detail.payment.payment_ref] message:nil delegate:self cancelButtonTitle:@"Tutup" otherButtonTitles:nil];
                    
                    for( NSString *title in invoices)  {
                        [invoiceAlert addButtonWithTitle:title];
                    }
                    
                    [invoiceAlert show];
                    
                    [_tableView reloadData];
                }
            }
        }
        else{
            
            [self cancel];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutDetail
{
    [self cancelDetail];
    
}


#pragma mark Request Generate Host
-(void)configureRestkitGenerateHost
{
    _objectManagerGenerateHost =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GenerateHost class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GenerateHostResult class]];
    
    RKObjectMapping *generatedhostMapping = [RKObjectMapping mappingForClass:[GeneratedHost class]];
    [generatedhostMapping addAttributeMappingsFromDictionary:@{
                                                               kTKPDGENERATEDHOST_APISERVERIDKEY:kTKPDGENERATEDHOST_APISERVERIDKEY,
                                                               kTKPDGENERATEDHOST_APIUPLOADHOSTKEY:kTKPDGENERATEDHOST_APIUPLOADHOSTKEY,
                                                               kTKPDGENERATEDHOST_APIUSERIDKEY:kTKPDGENERATEDHOST_APIUSERIDKEY
                                                               }];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY toKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY withMapping:generatedhostMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerGenerateHost addResponseDescriptor:responseDescriptor];
}

-(void)cancelGenerateHost
{
    [_requestGenerateHost cancel];
    _requestGenerateHost = nil;
    
    [_objectManagerGenerateHost.operationQueue cancelAllOperations];
    _objectManagerGenerateHost = nil;
}

- (void)requestGenerateHost
{
    if(_requestGenerateHost.isExecuting) return;
    
    NSTimer *timer;
    
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIUPLOADGENERATEHOSTKEY,
                            //kTKPD_SHOPIDKEY :shopID
                            };
    
    _requestGenerateHost = [_objectManagerGenerateHost appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAIL_UPLOADIMAGEAPIPATH parameters:[param encrypt]];
    
    [_requestGenerateHost setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessGenerateHost:mappingResult withOperation:operation];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureGenerateHost:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestGenerateHost];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutGenerateHost) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


-(void)requestSuccessGenerateHost:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _generateHost = info;
    NSString *statusstring = _generateHost.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessGenerateHost:object];
    }
}

-(void)requestFailureGenerateHost:(id)object
{
    
}

-(void)requestProcessGenerateHost:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _generateHost = info;
            NSString *statusstring = _generateHost.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if ([_generateHost.result.generated_host.server_id integerValue] == 0 || _generateHost.message_error) {
                    [self configureRestkitGenerateHost];
                    [self requestGenerateHost];
                }
                else
                {
                    
                }
                
            }
        }
        else
        {
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutGenerateHost
{
    [self cancelGenerateHost];
}

#pragma mark Request Action Upload Photo
-(void)configureRestkitUploadPhoto
{
    _objectManagerUploadPhoto =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[UploadImage class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[UploadImageResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY,
                                                        kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY:kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY,
                                                        API_UPLOAD_PHOTO_ID_KEY:API_UPLOAD_PHOTO_ID_KEY
                                                        }];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerUploadPhoto addResponseDescriptor:responseDescriptor];
    
    [_objectManagerUploadPhoto setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [_objectManagerUploadPhoto setRequestSerializationMIMEType:RKMIMETypeJSON];
}


- (void)cancelActionUploadPhoto
{
    _requestActionUploadPhoto = nil;
    
    [_operationQueue cancelAllOperations];
    _objectManagerUploadPhoto = nil;
}

- (void)requestActionUploadPhoto:(id)object
{
    NSDictionary* photo = [object objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    NSData* imageData = [photo objectForKey:DATA_CAMERA_IMAGEDATA]?:@"";
    NSString* imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME]?:@"";
    NSString *serverID = _generateHost.result.generated_host.server_id?:@"0";
    NSInteger userID = _generateHost.result.generated_host.user_id;
    
    NSDictionary *param = @{ kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIUPLOADPRODUCTIMAGEKEY,
                             kTKPDGENERATEDHOST_APISERVERIDKEY:serverID,
                             kTKPD_USERIDKEY : @(userID),
                             @"enc_dec" : @"off"
                             };
    
    _requestActionUploadPhoto = [NSMutableURLRequest requestUploadImageData:imageData
                                                                   withName:API_UPLOAD_PRODUCT_IMAGE_DATA_NAME
                                                                andFileName:imageName
                                                      withRequestParameters:param
                                 ];
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeoutUploadPhoto) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    
    [NSURLConnection sendAsynchronousRequest:_requestActionUploadPhoto
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               if ([httpResponse statusCode] == 200) {
                                   
                                   id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
                                   if (parsedData == nil && error) {
                                       NSLog(@"parser error");
                                       return;
                                   }
                                   
                                   NSLog(@"Index image %zd", index);
                                   [timer invalidate];
                                   
                                   NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
                                   for (RKResponseDescriptor *descriptor in _objectManagerUploadPhoto.responseDescriptors) {
                                       [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
                                   }
                                   
                                   RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
                                   NSError *mappingError = nil;
                                   BOOL isMapped = [mapper execute:&mappingError];
                                   if (isMapped && !mappingError) {
                                       NSLog(@"result %@",[mapper mappingResult]);
                                       RKMappingResult *mappingresult = [mapper mappingResult];
                                       NSDictionary *result = mappingresult.dictionary;
                                       id stat = [result objectForKey:@""];
                                       UploadImage *images = stat;
                                       BOOL status = [images.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                       
                                       if (status) {
                                           if (images.message_error) {
                                               NSArray *array = images.message_error?:[[NSArray alloc] initWithObjects:@"failed", nil];
                                               NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                                               [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                                           }
                                           else {
                                               [self configureRestKitProof];
                                               [self requestProof:images.result];
                                           }
                                       }
                                   }
                                   else
                                   {
                                       NSError *error = object;
                                       if (!([error code] == NSURLErrorCancelled)){
                                           NSString *errorDescription = error.localizedDescription;
                                           UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                                           [errorAlert show];
                                       }
                                   }
                               }
                               NSLog(@"%@",responsestring);
                           }];
}

-(void)requesttimeoutUploadPhoto
{
    //[self cancelActionUploadPhoto];
}

#pragma mark - Request Cancel Payment Confirmation
-(void)cancelProof
{
    [_requestProof cancel];
    _requestProof = nil;
    [_objectManagerProof.operationQueue cancelAllOperations];
    _objectManagerProof = nil;
}

-(void)configureRestKitProof
{
    _objectManagerProof = [RKObjectManager sharedClient];
    
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
    
    [_objectManagerProof addResponseDescriptor:responseDescriptor];
    
}

-(void)requestProof:(id)object
{
    if (_requestProof.isExecuting) return;
    NSTimer *timer;
    
    TxOrderConfirmedList *selectedConfirmation = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
    
    NSString * paymentID = selectedConfirmation.payment_id?:@"";
    UploadImageResult *image = object;
    NSString *fileName = [_dataInput objectForKey:API_FILE_NAME_KEY]?:@"";
    NSString *filePath = image.file_path?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_UPLOAD_PAYMENT_PROOF,
                            API_PAYMENT_ID_KEY: paymentID,
                            API_FILE_NAME_KEY: fileName,
                            API_FILE_PATH_KEY : filePath
                            };
    
#if DEBUG
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    
    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
    
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:userID forKey:kTKPD_USERIDKEY];
    
    _requestProof = [_objectManagerProof appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_TX_ORDER parameters:paramDictionary];
#else
    _requestProof = [_objectManagerProof appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_TX_ORDER parameters:[param encrypt]];
#endif
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
    
    [_requestProof setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessProof:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureProof:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_requestProof];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutProof) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessProof:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessProof:object];
    }
}

-(void)requestFailureProof:(id)object
{
    [self requestProcessProof:object];
}

-(void)requestProcessProof:(id)object
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
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
                    [alert show];

                    [_tableView reloadData];
                }
                if (order.result.is_success == 1) {
                    NSArray *array = order.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:array delegate:self];
                    [alert show];
                }
            }
        }
        else{
            
            [self cancelProof];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutProof
{
    [self cancelProof];
}


@end
