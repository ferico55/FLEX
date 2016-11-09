//
//  ShipmentStatusViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_order.h"

#import "Order.h"
#import "OrderTransaction.h"
#import "ActionOrder.h"

#import "ShipmentStatusViewController.h"
#import "FilterShipmentStatusViewController.h"
#import "DetailShipmentStatusViewController.h"
#import "ChangeReceiptNumberViewController.h"
#import "TrackOrderViewController.h"
#import "NavigateViewController.h"

#import "ShipmentStatusCell.h"
#import "StickyAlertView.h"
#import "OrderSellerShop.h"

#import "UITableView+IndexPath.h"

#import "Tokopedia-Swift.h"

@interface ShipmentStatusViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    ShipmentStatusCellDelegate,
    FilterShipmentStatusDelegate,
    ChangeReceiptNumberDelegate,
    TrackOrderViewControllerDelegate,
    DetailShipmentStatusDelegate
>

@property (strong, nonatomic) OrderOrder *order;
@property (strong, nonatomic) NSMutableArray *orders;

@property (strong, nonatomic) NSString *deadline;
@property (strong, nonatomic) NSString *invoice;
@property (strong, nonatomic) NSString *shipmentId;

@property (strong, nonatomic) NSString *start;
@property (strong, nonatomic) NSString *end;
@property (strong, nonatomic) NSString *page;
@property (strong, nonatomic) NSString *perPage;

@property (strong, nonatomic) NSURL *nextURL;
@property (strong, nonatomic) OrderTransaction *selectedOrder;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (strong, nonatomic) FilterShipmentStatusViewController *filterController;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) TokopediaNetworkManager *networkManager;
@property (strong, nonatomic) TokopediaNetworkManager *actionNetworkManager;

@end

@implementation ShipmentStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Status Pengiriman";
    
    [AnalyticsManager trackScreenName:@"Sales - Shipping Status"];

    self.navigationItem.backBarButtonItem = self.backBarButton;
    self.navigationItem.rightBarButtonItem = self.filterBarButton;
    
    self.deadline = @"";
    self.invoice = @"";
    self.shipmentId = @"";
    
    self.start = @"";
    self.end = @"";
    self.page = @"1";
    self.perPage = @"";
    
    self.orders = [NSMutableArray new];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.tableFooterView = _footerView;

    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    self.filterController = [FilterShipmentStatusViewController new];
    self.filterController.delegate = self;
    
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;
    [self fetchOrderData];

    self.actionNetworkManager = [TokopediaNetworkManager new];
    self.actionNetworkManager.isUsingHmac = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Bar button item

- (UIBarButtonItem *)backBarButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@""
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:nil];
    return button;
}

- (UIBarButtonItem *)filterBarButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(tap:)];
    return button;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orders.count;
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
    
    OrderTransaction *order = [self.orders objectAtIndex:indexPath.row];
    
    cell.invoiceNumberLabel.text = order.order_detail.detail_invoice;
    cell.buyerNameLabel.text = order.order_customer.customer_name;
    
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
    
    if (order.order_detail.detail_ship_ref_num) {
        if (order.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED) {
            [cell showTrackButton];
        } else if (order.order_detail.detail_order_status == ORDER_SHIPPING) {
            if(order.order_is_pickup == 1) {
                [cell showTrackButton];
            } else {
                [cell showAllButton];
            }
            
        } else if (
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
            OrderHistory *history = [order.order_history objectAtIndex:0];
            cell.dateFinishLabel.text = [history.history_status_date_full substringToIndex:[history.history_status_date_full length]-6];
        }
    }
    
    if (order.order_history.count > 0) {
        OrderHistory *history = [order.order_history objectAtIndex:0];
        [cell setStatusLabelText:history.history_seller_status];
    } else {
        [cell setStatusLabelText:@"-"];
    }

    cell.invoiceDateLabel.text = order.order_payment.payment_verify_date;
    
    if (order.order_detail.detail_order_status == ORDER_DELIVERED ||
         (order.order_detail.detail_order_status == ORDER_DELIVERED_DUE_DATE &&
         order.order_deadline.deadline_finish_day_left)) {
        cell.dateFinishLabel.hidden = NO;
        cell.dateFinishLabel.text = @"Selesai Otomatis";
        cell.dateFinishLabel.font = [UIFont microTheme];
        cell.finishLabel.hidden = NO;
             
         NSString *dateFinishString = order.order_deadline.deadline_finish_date;
         NSString *todayString = [[NSDate date] stringWithFormat:@"dd-MM-yyyy"];
         if ([dateFinishString isEqual:todayString]) {
             dateFinishString = @"Hari ini";
         }
     
        cell.finishLabel.text = dateFinishString;
    }
    
    NSLog(@"%@  -  %ld", order.order_detail.detail_invoice,
          (long)order.order_deadline.deadline_finish_day_left);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isLastIndexPath:indexPath] && self.nextURL) {
        self.tableView.tableFooterView = _footerView;
        [self fetchOrderData];
    } else {
        self.tableView.tableFooterView = nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderTransaction *order = [self.orders objectAtIndex:indexPath.row];
    if (order.order_detail.detail_ship_ref_num) {
        if (order.order_detail.detail_order_status == ORDER_SHIPPING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_WAITING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_TRACKER_INVALID ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_REF_NUM_EDITED ||
            order.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED) {
            return tableView.rowHeight;
        } else {
            return tableView.rowHeight - 45;
        }
    }
    return tableView.rowHeight - 45;
}

#pragma mark - Reskit methods


- (void)fetchOrderData {
    self.tableView.tableFooterView = _footerView;
    NSDictionary *parameters = @{
        @"deadline": _deadline,
        @"invoice": _invoice,
        @"start": _start,
        @"end": _end,
        @"page": _page,
        @"per_page": _perPage,
    };
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/myshop-order/get_order_status.pl"
                                     method:RKRequestMethodGET
                                  parameter:parameters
                                    mapping:[Order mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      [self didReceiveMappingResult:mappingResult];
                                  } onFailure:^(NSError *errorResult) {
                                      
                                  }];
}

- (void)didReceiveMappingResult:(RKMappingResult *)mappingResult {
    Order *response = [mappingResult.dictionary objectForKey:@""];
    self.order = response.result.order;
    if ([self.page isEqualToString:@"1"]) {
        [self.orders removeAllObjects];
    }
    [self.orders addObjectsFromArray:response.result.list];
    
    self.nextURL =  [NSURL URLWithString:response.result.paging.uri_next];
    self.page = [self.nextURL valueForKey:@"page"];

    if ([self.page isEqualToString:@"0"]) {
        self.tableView.tableFooterView = nil;
    }
    
    if (self.orders.count == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 103);
        NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
        self.tableView.tableFooterView = noResultView;
        self.tableView.sectionFooterHeight = noResultView.frame.size.height;
    }
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)requestFailure:(id)object {
    [self.refreshControl endRefreshing];
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Mohon maaf, sedang terjadi kendala pada server. Silahkan coba beberapa saat lagi."] delegate:self];
    [alert show];
    
    self.tableView.tableFooterView = nil;
}

- (void)refreshData {
    self.page = @"1";
    [self fetchOrderData];
}

#pragma mark - Reskit action methods

- (void)requestChangeReceiptNumber:(NSString *)receiptNumber
                      orderHistory:(OrderHistory *)orderHistory {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSDictionary *parameters = @{
        API_USER_ID_KEY             : auth.getUserId,
        API_ORDER_ID_KEY            : _selectedOrder.order_detail.detail_order_id,
        API_SHIPMENT_REF_KEY        : receiptNumber,
    };
    [self.actionNetworkManager requestWithBaseUrl:[NSString v4Url]
                                             path:@"/v4/action/myshop-order/edit_shipping_ref.pl"
                                           method:RKRequestMethodPOST
                                        parameter:parameters
                                          mapping:[ActionOrder mapping]
                                        onSuccess:^(RKMappingResult *mappingResult,
                                                    RKObjectRequestOperation *operation) {
                                            [self didReceiveMappingResult:mappingResult
                                                         forReceiptNumber:receiptNumber
                                                             orderHistory:orderHistory];
                                        } onFailure:^(NSError *errorResult) {
                                            
                                        }];
}

- (void)didReceiveMappingResult:(RKMappingResult *)mappingResult
               forReceiptNumber:(NSString *)receiptNumber
                   orderHistory:(OrderHistory *)orderHistory {
    ActionOrder *response = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [response.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status && [response.result.is_success boolValue]) {

        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil merubah nomor resi."] delegate:self];
        [alert show];

        _selectedOrder.order_detail.detail_ship_ref_num = receiptNumber;

        if (orderHistory) {
            NSMutableArray *history = [NSMutableArray arrayWithArray:_selectedOrder.order_history];
            [history insertObject:orderHistory atIndex:0];
            _selectedOrder.order_history = history;
        }

        [self.tableView reloadData];

    } else if (response.message_error) {
        NSArray *errorMessages = response.message_error?:@[@"Proses mengubah nomor resi gagal."];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
        [alert show];
    }
}

#pragma mark - Cell delegate

- (void)didTapTrackButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath {
    OrderTransaction *order = [self.orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    _selectedIndexPath = indexPath;
    
    TrackOrderViewController *controller = [TrackOrderViewController new];
    controller.order = _selectedOrder;
    controller.hidesBottomBarWhenPushed = YES;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}   

- (void)didTapReceiptButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath {
    OrderTransaction *order = [self.orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    _selectedIndexPath = indexPath;

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
    OrderTransaction *order = [self.orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    _selectedIndexPath = indexPath;

    DetailShipmentStatusViewController *controller = [DetailShipmentStatusViewController new];
    controller.order = order;
    controller.delegate = self;
    controller.is_allow_manage_tx = _order.is_allow_manage_tx;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didTapUserAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [self.orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    NavigateViewController *controller = [NavigateViewController new];
    [controller navigateToProfileFromViewController:self withUserID:_selectedOrder.order_customer.customer_id];
}

#pragma mark - Action

- (void)tap:(id)sender {
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];

    navigationController.viewControllers = @[_filterController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Filter delegate

- (void)filterShipmentStatusInvoice:(NSString *)invoice {
    self.invoice = invoice;
    self.page = @"1";
    
    [self.orders removeAllObjects];
    [self.tableView reloadData];
    
    [self fetchOrderData];
}

#pragma mark - Change receipt number delegate

- (void)changeReceiptNumber:(NSString *)receiptNumber orderHistory:(OrderHistory *)history {
    [self requestChangeReceiptNumber:receiptNumber orderHistory:history];
}

#pragma mark - Track order delegate

- (void)updateDeliveredOrder:(NSString *)receiverName {
    OrderHistory *history = [OrderHistory new];
    NSString *sellerStatus;
    if ([receiverName isEqualToString:@""] || receiverName == NULL) {
        sellerStatus = [NSString stringWithFormat:@"Pesanan telah tiba di tujuan"];
    } else {
        sellerStatus = [NSString stringWithFormat:@"Pesanan telah tiba di tujuan<br>Received by %@", receiverName];
    }
    history.history_seller_status = sellerStatus;
    [_selectedOrder.order_history insertObject:history atIndex:0];
    _selectedOrder.order_detail.detail_order_status = ORDER_DELIVERED;
    _selectedOrder.order_deadline.deadline_finish_day_left = 3;
    
    NSDate *deadlineFinishDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*3];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];

    _selectedOrder.order_deadline.deadline_finish_date = [dateFormatter stringFromDate:deadlineFinishDate];
    
    [self.tableView reloadData];
}

#pragma mark - Detail shipment delegate

- (void)successChangeReceiptWithOrderHistory:(OrderHistory *)history {
    if (history) {
        NSMutableArray *histories = [NSMutableArray arrayWithArray:_selectedOrder.order_history];
        [histories insertObject:history atIndex:0];
        _selectedOrder.order_history = histories;
        [self.tableView reloadData];
    }
}

@end
