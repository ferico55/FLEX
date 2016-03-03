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
#import "LoadingView.h"

#import "GalleryViewController.h"

@interface TxOrderConfirmedViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UIAlertViewDelegate,
    TxOrderConfirmedButtonCellDelegate,
    TxOrderConfirmedCellDelegate,
    TokopediaNetworkManagerDelegate,
    TKPDPhotoPickerDelegate,
    TxOrderPaymentViewControllerDelegate,
    LoadingViewDelegate,
    GalleryViewControllerDelegate
>
{
    BOOL _isNodata;
    NSMutableArray *_list;
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
    LoadingView *_loadingView;
    
    UIAlertView *_loadingAlert;
    
    UIImage *_imageproof;
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
    
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    _loadingAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Uploading" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
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
    
    UIEdgeInsets inset = _tableView.contentInset;
    inset.bottom = 20;
    [_tableView setContentInset:inset];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)refreshRequest
{
    _page = 1;
    _networkManager.delegate = self;
    [_refreshControl beginRefreshing];
    [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
    [_networkManager doRequest];
    [_act stopAnimating];
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
    switch (indexPath.row) {
        case 0:
            cell = [self cellConfirmedAtIndexPath:indexPath];
            break;
        case 1:
            cell = [self cellConfirmedBankAtIndexPath:indexPath];
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
    CGFloat rowHeight = 0;
    
    if (indexPath.row == 0) {
        rowHeight = 137;
    }
    else if (indexPath.row == 1)
        rowHeight = 130;
    else
    {
        rowHeight = 40;
    
        TxOrderConfirmedList *detailOrder = _list[indexPath.section];
        if (([[detailOrder.button objectForKey:API_ORDER_BUTTON_UPLOAD_PROOF_KEY] integerValue] != 1) &&
            [detailOrder.system_account_no integerValue] == 0)
                rowHeight = 0;
    }
    
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Cell Delegate
-(void)editConfirmation:(NSIndexPath *)indexPath
{
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    
    //if (detailOrder.has_user_bank ==1) {
    TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
    vc.isConfirmed = YES;
    vc.delegate = self;
    vc.paymentID = detailOrder.payment_id;
    [self.navigationController pushViewController:vc animated:YES];
    //}
}

-(void)uploadProofAtIndexPath:(NSIndexPath *)indexPath
{
    [_dataInput setObject:_list[indexPath.section] forKey:DATA_SELECTED_ORDER_KEY];
    
    _photoPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self
                                              pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
    _photoPicker.delegate = self;
    _photoPicker.data = @{@"indexOfCell" : indexPath};
}

-(void)didTapInvoiceButton:(UIButton *)button atIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    //TODO:: Invoice
    [self configureRestKitDetail];
    [self requestDetail:detailOrder];
}

-(void)didTapPaymentProofIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:detailOrder.img_proof_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = [UIImageView new];
    _imageproof = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        _imageproof = image;
        [self pushToGallery];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        _imageproof = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
        [self pushToGallery];
    }];
}

-(void)pushToGallery
{
    GalleryViewController *gallery = [GalleryViewController new];
    gallery.canDownload = NO;
    [gallery initWithPhotoSource:self withStartingIndex:0];
    [self.navigationController presentViewController:gallery animated:YES completion:nil];
}

- (int)numberOfPhotosForPhotoGallery:(GalleryViewController *)gallery
{
    return 1;
}

- (NSString*)photoGallery:(GalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    return @"Bukti Pembayaran";
}

- (UIImage *)photoGallery:(NSUInteger)index {

    return _imageproof;
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        TxOrderConfirmedDetailInvoice *invoice = _orderDetail.detail[buttonIndex-1];
        [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:invoice.url];
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
    cell.imagePayementProofButton.hidden = ([detailOrder.img_proof_url isEqualToString:@""]||detailOrder.img_proof_url == nil)?YES:NO;
    
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
    [cell.userNameLabel setCustomAttributedText:detailOrder.user_account_name?:@""];
    [cell.bankNameLabel setCustomAttributedText:detailOrder.user_bank_name?:@""];
    NSString *accountNumber = (![detailOrder.system_account_no isEqualToString:@""] && detailOrder.system_account_no != nil && ![detailOrder.system_account_no isEqualToString:@"0"])?detailOrder.system_account_no:@"";
    [cell.nomorRekLabel setCustomAttributedText:detailOrder.user_account_no?:@""];
    [cell.recieverNomorRekLabel setCustomAttributedText:[NSString stringWithFormat:@"%@ %@",detailOrder.bank_name, accountNumber]];
    
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
    
    
    if([cell.indexPath isEqual:[_dataInput objectForKey:@"indexOfCell"]]) {
        [cell.actUploadProof startAnimating];
    } else {
        [cell.actUploadProof stopAnimating];
        [cell.actUploadProof setHidesWhenStopped:YES];
    }
    
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

    if (!_refreshControl.isRefreshing) {
        _tableView.tableFooterView = _footer;
        [_act startAnimating];
    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    [_act stopAnimating];
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    TxOrderConfirmed *order = [result objectForKey:@""];
    
    if(_refreshControl.isRefreshing) {
        if (_page == 1||_page == 0) {
            _tableView.contentOffset = CGPointZero;
        }
        [_refreshControl endRefreshing];
    }
    
    if (_page == 1||_page == 0) {
        _list = [order.result.list mutableCopy];
    }
    else
    {
        [_list addObjectsFromArray:order.result.list];
    }
    
    if (_list.count >0) {
        _isNodata = NO;
        _URINext =  order.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_URINext] integerValue];
    }
    else
    {
        NoResultView *noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        _tableView.tableFooterView = noResultView;
    }
    
    [_tableView reloadData];
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if (_page == 1) {
        _tableView.contentOffset = CGPointZero;
    }
    [_refreshControl endRefreshing];
    [_act stopAnimating];
    _tableView.tableFooterView = _loadingView.view;
}

-(void)pressRetryButton
{
    [_act startAnimating];
    _tableView.tableFooterView = _act;
    [_networkManager doRequest];
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
                    
                    if (_page == 1) {
                        _tableView.contentOffset = CGPointZero;
                    }
                    
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

- (void)failedGenerateHost:(NSArray *)errorMessages
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
    [_dataInput removeAllObjects];
    [_tableView reloadData];
}

-(void)failedUploadErrorMessage:(NSArray *)errorMessage
{
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:self];
    [stickyAlertView show];
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
    
    NSString * paymentID = selectedConfirmation.payment_id?:@"";
    UploadImageResult *image = object;

    NSString *filePath = image.file_path?:@"";
    NSString *fileName = image.file_name?:@"";
    
    NSDictionary* param = @{@"pic_obj":image.pic_obj?:@"",
                            @"pic_src":image.pic_src?:@"",
                            API_ACTION_KEY : @"upload_valid_proof_by_payment",
                            API_PAYMENT_ID_KEY: paymentID,
                            API_FILE_NAME_KEY: fileName,
                            API_FILE_PATH_KEY : filePath,
                            kTKPDGENERATEDHOST_APISERVERIDKEY :_generateHost.result.generated_host.server_id,
                            @"new_add" : @(1)
                            };
    
    _requestProof = [_objectManagerProof appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_TX_ORDER parameters:[param encrypt]];
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
    
    [_requestProof setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessProof:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
        [_dataInput removeAllObjects];
        [_tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureProof:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
        [_dataInput removeAllObjects];
        [_tableView reloadData];
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
    [_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
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
                    [self refreshRequest];
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
    [_dataInput setObject:[userInfo objectForKey:@"indexOfCell"] forKey:@"indexOfCell"];

    [_loadingAlert show];
    
    RequestUploadImage *requestImage = [RequestUploadImage new];
    requestImage.generateHost = _generateHost;
    requestImage.imageObject = @{DATA_SELECTED_PHOTO_KEY:userInfo};
    requestImage.action = ACTION_UPLOAD_PROOF_IMAGE;
    requestImage.fieldName = API_FORM_FIELD_NAME_PROOF;
    requestImage.delegate = self;
    TxOrderConfirmedList *selectedConfirmation = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
    requestImage.paymentID = selectedConfirmation.payment_id?:@"";
    [_tableView reloadData];
    [requestImage configureRestkitUploadPhoto];
    [requestImage requestActionUploadPhoto];
}


@end
