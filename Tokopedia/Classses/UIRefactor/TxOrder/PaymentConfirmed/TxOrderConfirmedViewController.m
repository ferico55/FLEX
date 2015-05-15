//
//  TxOrderConfirmedViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedViewController.h"

#import "NoResult.h"
#import "requestGenerateHost.h"
#import "RequestUploadImage.h"

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

#import "WebViewInvoiceViewController.h"

#import "string_tx_order.h"
#import "detail.h"
#import "string_product.h"
#import "camera.h"

#import "StickyAlertView.h"

#import "NavigateViewController.h"

#import "TokopediaNetworkManager.h"
#import "TKPDPhotoPicker.h"

@interface TxOrderConfirmedViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UIAlertViewDelegate,
    TxOrderConfirmedButtonCellDelegate,
    TxOrderConfirmedCellDelegate,
    GenerateHostDelegate,
    RequestUploadImageDelegate,
    TokopediaNetworkManagerDelegate,
    TKPDPhotoPickerDelegate
>
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
    
    TokopediaNetworkManager *_networkManager;
    TKPDPhotoPicker *_photoPicker;
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
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //[self configureRestKit];
    //[self request];
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRequest)
                                                 name:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME
                                               object:nil];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    [_networkManager doRequest];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _networkManager.delegate = self;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    if (_isRefresh) {
        [_networkManager doRequest];
        _isRefresh = NO;
        [_delegate setIsRefresh:_isRefresh];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _networkManager.delegate = nil;
}

-(void)refreshRequest
{
    _page = 1;
    //[self configureRestKit];
    //[self request];
    [_networkManager doRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
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
        return 120;
    }
    else if (indexPath.row == 1)
        return isShowBank?181:44;
    else
        return 50;
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
}

#pragma mark - Cell Delegate
-(void)editConfirmation:(NSIndexPath *)indexPath
{
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    
    //if (detailOrder.has_user_bank ==1) {
    [_delegate editPayment:detailOrder];
    //}
}

-(void)uploadProofAtIndexPath:(NSIndexPath *)indexPath
{
    [_dataInput setObject:_list[indexPath.section] forKey:DATA_SELECTED_ORDER_KEY];
    
    _photoPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self
                                                                  pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
    _photoPicker.delegate = self;
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
        TxOrderConfirmedDetailInvoice *invoice = _orderDetail.detail[buttonIndex-1];
        NavigateViewController *vc =[NavigateViewController new];
        [vc navigateToInvoiceFromViewController:self withInvoiceURL:invoice.url];
    }
}
#pragma mark - Camera Controller Delegate
//-(void)didDismissCameraController:(CameraController *)controller withUserInfo:(NSDictionary *)userinfo
//{
//    NSDictionary* photo = [userinfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
//    NSString* imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME]?:@"";
//    
//    [_dataInput setObject:imageName forKey:API_FILE_NAME_KEY];
//    
//    RequestUploadImage *requestImage = [RequestUploadImage new];
//    requestImage.generateHost = _generateHost;
//    requestImage.imageObject = @{DATA_SELECTED_PHOTO_KEY:userinfo};
//    requestImage.action = ACTION_UPLOAD_PROOF_IMAGE;
//    requestImage.fieldName = API_FORM_FIELD_NAME_PROOF;
//    [requestImage configureRestkitUploadPhoto];
//    [requestImage requestActionUploadPhoto];
//    requestImage.delegate = self;
//}

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
    
    cell.indexPath = indexPath;
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
    [cell.userNameLabel setText:detailOrder.user_account_name?:@"" animated:NO];
    [cell.bankNameLabel setText:detailOrder.user_bank_name?:@"" animated:NO];
    [cell.nomorRekLabel setText:detailOrder.user_account_no?:@"" animated:NO];
    [cell.recieverNomorRekLabel setText:[NSString stringWithFormat:@"%@ %@",detailOrder.bank_name, detailOrder.system_account_no] animated:NO];
    
    if ([cell.userNameLabel.text isEqualToString:@""]) {
        cell.userNameLabel.text =@"-";
    }
    
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
    //cell.editButton.hidden = (detailOrder.has_user_bank != 1);
    //cell.editButton.enabled = (detailOrder.has_user_bank == 1);
    cell.uploadProofButton.hidden = ([[detailOrder.button objectForKey:API_ORDER_BUTTON_UPLOAD_PROOF_KEY] integerValue] != 1);
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
//-(void)cancel
//{
//    [_request cancel];
//    _request = nil;
//    [_objectManager.operationQueue cancelAllOperations];
//    _objectManager = nil;
//}

#pragma mark - Tokopedia Network Manager
-(id)getObjectManager:(int)tag
//-(void)configureRestKit
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
    return _objectManager;
    
}

-(NSDictionary *)getParameter:(int)tag
{
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_TX_ORDER_PAYMENT_CONFIRMED};
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
    TxOrderConfirmed *order = stat;
    return order.status;
}

- (void)actionBeforeRequest:(int)tag {

    _tableView.tableFooterView = nil;
    [_act startAnimating];
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    TxOrderConfirmed *order = [result objectForKey:@""];
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
    }
    
    if (_page == 1) {
        [_list removeAllObjects];
        [_isExpandedCell removeAllObjects];
    }
    
    [_list addObjectsFromArray:order.result.list];
    
    if (_list.count >0) {
        _isNodata = NO;
        _URINext =  order.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_URINext] integerValue];
        for (int i =0; i<_list.count; i++) {
            [_isExpandedCell addObject:@(NO)];
        }
    }
    else
    {
        NoResultView *noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        _tableView.tableFooterView = noResultView;
    }
    
    [_tableView reloadData];
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    [_refreshControl endRefreshing];
    _tableView.tableFooterView = _act;
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
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
    if (_requestDetail.isExecuting) return;
    NSTimer *timer;
    
    TxOrderConfirmedList *order = object;
    
    NSString *paymentID = order.payment_id;
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_TX_ORDER_PAYMENT_CONFIRMED_DETAIL,
                            API_ORDER_PAYMENT_ID_KEY: paymentID};
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
        
    _requestDetail = [_objectManagerDetail appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_TX_ORDER parameters:[param encrypt]];
    
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
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutDetail) userInfo:nil repeats:NO];
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
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
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
            
            //[self cancel];
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


#pragma mark - Request Generate Host
-(void)successGenerateHost:(GenerateHost *)generateHost
{
    _generateHost = generateHost;
}

- (void)failedGenerateHost
{

}

#pragma mark - Request Action Upload Photo
-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    [self configureRestKitProof];
    [self requestProof:uploadImage.result];
}

-(void)failedUploadObject:(id)object
{
    
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
    NSTimer *timer= [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(requestTimeoutProof) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    TxOrderConfirmedList *selectedConfirmation = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
    
    //contoh format URL :
    //http://tkpdevel-pg.api/img/cache/100-square/temp/2015/2/16/20000/1176/1176-93b1b124-b5c1-11e4-8017-ebaa1cb33c34.jpg
    
    NSString * paymentID = selectedConfirmation.payment_id?:@"";
    UploadImageResult *image = object;

    NSString *filePath = image.file_path?:@"";
    NSString *fileName = image.file_name?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_UPLOAD_PROOF_BY_PAYMENT_ID,
                            API_PAYMENT_ID_KEY: paymentID,
                            API_FILE_NAME_KEY: fileName,
                            API_FILE_PATH_KEY : filePath
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
//    [paramDictionary setObject:userID?:@"" forKey:kTKPD_USERIDKEY];
//    
//    _requestProof = [_objectManagerProof appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_TX_ORDER parameters:paramDictionary];
//#else
    _requestProof = [_objectManagerProof appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_TX_ORDER parameters:[param encrypt]];
//#endif
    
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
                if (order.result.is_success == 1) {
                    NSArray *array = order.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    [self showStickyAlertSuccessMessage:array];
                }
                else
                {
                    NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    [self showStickyAlertErrorMessage:array];
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


-(void)showStickyAlertErrorMessage:(NSArray*)messages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:messages delegate:self];
    [alert show];
}

-(void)showStickyAlertSuccessMessage:(NSArray*)messages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:messages delegate:self];
    [alert show];
}

#pragma mark - TKPD Camera controller delegate

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo
{
    NSDictionary *photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    NSString *imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME]?:@"";

    [_dataInput setObject:imageName forKey:API_FILE_NAME_KEY];

    RequestUploadImage *requestImage = [RequestUploadImage new];
    requestImage.generateHost = _generateHost;
    requestImage.imageObject = @{DATA_SELECTED_PHOTO_KEY:userInfo};
    requestImage.action = ACTION_UPLOAD_PROOF_IMAGE;
    requestImage.fieldName = API_FORM_FIELD_NAME_PROOF;
    [requestImage configureRestkitUploadPhoto];
    [requestImage requestActionUploadPhoto];
    requestImage.delegate = self;
}

@end
