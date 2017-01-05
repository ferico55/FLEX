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
    
    [AnalyticsManager trackScreenName:@"Sales - Transaction List"];

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
    
    _tableView.estimatedRowHeight = 218;
    _tableView.rowHeight = UITableViewAutomaticDimension;
}

- (UIBarButtonItem *)backBarButton {
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:nil];
    return backBarButtonItem;
}

- (UIBarButtonItem *)filterBarButton {
    UIBarButtonItem *filterBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                        style:UIBarButtonItemStylePlain
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
    
    cell.order = order;
    if ([self.response.result.order.is_allow_manage_tx boolValue] && order.order_detail.detail_ship_ref_num) {

        [cell hideAllButton];
        
        if (order.order_detail.detail_order_status == ORDER_SHIPPING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_WAITING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_TRACKER_INVALID ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_REF_NUM_EDITED) {
            
            [cell showTrackButtonOnTap:^(OrderTransaction *order) {
                [AnalyticsManager trackEventName:@"clickTransaction" category:GA_EVENT_CATEGORY_TRANSACTION action:GA_EVENT_ACTION_CLICK label:@"Track"];
                _selectedOrder = order;
                
                TrackOrderViewController *controller = [TrackOrderViewController new];
                controller.order = _selectedOrder;
                controller.hidesBottomBarWhenPushed = YES;
                controller.delegate = self;
                
                [self.navigationController pushViewController:controller animated:YES];
            }];
            
            [cell showEditResiButtonOnTap:^(OrderTransaction *order) {
                _selectedOrder = order;
                
                UINavigationController *navigationController = [[UINavigationController alloc] init];
                navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
                navigationController.navigationBar.translucent = NO;
                navigationController.navigationBar.tintColor = [UIColor whiteColor];
                
                ChangeReceiptNumberViewController *controller = [ChangeReceiptNumberViewController new];
                controller.receiptNumber = _selectedOrder.order_detail.detail_ship_ref_num;
                controller.orderID = _selectedOrder.order_detail.detail_order_id;
                
                controller.didSuccessEditReceipt = ^(NSString *newReceipt){
                    _selectedOrder.order_detail.detail_ship_ref_num = newReceipt;
                };
                
                navigationController.viewControllers = @[controller];
                
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            }];
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
- (void)didTapStatusAtIndexPath:(NSIndexPath *)indexPath {
    [AnalyticsManager trackEventName:@"clickTransaction" category:GA_EVENT_CATEGORY_TRANSACTION action:GA_EVENT_ACTION_VIEW label:@"Detail"];
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    DetailShipmentStatusViewController *controller = [DetailShipmentStatusViewController new];
    controller.order = order;
    controller.is_allow_manage_tx = _response.result.order.is_allow_manage_tx;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didTapUserAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    NavigateViewController *controller = [NavigateViewController new];
    [controller navigateToProfileFromViewController:self withUserID:_selectedOrder.order_customer.customer_id];
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
