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
#import "RequestOrderData.h"

@interface TxOrderConfirmedViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UIAlertViewDelegate,
    TxOrderConfirmedButtonCellDelegate,
    TxOrderConfirmedCellDelegate,
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
    
    TxOrderConfirmedDetailOrder *_orderDetail;
    
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
    
    _loadingAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Uploading" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    [self doRequestList];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    if (_isRefresh) {
        [self doRequestList];
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
    [_refreshControl beginRefreshing];
    [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
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
    vc.paymentID = @[detailOrder.payment_id];
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
    [self doRequestDetailOrder:detailOrder];
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

#pragma mark - Tokopedia Network Manager
-(void)doRequestList{
    if (!_refreshControl.isRefreshing) {
        _tableView.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    [RequestOrderData fetchListPaymentConfirmedSuccess:^(NSArray *list) {
        [_act stopAnimating];
        
        if(_refreshControl.isRefreshing) {
            if (_page == 1||_page == 0) {
                _tableView.contentOffset = CGPointZero;
            }
            [_refreshControl endRefreshing];
        }
        
        if (_page == 1||_page == 0) {
            _list = [list mutableCopy];
        } else {
            [_list addObjectsFromArray:list];
        }
        
        if (_list.count >0) {
            _isNodata = NO;
        }
        else
        {
            NoResultView *noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
            _tableView.tableFooterView = noResultView;
        }
        [_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        if (_page == 1) {
            _tableView.contentOffset = CGPointZero;
        }
        [_refreshControl endRefreshing];
        [_act stopAnimating];
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
    
    [self isLoading:YES];
    
    [RequestOrderData fetchDataDetailPaymentID:order.payment_id success:^(TxOrderConfirmedDetailOrder *data) {
        [self isLoading:NO];
        
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
        
        [_tableView reloadData];

        
    } failure:^(NSError *error) {
        [self isLoading:NO];
    }];
}


-(void)isLoading:(BOOL)isLoading{
    if(isLoading){
        [self.tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
        [_refreshControl beginRefreshing];
    } else {
        [self.tableView setContentOffset:CGPointZero];
        [_refreshControl endRefreshing];
    }
}


#pragma mark - TKPD Camera controller delegate

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo
{
    NSDictionary *photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    NSString *imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME]?:@"";

    [_dataInput setObject:imageName forKey:API_FILE_NAME_KEY];
    [_dataInput setObject:[userInfo objectForKey:@"indexOfCell"] forKey:@"indexOfCell"];

    [_loadingAlert show];
    
    TxOrderConfirmedList *selectedConfirmation = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
    
    [RequestOrderAction fetchUploadImageProof:photo[@"photo"]
                                 imageName:photo[@"cameraimagename"]
                                 paymentID:selectedConfirmation.payment_id
                                   success:^(TransactionActionResult *data) {

                                       [self refreshRequest];
                                       
    } failure:^(NSError *error) {
        [_dataInput removeAllObjects];
        [_tableView reloadData];
    }];
}


@end
