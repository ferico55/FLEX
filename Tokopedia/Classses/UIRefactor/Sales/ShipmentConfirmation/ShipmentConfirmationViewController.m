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
#import "RequestShipmentCourier.h"
#import "ShipmentCourier.h"
#import "UITableView+IndexPath.h"

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
    CancelShipmentConfirmationDelegate,
    RequestShipmentCourierDelegate
>
{
    RKObjectManager *_actionObjectManager;
    RKManagedObjectRequestOperation *_actionRequest;
    RKResponseDescriptor *_responseActionDescriptorStatus;
}

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

// parameters
@property (strong, nonatomic) NSString *start;
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

@property (strong, nonatomic) FilterShipmentConfirmationViewController *filterController;

@end

@implementation ShipmentConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Konfirmasi Pengiriman";

    [TPAnalytics trackScreenName:@"Sales - Shipping Confirmation"];

    self.navigationItem.backBarButtonItem = self.backBarButton;
    self.navigationItem.rightBarButtonItem = self.filterBarButton;
    
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;

    self.start = @"0";
    self.page = @"0";
    self.perPage = @"6";
    
    self.numberOfProcessedOrder = 0;
    
    self.orders = [NSMutableArray new];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.tableHeaderView = _headerView;
    [self.tableView addSubview:self.refreshControl];
    
    self.alertLabel.attributedText = self.alertAttributedString;

    self.filterController = [FilterShipmentConfirmationViewController new];
    self.filterController.delegate = self;
    
    RequestShipmentCourier *courier = [RequestShipmentCourier new];
    courier.delegate = self;
    [courier request];
    
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
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(tap:)];
    return button;
}

- (UIBarButtonItem *)filterBarButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(tap:)];
    return button;
}

#pragma mark - Refresh control

- (UIRefreshControl *)refreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    return refreshControl;
}

#pragma mark - Note view

- (NSAttributedString *)alertAttributedString {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName: [UIColor blackColor],
        NSFontAttributeName: [UIFont fontWithName:@"GothamBook" size:11],
        NSParagraphStyleAttributeName: style,
    };
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_alertLabel.text attributes:attributes];
    return attributedString;
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
    
    if (transaction.order_shipment.shipment_id == 10) {
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
    if ([tableView isLastIndexPath:indexPath]) {
        if (self.nextURL) {
            [self fetchShipmentConfirmationData];
        }
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

- (void)tableViewCell:(UITableViewCell *)cell rejectOrderAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)tableViewCell:(UITableViewCell *)cell didSelectPriceAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    OrderDetailViewController *controller = [[OrderDetailViewController alloc] init];
    controller.transaction = [_orders objectAtIndex:indexPath.row];
    controller.delegate = self;
    controller.shipmentCouriers = _shipmentCouriers;
    controller.booking = _orderBooking;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectUserAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    NavigateViewController *controller = [NavigateViewController new];
    [controller navigateToProfileFromViewController:self withUserID:_selectedOrder.order_customer.customer_id];
}

#pragma mark - Reskit methods

//NSDictionary *parameters = @{
//                             @"action_type": @"",
//                             @"order_id": @"",
//                             @"reason": @"",
//                             @"ship_day": @"",
//                             @"ship_month": @"",
//                             @"ship_year": @"",
//                             @"shipment_id": @"",
//                             @"shipment_name": @"",
//                             @"shipping_ref": @"",
//                             @"sp_id": @"",
//                             };

- (void)fetchShipmentConfirmationData {
    NSDictionary *parameters = @{
        @"deadline": _dueDate,
        @"invoice": _invoiceNumber,
        @"shipment_id": _courier.shipment_id,
        @"status": @"",
        @"start": _start,
        @"page": _page,
        @"per_page": _perPage,
    };
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/action/myshop-order/proceed_shipping.pl"
                                     method:RKRequestMethodGET
                                  parameter:parameters
                                    mapping:[Order mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      
                                  } onFailure:^(NSError *errorResult) {
                                  
                                  }];
}

//- (void)request
//{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    
//    if (_request.isExecuting) return;
//    
//    _requestCount++;
//
//    self.tableView.tableFooterView = _footerView;
//    [_activityIndicator startAnimating];
//
//    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
//    NSDictionary *auth = [secureStorage keychainDictionary];
//    
//    NSDictionary* param = @{
//                            API_ACTION_KEY           : API_GET_NEW_ORDER_PROCESS_KEY,
//                            API_USER_ID_KEY          : [auth objectForKey:API_USER_ID_KEY],
//                            API_INVOICE_KEY          : _invoiceNumber ?: @"",
//                            API_DEADLINE_KEY         : _dueDate ?: @"",
//                            API_SHIPMENT_ID_KEY      : _courier.shipment_id ?: @"",
//                            API_PAGE_KEY             : [NSNumber numberWithInteger:_page],
//                            };
//    
//    NSLog(@"\n\n\n\n%@\n\n\n\n", param);
//    
//    if (_page >= 1 || _isRefreshView) {
//        
//        [_activityIndicator startAnimating];
//        
//        _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_NEW_ORDER_PATH parameters:[param encrypt]];
//        
//        NSLog(@"\n\n\n\n%@\n\n\n\n", _request);
//
//        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//            
//            _isRefreshView = NO;
//            [_refreshControl endRefreshing];
//            
//            [_timer invalidate];
//            _timer = nil;
//            
//            [self requestSuccess:mappingResult withOperation:operation];
//            
//        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//            
//            _isRefreshView = NO;
//            [_refreshControl endRefreshing];
//            
//            [_timer invalidate];
//            _timer = nil;
//            
//            [self requestFailure:error];
//            
//        }];
//        
//        [_operationQueue addOperation:_request];
//        
//        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
//                                                          target:self
//                                                        selector:@selector(cancel)
//                                                        userInfo:nil
//                                                         repeats:NO];
//        
//        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//        
//    }
//}
//
//- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
//{
//    NSDictionary *result = ((RKMappingResult*)object).dictionary;
//    BOOL status = [[[result objectForKey:@""] status] isEqualToString:kTKPDREQUEST_OKSTATUS];
//    if (status) {
//        [self requestProcess:object];
//    }
//}
//
//- (void)requestProcess:(id)object
//{
//    if (object && [object isKindOfClass:[RKMappingResult class]]) {
//
//        NSDictionary *result = ((RKMappingResult*)object).dictionary;
//        Order *newOrders = [result objectForKey:@""];
//        
//        if (_page == 1) {
//            _orders = newOrders.result.list;
//        } else {
//            [_orders addObjectsFromArray:newOrders.result.list];
//        }
//        
//        _uriNext =  newOrders.result.paging.uri_next;
//        
//        _orderBooking = newOrders.result.booking;
//
//        NSURL *url = [NSURL URLWithString:_uriNext];
//        NSArray* query = [[url query] componentsSeparatedByString: @"&"];
//        NSMutableDictionary *queries = [NSMutableDictionary new];
//        for (NSString *keyValuePair in query)
//        {
//            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//            NSString *key = [pairComponents objectAtIndex:0];
//            NSString *value = [pairComponents objectAtIndex:1];
//            [queries setObject:value forKey:key];
//        }
//        _page = [[queries objectForKey:API_PAGE_KEY] integerValue];
//        NSLog(@"next page : %ld",(long)_page);
//        
//        _isNoData = NO;
//
//        if (_page == 0) {
//            [_activityIndicator stopAnimating];
//        }
//
//        if (_orders.count == 0) {
//            _activityIndicator.hidden = YES;
//            
//            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 103);
//            NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
//            _tableView.tableFooterView = noResultView;
//            _tableView.sectionFooterHeight = noResultView.frame.size.height;
//        }
//
//        [_tableView reloadData];
//    }
//}
//
//- (void)requestFailure:(id)object
//{
//
//}
//
//- (void)cancel
//{
//
//}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    _filterController.couriers = _shipmentCouriers;
    navigationController.viewControllers = @[_filterController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Order detail delegate

- (void)didReceiveActionType:(NSString *)type courier:(ShipmentCourier *)courier courierPackage:(ShipmentCourierPackage *)courierPackage receiptNumber:(NSString *)receiptNumber rejectionReason:(NSString *)rejectionReason
{
//    [self requestActionType:type
//                    courier:courier
//             courierPackage:courierPackage
//              receiptNumber:receiptNumber
//            rejectionReason:rejectionReason];
}

#pragma mark - Filter delegate

- (void)filterShipmentInvoice:(NSString *)invoice dueDate:(NSString *)dueDate courier:(ShipmentCourier *)courier
{
    _invoiceNumber = invoice;
    _dueDate = dueDate;
    _courier = courier;
    
    self.start = @"0";
    self.page = @"0";
    self.perPage = @"6";
    
    [self.orders removeAllObjects];
    [self.tableView reloadData];

    [self fetchShipmentConfirmationData];
}

#pragma mark - Accept shipment delegate

- (void)submitConfirmationReceiptNumber:(NSString *)receiptNumber courier:(ShipmentCourier *)courier courierPackage:(ShipmentCourierPackage *)courierPackage
{
//    [self requestActionType:@"confirm"
//                    courier:courier
//             courierPackage:courierPackage
//              receiptNumber:receiptNumber
//            rejectionReason:nil];
}

#pragma mark - Cancel shipment delegate

- (void)cancelShipmentWithExplanation:(NSString *)explanation
{
//    [self requestActionType:@"reject"
//                    courier:nil
//             courierPackage:nil
//              receiptNumber:nil
//            rejectionReason:explanation];
}

#pragma mark - Resktit methods for actions

//- (void)configureActionReskit
//{
//    _actionObjectManager =  [RKObjectManager sharedClient];
//    
//    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [_actionObjectManager.HTTPClient setDefaultHeader:@"X-APP-VERSION" value:appVersion];
//
//    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ActionOrder class]];
//    [statusMapping addAttributeMappingsFromDictionary:@{
//                                                        kTKPD_APISTATUSKEY              : kTKPD_APISTATUSKEY,
//                                                        kTKPD_APISERVERPROCESSTIMEKEY   : kTKPD_APISERVERPROCESSTIMEKEY,
//                                                        kTKPD_APISTATUSMESSAGEKEY       : kTKPD_APISTATUSMESSAGEKEY,
//                                                        kTKPD_APIERRORMESSAGEKEY        : kTKPD_APIERRORMESSAGEKEY,
//                                                        }];
//    
//    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ActionOrderResult class]];
//    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY : kTKPD_APIISSUCCESSKEY}];
//    
//    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
//                                                                                  toKeyPath:kTKPD_APIRESULTKEY
//                                                                                withMapping:resultMapping]];
//    
//    RKResponseDescriptor *actionResponseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
//                                                                                                        method:RKRequestMethodPOST
//                                                                                                   pathPattern:API_NEW_ORDER_ACTION_PATH
//                                                                                                       keyPath:@""
//                                                                                                   statusCodes:kTkpdIndexSetStatusCodeOK];
//    
//    [_actionObjectManager addResponseDescriptor:actionResponseDescriptorStatus];
//}
//
//- (void)requestActionType:(NSString *)type courier:(ShipmentCourier *)courier courierPackage:(ShipmentCourierPackage *)courierPackage receiptNumber:(NSString *)receiptNumber rejectionReason:(NSString *)rejectionReason
//{
//    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
//    NSDictionary *auth = [secureStorage keychainDictionary];
//    
//    NSDictionary *param = @{
//                            API_ACTION_KEY              : API_PROCEED_SHIPPING_KEY,
//                            API_ACTION_TYPE_KEY         : type,
//                            API_USER_ID_KEY             : [auth objectForKey:API_USER_ID_KEY],
//                            API_ORDER_ID_KEY            : _selectedOrder.order_detail.detail_order_id,
//                            API_SHIPMENT_ID_KEY         : courier.shipment_id ?: [NSNumber numberWithInteger:_selectedOrder.order_shipment.shipment_id],
//                            API_SHIPMENT_NAME_KEY       : courier.shipment_name ?: _selectedOrder.order_shipment.shipment_name,
//                            API_SHIPMENT_PACKAGE_ID_KEY : courierPackage.sp_id ?: _selectedOrder.order_shipment.shipment_package_id,
//                            API_SHIPMENT_REF_KEY        : receiptNumber ?: @"",
//                            API_REASON_KEY              : rejectionReason ?: @"",
//                            };
//    
//    _actionRequest = [_actionObjectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_NEW_ORDER_ACTION_PATH parameters:[param encrypt]];
//    [_operationQueue addOperation:_actionRequest];
//    
//    NSLog(@"\n\n\nRequest Operation : %@\n\n\n", _actionRequest);
//    
//    // Add information about which transaction is in processing and at what index path
//    OrderTransaction *order = _selectedOrder;
//    
//    NSIndexPath *indexPath = _selectedIndexPath;
//    
//    NSDictionary *object = @{@"order" : order, @"indexPath" : indexPath};
//    NSString *key = order.order_detail.detail_order_id;
//    [_orderInProcess setObject:object forKey:key];
//    
//    // Delete row for the object
//    [_orders removeObjectAtIndex:indexPath.row];
//    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
//    
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
//                                                      target:self
//                                                    selector:@selector(timeoutAtIndexPath:)
//                                                    userInfo:@{@"orderId" : key}
//                                                     repeats:NO];
//    
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//    
//    [_actionRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        
//        [self actionRequestSuccess:mappingResult
//                     withOperation:operation
//                           orderId:key
//                        actionType:type];
//        [timer invalidate];
//        
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        
//        [self actionRequestFailure:error orderId:key];
//        [timer invalidate];
//        
//    }];
//}
//
//- (void)actionRequestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation orderId:(NSString *)orderId actionType:(NSString *)actionType
//{
//    NSDictionary *result = ((RKMappingResult *)object).dictionary;
//    
//    ActionOrder *actionOrder = [result objectForKey:@""];
//    BOOL status = [actionOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
//    
//    if (status && [actionOrder.result.is_success boolValue]) {
//        NSString *message;
//        if ([actionType isEqualToString:@"confirm"]) {
//            message = @"Anda telah berhasil mengkonfirmasi pengiriman barang.";
//        } else if ([actionType isEqualToString:@"reject"]) {
//            message = @"Anda telah berhasil membatalkan pengiriman barang.";
//        }
//        _numberOfProcessedOrder++;
//        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[(message) ?: @""] delegate:self];
//        [alert show];
//        [_orderInProcess removeObjectForKey:orderId];
//    } else {
//        NSLog(@"\n\nRequest Message status : %@\n\n", actionOrder.message_error);
//        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:actionOrder.message_error
//                                                                       delegate:self];
//        [alert show];
//        [self performSelector:@selector(restoreData:) withObject:orderId];
//    }
//}
//
//- (void)actionRequestFailure:(id)object orderId:(NSString *)orderId
//{
//    NSLog(@"\n\nRequest error : %@\n\n", object);
//    NSDictionary *result = ((RKMappingResult *)object).dictionary;
//    ActionOrder *actionOrder = [result objectForKey:@""];
//
//    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:actionOrder.message_error
//                                                                   delegate:self];
//    [alert show];
//    
//    [self performSelector:@selector(restoreData:) withObject:orderId];
//}
//
//- (void)timeoutAtIndexPath:(NSTimer *)timer
//{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    NSString *orderId = [[timer userInfo] objectForKey:@"orderId"];
//    [self performSelector:@selector(restoreData:) withObject:orderId];
//}

- (void)reloadData {
    [_tableView reloadData];
}

- (void)restoreData:(NSString *)orderId
{
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
    self.page = @"0";
    self.perPage = @"6";
    [self fetchShipmentConfirmationData];
}

#pragma mark - Shipment courier request delegate

- (void)didReceiveShipmentCourier:(NSArray *)couriers {
    _shipmentCouriers = couriers;
}

- (void)requestShipmentCourierError {
    
}

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

@end
