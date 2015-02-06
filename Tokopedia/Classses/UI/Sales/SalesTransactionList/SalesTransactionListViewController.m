//
//  SalesTransactionListViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_order.h"

#import "SalesTransactionListViewController.h"
#import "FilterSalesTransactionListViewController.h"
#import "ChangeReceiptNumberViewController.h"
#import "FilterShipmentStatusViewController.h"
#import "DetailShipmentStatusViewController.h"

#import "StickyAlertView.h"

#import "ShipmentStatusCell.h"
#import "SalesOrderCell.h"

#import "Order.h"
#import "OrderTransaction.h"
#import "ActionOrder.h"

@interface SalesTransactionListViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    ShipmentStatusCellDelegate,
    ChangeReceiptNumberDelegate,
    FilterSalesTransactionListDelegate
>
{
    NSMutableArray *_orders;
    
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
    
    Order *_resultOrder;
    OrderTransaction *_selectedOrder;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SalesTransactionListViewController

typedef enum {
    ORDER_CANCELED                       = 0,     // update by ADMIN/SYSTEM order canceled for some reason
    ORDER_CANCELED_CHECKOUT              = 1,     // update by BUYER        cancel checkout baru, apabila dia 2x checkout
    ORDER_REJECTED                       = 10,    // update by SELLER       seller rejected the order
    ORDER_CHECKOUT_STATE                 = 90,    // update by BUYER        order status sebelum checkout, tidak tampil dimana2
    ORDER_PENDING                        = 100,   // update by BUYER        checked out an item in the shopping cart
    ORDER_PENDING_UNIK                   = 101,   // update by SYSTEM       fail UNIK payment
    ORDER_CREDIT_CARD_CHALLENGE          = 102,   // update by BUYER        credit card payment status challenge
    ORDER_PENDING_DUE_DATE               = 120,   // update by SYSTEM       after order age > 3 days
    ORDER_PAYMENT_CONFIRM                = 200,   // update by BUYER        confirm a payment
    ORDER_PAYMENT_CONFIRM_UNIK           = 201,   // update by BUYER        confirm a payment for UNIK
    ORDER_PAYMENT_DUE_DATE               = 210,   // update by SYSTEM       after order age > 6 days
    ORDER_PAYMENT_VERIFIED               = 220,   // update by SYSTEM       payment received and verified, ready to process
    ORDER_PROCESS                        = 400,   // update by SELLER       seller accepted the order
    ORDER_PROCESS_PARTIAL                = 401,   // update by SELLER       seller accepted the order, partially
    ORDER_PROCESS_DUE_DATE               = 410,   // update by SYSTEM       untouch verified order after payment age > 3 days
    ORDER_SHIPPING                       = 500,   // update by SELLER       seller confirm for shipment
    ORDER_SHIPPING_DATE_EDITED           = 505,   // update by ADMIN        seller input an invalid shipping date
    ORDER_SHIPPING_DUE_DATE              = 510,   // update by SYSTEM       seller not confirm for shipment after order accepted and payment age > 5 days
    ORDER_SHIPPING_TRACKER_INVALID       = 520,   // update by SYSTEM       invalid shipping ref num
    ORDER_SHIPPING_REF_NUM_EDITED        = 530,   // update by ADMIN        requested by user for shipping ref number correction because false entry
    ORDER_DELIVERED                      = 600,   // update by TRACKER      tells that buyer received the packet
    ORDER_CONFLICTED                     = 601,   // update by BUYER        Buyer open a case to finish an order
    ORDER_DELIVERED_CONFIRM              = 610,   // update by BUYER        buyer confirm for delivery
    ORDER_DELIVERED_DUE_DATE             = 620,   // update by SYSTEM       no response after delivery age > 3 days
    ORDER_DELIVERY_FAILURE               = 630,   // update by BUYER        buyer claim that he/she does not received any package
    ORDER_FINISHED                       = 700,   // update by ADMIN        order complete Confirmed
    ORDER_FINISHED_BOUNCE_BACK           = 701,   // update by ADMIN        order yang dianggap selesai tetapi barang tidak sampai ke buyer
    ORDER_REFUND                         = 800,   // update by ADMIN        order refund to the buyer for some reason
    ORDER_ROLLBACK                       = 801,   // update by ADMIN        order rollback from finished
    ORDER_BAD                            = 900    // update by ADMIN        bad order occurs and need further investigation} ORDER_STATUS;
} ORDER_STATUS;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Daftar Transaksi";

    _page = 1;
    _requestCount = 0;
    
    _orders = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    
    [self configureRestKit];
    [self requestInvoice:nil transactionStatus:nil startDate:nil endDate:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Tabel data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_orders count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    CGFloat height = 0;
    if ([_resultOrder.result.order.is_allow_manage_tx boolValue] && order.order_detail.detail_ship_ref_num) {
        if (order.order_detail.detail_order_status == ORDER_DELIVERED ||
            order.order_detail.detail_order_status == ORDER_SHIPPING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_REF_NUM_EDITED ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_TRACKER_INVALID) {
            height = tableView.rowHeight;
        } else {
            height = tableView.rowHeight - 45;
        }
    }
    return height;
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
    
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    
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
    
    if ([_resultOrder.result.order.is_allow_manage_tx boolValue] && order.order_detail.detail_ship_ref_num) {
        
        if (order.order_detail.detail_order_status == ORDER_DELIVERED) {
            
            [cell showTrackButton];
            
        } else if (order.order_detail.detail_order_status == ORDER_DELIVERED_CONFIRM) {
            
            cell.dateFinishLabel.hidden = NO;
            cell.finishLabel.hidden = NO;
            
            OrderHistory *history = [order.order_history objectAtIndex:0];
            cell.dateFinishLabel.text = [history.history_status_date_full substringToIndex:[history.history_status_date_full length]-6];
            
        } else if (order.order_detail.detail_order_status == ORDER_SHIPPING ||
                   order.order_detail.detail_order_status == ORDER_SHIPPING_REF_NUM_EDITED ||
                   order.order_detail.detail_order_status == ORDER_SHIPPING_TRACKER_INVALID) {
            
            [cell showAllButton];
            
        } else {
            
            [cell hideAllButton];
            
        }
    }
    
    [cell setStatusLabelText:[[order.order_history objectAtIndex:0] history_seller_status]];

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
            [self requestInvoice:nil transactionStatus:nil startDate:nil endDate:nil];
        } else {
            _tableView.tableFooterView = nil;
        }
    }
}

#pragma mark - Table cell delegate

- (void)didTapTrackButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didTapReceiptButton:(UIButton *)button indexPath:(NSIndexPath *)indexPath
{
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    ChangeReceiptNumberViewController *controller = [ChangeReceiptNumberViewController new];
    controller.delegate = self;
    navigationController.viewControllers = @[controller];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didTapStatusAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    
    DetailShipmentStatusViewController *controller = [DetailShipmentStatusViewController new];
    controller.order = order;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Filter delegate

- (void)filterOrderInvoice:(NSString *)invoice transactionStatus:(NSString *)transactionStatus startDate:(NSString *)startDate endDate:(NSString *)endDate
{
    _page = 1;
    _requestCount = 0;
    
    [_orders removeAllObjects];
    [_tableView reloadData];
    
    [self configureRestKit];
    [self requestInvoice:invoice transactionStatus:transactionStatus startDate:startDate endDate:endDate];
}

#pragma mark - Change receipt number delegate

- (void)changeReceiptNumber:(NSString *)receiptNumber
{
    [self requestChangeReceiptNumber:receiptNumber];
}

#pragma mark - Actions

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor whiteColor];

            FilterSalesTransactionListViewController *controller = [FilterSalesTransactionListViewController new];
            controller.delegate = self;
            navigationController.viewControllers = @[controller];
            
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
    }
}

#pragma mark - Restkit methods

- (void)configureRestKit
{
    _objectManager =  [RKObjectManager sharedClient];
    
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
                                                             @"detail_total_add_fee"        : @"detail_total_add_fee",
                                                             @"detail_open_amount_idr"      : @"detail_open_amount_idr",
                                                             }];
    
    RKObjectMapping *orderDeadlineMapping = [RKObjectMapping mappingForClass:[OrderDeadline class]];
    [orderDeadlineMapping addAttributeMappingsFromDictionary:@{
                                                               API_DEADLINE_PROCESS_DAY_LEFT  : API_DEADLINE_PROCESS_DAY_LEFT,
                                                               API_DEADLINE_SHIPPING_DAY_LEFT : API_DEADLINE_SHIPPING_DAY_LEFT,
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

- (void)requestInvoice:(NSString *)invoice transactionStatus:(NSString *)transactionStatus startDate:(NSString *)startDate endDate:(NSString *)endDate
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if (_request.isExecuting) return;
    
    _requestCount++;
    
    _tableView.tableFooterView = _footerView;
    [_activityIndicator startAnimating];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary* param = @{
                            API_ACTION_KEY           : API_GET_NEW_ORDER_LIST_KEY,
                            API_USER_ID_KEY          : [auth objectForKey:API_USER_ID_KEY],
                            API_PAGE_KEY             : [NSNumber numberWithInteger:_page],
                            API_INVOICE_KEY          : invoice ?: @"",
                            API_FILTER_KEY           : transactionStatus ?: @"",
                            API_START_KEY            : startDate ?: @"",
                            API_END_KEY              : endDate ?: @"",
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
            
            [_refreshControl endRefreshing];
            
            [_timer invalidate];
            _timer = nil;
            
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
    if (status)
    {
        [self requestProcess:object];
    }
    else
    {
        
    }
}

- (void)requestProcess:(id)object
{
    if (object && [object isKindOfClass:[RKMappingResult class]]) {
        
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        _resultOrder = [result objectForKey:@""];
        [_orders addObjectsFromArray:_resultOrder.result.list];
        
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
        
        if (_orders.count == 0) {
            _activityIndicator.hidden = YES;
        }
        
        if (_page == 0) {
            [_activityIndicator stopAnimating];
            _tableView.tableFooterView = nil;
        }
        
        [_tableView reloadData];
    }
}

- (void)requestFailure:(id)object
{
    
}

- (void)cancel
{
    
}

#pragma mark - Reskit action methods

- (void)configureActionReskit
{
    _actionObjectManager =  [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ActionOrder class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY              : kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY   : kTKPD_APISERVERPROCESSTIMEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY       : kTKPD_APISTATUSMESSAGEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ActionOrderResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY : kTKPD_APIISSUCCESSKEY}];
    
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

- (void)requestChangeReceiptNumber:(NSString *)receiptNumber
{
    [self configureActionReskit];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary *param = @{
                            API_ACTION_KEY              : API_EDIT_SHIPPING_REF,
                            API_USER_ID_KEY             : [auth objectForKey:API_USER_ID_KEY],
                            API_ORDER_ID_KEY            : [NSNumber numberWithInteger:_selectedOrder.order_detail.detail_order_id],
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
            
        } else {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Proses rubah sesi gagal."] delegate:self];
            [alert show];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Proses rubah sesi gagal."] delegate:self];
        [alert show];
        
    }];    
}

@end
