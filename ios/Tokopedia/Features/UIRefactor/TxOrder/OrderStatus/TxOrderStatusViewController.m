//
//  TxOrderStatusViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "UserAuthentificationManager.h"
#import "NavigateViewController.h"

#import "TxOrderStatusViewController.h"
#import "TxOrderStatusDetailViewController.h"
#import "TrackOrderViewController.h"
#import "FilterSalesTransactionListViewController.h"
#import "TransactionCartViewController.h"

#import "InboxResolutionCenterOpenViewController.h"

#import "TransactionAction.h"
#import "string_tx_order.h"

#import "TxOrderStatus.h"
#import "NoResultView.h"

#import "TextMenu.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"

#import "NoResultReusableView.h"
#import "RequestResolutionData.h"
#import "RequestOrderData.h"
#import "RequestResolutionData.h"
#import "ResolutionCenterCreateViewController.h"

#import "OrderDataManager.h"
#import "Tokopedia-Swift.h"
#import "OrderCellContext.h"
#import "SendMessageViewController.h"
#import "RetryCollectionReusableView.h"

@import SwiftOverlays;
@import NSAttributedString_DDHTML;

#define TAG_ALERT_SUCCESS_DELIVERY_CONFIRM 11
#define DATA_ORDER_DELIVERY_CONFIRMATION @"data_delivery_confirmation"
#define DATA_ORDER_REORDER_KEY @"data_reorder"
#define DATA_ORDER_COMPLAIN_KEY @"data_complain"

@interface TxOrderStatusViewController () <UIAlertViewDelegate, FilterSalesTransactionListDelegate, TrackOrderViewControllerDelegate, InboxResolutionCenterOpenViewControllerDelegate, ResolutionCenterCreateDelegate, LoadingViewDelegate, NoResultDelegate, RetryViewDelegate>
{
    NSString *_URINext;
    
    NSInteger _page;
    
    BOOL _isNodata;
    
    UIRefreshControl *_refreshControll;
    
    NSString *_transactionFilter;
    
    NSMutableDictionary *_dataInput;
    NSMutableArray *_objectsConfirmRequest;
    
    NSInteger _totalButtonsShow;
    
    NavigateViewController *_navigate;
    
    TxOrderStatusList *_selectedTrackOrder;
    LoadingView *_loadingView;
    
    FilterSalesTransactionListViewController *_filterSalesTransactionList;
    
    UIViewController *_detailViewController;
    
    OrderDataManager *_dataManager;
    
    BOOL _isFailRequest;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *filterView;

@end

@implementation TxOrderStatusViewController {
    NoResultReusableView *_noResultView;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
    }
    return self;
}

- (void)initNoResultView {
    _noResultView = [[NoResultReusableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [_noResultView generateAllElements:@"icon_no_data_grey.png"
                                 title:@"Tidak ada data"
                                  desc:@""
                              btnTitle:@""];
    
    [_noResultView hideButton:YES];
    _noResultView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataInput = [NSMutableDictionary new];
    _navigate = [NavigateViewController new];
    
    self.title = _viewControllerTitle?:@"";
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    _objectsConfirmRequest = [NSMutableArray new];
    
    _refreshControll = [[UIRefreshControl alloc] init];
    _refreshControll.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControll addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControll];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
    [self initNoResultView];
    
    if ([_action  isEqual: ACTION_GET_TX_ORDER_LIST] && !_isCanceledPayment) {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithTitle:@"Filter" style:UIBarButtonItemStyleDone target:self action:@selector(tap:)];
        self.navigationItem.rightBarButtonItem = barButton;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRequest)
                                                 name:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRequest)
                                                 name:DID_CANCEL_COMPLAIN_NOTIFICATION_NAME
                                               object:nil];
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    [self doRequestList];
    
    _collectionView.backgroundColor = [UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1];
    _dataManager = [self dataManager];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setWhite];
    
    self.title = _viewControllerTitle?:@" ";
    
    if ([_action isEqualToString:ACTION_GET_TX_ORDER_STATUS]) {
        [AnalyticsManager trackScreenName:@"Purchase - Order Status"];
    } else if ([_action isEqualToString:ACTION_GET_TX_ORDER_DELIVER]) {
        [AnalyticsManager trackScreenName:@"Purchase - Received Confirmation"];
    } else {
        [AnalyticsManager trackScreenName:@"Purchase - Transaction List"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    _collectionView.delegate = nil;
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

-(IBAction)tap:(id)sender
{
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        NSString *filterInvoice = [_dataInput objectForKey:API_INVOICE_KEY]?:@"";
        NSString *filterStartDate = [_dataInput objectForKey:API_TRANSACTION_START_DATE_KEY]?:@"";
        NSString *filterEndDate = [_dataInput objectForKey:API_TRANSACTION_END_DATE_KEY]?:@"";
        NSString *filterStatus = [_dataInput objectForKey:API_TRANSACTION_STATUS_KEY]?:@"";
        
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        
        FilterSalesTransactionListViewController *controller = [FilterSalesTransactionListViewController new];
        controller.invoiceMark = filterInvoice;
        controller.startDateMark = filterStartDate;
        controller.endDateMark = filterEndDate;
        controller.transactionStatusMark = filterStatus;
        controller.isOrderTransaction = YES;
        controller.delegate = self;
        navigationController.viewControllers = @[controller];
        
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - Detail delegate
-(void)delegateViewController:(UIViewController *)viewController{
    _detailViewController = viewController;
}

-(void)confirmDelivery:(TxOrderStatusList *)order{
    [self doRequestFinishOrder:order];
}

#pragma mark - Filter Delegate
-(void)filterOrderInvoice:(NSString *)invoice transactionStatus:(NSString *)transactionStatus startDate:(NSString *)startDate endDate:(NSString *)endDate
{
    [_dataInput setObject:invoice?:@"" forKey:API_INVOICE_KEY];
    [_dataInput setObject:transactionStatus?:@"" forKey:API_TRANSACTION_STATUS_KEY];
    [_dataInput setObject:startDate?:@"" forKey:API_TRANSACTION_START_DATE_KEY];
    [_dataInput setObject:endDate?:@"" forKey:API_TRANSACTION_END_DATE_KEY];
    
    [self refreshRequest];
    
}

#pragma mark - Track Order delegate
-(void)shouldRefreshRequest{
    [self refreshRequest];
}

-(OrderDataManager*)dataManager{
    
    if (!_dataManager) {
        _dataManager = [[OrderDataManager alloc] initWithCollectionView:_collectionView supplementaryViewDataSource:self];
        
        __weak typeof(self) weakSelf = self;
        
        [_dataManager context].onTapDetail = ^(TxOrderStatusList *order){
            [weakSelf tapDetailOrder:order];
        };
        
        [_dataManager context].onTapShop = ^(TxOrderStatusList *order){
            [weakSelf tapShopOrder:order];
        };
        
        [_dataManager context].onTapInvoice = ^(TxOrderStatusList *order){
            [weakSelf tapInvoiceOrder:order];
        };
        
        [_dataManager context].onTapSeeComplaint = ^(TxOrderStatusList *order){
            [weakSelf tapSeeComplaintDetailOrder:order];
        };
        
        [_dataManager context].onTapComplaintNotReceived = ^(TxOrderStatusList *order){
            [weakSelf tapComplaintNotReceivedOrder:order];
        };
        
        [_dataManager context].onTapTracking = ^(TxOrderStatusList *order){
            [weakSelf trackOrder:order];
        };
        
        [_dataManager context].onTapReceivedOrder = ^(TxOrderStatusList *order){
            [weakSelf tapDone:order];
        };
        
        [_dataManager context].onTapReorder = ^(TxOrderStatusList *order){
            [AnalyticsManager trackEventName:@"clickReorder" category:GA_EVENT_CATEGORY_REORDER action:GA_EVENT_ACTION_CLICK label:@"Click Reorder"];
            [weakSelf tapReorderOrder:order];
        };
        
        [_dataManager context].onTapCancel = ^(TxOrderStatusList *order){
            [weakSelf tapRequestCancelOrder:order];
        };
        
        [_dataManager context].onTapAskSeller = ^(TxOrderStatusList *order){
            [weakSelf tapAskSellerOrder:order];
        };
        
        [_dataManager context].onTapCancelReplacement = ^(TxOrderStatusList *order){
            [weakSelf tapCancelReplacement:order];
        };
        
        [_dataManager context].onTapComplaint = ^(TxOrderStatusList *order) {
            [weakSelf tapComplaint:order];
        };
        
    }
    return _dataManager;
}

-(void)tapCancelReplacement:(TxOrderStatusList *)order {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Batalkan Pesanan"
                                  message:@"Apakah Anda ingin melakukan pembatalan pesanan?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) wself = self;
    
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:@"Ya"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [wself doRequestCancelReplacementOrder:order];
                              
                          }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Tidak"
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alert addAction:yes];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)doRequestCancelReplacementOrder:(TxOrderStatusList *)order {
    __weak typeof(self) wself = self;
    [RequestOrderAction cancelReplacementOrderId:order.order_detail.detail_order_id onSuccess:^{
        [wself refreshRequest];
    }];
}

-(void)tapAskSellerOrder:(TxOrderStatusList *)order{
    SendMessageViewController *messageController = [SendMessageViewController new];
    messageController.data = @{
                               @"shop_id":order.order_shop.shop_id?:@"",
                               @"shop_name":order.order_shop.shop_name?:@""
                               };
    messageController.subject = order.order_detail.detail_invoice?:@"";
    messageController.message = [NSString stringWithFormat:@"INVOICE:\n%@\n\n\n",order.order_detail.detail_pdf_uri];
    [self.navigationController pushViewController:messageController animated:YES];
}

-(void)tapRequestCancelOrder:(TxOrderStatusList *)order{
    __weak typeof(self) weakSelf = self;
    CancelOrderViewController *vc = [CancelOrderViewController new];
    vc.order = order;
    vc.didRequestCancelOrder = ^(TxOrderStatusList *order){
        [weakSelf refreshRequest];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - loading view delegate
- (void)pressRetryButton {
    _isFailRequest = NO;
    [self doRequestList];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if(kind == UICollectionElementKindSectionFooter){
        if(_isFailRequest) {
            RetryCollectionReusableView* retryCollectionReusableView =
            (RetryCollectionReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                             withReuseIdentifier:@"RetryView"
                                                                                    forIndexPath:indexPath];
            retryCollectionReusableView.delegate = self;
            return retryCollectionReusableView;
        }else{
            return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        }
    }
    return nil;
}

-(BOOL)hasMoreItems{
    return (_URINext != NULL && ![_URINext isEqualToString:@"0"] && _URINext != 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[self dataManager] sizeForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [_dataManager orders].count-1){
        if ([self hasMoreItems]) {
            [self doRequestList];
        }
    }
    
    [[self dataManager] announceWillAppearForItemInCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [[self dataManager] announceDidDisappearForItemInCell:cell];
}

#pragma mark - Request Get Transaction Order Payment Confirmation

-(void)doRequestList{
    _isFailRequest = NO;
    if ([_action isEqualToString:ACTION_GET_TX_ORDER_STATUS]) {
        [self doRequestStatusList];
    } else if([_action isEqualToString:ACTION_GET_TX_ORDER_DELIVER]){
        [self doRequestDeliverList];
    }else{
        [self doRequestTransactionList];
    }
}

-(void)doRequestTransactionList{
    NSString *filterInvoice = [_dataInput objectForKey:API_INVOICE_KEY]?:@"";
    NSString *filterStartDate = [_dataInput objectForKey:API_TRANSACTION_START_DATE_KEY]?:@"";
    NSString *filterEndDate = [_dataInput objectForKey:API_TRANSACTION_END_DATE_KEY]?:@"";
    NSString *filterStatus = (_isCanceledPayment)?@"5":[_dataInput objectForKey:API_TRANSACTION_STATUS_KEY]?:@"";
    
    [RequestOrderData fetchListTransactionPage:_page invoice:filterInvoice startDate:filterStartDate endDate:filterEndDate status:filterStatus success:^(NSArray *list, NSInteger nextPage, NSString* uriNext) {
        [self adjustList:list nextPage:nextPage uriNext:uriNext];
    } failure:^(NSError *error) {
        [self failedFetch];
    }];
}

-(void)doRequestDeliverList{
    [RequestOrderData fetchListOrderDeliverPage:_page success:^(NSArray *list, NSInteger nextPage, NSString *uriNext) {
        [self adjustList:list nextPage:nextPage uriNext:uriNext];
    } failure:^(NSError *error) {
        [self failedFetch];
    }];
}

-(void)doRequestStatusList{
    [RequestOrderData fetchListOrderStatusPage:_page success:^(NSArray *list, NSInteger nextPage, NSString *uriNext) {
        [self adjustList:list nextPage:nextPage uriNext:uriNext];
    } failure:^(NSError *error) {
        [self failedFetch];
    }];
}

-(void)failedFetch{
    [_act stopAnimating];
    [_refreshControll endRefreshing];
    [_noResultView removeFromSuperview];
    _isFailRequest = YES;
}

-(void)adjustList:(NSArray*)list nextPage:(NSInteger)nextPage uriNext:(NSString*)uriNext{
    
    for (TxOrderStatusList *order in list) {
        order.type = _action;
    }
    
    if (_page <= 1) {
        [_dataManager removeAllOrders];
    }
    [_dataManager addOrders:list];
    if (list.count >0) {
        _isNodata = NO;
        _URINext =  uriNext;
        _page = nextPage;
        [_noResultView removeFromSuperview];
    } else {
        if ([self isUsingAnyFilter]) {
            NSString *noTransactionInfoString = @"";
            
            if ([_dataInput objectForKey:API_TRANSACTION_START_DATE_KEY] == nil || [_dataInput objectForKey:API_TRANSACTION_END_DATE_KEY] == nil) {
                noTransactionInfoString = @"Belum ada transaksi";
            } else {
                noTransactionInfoString = [NSString stringWithFormat:@"Belum ada transaksi untuk tanggal %@ - %@", [_dataInput objectForKey:API_TRANSACTION_START_DATE_KEY], [_dataInput objectForKey:API_TRANSACTION_END_DATE_KEY]];
            }
            
            [_noResultView setNoResultTitle:noTransactionInfoString];
            [_noResultView hideButton:YES];
        } else {
            [_noResultView setNoResultTitle:@"Belum ada transaksi"];
            [_noResultView hideButton:YES];
        }
        
        [_collectionView addSubview:_noResultView];
    }
    
    if (![self hasMoreItems]) {
        _layout.footerReferenceSize = CGSizeMake(0, 0.0001);
    }
    
    
    [_act stopAnimating];
    [_refreshControll endRefreshing];
}

#pragma mark - Request Delivery Finish Order
-(void)doRequestFinishOrder:(TxOrderStatusList*)order{
    if ([_action isEqualToString:ACTION_GET_TX_ORDER_DELIVER]) {
        [self confirmDeliveryOrderDeliver:order];
    } else if ([_action isEqualToString:ACTION_GET_TX_ORDER_STATUS]) {
        [self confirmDeliveryOrderStatus:order];
    } else if ([_action isEqualToString:ACTION_GET_TX_ORDER_LIST]) {
        if ([order fromShippingStatus]){
            [self confirmDeliveryOrderStatus:order];
        } else {
            [self confirmDeliveryOrderDeliver:order];
        }
    }
}


-(void)confirmDeliveryOrderStatus:(TxOrderStatusList*)order{
    __weak typeof(self) weakSelf = self;
    [RequestOrderAction fetchConfirmDeliveryOrderStatus:order success:^(TxOrderStatusList *order, TransactionActionResult* data) {
        [weakSelf refreshRequest];
        UIAlertView *alertSuccess = [[UIAlertView alloc]initWithTitle:nil message:@"Transaksi Anda sudah selesai! Silakan berikan Rating & Review sesuai tingkat kepuasan Anda atas pelayanan toko. Terima kasih sudah berbelanja di Tokopedia!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertSuccess show];
        alertSuccess.tag = TAG_ALERT_SUCCESS_DELIVERY_CONFIRM;
        [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil];
    } failure:^(NSError *error, TxOrderStatusList* order) {
        
        
    }];
}

-(void)confirmDeliveryOrderDeliver:(TxOrderStatusList*)order{
    __weak typeof(self) weakSelf = self;
    [RequestOrderAction fetchConfirmDeliveryOrderDeliver:order success:^(TxOrderStatusList *order, TransactionActionResult* data) {
        [weakSelf refreshRequest];
        UIAlertView *alertSuccess = [[UIAlertView alloc]initWithTitle:nil message:@"Transaksi Anda sudah selesai! Silakan berikan Rating & Review sesuai tingkat kepuasan Anda atas pelayanan toko. Terima kasih sudah berbelanja di Tokopedia!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertSuccess show];
        alertSuccess.tag = TAG_ALERT_SUCCESS_DELIVERY_CONFIRM;
        [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil];
        
    } failure:^(NSError *error, TxOrderStatusList* order) {
        
    }];
}

#pragma mark - Request ReOrder
-(void)doRequestReorder:(TxOrderStatusList*)order{
    self.view.userInteractionEnabled = NO;
    [SwiftOverlays showCenteredWaitOverlay:self.view];
    [RequestOrderAction fetchReorder:order success:^(TxOrderStatusList *order, TransactionActionResult *data) {
        TransactionCartViewController *vc = [TransactionCartViewController new];
        [self.navigationController pushViewController:vc animated:YES completion:^{
            self.view.userInteractionEnabled = YES;
            [SwiftOverlays removeAllOverlaysFromView:self.view];
        }];
    } failure:^(NSError *error, TxOrderStatusList *order) {
        self.view.userInteractionEnabled = YES;
        [SwiftOverlays removeAllOverlaysFromView:self.view];
    }];
}

-(void)tapConfirmDeliveryOrder:(TxOrderStatusList *)order{
    [_dataInput setObject:order forKey:DATA_ORDER_DELIVERY_CONFIRMATION];
    [self showAlertDeliver:order];
}

-(void)tapReorderOrder:(TxOrderStatusList *)order {
    [_dataInput setObject:order forKey:DATA_ORDER_REORDER_KEY];
    [self showAlertReorder];
}

-(void)tapComplaintNotReceivedOrder:(TxOrderStatusList *)order{
    [self createComplainOrder:order isReceived:NO];
}

-(void)tapSeeComplaintDetailOrder:(TxOrderStatusList *)order{
    NSDictionary *queries = [NSDictionary dictionaryFromURLString:order.order_button.button_res_center_url];
    
    NSString *resolutionID = [queries objectForKey:@"id"];
    ResolutionWebViewController *vc = [[ResolutionWebViewController alloc] initWithResolutionId:resolutionID];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tapShopOrder:(TxOrderStatusList *)order
{
    [_navigate navigateToShopFromViewController:self withShopID:order.order_shop.shop_id];
}

-(void)tapInvoiceOrder:(TxOrderStatusList *)order
{
    [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:order.order_detail.detail_pdf_uri];
}


#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_SUCCESS_DELIVERY_CONFIRM)
    {
        [_navigate navigateToInboxReviewFromViewController:self withGetDataFromMasterDB:YES];
    }
}

-(void)createComplainOrder:(TxOrderStatusList*)order isReceived:(BOOL)isReceived{
    ResolutionCenterCreateViewController *vc = [ResolutionCenterCreateViewController new];
    vc.order = order;
    vc.product_is_received = isReceived;
    
    __weak typeof(self) weakSelf = self;
    vc.didCreateComplaint = ^(TxOrderStatusList *order){
        [weakSelf refreshRequest];
    };
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [navigationController.navigationBar setTranslucent:NO];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Methods
-(void)refreshRequest
{
    _page = 1;
    [self doRequestList];
}

- (void)tapDone:(TxOrderStatusList *)order {
    __weak typeof(self) weakSelf = self;
    
    NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringFromHTML:order.order_detail.detail_finish_popup_msg normalFont:[UIFont largeTheme] boldFont:[UIFont largeThemeMedium] italicFont:[UIFont largeTheme]]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:order.order_detail.detail_finish_popup_title
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *receivedAction = [UIAlertAction actionWithTitle:@"Selesai"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [AnalyticsManager trackEventName:@"clickReceived" category:GA_EVENT_CATEGORY_RECEIVED action:GA_EVENT_ACTION_CLICK label:@"Confirmation"];
                                                               [weakSelf confirmDelivery:order];
                                                           }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Kembali"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertController addAction:receivedAction];
    [alertController addAction:cancelAction];
    [alertController setValue:messageString forKey:@"attributedMessage"];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)tapComplaint:(TxOrderStatusList *)order {
    __weak typeof(self) weakSelf = self;
    
    BOOL isNotReceived = (order.order_button.button_open_complaint_not_received == 1);
    
    NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringFromHTML:order.order_detail.detail_complaint_popup_msg normalFont:[UIFont largeTheme] boldFont:[UIFont largeThemeMedium] italicFont:[UIFont largeTheme]]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:order.order_detail.detail_complaint_popup_title
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *receivedAction = [UIAlertAction actionWithTitle:@"Sudah Sampai"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [weakSelf createComplainOrder:order isReceived:YES];
                                                           }];
    
    UIAlertAction *notReceivedAction = [UIAlertAction actionWithTitle:@"Belum Sampai"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [weakSelf createComplainOrder:order isReceived:NO];
                                                              }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Kembali"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertController addAction:receivedAction];
    
    if (isNotReceived) {
        [alertController addAction:notReceivedAction];
    }
    
    [alertController addAction:cancelAction];
    [alertController setValue:messageString forKey:@"attributedMessage"];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)tapDetailOrder:(TxOrderStatusList *)order
{
    __weak typeof(self) weakSelf = self;
    TxOrderStatusDetailViewController *detail = [TxOrderStatusDetailViewController new];
    detail.order = order;
    detail.didRequestCancel = ^(TxOrderStatusList *order){
        [weakSelf refreshRequest];
    };
    detail.didReorder = ^(TxOrderStatusList *order){
        [weakSelf refreshRequest];
    };
    detail.didReceivedOrder = ^(TxOrderStatusList *order){
        [weakSelf refreshRequest];
    };
    detail.didCancelComplaint = ^(TxOrderStatusList *order){
        [weakSelf refreshRequest];
    };
    detail.didComplaint = ^(TxOrderStatusList *order){
        [weakSelf refreshRequest];
    };
    detail.didCreateComplaint = ^(TxOrderStatusList *order){
        [weakSelf refreshRequest];
    };
    detail.didCancelReplacement = ^(TxOrderStatusList *order){
        [weakSelf refreshRequest];
    };
    
    [self.navigationController pushViewController:detail animated:YES];
}

-(void)trackOrder:(TxOrderStatusList*)order
{
    TrackOrderViewController *vc = [TrackOrderViewController new];
    vc.delegate = self;
    vc.hidesBottomBarWhenPushed = YES;
    vc.orderID = [order.order_detail.detail_order_id integerValue];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showAlertDeliver:(TxOrderStatusList*)order
{
    [_dataInput setObject:order forKey:DATA_ORDER_COMPLAIN_KEY];
    OrderDeliveredConfirmationAlertView *confirmationAlert = [OrderDeliveredConfirmationAlertView newview];
    if ([self isOrderFreeReturn:order]) {
        confirmationAlert.title = @"Sudah Diterima";
        confirmationAlert.message = order.order_detail.detail_free_return_msg;
        confirmationAlert.isFreeReturn = YES;
    } else {
        confirmationAlert.title = [NSString stringWithFormat:ALERT_DELIVERY_CONFIRM_FORMAT,order.order_shop.shop_name];
        confirmationAlert.message = ALERT_DELIVERY_CONFIRM_DESCRIPTION;
        confirmationAlert.isFreeReturn = NO;
    }
    __weak typeof(self) weakSelf = self;
    confirmationAlert.didComplain = ^{
        [weakSelf tapComplaint:order];
    };
    
    confirmationAlert.didOK = ^{
        [AnalyticsManager trackEventName:@"clickReceived" category:GA_EVENT_CATEGORY_RECEIVED action:GA_EVENT_ACTION_CLICK label:@"Confirmation"];
        [weakSelf confirmDelivery:order];
    };
    
    [confirmationAlert show];
}

-(void)showAlertReorder {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ALERT_REORDER_TITLE message:ALERT_REORDER_DESCRIPTION preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ya" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [AnalyticsManager trackEventName:@"clickReorder" category:GA_EVENT_CATEGORY_REORDER action:GA_EVENT_ACTION_CLICK label:@"Confirm Reorder"];
        
        TxOrderStatusList *order = [_dataInput objectForKey:DATA_ORDER_REORDER_KEY];
        [self doRequestReorder:order];
        
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Tidak" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:actionOk];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:true completion:nil];
}

- (BOOL) isUsingAnyFilter {
    NSString *filterInvoice = [_dataInput objectForKey:API_INVOICE_KEY]?:@"";
    NSString *filterStartDate = [_dataInput objectForKey:API_TRANSACTION_START_DATE_KEY]?:@"";
    NSString *filterEndDate = [_dataInput objectForKey:API_TRANSACTION_END_DATE_KEY]?:@"";
    NSString *filterStatus = (_isCanceledPayment)?@"5":[_dataInput objectForKey:API_TRANSACTION_STATUS_KEY]?:@"";
    
    BOOL isUsingInvoiceFilter = filterInvoice != nil && ![filterInvoice isEqualToString:@""];
    BOOL isUsingTransactionStatusFilter = filterStatus != nil && ![filterStatus isEqualToString:@""];
    BOOL isUsingDateFilter = (filterStartDate != nil && ![filterStartDate isEqualToString:@""]) || (filterEndDate != nil && ![filterEndDate isEqualToString:@""]);
    
    return (isUsingInvoiceFilter || isUsingTransactionStatusFilter || isUsingDateFilter);
}

- (BOOL) isOrderFreeReturn: (TxOrderStatusList*) order {
    if (order.order_detail.detail_free_return == 0) {
        return NO;
    } else if (order.order_detail.detail_free_return == 1) {
        return YES;
    }
    
    return YES;
}

@end
