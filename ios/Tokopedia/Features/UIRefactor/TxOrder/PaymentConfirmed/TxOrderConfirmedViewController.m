//
//  TxOrderConfirmedViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedViewController.h"

#import "NoResult.h"
#import "RequestUploadImage.h"

#import "TxOrderConfirmedDetail.h"
#import "UploadImage.h"
#import "GenerateHost.h"
#import "TransactionAction.h"

#import "TxOrderConfirmedCell.h"

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
#import "RequestOrderData.h"
#import "Tokopedia-Swift.h"
@import SwiftOverlays;

@interface TxOrderConfirmedViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UIAlertViewDelegate,
    TKPDPhotoPickerDelegate,
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
    
    TxOrderConfirmedDetailOrder *_orderDetail;
    TxOrderConfirmedList *_selectedOrder;
    
    TKPDPhotoPicker *_photoPicker;
    LoadingView *_loadingView;
    
    UIAlertView *_loadingAlert;
    
    UIImage *_imageproof;
    PaymentService *_service;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation TxOrderConfirmedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Status Pembayaran";
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];

    _isNodata = NO;
    _list = [NSMutableArray new];
    _orderDetail = [TxOrderConfirmedDetailOrder new];
    _dataInput = [NSMutableDictionary new];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRequest)
                                                 name:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME
                                               object:nil];
    
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    _loadingAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Processing" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    [self doRequestList];
    
    _tableView.estimatedRowHeight = 40;
    _service = [PaymentService new];
    [AnalyticsManager trackScreenName:@"StatusPembayaran"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setWhite];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    if (_isRefresh) {
        [self doRequestList];
        _isRefresh = NO;
    }
    
    UIEdgeInsets inset = _tableView.contentInset;
    inset.bottom = 20;
    [_tableView setContentInset:inset];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)refreshRequest
{
    _page = 1;
    [_act stopAnimating];
    [self doRequestList];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
    }
    return _list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    switch (indexPath.section) {
        case 0:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rekeningCell"];
            cell.textLabel.text = @"Nomor Rekening Tokopedia";
            cell.textLabel.font = [UIFont largeTheme];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell = [self cellConfirmedAtIndexPath:indexPath];
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = UITableViewAutomaticDimension;
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        [cell setBackgroundColor:[UIColor whiteColor]];
    } else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        ListBankViewController *vc = [ListBankViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Cell Delegate
-(void)pushEditConfirmationForm:(TxOrderConfirmedList *)order{
    EditConfirmationViewController *vc = [EditConfirmationViewController new];
    vc.paymentID = order.payment_id;
    __weak typeof(self) wself = self;
    vc.didEditPayment = ^{
        [wself refreshRequest];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)uploadProofOrder:(TxOrderConfirmedList *)order
{
    [_dataInput setObject:order forKey:DATA_SELECTED_ORDER_KEY];
    
    _photoPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self
                                              pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
    _photoPicker.delegate = self;
}

-(void)pushToGallery
{
    GalleryViewController *gallery = [[GalleryViewController alloc] initWithPhotoSource:self withStartingIndex:0 usingNetwork:YES];
    gallery.canDownload = NO;
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

-(NSString *)photoGallery:(GalleryViewController *)gallery urlForPhotoSize:(GalleryPhotoSize)size atIndex:(NSUInteger)index{
    return _selectedOrder.img_proof_url;
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        TxOrderConfirmedDetailInvoice *invoice = _orderDetail.detail[buttonIndex-1];
        [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:invoice.url];
    }
}

#pragma mark - Cell
-(UITableViewCell*)cellConfirmedAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = CONFIRMED_CELL_IDENTIFIER;
    
    TxOrderConfirmedList *detailOrder = _list[indexPath.row];
    
    TxOrderConfirmedCell *cell = (TxOrderConfirmedCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmedCell newCell];
    }
    
    [cell setupViewWithOrder:detailOrder];
    __weak typeof(self) wself = self;
    cell.didTapInvoice = ^(TxOrderConfirmedList *order) {
        [wself doRequestDetailOrder:order];
    };
    
    cell.didTapPaymentProof = ^(TxOrderConfirmedList *order) {
        _selectedOrder = order;
        [wself pushToGallery];
    };
    
    cell.didTapEditPayment = ^(TxOrderConfirmedList *order) {
        if (order.has_user_bank == 1) {
            [wself pushEditConfirmationForm:order];
        }
    };
    
    cell.didTapUploadProof = ^(TxOrderConfirmedList *order) {
        [wself uploadProofOrder:order];
    };
    
    cell.didTapCancelPayment = ^(TxOrderConfirmedList *order) {
        [AnalyticsManager trackEventName:@"clickBatal" category:@"Status Pembayaran" action:@"Click" label:@"Batal"];
        [wself showAlertConfirmationCancelPayment:order];
    };
    
    return cell;
}

-(void)showAlertConfirmationCancelPayment:(TxOrderConfirmedList *)order {
    [SwiftOverlays showCenteredWaitOverlay:self.view];
    __weak typeof(self) wself = self;
    [_service getPaymentStatusWithPaymentID:order.payment_id onSuccess:^(NSString *confirmationMessage){
        
        [SwiftOverlays removeAllOverlaysFromView:wself.view];

        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Konfirmasi Pembatalan Transaksi"
                                     message:confirmationMessage
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yes = [UIAlertAction
                              actionWithTitle:@"Ya"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [AnalyticsManager trackEventName:@"clickBatal" category:@"Status Pembayaran" action:@"Click" label:@"Ya"];
                                  [wself cancelPayment:order];
                              }];
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Tidak"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * _Nonnull action) {
                                     [AnalyticsManager trackEventName:@"clickBatal" category:@"Status Pembayaran" action:@"Click" label:@"Tidak"];
                                 }];
        
        [alert addAction:yes];
        [alert addAction:cancel];
        
        [wself presentViewController:alert animated:YES completion:nil];
        
    } onFailure:^(NSString *errorMessage) {
        
        [SwiftOverlays removeAllOverlaysFromView:wself.view];
        [StickyAlertView showErrorMessage:@[errorMessage]];
        
    }];
}


-(void)cancelPayment:(TxOrderConfirmedList *)order {
    [SwiftOverlays showCenteredWaitOverlay:self.view];
    
    __weak typeof(self) wself = self;
    [_service cancelPaymentWithPaymentID:order.payment_id onSuccess:^(NSString *successMessage){
        [SwiftOverlays removeAllOverlaysFromView:wself.view];
        [StickyAlertView showSuccessMessage:@[successMessage]];
        [wself refreshRequest];
        [SwiftOverlays removeAllOverlaysFromView:wself.view];
    } onFailure:^(NSString *errorMessage, BOOL shouldRefresh){
        [SwiftOverlays removeAllOverlaysFromView:wself.view];
        [StickyAlertView showErrorMessage:@[errorMessage]];
        
        if (shouldRefresh) {
            [wself refreshRequest];
        }
        [SwiftOverlays removeAllOverlaysFromView:wself.view];
    }];
}

#pragma mark - Tokopedia Network Manager
-(void)doRequestList{
    if (!_refreshControl.isRefreshing) {
        _tableView.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    [RequestOrderData fetchListPaymentConfirmedSuccess:^(NSArray *list) {
        [_act stopAnimating];
        [_refreshControl endRefreshing];
        
        if (_page == 1||_page == 0) {
            _list = [list mutableCopy];
        } else {
            [_list addObjectsFromArray:list];
        }
        
        if (_list.count >0) {
            _isNodata = NO;
            _tableView.tableFooterView = nil;
        }
        else
        {
            NoResultView *noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
            _tableView.tableFooterView = noResultView;
        }
        [_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [_act stopAnimating];
        [_refreshControl endRefreshing];
        
        _tableView.tableFooterView = _loadingView.view;
        [_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
    }];
}

-(void)pressRetryButton
{
    [_act startAnimating];
    _tableView.tableFooterView = _act;
    [self doRequestList];
}

#pragma mark - Request Detail
-(void)doRequestDetailOrder:(TxOrderConfirmedList*)order{
    
    [_loadingAlert show];
    
    __weak typeof(self) wself = self;
    [RequestOrderData fetchDataDetailPaymentID:order.payment_id success:^(TxOrderConfirmedDetailOrder *data) {
        [_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
        
        _orderDetail = data;
        
        NSMutableArray *invoices = [NSMutableArray new];
        for (TxOrderConfirmedDetailInvoice *detailInvoice in data.detail) {
            [invoices addObject: detailInvoice.invoice];
        }
        
        UIAlertView *invoiceAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat: ALERT_TITLE_INVOICE_LIST,data.payment.payment_ref] message:nil delegate:self cancelButtonTitle:@"Tutup" otherButtonTitles:nil];
        
        for( NSString *title in invoices)  {
            [invoiceAlert addButtonWithTitle:title];
        }
        
        [invoiceAlert show];
        
    } failure:^(NSError *error) {
        
        [_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
    }];
}

#pragma mark - TKPD Camera controller delegate

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo
{
    NSDictionary *photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    NSString *imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME]?:@"";

    [_dataInput setObject:imageName forKey:API_FILE_NAME_KEY];

    [_loadingAlert show];
    
    TxOrderConfirmedList *selectedConfirmation = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
    
    __weak typeof(self) wself = self;
    [RequestOrderAction fetchUploadImageProof:photo[@"photo"]
                                 imageName:photo[@"cameraimagename"]
                                 paymentID:selectedConfirmation.payment_id
                                   success:^(TransactionActionResult *data) {

                                       [wself refreshRequest];
                                       
    } failure:^(NSError *error) {
        [_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
        [_dataInput removeAllObjects];
        [_tableView reloadData];
    }];
}


@end
