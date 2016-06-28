//
//  SalesTransactionListViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_order.h"

#import "Order.h"
#import "OrderTransaction.h"
#import "ActionOrder.h"

#import "ShipmentStatusCell.h"
#import "StickyAlertView.h"

#import "SalesTransactionListViewController.h"
#import "FilterSalesTransactionListViewController.h"
#import "TrackOrderViewController.h"
#import "ChangeReceiptNumberViewController.h"
#import "DetailShipmentStatusViewController.h"
#import "NavigateViewController.h"
#import "NoResultReusableView.h"
#import "UITableView+IndexPath.h"

@interface SalesTransactionListViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    ShipmentStatusCellDelegate,
    FilterSalesTransactionListDelegate,
    ChangeReceiptNumberDelegate,
    TrackOrderViewControllerDelegate,
    NoResultDelegate
>

@property (strong, nonatomic) NSString *invoice;
@property (strong, nonatomic) NSString *transactionStatus;
@property (strong, nonatomic) NSString *startDate;
@property (strong, nonatomic) NSString *endDate;

@property (strong, nonatomic) NSString *page;
@property (strong, nonatomic) NSURL *nextURL;

@property (strong, nonatomic) NSMutableArray *orders;
@property (strong, nonatomic) Order *response;
@property (strong, nonatomic) OrderTransaction *selectedOrder;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) FilterSalesTransactionListViewController *filterViewController;

@property (strong, nonatomic) NoResultReusableView *noResultView;

@property (strong, nonatomic) TokopediaNetworkManager *networkManager;
@property (strong, nonatomic) TokopediaNetworkManager *actionNetworkManager;

@end

@implementation SalesTransactionListViewController

- (void)initNoResultView {
    self.noResultView = [[NoResultReusableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self.noResultView generateAllElements:@"icon_no_data_grey.png"
                                     title:@"Tidak ada data"
                                      desc:@""
                                  btnTitle:@""];
    
    [self.noResultView hideButton:YES];
    self.noResultView.delegate = self;
}

    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Daftar Transaksi";
    
    [TPAnalytics trackScreenName:@"Sales - Transaction List"];
    
    self.screenName = @"Sales - Transaction List";

    self.navigationItem.backBarButtonItem = self.backBarButton;
    self.navigationItem.rightBarButtonItem = self.filterBarButton;
    
    self.tableView.tableFooterView = _footerView;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];

    self.page = @"1";
    
    self.invoice = @"";
    self.transactionStatus = @"";
    self.startDate = @"";
    self.endDate = @"";
    
    self.orders = [NSMutableArray new];

    [self request];
    [self initNoResultView];
    [self.activityIndicatorView startAnimating];
    
    self.filterViewController = [FilterSalesTransactionListViewController new];
    self.filterViewController.delegate = self;
}

- (UIBarButtonItem *)backBarButton {
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    return backBarButtonItem;
}

- (UIBarButtonItem *)filterBarButton {
    UIBarButtonItem *filterBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(didTapFilterButton:)];
    return filterBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_orders count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    if ([self.response.result.order.is_allow_manage_tx boolValue] && order.order_detail.detail_ship_ref_num) {
        if (order.order_detail.detail_order_status == ORDER_SHIPPING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_WAITING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_TRACKER_INVALID ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_REF_NUM_EDITED) {
            return tableView.rowHeight;
        } else {
            return tableView.rowHeight - 50;
        }
    }
    return tableView.rowHeight - 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifer = @"ShipmentStatusCell";
    ShipmentStatusCell *cell = (ShipmentStatusCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ShipmentStatusCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.delegate = self;
    cell.indexPath = indexPath;

    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    
    cell.invoiceNumberLabel.text = order.order_detail.detail_invoice;
    cell.buyerNameLabel.text = order.order_customer.customer_name;
    cell.invoiceDateLabel.text = order.order_detail.detail_order_date;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:order.order_customer.customer_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    cell.buyerProfileImageView.image = nil;
    [cell.buyerProfileImageView setImageWithURLRequest:request
                                      placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   [cell.buyerProfileImageView setImage:image];
                                                   [cell.buyerProfileImageView setContentMode:UIViewContentModeScaleAspectFill];
                                               } failure:nil];
    
    cell.dateFinishLabel.hidden = YES;
    cell.finishLabel.hidden = YES;
    
    if ([self.response.result.order.is_allow_manage_tx boolValue] && order.order_detail.detail_ship_ref_num) {

        if (order.order_detail.detail_order_status == ORDER_SHIPPING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_WAITING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_TRACKER_INVALID ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_REF_NUM_EDITED) {
            [cell showAllButton];
        } else {
            [cell hideAllButton];
        }
        
        if (order.order_detail.detail_order_status == ORDER_DELIVERED_CONFIRM) {
            cell.dateFinishLabel.hidden = NO;
            cell.finishLabel.hidden = NO;
            if ([order.order_history count]) {
                OrderHistory *history = [order.order_history objectAtIndex:0];
                cell.dateFinishLabel.text = [history.history_status_date_full substringToIndex:[history.history_status_date_full length]-6];
            } else {
                cell.dateFinishLabel.text = @"";
            }
        }
    }

    if ([order.order_history count]) {
        [cell setStatusLabelText:[[order.order_history objectAtIndex:0] history_seller_status]];
    } else {
        [cell setStatusLabelText:@"-"];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isLastIndexPath:indexPath] && self.nextURL) {
        self.tableView.tableFooterView = _footerView;
        [self.activityIndicatorView startAnimating];
        [self request];
    } else {
        self.tableView.tableFooterView = nil;
    }
}

#pragma mark - Cell delegate

- (void)didTapReceiptButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath {
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    ChangeReceiptNumberViewController *controller = [ChangeReceiptNumberViewController new];
    controller.delegate = self;
    controller.order = _selectedOrder;
    navigationController.viewControllers = @[controller];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didTapStatusAtIndexPath:(NSIndexPath *)indexPath {
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    DetailShipmentStatusViewController *controller = [DetailShipmentStatusViewController new];
    controller.order = order;
    controller.is_allow_manage_tx = _response.result.order.is_allow_manage_tx;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didTapTrackButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath {
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    TrackOrderViewController *controller = [TrackOrderViewController new];
    controller.order = _selectedOrder;
    controller.hidesBottomBarWhenPushed = YES;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didTapUserAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    NavigateViewController *controller = [NavigateViewController new];
    [controller navigateToProfileFromViewController:self withUserID:_selectedOrder.order_customer.customer_id];
}

#pragma mark - Change receipt delegate

- (void)changeReceiptNumber:(NSString *)receiptNumber orderHistory:(OrderHistory *)history {
    [self requestActionReceiptNumber:receiptNumber];
}

#pragma mark - Rest Kit Methods

- (void)request {
    if (self.networkManager == nil) {
        self.networkManager = [TokopediaNetworkManager new];
        self.networkManager.isUsingHmac = YES;
    }
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSDictionary *parameters = @{
        @"user_id"  : [auth getUserId],
        @"page"     : self.page,
        @"invoice"  : self.invoice?: @"",
        @"status"   : self.transactionStatus?: @"",
        @"start"    : self.startDate?: @"",
        @"end"      : self.endDate?: @"",
    };
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/myshop-order/get_order_list.pl"
                                     method:RKRequestMethodGET
                                  parameter:parameters
                                    mapping:[Order mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      [self didReceiveMappingResult:mappingResult];
                                  } onFailure:^(NSError *errorResult) {
                                      [self requestFailure];
                                  }];
}

- (void)didReceiveMappingResult:(RKMappingResult *)mappingResult {
    NSDictionary *dict = mappingResult.dictionary;
    self.response = [dict objectForKey:@""];
    if ([self.response.status isEqualToString:@"OK"]) {
        [self.noResultView removeFromSuperview];
        if ([self.page isEqualToString:@"1"]) {
            self.orders = _response.result.list;
        } else {
            [self.orders addObjectsFromArray:_response.result.list];
        }
        self.nextURL = [NSURL URLWithString:_response.result.paging.uri_next];
        self.page = [_nextURL valueForKey:@"page"];
        [self.activityIndicatorView stopAnimating];
        if (self.orders.count == 0) {
            if ([self isUsingAnyFilter]) {
                [self.noResultView setNoResultTitle:[NSString stringWithFormat:@"Belum ada transaksi untuk tanggal %@ - %@", _startDate, _endDate]];
                [self.noResultView hideButton:YES];
            } else {
                [self.noResultView setNoResultTitle:@"Belum ada transaksi"];
                [self.noResultView hideButton:YES];
            }
            [self.tableView addSubview:_noResultView];
        } else {
            self.tableView.tableFooterView = nil;
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } else {
        [self.activityIndicatorView stopAnimating];
        self.tableView.tableFooterView = nil;
    }
}

- (void)requestFailure {
    [self.activityIndicatorView stopAnimating];
    self.tableView.tableFooterView = nil;
    [self.refreshControl endRefreshing];
}

- (void)refreshData {
    self.page = @"1";
    [self request];
}

#pragma mark - Reskit action methods

- (void)requestActionReceiptNumber:(NSString *)receiptNumber {
    if (self.actionNetworkManager == nil) {
        self.actionNetworkManager = [TokopediaNetworkManager new];
        self.actionNetworkManager.isUsingHmac = YES;
    }
    NSDictionary *parameters = @{
        @"order_id"     : _selectedOrder.order_detail.detail_order_id,
        @"shipping_ref" : receiptNumber,
    };
    [self.actionNetworkManager requestWithBaseUrl:[NSString v4Url]
                                             path:@"/v4/action/myshop-order/edit_shipping_ref.pl"
                                           method:RKRequestMethodPOST
                                        parameter:parameters
                                          mapping:[ActionOrder mapping]
                                        onSuccess:^(RKMappingResult *mappingResult,
                                                    RKObjectRequestOperation *operation) {
                                            [self didReceiveActionMappingResult:mappingResult forReceiptNumber:receiptNumber];
                                        } onFailure:^(NSError *errorResult) {
                                            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Proses mengubah nomor resi gagal."] delegate:self];
                                            [alert show];
                                        }];
}

- (void)didReceiveActionMappingResult:(RKMappingResult *)mappingResult forReceiptNumber:(NSString *)receiptNumber {
    ActionOrder *actionOrder = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [actionOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil merubah nomor resi."] delegate:self];
        [alert show];
        _selectedOrder.order_detail.detail_ship_ref_num = receiptNumber;
    } else {
        if (actionOrder.message_error) {
            NSArray *errorMessages = actionOrder.message_error?:@[@"Proses mengubah nomor resi gagal."];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        } else {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Nomor resi tidak valid."] delegate:self];
            [alert show];
        }
    }
}

#pragma mark - Actions

- (void)didTapFilterButton:(id)sender {
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    navigationController.viewControllers = @[_filterViewController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Filter delegate

- (void)filterOrderInvoice:(NSString *)invoice
         transactionStatus:(NSString *)transactionStatus
                 startDate:(NSString *)startDate
                   endDate:(NSString *)endDate {
    self.page = @"1";

    self.invoice = invoice;
    self.transactionStatus = transactionStatus;
    self.startDate = startDate;
    self.endDate = endDate;
    
    [self.orders removeAllObjects];
    [self.tableView reloadData];
    
    [self request];
}

#pragma mark - Track order delegate

- (void)shouldRefreshRequest {
    self.page = @"1";
    [self request];
}

#pragma mark - Other Method

- (BOOL) isUsingAnyFilter {
    BOOL isUsingInvoiceFilter = _invoice != nil && ![_invoice isEqualToString:@""];
    BOOL isUsingTransactionStatusFilter = _transactionStatus != nil && ![_transactionStatus isEqualToString:@""];
    BOOL isUsingDateFilter = (_startDate != nil && ![_startDate isEqualToString:@""]) || (_endDate != nil && ![_endDate isEqualToString:@""]);
    
    return (isUsingInvoiceFilter || isUsingTransactionStatusFilter || isUsingDateFilter);
}

@end
