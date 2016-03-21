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
#import "InboxReviewViewController.h"
#import "TKPDTabInboxReviewNavigationController.h"
#import "TrackOrderViewController.h"
#import "FilterSalesTransactionListViewController.h"
#import "TransactionCartRootViewController.h"
#import "ResolutionCenterDetailViewController.h"
#import "RequestCancelResolution.h"

#import "InboxResolutionCenterOpenViewController.h"

#import "TxOrderStatusCell.h"

#import "TransactionAction.h"
#import "string_tx_order.h"

#import "TxOrderStatus.h"
#import "TxOrderObjectMapping.h"
#import "NoResultView.h"

#import "TextMenu.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"

#import "NoResultReusableView.h"
#import "RequestLDExtension.h"

#import "RequestPurchase.h"

#define TAG_ALERT_DELIVERY_CONFIRMATION 10
#define TAG_ALERT_SUCCESS_DELIVERY_CONFIRM 11
#define TAG_ALERT_REORDER 12
#define TAG_ALERT_COMPLAIN 13
#define DATA_ORDER_DELIVERY_CONFIRMATION @"data_delivery_confirmation"
#define DATA_ORDER_REORDER_KEY @"data_reorder"
#define DATA_ORDER_COMPLAIN_KEY @"data_complain"

@interface TxOrderStatusViewController () <UITableViewDataSource, UITableViewDelegate, TxOrderStatusCellDelegate, UIAlertViewDelegate, FilterSalesTransactionListDelegate, TxOrderStatusDetailViewControllerDelegate, TrackOrderViewControllerDelegate, TokopediaNetworkManagerDelegate, ResolutionCenterDetailViewControllerDelegate, CancelComplainDelegate, InboxResolutionCenterOpenViewControllerDelegate, LoadingViewDelegate, NoResultDelegate, requestLDExttensionDelegate>
{
    NSMutableArray *_list;
    NSOperationQueue *_operationQueue;
    NSString *_URINext;
    
    NSInteger _page;
    
    BOOL _isNodata;
    
    TxOrderObjectMapping *_mapping;
    
    UIRefreshControl *_refreshControll;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKObjectManager *_objectManagerFinishOrder;
    __weak RKManagedObjectRequestOperation *_requestFinishOrder;
    __weak RKObjectManager *_objectManagerReOrder;
    __weak RKManagedObjectRequestOperation *_requestReOrder;
    
    NSString *_transactionFilter;
    
    NSMutableDictionary *_dataInput;
    NSMutableArray *_objectsConfirmRequest;
    
    NSInteger _totalButtonsShow;
    
    NavigateViewController *_navigate;
    
    TxOrderStatusList *_selectedTrackOrder;
    LoadingView *_loadingView;
    
    RequestCancelResolution *_requestCancelComplain;
    FilterSalesTransactionListViewController *_filterSalesTransactionList;
    
    UIViewController *_detailViewController;
    
    RequestLDExtension *_requestLD;
    LuckyDealWord *_worlds;
    
    BOOL _isNeedPopUpLD;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *filterView;

@property (strong, nonatomic) IBOutlet UIView *threeButtonsView;
@property (strong, nonatomic) IBOutlet UIView *twoButtonsView;
@property (strong, nonatomic) IBOutlet UIView *oneButtonView;
@property (strong, nonatomic) IBOutlet UIView *oneButtonReOrderView;

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
    
    _list = [NSMutableArray new];
    _mapping = [TxOrderObjectMapping new];
    _operationQueue = [NSOperationQueue new];
    _objectsConfirmRequest = [NSMutableArray new];
    
    _refreshControll = [[UIRefreshControl alloc] init];
    _refreshControll.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControll addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControll];
    
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
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = _viewControllerTitle?:@" ";
    
    if ([_action isEqualToString:@"get_tx_order_status"]) {
        [TPAnalytics trackScreenName:@"Purchase - Order Status"];
        self.screenName = @"Purchase - Order Status";
    } else if ([_action isEqualToString:@"get_tx_order_deliver"]) {
        [TPAnalytics trackScreenName:@"Purchase - Received Confirmation"];
        self.screenName = @"Purchase - Received Confirmation";
    } else {
        [TPAnalytics trackScreenName:@"Purchase - Transaction List"];
        self.screenName = @"Purchase - Transaction List";
    }
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

-(IBAction)tap:(id)sender
{

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        NSString *filterInvoice = [_dataInput objectForKey:API_INVOICE_KEY]?:@"";
        NSString *filterStartDate = [_dataInput objectForKey:API_TRANSACTION_START_DATE_KEY]?:@"";
        NSString *filterEndDate = [_dataInput objectForKey:API_TRANSACTION_END_DATE_KEY]?:@"";
        NSString *filterStatus = [_dataInput objectForKey:API_TRANSACTION_STATUS_KEY]?:@"";
        
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
        navigationController.navigationBar.translucent = NO;
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
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
-(void)delegateViewController:(UIViewController *)viewController
{
    _detailViewController = viewController;
}

-(void)confirmDelivery:(TxOrderStatusList *)order atIndexPath:(NSIndexPath*)indexPath
{
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:order forKey:DATA_ORDER_DELIVERY_CONFIRM];
    [object setObject:indexPath forKey:DATA_INDEXPATH_DELIVERY_CONFIRM];
    
    [_list removeObject:order];
    [_tableView reloadData];
    
    [self configureRestKitFinishOrder];
    [self requestFinishOrder:object];
}

-(void)complainOrder:(TxOrderStatusList *)order
{
    
}

-(void)reOrder:(TxOrderStatusList *)order atIndexPath:(NSIndexPath *)indexPath
{
    [self configureRestKitReOrder];
    [self requestReOrder:order];
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
-(void)shouldRefreshRequest
{
    
    [self refreshRequest];
}

- (void)updateDeliveredOrder:(NSString *)receiverName
{
//    OrderHistory *history = [OrderHistory new];
//    NSString *buyerStatus;
//    if ([receiverName isEqualToString:@""] || receiverName == NULL) {
//        buyerStatus = [NSString stringWithFormat:@"Pesanan telah tiba di tujuan"];
//    } else {
//        buyerStatus = [NSString stringWithFormat:@"Pesanan telah tiba di tujuan<br>Received by %@", receiverName];
//    }
//    history.history_seller_status = buyerStatus;
//    _selectedTrackOrder.order_detail.detail_order_status = ORDER_DELIVERED;
//    _selectedTrackOrder.order_last.last_buyer_status = buyerStatus;
//    
//    [_selectedTrackOrder.order_history insertObject:history atIndex:0];
//    _selectedOrder.order_detail.detail_order_status = ORDER_DELIVERED;
//    _selectedOrder.order_deadline.deadline_finish_day_left = 3;
//    
//    NSDate *deadlineFinishDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*3];
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
//    
//    _selectedOrder.order_deadline.deadline_finish_date = [dateFormatter stringFromDate:deadlineFinishDate];
//    
//    [self.tableView reloadData];
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TxOrderStatusCell * cell = nil;
    NSString *cellid = TRANSACTION_ORDER_STATUS_CELL_IDENTIFIER;
    
    cell = (TxOrderStatusCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderStatusCell newCell];
        cell.delegate = self;
    }
    
    TxOrderStatusList *order = _list[indexPath.row];
    
    cell.invoiceNumberLabel.text = order.order_detail.detail_invoice;
    cell.invoiceDateLabel.text = order.order_detail.detail_order_date;
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:order.order_shop.shop_pic] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.shopProfileImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    [cell.finishLabel setHidden:YES];
    [cell.cancelAutomaticLabel setHidden:YES];
    if ([self isShowTimeLeftOrder:order]) {
        cell.deadlineProcessDayLeft = (order.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED)?order.order_deadline.deadline_process_day_left:order.order_deadline.deadline_shipping_day_left;
    }
    
    NSString *shipRef = order.order_detail.detail_ship_ref_num?:@"";
    NSLog(@"shipping resi :%@",shipRef);
    NSString *lastComment = order.order_last.last_comments?:@"";
    
    [cell.shopNameLabel setText:order.order_shop.shop_name animated:YES];
    
    NSString *lastStatus = [NSString convertHTML:order.order_last.last_buyer_status];

    NSMutableArray *comment = [NSMutableArray new];

    if (lastStatus &&![lastStatus isEqualToString:@""]&&![lastStatus isEqualToString:@"0"]) {
        [comment addObject:lastStatus];
    }
    if (shipRef &&
        ![shipRef isEqualToString:@""] &&
        ![shipRef isEqualToString:@"0"])
    {
        [comment addObject:[NSString stringWithFormat:@"Nomor resi: %@", order.order_last.last_shipping_ref_num]];
    }
    if (lastComment && ![lastComment isEqualToString:@"0"] && [lastComment isEqualToString:@""]) {
        [comment addObject:lastComment];
    }
    
    NSString *statusString = [[comment valueForKey:@"description"] componentsJoinedByString:@"\n"];
    
    [cell.statusTv setText:statusString];
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"Gotham Medium" size:11.0f],
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:statusString?:@"" attributes:attributes];
    cell.statusTv.attributedText = attributedText;
    
    if ([cell.statusTv.text isEqualToString:@"0"] || [cell.statusTv.text isEqual:@""]) {
        cell.statusTv.text = @"-";
    }

    [cell hideAllButton];
    if ([self isShowButtonSeeComplainOrder:order])
        cell.oneButtonView.hidden = NO;
    if ([self isShowButtonReorder:order])
        cell.oneButtonReOrderView.hidden = NO;
    if ([self isShowTwoButtonsOrder:order])
    {
        cell.twoButtonsView.hidden = NO;
        [self adjustTwoButtonOrder:order cell:cell];
    }
    if ([self isShowThreeButtonsOrder:order])
        cell.threeButtonsView.hidden = NO;
    
//    if ([self isShowTwoButtonsOrder:order] ||
//        [self isShowThreeButtonsOrder:order] ||
//        [self isShowButtonSeeComplainOrder:order] ||
//        [self isShowButtonSeeComplainOrder:order] ||
//        [self isShowButtonReorder:order]) {
//        [cell.buttonsConstraintHeight makeObjectsPerformSelector:@selector(setConstant:)withObject:@(44)];
//    } else {
//        [cell.buttonsConstraintHeight makeObjectsPerformSelector:@selector(setConstant:)withObject:@(0)];
//    }

    cell.indexPath = indexPath;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)adjustTwoButtonOrder:(TxOrderStatusList*)order cell:(TxOrderStatusCell*)cell
{
    NSString *title1 = @"";
    NSString *title2 = @"";
    if ([self isShowButtonTrackOrder:order]) {
        if ([title1 isEqualToString:@""])
            title1 = @"Lacak";
        else
            title2 = @"Lacak";
    }
    if ([self isShowButtonComplainOrder:order]) {
        if ([title1 isEqualToString:@""])
            title1 = @"Komplain";
        else
            title2 = @"Komplain";
    }
    if ([self isShowButtonConfirmOrder:order]) {
        if ([title1 isEqualToString:@""])
            title1 = @"Sudah Terima";
        else
            title2 = @"Sudah Terima";
    }
    
    UIButton *button1 = (UIButton*)cell.twoButtons[0];
    UIButton *button2 = (UIButton*)cell.twoButtons[1];
    
    [button1 setTitle:title1 forState:UIControlStateNormal];
    [button1 setImage:[UIImage imageNamed:[self imageNameButton:button1]] forState:UIControlStateNormal];
    
    [button2 setTitle:title2 forState:UIControlStateNormal];
    [button2 setImage:[UIImage imageNamed:[self imageNameButton:button2]] forState:UIControlStateNormal];
}

-(NSString*)imageNameButton:(UIButton*)button
{
    NSString *imageName = @"";
    if ([button.titleLabel.text isEqualToString:@"Lacak"]) {
        imageName = @"icon_track_grey.png";
    }
    if ([button.titleLabel.text isEqualToString:@"Sudah Terima"]) {
        imageName = @"icon_order_check-01.png";
    }
    if ([button.titleLabel.text isEqualToString:@"Komplain"]) {
        imageName = @"icon_komplain.png";
    }
    return imageName;
}


#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusList *order = _list[indexPath.row];
    CGFloat height = tableView.rowHeight;
    if (height>=0) {
        if ([self isShowTwoButtonsOrder:order] ||
            [self isShowThreeButtonsOrder:order] ||
            [self isShowButtonSeeComplainOrder:order] ||
            [self isShowButtonSeeComplainOrder:order] ||
            [self isShowButtonReorder:order]) {
            height = tableView.rowHeight;
        } else {
            height = tableView.rowHeight - 45;
        }
    }
    else
    {
    }

    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.row] -1;
    
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"%ld", (long)row);
        
        if (_URINext != NULL && ![_URINext isEqualToString:@"0"] && _URINext != 0) {
            [self doRequestList];
        }
    }
}


#pragma mark - Request Get Transaction Order Payment Confirmation

-(void)doRequestList{
    NSString *filterInvoice = [_dataInput objectForKey:API_INVOICE_KEY]?:@"";
    NSString *filterStartDate = [_dataInput objectForKey:API_TRANSACTION_START_DATE_KEY]?:@"";
    NSString *filterEndDate = [_dataInput objectForKey:API_TRANSACTION_END_DATE_KEY]?:@"";
    NSString *filterStatus = (_isCanceledPayment)?@"5":[_dataInput objectForKey:API_TRANSACTION_STATUS_KEY]?:@"";
    if (![_refreshControll isRefreshing]) {
        _tableView.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    [RequestPurchase fetchListPuchasePage:_page action:_action invoice:filterInvoice startDate:filterStartDate endDate:filterEndDate status:filterStatus success:^(NSArray *list, NSInteger nextPage, NSString* uriNext) {
        
        if (_page == 1) {
            [_list removeAllObjects];
        }
        [_list addObjectsFromArray:list];
        if (_list.count >0) {
            _isNodata = NO;
            _URINext =  uriNext;
            _page = nextPage;
            _tableView.tableFooterView = nil;
        } else {
            if ([self isUsingAnyFilter]) {
                [_noResultView setNoResultTitle:[NSString stringWithFormat:@"Belum ada transaksi untuk tanggal %@ - %@", [_dataInput objectForKey:API_TRANSACTION_START_DATE_KEY], [_dataInput objectForKey:API_TRANSACTION_END_DATE_KEY]]];
                [_noResultView hideButton:YES];
            } else {
                [_noResultView setNoResultTitle:@"Belum ada transaksi"];
                [_noResultView hideButton:YES];
            }
            
            [_tableView addSubview:_noResultView];
        }
        
        [_act stopAnimating];
        [_refreshControll endRefreshing];
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        [_act stopAnimating];
        [_refreshControll endRefreshing];
        
        [_noResultView removeFromSuperview];
        
        _tableView.tableFooterView = _loadingView.view;
    }];
}

#pragma mark - loading view delegate
-(void)pressRetryButton
{
    [_act startAnimating];
    _tableView.tableFooterView = _footer;
    [self doRequestList];
}


#pragma mark - Request Delivery Finish Order
-(void)cancelFinishOrder
{
    [_requestFinishOrder cancel];
    //_requestFinishOrder = nil;
    [_objectManagerFinishOrder.operationQueue cancelAllOperations];
    _objectManagerFinishOrder = nil;
}

-(void)configureRestKitFinishOrder
{
    _objectManagerFinishOrder = [RKObjectManager sharedClient];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[TransactionAction mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerFinishOrder addResponseDescriptor:responseDescriptor];
    
}

-(void)requestFinishOrder:(id)object
{
    NSDictionary *selectedObject = (NSDictionary*)object;
    
    TxOrderStatusList *order = [selectedObject objectForKey:DATA_ORDER_DELIVERY_CONFIRM];
    NSIndexPath *indexPath = [selectedObject objectForKey:DATA_INDEXPATH_DELIVERY_CONFIRM];
    
    NSMutableDictionary *processingObject = [NSMutableDictionary new];
    [processingObject setObject:order forKey:DATA_ORDER_DELIVERY_CONFIRM];
    [processingObject setObject:indexPath forKey:DATA_INDEXPATH_DELIVERY_CONFIRM];
    
    [_objectsConfirmRequest addObject:processingObject];
    
    if (_requestFinishOrder.isExecuting) return;
    
    NSTimer *timer;
    
    NSString *action = ACTION_DELIVERY_FINISH_ORDER;
    if ([_action isEqualToString:@"get_tx_order_deliver"]) {
        action = ACTION_DETIVERY_CONFIRM;
    }
    
    NSDictionary* param = @{API_ACTION_KEY : action,
                            API_ORDER_ID_KEY : order.order_detail.detail_order_id};

    _requestFinishOrder = [_objectManagerFinishOrder appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_TX_ORDER parameters:[param encrypt]];
    
    [_requestFinishOrder setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessFinishOrder:object
                          withOperation:operation
                      withMappingResult:mappingResult];
        [_objectsConfirmRequest removeObject:processingObject];
        [timer invalidate];
        [_act stopAnimating];
        [self requestProcessFinishOrder];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self failedConfirmDelivery:object];
        [self requestFailureFinishOrder:error];
        [timer invalidate];
        [_act stopAnimating];
        [_objectsConfirmRequest removeObject:processingObject];
        [self requestProcessFinishOrder];
    }];
    
    [_operationQueue addOperation:_requestFinishOrder];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutFinishOrder) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessFinishOrder:(NSDictionary*)object withOperation:(RKObjectRequestOperation *)operation withMappingResult:(RKMappingResult*)mappingResult
{
    NSDictionary *result = mappingResult.dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (order.result.is_success == 1) {
            UIAlertView *alertSuccess = [[UIAlertView alloc]initWithTitle:nil message:@"Transaksi Anda sudah selesai! Silakan berikan Rating & Review sesuai tingkat kepuasan Anda atas pelayanan toko. Terima kasih sudah berbelanja di Tokopedia!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertSuccess show];
            alertSuccess.tag = TAG_ALERT_SUCCESS_DELIVERY_CONFIRM;
            [self refreshRequest];
            [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil];
        }
        else
        {
            [self failedConfirmDelivery:object];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:order.message_error?:@[@"Permintaan anda gagal. Mohon coba kembali"] delegate:self];
            StickyAlertView *alertDelegate = [[StickyAlertView alloc] initWithErrorMessages:order.message_error?:@[@"Permintaan anda gagal. Mohon coba kembali"] delegate:_detailViewController];
            [alertDelegate show];
            [alert show];
        }
        
        if (order.result.ld.url) {
            _requestLD = [RequestLDExtension new];
            _requestLD.luckyDeal = order.result.ld;
            _requestLD.delegate = self;
            [_requestLD doRequestMemberExtendURLString:order.result.ld.url];
        }
    }
    else
    {
        [self failedConfirmDelivery:object];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Permintaan anda gagal. Mohon coba kembali"] delegate:self];
        [alert show];
        StickyAlertView *alertDelegate = [[StickyAlertView alloc] initWithErrorMessages:order.message_error?:@[@"Permintaan anda gagal. Mohon coba kembali"] delegate:_detailViewController];
        [alertDelegate show];
    }
}

-(void)requestFailureFinishOrder:(id)object
{
    NSError *error = object;

    NSArray *errors;
    if(error.code == -1011) {
        errors = @[@"Mohon maaf, terjadi kendala pada server"];
    } else if (error.code==-1009 || error.code==-999) {
        errors = @[@"Tidak ada koneksi internet"];
    } else {
        errors = @[error.localizedDescription];
    }
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errors delegate:self];
    [alert show];
}

-(void)requestProcessFinishOrder
{
    if ([_objectsConfirmRequest count]>0) {
        [self configureRestKitFinishOrder];
        [self requestFinishOrder:[_objectsConfirmRequest firstObject]];
    }
}

-(void)requestTimeoutFinishOrder
{
    [self cancelFinishOrder];
}

#pragma mark - Request ReOrder
-(void)cancelReOrder
{
    [_requestReOrder cancel];
    //_requestReOrder = nil;
    [_objectManagerReOrder.operationQueue cancelAllOperations];
    _objectManagerReOrder = nil;
}

-(void)configureRestKitReOrder
{
    _objectManagerReOrder = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[API_IS_SUCCESS_KEY]];
    
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    [statusMapping addPropertyMapping:resultRel];
    
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerReOrder addResponseDescriptor:responseDescriptor];
    
}

-(void)requestReOrder:(TxOrderStatusList*)order
{
    if (_requestReOrder.isExecuting) return;
    
    NSTimer *timer;
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_RE_ORDER,
                            API_ORDER_ID_KEY : order.order_detail.detail_order_id};

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
//    _requestReOrder = [_objectManagerReOrder appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_TX_ORDER parameters:paramDictionary];
//#else
    _requestReOrder = [_objectManagerReOrder appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_TX_ORDER parameters:[param encrypt]];
//#endif
    
    [_requestReOrder setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessReOrder:order
                          withOperation:operation
                      withMappingResult:mappingResult];
        [timer invalidate];
        [_act stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureReOrder:order withError:error];
        [timer invalidate];
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_requestReOrder];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutReOrder) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessReOrder:(TxOrderStatusList*)object withOperation:(RKObjectRequestOperation *)operation withMappingResult:(RKMappingResult*)mappingResult
{
    NSDictionary *result = mappingResult.dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (order.result.is_success == 1) {
            TransactionCartRootViewController *vc = [TransactionCartRootViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            if(order.message_error)
            {
                NSMutableArray *errors = [order.message_error mutableCopy];
                for (int i = 0; i<errors.count; i++) {
                    if ([order.message_error[i] rangeOfString:@"Alamat"].location == NSNotFound) {
                    //if ([order.message_error[i] containsString:@"Alamat"]) {
                        [errors replaceObjectAtIndex:i withObject:@"Pesan ulang tidak dapat dilakukan karena alamat tidak valid."];
                    }
                }
                NSArray *array = errors?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                [alert show];
            }        }
    }
    else
    {
        [self requestFailureReOrder:object withError:nil];
    }
}


-(void)requestFailureReOrder:(TxOrderStatusList*)order withError:(NSError*)error
{
    if ([error code] != NSURLErrorCancelled) {
        NSString *errorDescription = error.localizedDescription;
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
        [errorAlert show];
    }
}

-(void)requestProcessReOrder
{

}

-(void)requestTimeoutReOrder
{
    [self cancelReOrder];
}


#pragma mark - Cell Delegate
-(void)trackOrderAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusList *order = _list[indexPath.row];
    [self shouldTrackOrder:order];
}

-(void)confirmDeliveryAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusList *order = _list[indexPath.row];
    [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_DELIVERY_CONFIRM];
    [_dataInput setObject:order forKey:DATA_ORDER_DELIVERY_CONFIRMATION];
    [self showAlertDeliver:order];
}

-(void)reOrderAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusList *order = _list[indexPath.row];
    [_dataInput setObject:order forKey:DATA_ORDER_REORDER_KEY];
    [self showAlertReorder];
}

-(void)complainAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusList *order = _list[indexPath.row];
    [_dataInput setObject:order forKey:DATA_ORDER_COMPLAIN_KEY];
    [self showAlertViewOpenComplain];
}

-(void)goToComplaintDetailAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusList *order = _list[indexPath.row];
    ResolutionCenterDetailViewController *vc = [ResolutionCenterDetailViewController new];
    vc.indexPath = indexPath;
    vc.delegate = self;
    vc.isNeedRequestListDetail = YES;
    NSDictionary *queries = [NSDictionary dictionaryFromURLString:order.order_button.button_res_center_url];
    NSString *resolutionID = [queries objectForKey:@"id"];
    vc.resolutionID = resolutionID;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)shouldCancelComplain:(InboxResolutionCenterList *)resolution atIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusList *order = _list[indexPath.row];
    RequestCancelResolution *request = [self requestCancelComlpain];
    NSDictionary *queries = [NSDictionary dictionaryFromURLString:order.order_button.button_res_center_url];
    NSString *resolutionID = [queries objectForKey:@"id"];
    request.resolutionID = [resolutionID integerValue];
    request.delegate = self;
    request.resolution = resolution;
    [request doRequest];
}

-(RequestCancelResolution*)requestCancelComlpain
{
    if (!_requestCancelComplain) {
        _requestCancelComplain = [RequestCancelResolution new];
        _requestCancelComplain.delegate = self;
    }
    
    return _requestCancelComplain;
}

-(void)successCancelComplain:(InboxResolutionCenterList *)resolution successStatus:(NSArray *)successStatus
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:successStatus?:@[@"Anda telah berhasil membatalkan komplain"] delegate:self];
    [alert show];
    [_list removeObject:resolution];
    [_tableView reloadData];
    [self refreshRequest];
}

-(void)failedCancelComplain:(InboxResolutionCenterList *)resolution errors:(NSArray *)errors
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errors delegate:self];
    [alert show];
}

-(void)failedConfirmDelivery:(NSDictionary*)object
{
    TxOrderStatusList *order = [object objectForKey:DATA_ORDER_DELIVERY_CONFIRM];
    NSIndexPath *indexPath = [object objectForKey:DATA_INDEXPATH_DELIVERY_CONFIRM];
    [_list insertObject:order atIndex:indexPath.row];
    [_tableView reloadData];
}

-(void)goToShopAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusList *order = _list[indexPath.row];
    [_navigate navigateToShopFromViewController:self withShopID:order.order_shop.shop_id];
}

-(void)goToInvoiceAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusList *order = _list[indexPath.row];
    [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:order.order_detail.detail_pdf_uri];
}


#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == TAG_ALERT_DELIVERY_CONFIRMATION)
    {
        switch (buttonIndex) {
            case 1://Selesai
            {
                TxOrderStatusList *order = [_dataInput objectForKey:DATA_ORDER_DELIVERY_CONFIRMATION];
                NSIndexPath *indexPath = [_dataInput objectForKey:DATA_INDEXPATH_DELIVERY_CONFIRM];
                [self confirmDelivery:order atIndexPath:(NSIndexPath*)indexPath];
            }
                break;
            case 2://Complain
            {
                [self showAlertViewOpenComplain];
            }
                break;
            default:
                break;
        }
    }
    else if (alertView.tag == TAG_ALERT_SUCCESS_DELIVERY_CONFIRM)
    {
        [_navigate navigateToInboxReviewFromViewController:self withGetDataFromMasterDB:YES];
        if(_isNeedPopUpLD)[_navigate popUpLuckyDeal:_worlds];
    }
    else if (alertView.tag == TAG_ALERT_REORDER)
    {
        if (buttonIndex == 1) {
            TxOrderStatusList *order = [_dataInput objectForKey:DATA_ORDER_REORDER_KEY];
            [self configureRestKitReOrder];
            [self requestReOrder:order];
        }
    }
    else if (alertView.tag == TAG_ALERT_COMPLAIN)
    {
        if (buttonIndex == 2) {
            return;
        }
        
        TxOrderStatusList *order = [_dataInput objectForKey:DATA_ORDER_COMPLAIN_KEY];
        InboxResolutionCenterOpenViewController *vc = [InboxResolutionCenterOpenViewController new];
        vc.controllerTitle = @"Buka Komplain";
        if (buttonIndex == 0) {
            //Tidak Terima Barang
            vc.isGotTheOrder = NO;
        }
        else if (buttonIndex ==1)
        {
            //Terima barang
            vc.isGotTheOrder = YES;
            
        }
        vc.isChangeSolution = NO;
        vc.isCanEditProblem = YES;
        vc.order = order;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Cell Show Button Validation
-(BOOL)isShowButtonConfirmOrder:(TxOrderStatusList*)order
{
    NSInteger orderStatus = order.order_detail.detail_order_status;
    NSString *shipRef = order.order_detail.detail_ship_ref_num?:@"";
    if(orderStatus == ORDER_SHIPPING ||
       orderStatus == ORDER_SHIPPING_TRACKER_INVALID ||
       orderStatus == ORDER_SHIPPING_REF_NUM_EDITED ||
       orderStatus == ORDER_DELIVERED ||
       orderStatus == ORDER_DELIVERY_FAILURE||
       orderStatus == ORDER_SHIPPING_WAITING||
       orderStatus == ORDER_DELIVERED_DUE_LIMIT)
    {
        
        if((orderStatus == ORDER_SHIPPING ||
            orderStatus == ORDER_SHIPPING_TRACKER_INVALID ||
            orderStatus == ORDER_SHIPPING_REF_NUM_EDITED ||
            orderStatus == ORDER_SHIPPING_WAITING) &&
           ![shipRef isEqualToString:@""]) {
            if(([_action isEqualToString:ACTION_GET_TX_ORDER_STATUS] || [_action isEqualToString:ACTION_GET_TX_ORDER_LIST]) )
            {
                return YES;
            }
        }
        else {
            if([_action isEqualToString:ACTION_GET_TX_ORDER_DELIVER]) {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)isShowButtonTrackOrder:(TxOrderStatusList*)order
{
    NSInteger orderStatus = order.order_detail.detail_order_status;
    NSString *shipRef = order.order_detail.detail_ship_ref_num?:@"";
    if(orderStatus == ORDER_SHIPPING ||
       orderStatus == ORDER_SHIPPING_TRACKER_INVALID ||
       orderStatus == ORDER_SHIPPING_REF_NUM_EDITED ||
       orderStatus == ORDER_DELIVERED ||
       orderStatus == ORDER_DELIVERY_FAILURE||
       orderStatus == ORDER_SHIPPING_WAITING)
    {
        
        if((orderStatus == ORDER_SHIPPING ||
            orderStatus == ORDER_SHIPPING_TRACKER_INVALID ||
            orderStatus == ORDER_SHIPPING_REF_NUM_EDITED ||
            orderStatus == ORDER_SHIPPING_WAITING) &&
           ![shipRef isEqualToString:@""])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isShowButtonComplainOrder:(TxOrderStatusList*)order
{
    if(order.order_button.button_open_dispute == 1) {
        return YES;
    }
    return NO;
}

-(BOOL)isShowButtonSeeComplainOrder:(TxOrderStatusList*)order
{
    if(order.order_button.button_res_center_go_to==1) {
        return YES;
    }
    return NO;
}

-(BOOL)isShowButtonReorder:(TxOrderStatusList*)order
{
    if (order.order_detail.detail_order_status == ORDER_CANCELED || order.order_detail.detail_order_status == ORDER_REJECTED) {
        return YES;
    }
    return NO;
}

-(BOOL)isShowTimeLeftOrder:(TxOrderStatusList*)order
{
    //if([self isShowButtonSeeComplainOrder:order]||
    //   [self isShowButtonReorder:order]||
    //   [self isShowTwoButtonsOrder:order]||
    //   [self isShowThreeButtonsOrder:order]||
    //   order.order_detail.detail_order_status == ORDER_PAYMENT_CONFIRM ||
    //   order.order_detail.detail_order_status == ORDER_PENDING ||
    //   order.order_detail.detail_order_status == ORDER_FINISHED)
    //    return NO;
    if ((order.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED ||
        order.order_detail.detail_order_status == ORDER_PROCESS ||
        order.order_detail.detail_order_status == ORDER_PROCESS_PARTIAL)&&
        ![self isShowButtonSeeComplainOrder:order]&&
        ![self isShowButtonReorder:order]&&
        ![self isShowTwoButtonsOrder:order]&&
        ![self isShowThreeButtonsOrder:order]) {
        return YES;
    }
    return NO;
}

-(BOOL)isShowTwoButtonsOrder:(TxOrderStatusList*)order
{
    int buttonCount = 0;
    if ([self isShowButtonTrackOrder:order]) {
        buttonCount +=1;
    }
    if ([self isShowButtonConfirmOrder:order]) {
        buttonCount +=1;
    }
    if ([self isShowButtonComplainOrder:order]) {
        buttonCount +=1;
    }
    
    if (buttonCount == 2) {
        return YES;
    }

    return NO;
}

-(BOOL)isShowThreeButtonsOrder:(TxOrderStatusList*)order
{
    if ([self isShowButtonTrackOrder:order] &&
        [self isShowButtonConfirmOrder:order]&&
        [self isShowButtonComplainOrder:order])
        return YES;
    
    return NO;
}

#pragma mark - Methods
-(void)refreshRequest
{
    _page = 1;
    [self doRequestList];
}

-(void)statusDetailAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderStatusDetailViewController *vc = [TxOrderStatusDetailViewController new];
    TxOrderStatusList *order = _list[indexPath.row];
    vc.order = order;
    int buttonCount = 0;
    if ([self isShowButtonConfirmOrder:order]) {
        buttonCount +=1;
    }
    if ([self isShowButtonComplainOrder:order]) {
        buttonCount +=1;
    }
    
    vc.buttonHeaderCount = buttonCount;
    
    if ([self isShowButtonSeeComplainOrder:order])
        vc.isComplain = YES;
    else if ([self isShowButtonReorder:order])
        vc.reOrder = YES;
    vc.indexPath = indexPath;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)shouldTrackOrder:(TxOrderStatusList*)order
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
    UIAlertView *alertConfirmation = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:ALERT_DELIVERY_CONFIRM_FORMAT,order.order_shop.shop_name]
                                                               message:ALERT_DELIVERY_CONFIRM_DESCRIPTION
                                                              delegate:self
                                                     cancelButtonTitle:@"Batal"
                                                     otherButtonTitles:@"Selesai",@"Komplain", nil];
    alertConfirmation.tag = TAG_ALERT_DELIVERY_CONFIRMATION;
    [alertConfirmation show];
}

-(void)showAlertReorder
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_REORDER_TITLE
                                                   message:ALERT_REORDER_DESCRIPTION
                                                  delegate:self
                                         cancelButtonTitle:@"Tidak"
                                         otherButtonTitles:@"Ya", nil];
    alert.tag = TAG_ALERT_REORDER;
    [alert show];
}

-(void)showAlertViewOpenComplain
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Buka Komplain" message:@"Apakah Anda sudah menerima barang yang dipesan?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Tidak Terima", @"Terima", @"Batal", nil];
    alert.tag = TAG_ALERT_COMPLAIN;
    [alert show];
}

-(void)showPopUpLuckyDeal:(LuckyDealWord *)words
{
    _isNeedPopUpLD = YES;
    _worlds = words;
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

@end
