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
{
    NSMutableArray *_shipments;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    RKResponseDescriptor *_responseDescriptorStatus;

    __weak RKObjectManager *_actionObjectManager;
    __weak RKManagedObjectRequestOperation *_actionRequest;
    RKResponseDescriptor *_responseActionDescriptorStatus;
    
    NSOperationQueue *_operationQueue;
    
    NSInteger _page;
    NSInteger _requestCount;
    NSString *_nextURI;

    NSTimer *_timer;
    
    UIRefreshControl *_refreshControl;
    
    NSString *_status;
    Order *_resultOrder;
    
    OrderTransaction *_selectedOrder;
    NSIndexPath *_selectedIndexPath;
    
    FilterShipmentStatusViewController *_filterController;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ShipmentStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 1;
    _requestCount = 0;
    
    _shipments = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    
    _tableView.tableFooterView = _footerView;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);

    [_activityIndicator startAnimating];
    
    [self configureRestKit];
    [self requestInvoice:nil];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    _filterController = [FilterShipmentStatusViewController new];
    _filterController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Status Pengiriman";
    
    [TPAnalytics trackScreenName:@"Sales - Shipping Status"];
    self.screenName = @"Sales - Shipping Status";
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    UIBarButtonItem *filterBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(tap:)];
    filterBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = filterBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_shipments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    OrderTransaction *order = [_shipments objectAtIndex:indexPath.row];
    
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
    
    if ([_resultOrder.result.order.is_allow_manage_tx boolValue] &&
        order.order_detail.detail_ship_ref_num) {
        
        if (order.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED) {
            [cell showTrackButton];
        } else if (order.order_detail.detail_order_status == ORDER_SHIPPING &&
                   order.order_shipment.shipment_id == 10) {
            [cell showTrackButton];
        } else if (order.order_detail.detail_order_status == ORDER_SHIPPING ||
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
    
    if ((order.order_detail.detail_order_status == ORDER_DELIVERED ||
         order.order_detail.detail_order_status == ORDER_DELIVERED_DUE_DATE) &&
         order.order_deadline.deadline_finish_day_left) {
        cell.dateFinishLabel.hidden = NO;
        cell.dateFinishLabel.text = @"Selesai Otomatis";
        cell.dateFinishLabel.font = [UIFont fontWithName:@"GothamBook" size:9];
        cell.finishLabel.hidden = NO;
        cell.finishLabel.text = order.order_deadline.deadline_finish_date;        
    }
    
    NSLog(@"%@  -  %ld", order.order_detail.detail_invoice,
          (long)order.order_deadline.deadline_finish_day_left);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_nextURI != NULL && ![_nextURI isEqualToString:@"0"] && _nextURI != 0) {
            _tableView.tableFooterView = _footerView;
            [_activityIndicator startAnimating];
            [self configureRestKit];
            [self requestInvoice:nil];
        } else {
            _tableView.tableFooterView = nil;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTransaction *order = [_shipments objectAtIndex:indexPath.row];
    if ([_resultOrder.result.order.is_allow_manage_tx boolValue] && order.order_detail.detail_ship_ref_num) {
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

- (void)configureRestKit
{
    _objectManager =  [RKObjectManager sharedClient];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_objectManager.HTTPClient setDefaultHeader:@"X-APP-VERSION" value:appVersion];

    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Order class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY : kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY : kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[OrderResult class]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{
                                                        API_PAGING_URI_NEXT     : API_PAGING_URI_NEXT,
                                                        API_PAGING_URI_PREVIOUS : API_PAGING_URI_PREVIOUS,
                                                        }];
    
    RKObjectMapping *orderMapping = [RKObjectMapping mappingForClass:[OrderOrder class]];
    [orderMapping addAttributeMappingsFromDictionary:@{
                                                       API_ORDER_IS_ALLOW_MANAGE_TX      : API_ORDER_IS_ALLOW_MANAGE_TX,
                                                       API_ORDER_SHOP_NAME               : API_ORDER_SHOP_NAME,
                                                       API_ORDER_IS_GOLD_SHOP            : API_ORDER_IS_GOLD_SHOP,
                                                       }];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[OrderTransaction class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 API_LIST_ORDER_JOB_STATUS,
                                                 API_LIST_ORDER_AUTO_RESI,
                                                 API_LIST_ORDER_AUTO_AWB,
                                                 ]];
    
    RKObjectMapping *orderCustomerMapping = [RKObjectMapping mappingForClass:[OrderCustomer class]];
    [orderCustomerMapping addAttributeMappingsFromDictionary:@{
                                                               API_CUSTOMER_URL     : API_CUSTOMER_URL,
                                                               API_CUSTOMER_ID      : API_CUSTOMER_ID,
                                                               API_CUSTOMER_NAME    : API_CUSTOMER_NAME,
                                                               API_CUSTOMER_IMAGE   : API_CUSTOMER_IMAGE,
                                                               }];
    
    RKObjectMapping *orderPaymentMapping = [RKObjectMapping mappingForClass:[OrderPayment class]];
    [orderPaymentMapping addAttributeMappingsFromDictionary:@{
                                                              API_PAYMENT_PROCESS_DUE_DATE  : API_PAYMENT_PROCESS_DUE_DATE,
                                                              API_PAYMENT_KOMISI            : API_PAYMENT_KOMISI,
                                                              API_PAYMENT_VERIFY_DATE       : API_PAYMENT_VERIFY_DATE,
                                                              API_PAYMENT_SHIPPING_DUE_DATE : API_PAYMENT_SHIPPING_DUE_DATE,
                                                              API_PAYMENT_SHIPPING_DAY_LEFT : API_PAYMENT_SHIPPING_DAY_LEFT,
                                                              API_PAYMENT_PROCESS_DAY_LEFT  : API_PAYMENT_PROCESS_DAY_LEFT,
                                                              API_PAYMENT_GATEWAY_ID        : API_PAYMENT_GATEWAY_ID,
                                                              API_PAYMENT_GATEWAY_IMAGE     : API_PAYMENT_GATEWAY_IMAGE,
                                                              API_PAYMENT_GATEWAY_NAME      : API_PAYMENT_GATEWAY_NAME,
                                                              API_PAYMENT_SHIPPING_DAY_LEFT : API_PAYMENT_SHIPPING_DAY_LEFT,
                                                              API_PAYMENT_GATEWAY_NAME      : API_PAYMENT_GATEWAY_NAME,
                                                              }];
    
    RKObjectMapping *orderDetailMapping = [RKObjectMapping mappingForClass:[OrderDetail class]];
    [orderDetailMapping addAttributeMappingsFromDictionary:@{
                                                             API_DETAIL_INSURANCE_PRICE     : API_DETAIL_INSURANCE_PRICE,
                                                             API_DETAIL_OPEN_AMOUNT         : API_DETAIL_OPEN_AMOUNT,
                                                             API_DETAIL_QUANTITY            : API_DETAIL_QUANTITY,
                                                             API_DETAIL_PRODUCT_PRICE_IDR   : API_DETAIL_PRODUCT_PRICE_IDR,
                                                             API_DETAIL_INVOICE             : API_DETAIL_INVOICE,
                                                             API_DETAIL_SHIPPING_PRICE_IDR  : API_DETAIL_SHIPPING_PRICE_IDR,
                                                             API_DETAIL_PDF_PATH            : API_DETAIL_PDF_PATH,
                                                             API_DETAIL_ADDITIONAL_FEE_IDR  : API_DETAIL_ADDITIONAL_FEE_IDR,
                                                             API_DETAIL_PRODUCT_PRICE       : API_DETAIL_PRODUCT_PRICE,
                                                             API_DETAIL_FORCE_INSURANCE     : API_DETAIL_FORCE_INSURANCE,
                                                             API_DETAIL_ADDITIONAL_FEE      : API_DETAIL_ADDITIONAL_FEE,
                                                             API_DETAIL_ORDER_ID            : API_DETAIL_ORDER_ID,
                                                             API_DETAIL_TOTAL_ADD_FEE_IDR   : API_DETAIL_TOTAL_ADD_FEE_IDR,
                                                             API_DETAIL_ORDER_DATE          : API_DETAIL_ORDER_DATE,
                                                             API_DETAIL_SHIPPING_PRICE      : API_DETAIL_SHIPPING_PRICE,
                                                             API_DETAIL_PAY_DUE_DATE        : API_DETAIL_PAY_DUE_DATE,
                                                             API_DETAIL_TOTAL_WEIGHT        : API_DETAIL_TOTAL_WEIGHT,
                                                             API_DETAIL_INSURANCE_PRICE_IDR : API_DETAIL_INSURANCE_PRICE_IDR,
                                                             API_DETAIL_PDF_URI             : API_DETAIL_PDF_URI,
                                                             API_DETAIL_SHIP_REF_NUM        : API_DETAIL_SHIP_REF_NUM,
                                                             API_DETAIL_FORCE_CANCEL        : API_DETAIL_FORCE_CANCEL,
                                                             API_DETAIL_PRINT_ADDRESS_URI   : API_DETAIL_PRINT_ADDRESS_URI,
                                                             API_DETAIL_PDF                 : API_DETAIL_PDF,
                                                             API_DETAIL_ORDER_STATUS        : API_DETAIL_ORDER_STATUS,
                                                             API_DETAIL_FORCE_CANCEL        : API_DETAIL_FORCE_CANCEL,
                                                             API_DETAIL_DROPSHIP_NAME       : API_DETAIL_DROPSHIP_NAME,
                                                             API_DETAIL_DROPSHIP_TELP       : API_DETAIL_DROPSHIP_TELP,
                                                             API_DETAIL_PARTIAL_ORDER       : API_DETAIL_PARTIAL_ORDER,
                                                             @"detail_total_add_fee"        : @"detail_total_add_fee",
                                                             @"detail_open_amount_idr"      : @"detail_open_amount_idr",
                                                             }];
    
    RKObjectMapping *orderShopMapping = [RKObjectMapping mappingForClass:[OrderSellerShop class]];
    [orderShopMapping addAttributeMappingsFromArray:@[API_SHOP_ADDRESS_STREET,
                                                      API_SHOP_ADDRESS_DISTRICT,
                                                      API_SHOP_ADDRESS_CITY,
                                                      API_SHOP_ADDRESS_PROVINCE,
                                                      API_SHOP_ADDRESS_COUNTRY,
                                                      API_SHOP_ADDRESS_POSTAL
                                                      API_SHOP_SHIPPER_PHONE]];
    
    RKObjectMapping *orderDeadlineMapping = [RKObjectMapping mappingForClass:[OrderDeadline class]];
    [orderDeadlineMapping addAttributeMappingsFromDictionary:@{
                                                               API_DEADLINE_PROCESS_DAY_LEFT  : API_DEADLINE_PROCESS_DAY_LEFT,
                                                               API_DEADLINE_SHIPPING_DAY_LEFT : API_DEADLINE_SHIPPING_DAY_LEFT,
                                                               API_DEADLINE_FINISH_DAY_LEFT   : API_DEADLINE_FINISH_DAY_LEFT,
                                                               API_DEADLINE_FINISH_DATE       : API_DEADLINE_FINISH_DATE,
                                                               }];
    
    RKObjectMapping *orderProductMapping = [RKObjectMapping mappingForClass:[OrderProduct class]];
    [orderProductMapping addAttributeMappingsFromDictionary:@{
                                                              API_ORDER_DELIVERY_QUANTITY   : API_ORDER_DELIVERY_QUANTITY,
                                                              API_PRODUCT_PICTURE           : API_PRODUCT_PICTURE,
                                                              API_PRODUCT_PRICE             : API_PRODUCT_PRICE,
                                                              API_ORDER_DETAIL_ID           : API_ORDER_DETAIL_ID,
                                                              API_PRODUCT_NOTES             : API_PRODUCT_NOTES,
                                                              API_PRODUCT_STATUS            : API_PRODUCT_STATUS,
                                                              API_ORDER_SUBTOTAL_PRICE      : API_ORDER_SUBTOTAL_PRICE,
                                                              API_PRODUCT_ID                : API_PRODUCT_ID,
                                                              API_PRODUCT_QUANTITY          : API_PRODUCT_QUANTITY,
                                                              API_PRODUCT_WEIGHT            : API_PRODUCT_WEIGHT,
                                                              API_ORDER_SUBTOTAL_PRICE_IDR  : API_ORDER_SUBTOTAL_PRICE_IDR,
                                                              API_PRODUCT_REJECT_QUANTITY   : API_PRODUCT_REJECT_QUANTITY,
                                                              API_PRODUCT_NAME              : API_PRODUCT_NAME,
                                                              API_PRODUCT_URL               : API_PRODUCT_URL,
                                                              }];
    
    
    RKObjectMapping *orderShipmentMapping = [RKObjectMapping mappingForClass:[OrderShipment class]];
    [orderShipmentMapping addAttributeMappingsFromDictionary:@{
                                                               API_SHIPMENT_LOGO             : API_SHIPMENT_LOGO,
                                                               API_SHIPMENT_PACKAGE_ID       : API_SHIPMENT_PACKAGE_ID,
                                                               API_SHIPMENT_ID               : API_SHIPMENT_ID,
                                                               API_SHIPMENT_PRODUCT          : API_SHIPMENT_PRODUCT,
                                                               API_SHIPMENT_NAME             : API_SHIPMENT_NAME,
                                                               }];
    
    
    RKObjectMapping *orderLastMapping = [RKObjectMapping mappingForClass:[OrderLast class]];
    [orderLastMapping addAttributeMappingsFromDictionary:@{
                                                           API_LAST_ORDER_ID            : API_LAST_ORDER_ID,
                                                           API_LAST_SHIPMENT_ID         : API_LAST_SHIPMENT_ID,
                                                           API_LAST_EST_SHIPPING_LEFT   : API_LAST_EST_SHIPPING_LEFT,
                                                           API_LAST_ORDER_STATUS        : API_LAST_ORDER_STATUS,
                                                           API_LAST_ORDER_STATUS_DATE   : API_LAST_ORDER_STATUS_DATE,
                                                           API_LAST_POD_CODE            : API_LAST_POD_CODE,
                                                           API_LAST_POD_DESC            : API_LAST_POD_DESC,
                                                           API_LAST_SHIPPING_REF_NUM    : API_LAST_SHIPPING_REF_NUM,
                                                           API_LAST_POD_RECEIVER        : API_LAST_POD_RECEIVER,
                                                           API_LAST_COMMENTS            : API_LAST_COMMENTS,
                                                           API_LAST_BUYER_STATUS        : API_LAST_BUYER_STATUS,
                                                           API_LAST_STATUS_DATE_WIB     : API_LAST_STATUS_DATE_WIB,
                                                           API_LAST_SELLER_STATUS       : API_LAST_SELLER_STATUS,
                                                           }];
    
    RKObjectMapping *orderHistoryMapping = [RKObjectMapping mappingForClass:[OrderHistory class]];
    [orderHistoryMapping addAttributeMappingsFromDictionary:@{
                                                              API_HISTORY_STATUS_DATE       : API_HISTORY_STATUS_DATE,
                                                              API_HISTORY_STATUS_DATE_FULL  : API_HISTORY_STATUS_DATE_FULL,
                                                              API_HISTORY_ORDER_STATUS      : API_HISTORY_ORDER_STATUS,
                                                              API_HISTORY_COMMENTS          : API_HISTORY_COMMENTS,
                                                              API_HISTORY_ACTION_BY         : API_HISTORY_ACTION_BY,
                                                              API_HISTORY_BUYER_STATUS      : API_HISTORY_BUYER_STATUS,
                                                              API_HISTORY_SELLER_STATUS     : API_HISTORY_SELLER_STATUS,
                                                              }];
    
    RKObjectMapping *orderDestinationMapping = [RKObjectMapping mappingForClass:[OrderDestination class]];
    [orderDestinationMapping addAttributeMappingsFromDictionary:@{
                                                                  API_RECEIVER_NAME         : API_RECEIVER_NAME,
                                                                  API_ADDRESS_COUNTRY       : API_ADDRESS_COUNTRY,
                                                                  API_ADDRESS_POSTAL        : API_ADDRESS_POSTAL,
                                                                  API_ADDRESS_DISTRICT      : API_ADDRESS_DISTRICT,
                                                                  API_RECEIVER_PHONE        : API_RECEIVER_PHONE,
                                                                  API_ADDRESS_STREET        : API_ADDRESS_STREET,
                                                                  API_ADDRESS_CITY          : API_ADDRESS_CITY,
                                                                  API_ADDRESS_PROVINCE      : API_ADDRESS_PROVINCE,
                                                                  }];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_KEY
                                                                                  toKeyPath:API_ORDER_KEY
                                                                                withMapping:orderMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_PAGING_KEY
                                                                                  toKeyPath:API_PAGING_KEY
                                                                                withMapping:pagingMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                  toKeyPath:kTKPD_APILISTKEY
                                                                                withMapping:listMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_CUSTOMER
                                                                                toKeyPath:API_LIST_ORDER_CUSTOMER
                                                                              withMapping:orderCustomerMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_PAYMENT
                                                                                toKeyPath:API_LIST_ORDER_PAYMENT
                                                                              withMapping:orderPaymentMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_DETAIL
                                                                                toKeyPath:API_LIST_ORDER_DETAIL
                                                                              withMapping:orderDetailMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_SHOP
                                                                                toKeyPath:API_LIST_ORDER_SHOP
                                                                              withMapping:orderShopMapping]];

    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_DEADLINE
                                                                                toKeyPath:API_LIST_ORDER_DEADLINE
                                                                              withMapping:orderDeadlineMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_PRODUCTS
                                                                                toKeyPath:API_LIST_ORDER_PRODUCTS
                                                                              withMapping:orderProductMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_SHIPMENT
                                                                                toKeyPath:API_LIST_ORDER_SHIPMENT
                                                                              withMapping:orderShipmentMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_HISTORY
                                                                                toKeyPath:API_LIST_ORDER_HISTORY
                                                                              withMapping:orderHistoryMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_DESTINATION
                                                                                toKeyPath:API_LIST_ORDER_DESTINATION
                                                                              withMapping:orderDestinationMapping]];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:API_NEW_ORDER_PATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];    
}

- (void)requestInvoice:(NSString *)invoice
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if (_request.isExecuting) return;
    
    _requestCount++;
    
    _tableView.tableFooterView = _footerView;
    [_activityIndicator startAnimating];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary* param = @{
                            API_ACTION_KEY           : API_GET_NEW_ORDER_STATUS_KEY,
                            API_USER_ID_KEY          : [auth objectForKey:API_USER_ID_KEY],
                            API_INVOICE_KEY          : invoice ?: @"",
                            API_PAGE_KEY             : [NSNumber numberWithInteger:_page],
                            };
    
    NSLog(@"\n\n\n\n%@\n\n\n\n", param);
    
    if (_page >= 1) {
        
        [_activityIndicator startAnimating];
        
        _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                        method:RKRequestMethodPOST
                                                                          path:API_NEW_ORDER_PATH
                                                                    parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            [_refreshControl endRefreshing];
            
            [_timer invalidate];
            _timer = nil;
            
            [self requestSuccess:mappingResult withOperation:operation];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            [self requestFailure:error];
            
        }];
        
        [_operationQueue addOperation:_request];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                          target:self
                                                        selector:@selector(cancel)
                                                        userInfo:nil
                                                         repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
    }
}

- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    BOOL status = [[[result objectForKey:@""] status] isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self requestProcess:object];
    }
}

- (void)requestProcess:(id)object
{
    if (object && [object isKindOfClass:[RKMappingResult class]]) {

        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        _resultOrder = [result objectForKey:@""];
        
        if (_page == 1) {
            _shipments = _resultOrder.result.list;
        } else {
            [_shipments addObjectsFromArray:_resultOrder.result.list];
        }
        
        _nextURI =  _resultOrder.result.paging.uri_next;
        NSURL *url = [NSURL URLWithString:_nextURI];
        NSArray* query = [[url query] componentsSeparatedByString: @"&"];
        NSMutableDictionary *queries = [NSMutableDictionary new];
        for (NSString *keyValuePair in query)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            [queries setObject:value forKey:key];
        }
        
        _page = [[queries objectForKey:API_PAGE_KEY] integerValue];
        
        NSLog(@"next page : %ld",(long)_page);
        
        if (_page == 0) {
            [_activityIndicator stopAnimating];
            _tableView.tableFooterView = nil;
        }

        if (_shipments.count == 0) {
            _activityIndicator.hidden = YES;
            
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 103);
            NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
            _tableView.tableFooterView = noResultView;
            _tableView.sectionFooterHeight = noResultView.frame.size.height;
        }

        [_tableView reloadData];
    }
}

- (void)requestFailure:(id)object
{
    [_refreshControl endRefreshing];
    
    [_timer invalidate];
    _timer = nil;
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Mohon maaf, sedang terjadi kendala pada server. Silahkan coba beberapa saat lagi."] delegate:self];
    [alert show];
    
    self.tableView.tableFooterView = nil;
}

- (void)cancel
{

}

- (void)refreshData
{
    _page = 1;
    [self configureRestKit];
    [self requestInvoice:nil];
}

#pragma mark - Reskit action methods

- (void)configureActionReskit
{
    _actionObjectManager =  [RKObjectManager sharedClient];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_objectManager.HTTPClient setDefaultHeader:@"X-APP-VERSION" value:appVersion];

    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ActionOrder class]];
    [statusMapping addAttributeMappingsFromArray:@[
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY,
                                                   kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APIERRORMESSAGEKEY
                                                   ]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ActionOrderResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *actionResponseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                        method:RKRequestMethodPOST
                                                                                                   pathPattern:API_NEW_ORDER_ACTION_PATH
                                                                                                       keyPath:@""
                                                                                                   statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_actionObjectManager addResponseDescriptor:actionResponseDescriptorStatus];
}

- (void)requestChangeReceiptNumber:(NSString *)receiptNumber orderHistory:(OrderHistory *)orderHistory
{
    [self configureActionReskit];
 
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary *param = @{
                            API_ACTION_KEY              : API_EDIT_SHIPPING_REF,
                            API_USER_ID_KEY             : [auth objectForKey:API_USER_ID_KEY],
                            API_ORDER_ID_KEY            : _selectedOrder.order_detail.detail_order_id,
                            API_SHIPMENT_REF_KEY        : receiptNumber,
                            };
    
    _actionRequest = [_actionObjectManager appropriateObjectRequestOperationWithObject:self
                                                                                method:RKRequestMethodPOST
                                                                                  path:API_NEW_ORDER_ACTION_PATH
                                                                            parameters:[param encrypt]];
    [_operationQueue addOperation:_actionRequest];
    
    [_actionRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSDictionary *result = ((RKMappingResult *) mappingResult).dictionary;
        ActionOrder *actionOrder = [result objectForKey:@""];
        BOOL status = [actionOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status && [actionOrder.result.is_success boolValue]) {

            StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil merubah nomor resi."] delegate:self];
            [alert show];
        
            _selectedOrder.order_detail.detail_ship_ref_num = receiptNumber;

            if (orderHistory) {
                NSMutableArray *history = [NSMutableArray arrayWithArray:_selectedOrder.order_history];
                [history insertObject:orderHistory atIndex:0];
                _selectedOrder.order_history = history;
            }
            
            [self.tableView reloadData];
            
        } else if (actionOrder.message_error) {
            NSArray *errorMessages = actionOrder.message_error?:@[@"Proses mengubah nomor resi gagal."];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Proses mengubah nomor resi gagal."] delegate:self];
        [alert show];
        
    }];
}

#pragma mark - Cell delegate

- (void)didTapTrackButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath
{
    OrderTransaction *order = [_shipments objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    _selectedIndexPath = indexPath;
    
    TrackOrderViewController *controller = [TrackOrderViewController new];
    controller.order = _selectedOrder;
    controller.hidesBottomBarWhenPushed = YES;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}   

- (void)didTapReceiptButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath
{
    OrderTransaction *order = [_shipments objectAtIndex:indexPath.row];
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

- (void)didTapStatusAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTransaction *order = [_shipments objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    _selectedIndexPath = indexPath;

    DetailShipmentStatusViewController *controller = [DetailShipmentStatusViewController new];
    controller.order = order;
    controller.delegate = self;
    controller.is_allow_manage_tx = _resultOrder.result.order.is_allow_manage_tx;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didTapUserAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedOrder = [_shipments objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    NavigateViewController *controller = [NavigateViewController new];
    [controller navigateToProfileFromViewController:self withUserID:_selectedOrder.order_customer.customer_id];
}

#pragma mark - Action

- (IBAction)tap:(id)sender {
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];

    navigationController.viewControllers = @[_filterController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Filter delegate

- (void)filterShipmentStatusInvoice:(NSString *)invoice
{
    _tableView.tableFooterView = _footerView;
    [_activityIndicator startAnimating];

    _status = invoice;
    _page = 1;
    _requestCount = 0;
    
    [_shipments removeAllObjects];
    [_tableView reloadData];
    
    [self configureRestKit];
    [self requestInvoice:invoice];
}

#pragma mark - Change receipt number delegate

- (void)changeReceiptNumber:(NSString *)receiptNumber orderHistory:(OrderHistory *)history
{
    [self requestChangeReceiptNumber:receiptNumber orderHistory:history];
}

#pragma mark - Track order delegate

- (void)updateDeliveredOrder:(NSString *)receiverName
{
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
