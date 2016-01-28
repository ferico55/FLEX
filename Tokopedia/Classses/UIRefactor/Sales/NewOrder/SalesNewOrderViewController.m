//
//  SalesNewOrderViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SalesNewOrderViewController.h"
#import "SalesOrderCell.h"
#import "FilterNewOrderViewController.h"
#import "ChooseProductViewController.h"
#import "OrderRejectExplanationViewController.h"
#import "URLCacheController.h"
#import "TKPDSecureStorage.h"
#import "ProductQuantityViewController.h"
#import "OrderDetailViewController.h"
#import "TKPDTabProfileNavigationController.h"
#import "NavigateViewController.h"
#import "TokopediaNetworkManager.h"

#import "Order.h"
#import "OrderTransaction.h"
#import "string_order.h"
#import "detail.h"
#import "WarehouseResponse.h"

#import "StickyAlert.h"
#import "StickyAlertView.h"

#import "ActionOrder.h"

#import "OrderSellerShop.h"

@interface SalesNewOrderViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIAlertViewDelegate,
    SalesOrderCellDelegate,
    ChooseProductDelegate,
    RejectExplanationDelegate,
    FilterDelegate,
    ProductQuantityDelegate,
    OrderDetailDelegate,
    TokopediaNetworkManagerDelegate
>
{
    NSMutableArray *_transactions;
    NSMutableDictionary *_paging;
    NSInteger _page;
    NSInteger _limit;
    NSInteger _requestCount;
    NSString *_uriNext;
    
    NSString *_deadline;
    NSString *_filter;
    
    BOOL _isNoData;
    BOOL _isRefreshView;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;

    RKObjectManager *_actionObjectManager;
    RKManagedObjectRequestOperation *_actionRequest;

    RKObjectManager *_warehouseObjectManager;
    RKManagedObjectRequestOperation *_warehouseRequest;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationQueueAction;
    NSTimer *_timer;

    UIRefreshControl *_refreshControl;

    OrderTransaction *_selectedTransaction;
    NSMutableDictionary *_orderInProcess;
    NSIndexPath *_selectedIndexPath;
    
    NSInteger _numberOfProcessedOrder;
    
    NSArray *_selectedProducts;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@property (weak, nonatomic) IBOutlet UIButton *filterButton;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SalesNewOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isNoData = YES;
    _isRefreshView = NO;

    _page = 1;
    _limit = 6;
    _requestCount = 0;

    _deadline = @"";
    _filter = @"";
    
    _numberOfProcessedOrder = 0;
    
    _transactions = [NSMutableArray new];
    _paging = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _orderInProcess = [NSMutableDictionary new];
    _operationQueueAction = [NSOperationQueue new];
    
    
    self.title = @"Pesanan Baru";
    
    [TPAnalytics trackScreenName:@"Sales - New Order"];
    self.screenName = @"Sales - New Order";
    
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
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.tableHeaderView = _alertView;
    self.tableView.tableFooterView = _footerView;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"GothamBook" size:11],
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:_alertLabel.text
                                                                                    attributes:attributes];
    _alertLabel.attributedText = productNameAttributedText;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    [self configureRestKit];
    [self request];
    [self configureActionReskit];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(viewController:numberOfProcessedOrder:)]) {
        [self.delegate viewController:self numberOfProcessedOrder:_numberOfProcessedOrder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#ifdef NO_DATE_ENABLE
    return _isNoData ? 1 : _transactions.count;
#else
    return _isNoData ? 0 : _transactions.count;
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    OrderTransaction *transaction = [_transactions objectAtIndex:indexPath.row];

    cell.invoiceNumberLabel.text = transaction.order_detail.detail_invoice;

    if (transaction.order_payment.payment_process_day_left == 1) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:145.0/255.0
                                                                   blue:0.0/255.0
                                                                  alpha:1];
        cell.remainingDaysLabel.text = @"Besok";

    } else if (transaction.order_payment.payment_process_day_left == 0) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:59.0/255.0
                                                                   blue:48.0/255.0
                                                                  alpha:1];
        cell.remainingDaysLabel.text = @"Hari ini";

    } else if (transaction.order_payment.payment_process_day_left < 0) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:158.0/255.0
                                                                  green:158.0/255.0
                                                                   blue:158.0/255.0
                                                                  alpha:1];

        cell.automaticallyCanceledLabel.hidden = YES;

        cell.remainingDaysLabel.text = @"Expired";

        CGRect frame = cell.remainingDaysLabel.frame;
        frame.origin.y = 17;
        cell.remainingDaysLabel.frame = frame;
        
    } else {
        
        cell.remainingDaysLabel.text = [NSString stringWithFormat:@"%d Hari lagi",
                                        (int)transaction.order_payment.payment_process_day_left];
        
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
    cell.dueDateLabel.text = [NSString stringWithFormat:@"Batas Respon : %@", transaction.order_payment.payment_process_due_date];
    
    // Reset button style
    [cell.acceptButton.titleLabel setFont:[UIFont fontWithName:@"GothamBook" size:12]];
    [cell.acceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    [cell.rejectButton.titleLabel setFont:[UIFont fontWithName:@"GothamBook" size:12]];
    [cell.rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            [self configureRestKit];
            [self request];
        }
    }
}

#pragma mark - Action

- (void)tap:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    FilterNewOrderViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FilterNewOrderViewController"];
    controller.delegate = self;
    controller.dueDate = _deadline;
    controller.filter = _filter;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - Cell delegate

- (void)tableViewCell:(UITableViewCell *)cell acceptOrderAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTransaction *transaction = [_transactions objectAtIndex:indexPath.row];
    _selectedTransaction = [_transactions objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;

    if (transaction.order_payment.payment_process_day_left >= 0) {

        if (transaction.order_detail.detail_partial_order == 1) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Terima Pesanan"
                                                                message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"
                                                               delegate:self
                                                      cancelButtonTitle:@"Batal"
                                                      otherButtonTitles:@"Terima Pesanan", @"Terima Sebagian", nil];
            alertView.tag = 2;
            [alertView show];
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Terima Pesanan"
                                                                message:@"Apakah Anda yakin ingin menerima pesanan ini?"
                                                               delegate:self
                                                      cancelButtonTitle:@"Batal"
                                                      otherButtonTitles:@"Ya", nil];
            alertView.tag = 4;
            [alertView show];
        }
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pesanan Expired"
                                                            message:@"Pesanan ini telah melewati batas waktu respon (3 hari)"
                                                           delegate:self
                                                  cancelButtonTitle:@"Batal"
                                                  otherButtonTitles:@"Tolak Pesanan", nil];
        alertView.tag = 5;
        [alertView show];
        
    }
}

- (void)tableViewCell:(UITableViewCell *)cell rejectOrderAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTransaction *transaction = [_transactions objectAtIndex:indexPath.row];
    _selectedTransaction = [_transactions objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    if (transaction.order_detail.detail_partial_order == 1) {
    
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tolak Pesanan"
                                                            message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"
                                                           delegate:self
                                                  cancelButtonTitle:@"Batal"
                                                  otherButtonTitles:@"Tolak Pesanan", @"Terima Sebagian", nil];
        alertView.tag = 1;
        [alertView show];
        
    } else {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pilih Alasan Penolakan"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Batal"
                                                  otherButtonTitles:@"Pesanan barang habis", @"Barang tidak dapat dikirim", @"Lainnya", nil];
        alertView.tag = 3;
        [alertView show];

    }
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectPriceAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedTransaction = [_transactions objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;

    OrderDetailViewController *controller = [[OrderDetailViewController alloc] init];
    controller.transaction = [_transactions objectAtIndex:indexPath.row];
    controller.delegate = self;

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectUserAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedTransaction = [_transactions objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;

    NavigateViewController *controller = [NavigateViewController new];
    [controller navigateToProfileFromViewController:self withUserID:_selectedTransaction.order_customer.customer_id];
}

#pragma mark - Choose product delegate

- (void)didSelectProducts:(NSArray *)products
{
    _selectedProducts = products;
    
    [self requestActionType:@"reject"
                     reason:@"Persediaan barang habis"
                   products:products
            productQuantity:nil];
    
    for (int i = 0; i < products.count; i++) {
        TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
        networkManager.delegate = self;
        networkManager.tagRequest = i;
        [networkManager doRequest];
    }
}

#pragma mark - Reject explanation delegate

- (void)didFinishWritingExplanation:(NSString *)explanation
{
    [self requestActionType:@"reject"
                     reason:explanation
                   products:nil
            productQuantity:nil];
}


#pragma mark - Product quantity delegate

- (void)didUpdateProductQuantity:(NSArray *)productQuantity explanation:(NSString *)explanation
{
    [self configureActionReskit];
    [self requestActionType:@"partial"
                     reason:explanation
                   products:nil
            productQuantity:productQuantity];
}

#pragma mark - Filter delegate

- (void)didFinishFilterInvoice:(NSString *)invoice dueDate:(NSString *)dueDate
{
    [_transactions removeAllObjects];
    [_tableView reloadData];
    
    _tableView.tableFooterView = _footerView;
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    
    _isNoData = YES;
    _isRefreshView = NO;
        
    _page = 1;
    _limit = 6;
    _requestCount = 0;
    
    _filter = invoice;
    _deadline = dueDate;
    
    [self request];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {

        if (buttonIndex == 1) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pilih Alasan Penolakan"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Batal"
                                                      otherButtonTitles:@"Pesanan barang habis", @"Barang tidak dapat dikirim", @"Lainnya", nil];
            alertView.tag = 3;
            [alertView show];
            
        } else if (buttonIndex == 2) {

            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor whiteColor];
            ProductQuantityViewController *controller = [[ProductQuantityViewController alloc] init];
            OrderTransaction *order = [_transactions objectAtIndex:_selectedIndexPath.row];
            controller.products = order.order_products;
            controller.delegate = self;
            navigationController.viewControllers = @[controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];

        }
        
    } else if (alertView.tag == 2) {
        
        if (buttonIndex == 1) {
            
            [self requestActionType:@"accept" 
                             reason:nil
                           products:nil
                    productQuantity:nil];
            
        } else if (buttonIndex == 2) {

            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor whiteColor];
            ProductQuantityViewController *controller = [[ProductQuantityViewController alloc] init];
            OrderTransaction *order = [_transactions objectAtIndex:_selectedIndexPath.row];
            controller.products = order.order_products;
            controller.delegate = self;
            navigationController.viewControllers = @[controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];

        }

    } else if (alertView.tag == 3) {
        
        if (buttonIndex == 1) {
            
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.translucent = NO;
            ChooseProductViewController *controller = [[ChooseProductViewController alloc] init];
            controller.delegate = self;
            controller.products = _selectedTransaction.order_products;
            navigationController.viewControllers = @[controller];
            [self.navigationController presentViewController:navigationController
                                                    animated:YES
                                                  completion:nil];
            
        } else if (buttonIndex == 2) {
            
            [self requestActionType:@"reject"
                             reason:@"Barang tidak dapat dikirim"
                           products:_selectedTransaction.order_products
                    productQuantity:nil];
            
        } else if (buttonIndex == 3) {
            
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.translucent = NO;
            OrderRejectExplanationViewController *controller = [[OrderRejectExplanationViewController alloc] init];
            controller.delegate = self;
            navigationController.viewControllers = @[controller];
            [self.navigationController presentViewController:navigationController
                                                    animated:YES
                                                  completion:nil];
        
        }
        
    } else if (alertView.tag == 4) {
        if (buttonIndex == 1) {
            [self requestActionType:@"accept"
                             reason:nil
                           products:nil
                    productQuantity:nil];
        }
    } else if (alertView.tag == 5) {
        if (buttonIndex == 1) {
            [self requestActionType:@"reject"
                             reason:@"Order expired"
                           products:_selectedTransaction.order_products
                    productQuantity:nil];   
        }
    }
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
                                                       API_PAGING_URI_NEXT      : API_PAGING_URI_NEXT,
                                                       API_PAGING_URI_PREVIOUS  : API_PAGING_URI_PREVIOUS,
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
                                                             API_DETAIL_PRINT_ADDRESS_URI   : API_DETAIL_PRINT_ADDRESS_URI,
                                                             API_DETAIL_PDF                 : API_DETAIL_PDF,
                                                             API_DETAIL_ORDER_STATUS        : API_DETAIL_ORDER_STATUS,
                                                             API_DETAIL_FORCE_CANCEL        : API_DETAIL_FORCE_CANCEL,
                                                             API_DETAIL_PARTIAL_ORDER       : API_DETAIL_PARTIAL_ORDER,
                                                             API_DETAIL_DROPSHIP_NAME       : API_DETAIL_DROPSHIP_NAME,
                                                             API_DETAIL_DROPSHIP_TELP       : API_DETAIL_DROPSHIP_TELP,
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

    [orderHistoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_ORDER_HISTORY
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

- (void)request
{

    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_request.isExecuting) return;
    
    _requestCount++;
    
    self.tableView.tableFooterView = _footerView;
    [_activityIndicator startAnimating];

    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : API_GET_NEW_ORDER_KEY,
                            API_USER_ID_KEY          : [auth objectForKey:API_USER_ID_KEY],
                            API_DEADLINE_KEY         : _deadline,
                            API_STATUS_KEY           : _filter,
                            API_PAGE_KEY             : [NSNumber numberWithInteger:_page],
                            };
    
    NSLog(@"\n\n\n\n%@\n\n\n\n", param);
    
    if (_page >= 1 || _isRefreshView) {
    
        [_activityIndicator startAnimating];
        
        _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                        method:RKRequestMethodPOST
                                                                          path:API_NEW_ORDER_PATH
                                                                    parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            _isRefreshView = NO;
            [_refreshControl endRefreshing];
            
            [_timer invalidate];
            _timer = nil;
            
            [self requestSuccess:mappingResult withOperation:operation];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            _isRefreshView = NO;
            [_refreshControl endRefreshing];
            
            [_timer invalidate];
            _timer = nil;

            [self requestFailure:error];

        }];

        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                  target:self
                                                selector:@selector(cancel)
                                                userInfo:nil
                                                 repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

    }
}

- (void)requestFailure:(id)object
{
}

- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    Order *newOrder = [result objectForKey:@""];
    BOOL status = [newOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status)
    {
        [self requestProcess:object];
    }
    else
    {
        [self cancel];
        
        NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);

        if ([(NSError*)object code] == NSURLErrorCancelled && _requestCount < kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %ld =====",(long)_requestCount);
            [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            [self performSelector:@selector(request) withObject:nil  afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
    }
}

- (void)cancel
{
    [_request cancel];
    _request = nil;
    
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
    
    _tableView.tableFooterView = nil;
}

- (void)requestProcess:(id)object
{
    if (object && [object isKindOfClass:[RKMappingResult class]]) {
    
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        Order *newOrder = [result objectForKey:@""];
        
        if (newOrder.result.list.count > 0) {
            if (_page == 1) {
                _transactions = newOrder.result.list;
            } else {
                [_transactions addObjectsFromArray:newOrder.result.list];
            }
        } else {
            [_transactions removeAllObjects];
        }
        
        NSLog(@"\n\n\n%@\n\n\n", _transactions);
        
        _uriNext =  newOrder.result.paging.uri_next;
        
        NSURL *url = [NSURL URLWithString:newOrder.result.paging.uri_next];
        NSArray* query = [[url query] componentsSeparatedByString: @"&"];
        
        NSMutableDictionary *queries = [NSMutableDictionary new];
        
        for (NSString *keyValuePair in query)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            [queries setObject:value forKey:key];
        }
        
        _page = [[queries objectForKey:kTKPDDETAIL_APIPAGEKEY] integerValue];

        NSLog(@"next page : %ld",(long)_page);
        
        if (_transactions.count == 0) _activityIndicator.hidden = YES;
        
        _isNoData = NO;
        _timer = nil;
        
        if (_page == 0) {
            [_activityIndicator stopAnimating];
            _activityIndicator.hidden = YES;
            _tableView.tableFooterView = nil;
        }
        
        if (_transactions.count == 0) {
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 103);
            NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
            _tableView.tableFooterView = noResultView;
            _tableView.sectionFooterHeight = noResultView.frame.size.height;
        }
        
        [_tableView reloadData];
    }
}

#pragma mark - Reskit Actions

- (void)configureActionReskit
{
    _actionObjectManager =  [RKObjectManager sharedClient];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_actionObjectManager.HTTPClient setDefaultHeader:@"X-APP-VERSION" value:appVersion];

    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ActionOrder class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY              : kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY   : kTKPD_APISERVERPROCESSTIMEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY       : kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY        : kTKPD_APIERRORMESSAGEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ActionOrderResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APIISSUCCESSKEY   : kTKPD_APIISSUCCESSKEY,
                                                        }];
    
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

- (void)requestActionType:(NSString *)type reason:(NSString *)reason products:(NSArray *)products productQuantity:(NSArray *)productQuantity
{
    NSString *productIds = @"";
    if (products) {
        for (OrderProduct *product in products) {
            productIds = [NSString stringWithFormat:@"%@~%@", product.product_id, productIds];
        }
    }
    
    NSString *productQuantities = @"";
    if (productQuantity) {
        for (NSDictionary *quantity in productQuantity) {
            productQuantities = [NSString stringWithFormat:@"%@~%@*~*%@",
                                 [quantity objectForKey:@"order_detail_id"],
                                 [quantity objectForKey:@"product_quantity"],
                                 productQuantities];
        }
    }
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary *param = @{
                            API_ACTION_KEY           : API_PROCEED_ORDER_KEY,
                            API_ACTION_TYPE_KEY      : type,
                            API_USER_ID_KEY          : [[auth objectForKey:API_USER_ID_KEY] stringValue],
                            API_ORDER_ID_KEY         : _selectedTransaction.order_detail.detail_order_id,
                            API_REASON_KEY           : reason ?: @"",
                            API_LIST_PRODUCT_ID_KEY  : productIds ?: @"",
                            API_PRODUCT_QUANTITY_KEY : productQuantities ?: @"",
                            };

    _actionRequest = [_actionObjectManager appropriateObjectRequestOperationWithObject:self
                                                                                method:RKRequestMethodPOST
                                                                                  path:API_NEW_ORDER_ACTION_PATH
                                                                            parameters:[param encrypt]];
    
    NSLog(@"\n\n\n%@\n\n\n", _actionRequest);
    
    // Add information about which transaction is in processing and at what index path
    OrderTransaction *order = _selectedTransaction;
    
    NSIndexPath *indexPath = _selectedIndexPath;
    
    NSDictionary *object = @{@"order" : order, @"indexPath" : indexPath};
    NSString *key = order.order_detail.detail_order_id;
    [_orderInProcess setObject:object forKey:key];
    
    // Delete row for the object
    [_transactions removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(timeoutAtIndexPath:)
                                                    userInfo:@{@"orderId" : key}
                                                     repeats:NO];
    
    __weak typeof(self) wself = self;
    [_actionRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [wself actionRequestSuccess:mappingResult
                     withOperation:operation
                           orderId:key
                        actionType:type];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

        [wself actionRequestFailure:error orderId:key];
        [timer invalidate];

    }];
    
    [_operationQueueAction addOperation:_actionRequest];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)actionRequestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation orderId:(NSString *)orderId actionType:(NSString *)actionType
{
    NSDictionary *result = ((RKMappingResult *)object).dictionary;
    
    ActionOrder *actionOrder = [result objectForKey:@""];
    BOOL status = [actionOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status && [actionOrder.result.is_success boolValue]) {
        NSString *message;
        if ([actionType isEqualToString:@"accept"]) {
            message = @"Anda telah berhasil memproses transaksi.";
        } else if ([actionType isEqualToString:@"partial"]) {
            message = @"Anda telah berhasil memproses transaksi sebagian.";
        } else {
            message = @"Anda telah berhasil membatalkan transaksi.";
        }
        _numberOfProcessedOrder++;
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[message] delegate:self];
        [alert show];
        [_orderInProcess removeObjectForKey:orderId];

        if (_transactions.count == 0) {
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
            NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
            self.tableView.tableFooterView = noResultView;
        }
    
    } else if (actionOrder.message_error) {

        [self performSelector:@selector(restoreData:errorMessages:)
                   withObject:orderId
                   withObject:actionOrder.message_error];

    } else {
        NSLog(@"\n\nRequest Message status : %@\n\n", actionOrder.message_status);
        [self performSelector:@selector(restoreData:errorMessages:) withObject:orderId];
    }
}

- (void)actionRequestFailure:(id)object orderId:(NSString *)orderId
{
    NSLog(@"\n\nRequest error : %@\n\n", object);
    [self performSelector:@selector(restoreData:errorMessages:) withObject:orderId];
}

- (void)timeoutAtIndexPath:(NSTimer *)timer
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSString *orderId = [[timer userInfo] objectForKey:@"orderId"];
    [self performSelector:@selector(restoreData:errorMessages:) withObject:orderId];
}

- (void)reloadData
{
    [_tableView reloadData];
}

- (void)restoreData:(NSString *)orderId errorMessages:(NSArray *)errorMessages
{
    NSDictionary *dict = [_orderInProcess objectForKey:orderId];
    if (dict) {
        NSArray *messages;
        if ([errorMessages isKindOfClass:[NSArray class]]) {
            messages = messages?:@[@"Proses transaksi gagal."];
        } else {
            messages = @[@"Proses transaksi gagal."];
        }
        
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];

        OrderTransaction *order = [dict objectForKey:@"order"];
        NSIndexPath *objectIndexPath = [dict objectForKey:@"indexPath"];
        
        [_transactions insertObject:order atIndex:objectIndexPath.row];
        [_tableView insertRowsAtIndexPaths:@[objectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];

        [_orderInProcess removeObjectForKey:orderId];
    }
}

- (void)refreshData
{
    _page = 1;
    [self configureRestKit];
    [self request];
}

#pragma mark - Order detail delegate

- (void)didReceiveActionType:(NSString *)actionType
                      reason:(NSString *)reason
                    products:(NSArray *)products
             productQuantity:(NSArray *)productQuantity
{
    [self requestActionType:actionType
                     reason:reason
                   products:products
            productQuantity:productQuantity];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:1];
}

#pragma mark - Network manager

- (NSDictionary *)getParameter:(int)tag {
    OrderProduct *product = [_selectedProducts objectAtIndex:tag];
    NSDictionary *parameter = @{
                                API_ACTION_KEY  : @"move_to_warehouse",
                                API_PRODUCT_ID  : product.product_id
                                };
    return parameter;
}

- (NSString *)getPath:(int)tag {
    return @"action/product.pl";
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    WarehouseResponse *response = [mappingResult.dictionary objectForKey:@""];
    return response.status;
}

- (id)getObjectManager:(int)tag {
    _warehouseObjectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[WarehouseResponse class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY,
                                                   kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSMESSAGEKEY]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[WarehouseResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *actionResponseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                        method:RKRequestMethodPOST
                                                                                                   pathPattern:API_PRODUCT_ACTION_PATH
                                                                                                       keyPath:@""
                                                                                                   statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_warehouseObjectManager addResponseDescriptor:actionResponseDescriptorStatus];

    return _warehouseObjectManager;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}

@end