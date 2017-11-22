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
#import "Tokopedia-Swift.h"
#import "UIColor+Theme.h"
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
    
    [AnalyticsManager trackScreenName:@"Sales - Shipping Confirmation"];
    
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
    cell.remainingDaysLabel.backgroundColor = [UIColor fromHexString:transaction.order_deadline.deadline_color];
    cell.remainingDaysLabel.text = transaction.deadline_string;
    cell.automaticallyCanceledLabel.text = transaction.deadline_label;
    cell.remainingDaysLabel.hidden = transaction.deadline_hidden;
    cell.automaticallyCanceledLabel.hidden = transaction.deadline_hidden;

    if (transaction.order_deadline.deadline_shipping_day_left < 0) {
        cell.acceptButton.enabled = NO;
        cell.acceptButton.layer.opacity = 0.25;
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
    cell.priceView.hidden = NO;
    cell.statusView.hidden = YES;
    
    [cell.rejectButton setTitle:@"Batal" forState:UIControlStateNormal];
    
    cell.order = transaction;
    
    [cell removeAllButtons];
    
    [cell showCancelButtonOnTap:^(OrderTransaction *order) {
    	__weak typeof(self) weakSelf = self;
		
    	CancelOrderShipmentViewController *controller = [[CancelOrderShipmentViewController alloc] initWithOrderTransaction:order];
    	controller.onFinishRequestCancel = ^(BOOL isSuccess) {
    	    if (isSuccess) {
    	        [weakSelf refreshData];
    	    } else {
    	        [weakSelf restoreData:order.order_detail.detail_order_id];
    	    }
    	};
    	
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    	[self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }];
    
    __weak typeof(self) wself = self;
    [cell showAskBuyerButtonOnTap:^(OrderTransaction *order) {
        [wself doAskBuyerWithOrder:order];
    }];

    if (transaction.order_is_pickup == 1) {
        [cell showPickUpButtonOnTap:^(OrderTransaction *order) {
            SubmitShipmentConfirmationViewController *controller = [SubmitShipmentConfirmationViewController new];
            controller.delegate = wself;
            controller.shipmentCouriers = _shipmentCouriers;
            controller.order = transaction;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }];
    } else if ([transaction.order_shipment.shipment_package_id isEqualToString:@"19"]) {
        [cell showChangeCourierButtonOnTap:^(OrderTransaction *order) {
            ChangeCourierViewController *controller = [ChangeCourierViewController new];
            controller.delegate = wself;
            controller.shipmentCouriers = _shipmentCouriers;
            controller.order = order;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            [wself.navigationController presentViewController:navigationController animated:YES completion:nil];
        }];
    } else {
        [cell showConfirmButtonOnTap:^(OrderTransaction *order) {
            SubmitShipmentConfirmationViewController *controller = [SubmitShipmentConfirmationViewController new];
            controller.delegate = wself;
            controller.shipmentCouriers = _shipmentCouriers;
            controller.order = order;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            [wself.navigationController presentViewController:navigationController animated:YES completion:nil];
        }];
    }
    
    return cell;
}

-(void)doAskBuyerWithOrder:(OrderTransaction*)order{
    SendChatViewController *vc = [[SendChatViewController alloc] initWithUserID:order.order_customer.customer_id shopID:nil name:order.order_customer.customer_name imageURL:order.order_customer.customer_image invoiceURL:order.order_detail.detail_pdf_uri productURL:nil source:@"tx_ask_buyer"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isLastIndexPath:indexPath] && self.nextURL) {
        [self fetchShipmentConfirmationData];
    }
}

#pragma mark - Cell delegate
- (void)tableViewCell:(UITableViewCell *)cell didSelectPriceAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    OrderDetailViewController *controller = [[OrderDetailViewController alloc] init];
    controller.transaction = _selectedOrder;
    controller.delegate = self;
    controller.shipmentCouriers = _shipmentCouriers;
    controller.booking = _orderBooking;
    controller.shouldRequestIDropCode = [_selectedOrder.order_shipment.shipment_package_id isEqualToString:IDropShipmentPackageID];
    controller.isDetailShipmentConfirmation = YES;
    
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
    self.filterController.couriers = _shipmentCouriers;
    navigationController.viewControllers = @[_filterController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Order detail delegate

- (void)didReceiveActionType:(ProceedType)type
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
    [self requestAction:ProceedTypeConfirm
                courier:courier
         courierPackage:courierPackage
          receiptNumber:receiptNumber
        rejectionReason:nil];
}

#pragma mark - Cancel shipment delegate

- (void)cancelShipmentWithExplanation:(NSString *)explanation {
    [self requestAction:ProceedTypeReject
                courier:nil
         courierPackage:nil
          receiptNumber:nil
        rejectionReason:explanation];
}

#pragma mark - Resktit methods for actions

- (void)requestAction:(ProceedType)type
              courier:(ShipmentCourier *)courier
       courierPackage:(ShipmentCourierPackage *)courierPackage
        receiptNumber:(NSString *)receiptNumber
      rejectionReason:(NSString *)rejectionReason {
    
    ProceedShippingObjectRequest *object = [ProceedShippingObjectRequest new];
    object.type = type;
    object.orderID = _selectedOrder.order_detail.detail_order_id;
    object.shippingRef = courier.shipment_id;
    object.shipmentID = courier.shipment_id ?: [NSString stringWithFormat:@"%zd",_selectedOrder.order_shipment.shipment_id];
    object.shipmentName = courier.shipment_name ?: _selectedOrder.order_shipment.shipment_name;
    object.shipmentPackageID = courierPackage.sp_id ?: _selectedOrder.order_shipment.shipment_package_id;
    object.reason = rejectionReason;

    // Add information about which transaction is in processing and at what index path
    OrderTransaction *order = _selectedOrder;
    
    NSIndexPath *indexPath = _selectedIndexPath;
    
    NSString *orderID = order.order_detail.detail_order_id;
    [_orderInProcess setObject:object forKey:orderID];
    
    // Delete row for the object
    [_orders removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    
    [ShipmentRequest fetchProceedShipping:object onSuccess:^{
        
        _numberOfProcessedOrder++;
        [_orderInProcess removeObjectForKey:orderID];
        
    } onFailure:^{
        
        [self performSelector:@selector(restoreData:) withObject:orderID];

    }];
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
