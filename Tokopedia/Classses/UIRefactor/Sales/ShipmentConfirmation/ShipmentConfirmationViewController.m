//
//  ShipmentConfirmationViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShipmentConfirmationViewController.h"
#import "SalesOrderCell.h"
#import "Order.h"
#import "OrderTransaction.h"
#import "string_order.h"
#import "TKPDSecureStorage.h"
#import "OrderDetailViewController.h"
#import "FilterShipmentConfirmationViewController.h"
#import "SubmitShipmentConfirmationViewController.h"
#import "ChangeCourierViewController.h"
#import "CancelShipmentViewController.h"
#import "NavigateViewController.h"
#import "ActionOrder.h"
#import "StickyAlertView.h"
#import "ShipmentOrder.h"
#import "ShipmentCourier.h"
#import "UITableView+IndexPath.h"

#define IDropShipmentPackageID @"19"

@interface ShipmentConfirmationViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIAlertViewDelegate,
    SalesOrderCellDelegate,
    OrderDetailDelegate,
    FilterShipmentConfirmationDelegate,
    SubmitShipmentConfirmationDelegate,
    ChangeCourierDelegate,
    CancelShipmentConfirmationDelegate
>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

// parameters
@property (strong, nonatomic) NSString *start;
@property (strong, nonatomic) NSString *end;
@property (strong, nonatomic) NSString *page;
@property (strong, nonatomic) NSString *perPage;

@property (strong, nonatomic) NSString *invoiceNumber;
@property (strong, nonatomic) NSString *dueDate;

@property (strong, nonatomic) NSURL *nextURL;

@property (strong, nonatomic) ShipmentCourier *courier;
@property (strong, nonatomic) NSArray *shipmentCouriers;

@property (strong, nonatomic) OrderBooking *orderBooking;

@property (strong, nonatomic) NSMutableArray *orders;
@property (strong, nonatomic) OrderTransaction *selectedOrder;
@property (strong, nonatomic) NSMutableDictionary *orderInProcess;
@property NSInteger numberOfProcessedOrder;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (strong, nonatomic) TokopediaNetworkManager *networkManager;
@property (strong, nonatomic) TokopediaNetworkManager *actionNetworkManager;
@property (strong, nonatomic) TokopediaNetworkManager *courierNetworkManager;

@property (strong, nonatomic) FilterShipmentConfirmationViewController *filterController;

@end

@implementation ShipmentConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Konfirmasi Pengiriman";
    self.alertLabel.text = [self announcementString];
    
    [TPAnalytics trackScreenName:@"Sales - Shipping Confirmation"];
    
    self.navigationItem.backBarButtonItem = self.backBarButton;
    self.navigationItem.rightBarButtonItem = self.filterBarButton;
    
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;
    
    self.actionNetworkManager = [TokopediaNetworkManager new];
    self.actionNetworkManager.isUsingHmac = YES;

    self.courierNetworkManager = [TokopediaNetworkManager new];
    self.courierNetworkManager.isUsingHmac = YES;
    [self requestShipmentCouriers];

    self.dueDate = @"";
    self.invoiceNumber = @"";
    
    self.start = @"";
    self.end = @"";
    self.page = @"1";
    self.perPage = @"";
    
    self.numberOfProcessedOrder = 0;
    
    self.orders = [NSMutableArray new];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.tableHeaderView = _headerView;

    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    self.filterController = [FilterShipmentConfirmationViewController new];
    self.filterController.delegate = self;
    
    [self fetchShipmentConfirmationData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(viewController:numberOfProcessedOrder:)]) {
        [self.delegate viewController:self numberOfProcessedOrder:_numberOfProcessedOrder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Bar button item

- (UIBarButtonItem *)backBarButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@""
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:nil];
    return button;
}

- (UIBarButtonItem *)filterBarButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                               style:UIBarButtonItemStylePlain
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
    static NSString *cellIdentifer = @"SalesOrderCell";
    SalesOrderCell *cell = (SalesOrderCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SalesOrderCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.delegate = self;
    }
    
    cell.indexPath = indexPath;
    
    OrderTransaction *transaction = [_orders objectAtIndex:indexPath.row];
    
    cell.invoiceNumberLabel.text = transaction.order_detail.detail_invoice;
    
    if (transaction.order_deadline.deadline_shipping_day_left == 1) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:145.0/255.0
                                                                   blue:0.0/255.0
                                                                  alpha:1];
        cell.remainingDaysLabel.text = @"Besok";
        
    } else if (transaction.order_deadline.deadline_shipping_day_left == 0) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:59.0/255.0
                                                                   blue:48.0/255.0
                                                                  alpha:1];
        cell.remainingDaysLabel.text = @"Hari ini";
        
    } else if (transaction.order_deadline.deadline_shipping_day_left < 0) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:158.0/255.0
                                                                  green:158.0/255.0
                                                                   blue:158.0/255.0
                                                                  alpha:1];
        
        cell.automaticallyCanceledLabel.hidden = YES;
        
        cell.remainingDaysLabel.text = @"Expired";
        
        CGRect frame = cell.remainingDaysLabel.frame;
        frame.origin.y = 17;
        cell.remainingDaysLabel.frame = frame;
        
        cell.acceptButton.enabled = NO;
        cell.acceptButton.layer.opacity = 0.25;
        
    } else {
        
        cell.remainingDaysLabel.text = [NSString stringWithFormat:@"%d Hari lagi", (int)transaction.order_deadline.deadline_shipping_day_left];
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0
                                                                  green:121.0/255.0
                                                                   blue:255.0/255.0
                                                                  alpha:1];
    }
    
    cell.userNameLabel.text = transaction.order_customer.customer_name;
    cell.purchaseDateLabel.text = transaction.order_payment.payment_verify_date;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:transaction.order_customer.customer_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [cell.userImageView setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           [cell.userImageView setImage:image];
                                           [cell.userImageView setContentMode:UIViewContentModeScaleAspectFill];
                                       } failure:nil];
    
    cell.paymentAmountLabel.text = transaction.order_detail.detail_open_amount_idr;
    cell.dueDateLabel.text = [NSString stringWithFormat:@"Batas Respon : %@", transaction.order_payment.payment_shipping_due_date];
    
    [cell.rejectButton setTitle:@"Batal" forState:UIControlStateNormal];
    
    if (transaction.order_is_pickup == 1) {
        [cell.acceptButton setTitle:@"Pickup" forState:UIControlStateNormal];
        [cell.acceptButton setImage:[UIImage imageNamed:@"icon_order_check.png"] forState:UIControlStateNormal];
        cell.acceptButton.tag = 2;
    } else if ([transaction.order_shipment.shipment_package_id isEqualToString:@"19"]) {
        [cell.acceptButton setTitle:@"Ubah Kurir" forState:UIControlStateNormal];
        [cell.acceptButton setImage:[UIImage imageNamed:@"icon_truck.png"] forState:UIControlStateNormal];
        cell.acceptButton.tag = 3;
    } else {
        [cell.acceptButton setTitle:@"Konfirmasi" forState:UIControlStateNormal];
        cell.acceptButton.tag = 2;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isLastIndexPath:indexPath] && self.nextURL) {
        [self fetchShipmentConfirmationData];
    }
}

#pragma mark - Cell delegate

- (void)tableViewCell:(UITableViewCell *)cell acceptOrderAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedOrder = [_orders objectAtIndex:indexPath.row];
    self.selectedIndexPath = indexPath;
    
    SubmitShipmentConfirmationViewController *controller = [SubmitShipmentConfirmationViewController new];
    controller.delegate = self;
    controller.shipmentCouriers = _shipmentCouriers;
    controller.order = _selectedOrder;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)tableViewCell:(UITableViewCell *)cell changeCourierAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    ChangeCourierViewController *controller = [ChangeCourierViewController new];
    controller.delegate = self;
    controller.shipmentCouriers = _shipmentCouriers;
    controller.order = _selectedOrder;
    navigationController.viewControllers = @[controller];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)tableViewCell:(UITableViewCell *)cell rejectOrderAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    CancelShipmentViewController *controller = [CancelShipmentViewController new];
    controller.delegate = self;
    navigationController.viewControllers = @[controller];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectPriceAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    OrderDetailViewController *controller = [[OrderDetailViewController alloc] init];
    controller.transaction = _selectedOrder;
    controller.delegate = self;
    controller.shipmentCouriers = _shipmentCouriers;
    controller.booking = _orderBooking;
    controller.shouldRequestIDropCode = [_selectedOrder.order_shipment.shipment_package_id isEqualToString:IDropShipmentPackageID];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectUserAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    NavigateViewController *controller = [NavigateViewController new];
    [controller navigateToProfileFromViewController:self withUserID:_selectedOrder.order_customer.customer_id];
}

#pragma mark - Reskit methods

- (void)fetchShipmentConfirmationData {
    self.tableView.tableFooterView = _footerView;
    
    NSDictionary *parameters = @{
                                 @"deadline": _dueDate?:@"",
                                 @"invoice": _invoiceNumber?:@"",
                                 @"shipment_id": _courier? _courier.shipment_id: @"",
                                 @"start": _start?:@"",
                                 @"end": _end?:@"",
                                 @"page": _page?:@"",
                                 @"per_page": _perPage?:@"",
                                 };
    
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/myshop-order/get_order_process.pl"
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
    
    if ([_page isEqualToString:@"1"]) {
        self.orders = response.result.list;
    } else {
        [self.orders addObjectsFromArray:response.result.list];
    }
    
    self.orderBooking = response.result.booking;
    
    self.nextURL =  [NSURL URLWithString:response.result.paging.uri_next];
    self.page = [self.nextURL valueForKey:@"page"];
    
    NSLog(@"next page : %ld",(long)_page);
    
    if (self.page == 0) {
        self.tableView.tableFooterView = nil;
    }
    
    if (self.orders.count == 0) {
        self.activityIndicator.hidden = YES;
        
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 103);
        NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
        self.tableView.tableFooterView = noResultView;
        self.tableView.sectionFooterHeight = noResultView.frame.size.height;
    }
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)tap:(id)sender {
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.filterController.couriers = _shipmentCouriers;
    navigationController.viewControllers = @[_filterController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Order detail delegate

- (void)didReceiveActionType:(NSString *)type
                     courier:(ShipmentCourier *)courier
              courierPackage:(ShipmentCourierPackage *)courierPackage
               receiptNumber:(NSString *)receiptNumber
             rejectionReason:(NSString *)rejectionReason {
    [self requestAction:type
                courier:courier
         courierPackage:courierPackage
          receiptNumber:receiptNumber
        rejectionReason:rejectionReason];
}

#pragma mark - Filter delegate

- (void)filterShipmentInvoice:(NSString *)invoice
                      dueDate:(NSString *)dueDate
                      courier:(ShipmentCourier *)courier {
    _invoiceNumber = invoice;
    _dueDate = dueDate;
    _courier = courier;
    
    self.start = @"0";
    self.page = @"1";
    self.perPage = @"6";
    
    [self.orders removeAllObjects];
    [self.tableView reloadData];
    
    [self fetchShipmentConfirmationData];
}

#pragma mark - Accept shipment delegate

- (void)submitConfirmationReceiptNumber:(NSString *)receiptNumber
                                courier:(ShipmentCourier *)courier
                         courierPackage:(ShipmentCourierPackage *)courierPackage {
    [self requestAction:@"confirm"
                courier:courier
         courierPackage:courierPackage
          receiptNumber:receiptNumber
        rejectionReason:nil];
}

#pragma mark - Cancel shipment delegate

- (void)cancelShipmentWithExplanation:(NSString *)explanation {
    [self requestAction:@"reject"
                courier:nil
         courierPackage:nil
          receiptNumber:nil
        rejectionReason:explanation];
}

#pragma mark - Resktit methods for actions

- (void)requestAction:(NSString *)type
              courier:(ShipmentCourier *)courier
       courierPackage:(ShipmentCourierPackage *)courierPackage
        receiptNumber:(NSString *)receiptNumber
      rejectionReason:(NSString *)rejectionReason {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSDictionary *parameters = @{
                                 API_ACTION_KEY              : API_PROCEED_SHIPPING_KEY,
                                 API_ACTION_TYPE_KEY         : type,
                                 API_USER_ID_KEY             : auth.getUserId,
                                 API_ORDER_ID_KEY            : _selectedOrder.order_detail.detail_order_id,
                                 API_SHIPMENT_ID_KEY         : courier.shipment_id ?: [NSNumber numberWithInteger:_selectedOrder.order_shipment.shipment_id],
                                 API_SHIPMENT_NAME_KEY       : courier.shipment_name ?: _selectedOrder.order_shipment.shipment_name,
                                 API_SHIPMENT_PACKAGE_ID_KEY : courierPackage.sp_id ?: _selectedOrder.order_shipment.shipment_package_id,
                                 API_SHIPMENT_REF_KEY        : receiptNumber ?: @"",
                                 API_REASON_KEY              : rejectionReason ?: @"",
                                 };
    
    // Add information about which transaction is in processing and at what index path
    OrderTransaction *order = _selectedOrder;
    
    NSIndexPath *indexPath = _selectedIndexPath;
    
    NSDictionary *object = @{@"order" : order, @"indexPath" : indexPath};
    NSString *key = order.order_detail.detail_order_id;
    [_orderInProcess setObject:object forKey:key];
    
    // Delete row for the object
    [_orders removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(timeoutAtIndexPath:)
                                                    userInfo:@{@"orderId" : key}
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    [self.actionNetworkManager requestWithBaseUrl:[NSString v4Url]
                                             path:@"/v4/action/myshop-order/proceed_shipping.pl"
                                           method:RKRequestMethodPOST
                                        parameter:parameters
                                          mapping:[ActionOrder mapping]
                                        onSuccess:^(RKMappingResult *mappingResult,
                                                    RKObjectRequestOperation *operation) {
                                            [self actionRequestSuccess:mappingResult
                                                         withOperation:operation
                                                               orderId:key
                                                            actionType:type];
                                        } onFailure:^(NSError *error) {
                                            [self actionRequestFailure:error orderId:key];
                                        }];
}

- (void)actionRequestSuccess:(id)object
               withOperation:(RKObjectRequestOperation *)operation
                     orderId:(NSString *)orderId
                  actionType:(NSString *)actionType {
    NSDictionary *result = ((RKMappingResult *)object).dictionary;
    
    ActionOrder *actionOrder = [result objectForKey:@""];
    BOOL status = [actionOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status && [actionOrder.result.is_success boolValue]) {
        NSString *message;
        if ([actionType isEqualToString:@"confirm"]) {
            message = @"Anda telah berhasil mengkonfirmasi pengiriman barang.";
        } else if ([actionType isEqualToString:@"reject"]) {
            message = @"Anda telah berhasil membatalkan pengiriman barang.";
        }
        _numberOfProcessedOrder++;
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[(message) ?: @""] delegate:self];
        [alert show];
        [_orderInProcess removeObjectForKey:orderId];
    } else {
        NSLog(@"\n\nRequest Message status : %@\n\n", actionOrder.message_error);
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:actionOrder.message_error
                                                                       delegate:self];
        [alert show];
        [self performSelector:@selector(restoreData:) withObject:orderId];
    }
}

- (void)actionRequestFailure:(id)object orderId:(NSString *)orderId {
    NSLog(@"\n\nRequest error : %@\n\n", object);
    NSDictionary *result = ((RKMappingResult *)object).dictionary;
    ActionOrder *actionOrder = [result objectForKey:@""];
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:actionOrder.message_error
                                                                   delegate:self];
    [alert show];
    
    [self performSelector:@selector(restoreData:) withObject:orderId];
}

- (void)timeoutAtIndexPath:(NSTimer *)timer {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSString *orderId = [[timer userInfo] objectForKey:@"orderId"];
    [self performSelector:@selector(restoreData:) withObject:orderId];
}

- (void)reloadData {
    [_tableView reloadData];
}

- (void)restoreData:(NSString *)orderId {
    NSDictionary *dict = [_orderInProcess objectForKey:orderId];
    if (dict) {
        OrderTransaction *order = [dict objectForKey:@"order"];
        NSIndexPath *objectIndexPath = [dict objectForKey:@"indexPath"];
        
        [_orders insertObject:order atIndex:objectIndexPath.row];
        [_tableView insertRowsAtIndexPaths:@[objectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
        
        [_orderInProcess removeObjectForKey:orderId];
    }
}

- (void)refreshData {
    self.start = @"0";
    self.page = @"1";
    self.perPage = @"6";
    [self fetchShipmentConfirmationData];
}

#pragma mark - Shipment courier request delegate

- (void)requestShipmentCouriers {
    [self.courierNetworkManager requestWithBaseUrl:[NSString v4Url]
                                              path:@"/v4/myshop-order/get_edit_shipping_form.pl"
                                            method:RKRequestMethodGET
                                         parameter:@{}
                                           mapping:[ShipmentOrder mapping]
                                         onSuccess:^(RKMappingResult *mappingResult,
                                                     RKObjectRequestOperation *operation) {
                                             ShipmentOrder *shipment = [mappingResult.dictionary objectForKey:@""];
                                             self.shipmentCouriers = shipment.data.shipment;
                                         } onFailure:nil];
}

#pragma mark - Order detail delegate

- (void)successConfirmOrder:(OrderTransaction *)order {
    NSInteger index = [_orders indexOfObject:order];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_orders removeObject:order];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
    if (_orders.count == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 103);
        NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
        _tableView.tableFooterView = noResultView;
        _tableView.sectionFooterHeight = noResultView.frame.size.height;
    }
}

- (NSString*)announcementString {
    return @"Order Anda akan otomatis kami batalkan apabila Anda melewati batas waktu respon 4 hari kerja (Senin - Jumat) setelah order diverifikasi";
}

@end