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
#import "NavigateViewController.h"
#import "TokopediaNetworkManager.h"
#import "UITableView+IndexPath.h"
#import "NSURL+Dictionary.h"

#import "Order.h"
#import "OrderTransaction.h"
#import "string_order.h"
#import "detail.h"
#import "WarehouseResponse.h"

#import "StickyAlert.h"
#import "StickyAlertView.h"

#import "ActionOrder.h"

#import "OrderSellerShop.h"

#import "ProductRequest.h"
#import "RejectReasonViewController.h"

#import <BlocksKit/BlocksKit.h>
#import "UIAlertView+BlocksKit.h"

@interface SalesNewOrderViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIAlertViewDelegate,
    SalesOrderCellDelegate,
    ChooseProductDelegate,
    FilterDelegate,
    ProductQuantityDelegate,
    OrderDetailDelegate
>
{
    RKObjectManager *_actionObjectManager;
    RKManagedObjectRequestOperation *_actionRequest;

    RKObjectManager *_warehouseObjectManager;
    RKManagedObjectRequestOperation *_warehouseRequest;
    
    NSOperationQueue *_operationQueueAction;
}

@property (strong, nonatomic) NSMutableArray *orders;

// Parameters
@property NSInteger page;
@property NSInteger limit;
@property (strong, nonatomic) NSString *deadline;
@property (strong, nonatomic) NSString *filter;

@property (strong, nonatomic) NSURL *nextURL;

@property (strong, nonatomic) OrderTransaction *selectedOrder;
@property (strong, nonatomic) NSArray *selectedProducts;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property NSInteger numberOfProcessedOrder;

@property (strong, nonatomic) NSMutableDictionary *orderInProcess;

@property (strong, nonatomic) TokopediaNetworkManager *networkManager;
@property (strong, nonatomic) TokopediaNetworkManager *actionNetworkManager;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation SalesNewOrderViewController{
    BOOL _needToDoLazyCellRemoval;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Pesanan Baru";

    [TPAnalytics trackScreenName:@"Sales - New Order"];

    self.navigationItem.backBarButtonItem = self.backBarButton;
    self.navigationItem.rightBarButtonItem = self.filterBarButton;
    [_activityIndicator startAnimating];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;

    _actionNetworkManager = [TokopediaNetworkManager new];
    _actionNetworkManager.isUsingHmac = YES;

    _page = 1;
    _limit = 6;
    _deadline = @"";
    _filter = @"";
    
    _numberOfProcessedOrder = 0;
    
    _orders = [NSMutableArray new];
    _orderInProcess = [NSMutableDictionary new];
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    _tableView.tableHeaderView = _alertView;
    _tableView.tableFooterView = _footerView;
    
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    self.alertLabel.attributedText = self.alertAttributedString;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyRejectOperation) name:@"applyRejectOperation" object:nil];
    [self fetchLatestOrderData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_needToDoLazyCellRemoval){
        [self performSelector:@selector(removeFinishedCell) withObject:nil afterDelay:0.5];
        _needToDoLazyCellRemoval = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([_delegate respondsToSelector:@selector(viewController:numberOfProcessedOrder:)]) {
        [_delegate viewController:self numberOfProcessedOrder:_numberOfProcessedOrder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)applyRejectOperation{
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        _needToDoLazyCellRemoval = YES;
    }else{        
        [self performSelector:@selector(removeFinishedCell) withObject:nil afterDelay:0.5];
    }
}

-(void)removeFinishedCell{
    if(_selectedIndexPath != nil){
        [_orders removeObjectAtIndex:_selectedIndexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
        _selectedIndexPath = nil;
        
        StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:@[@"Anda berhasil membatalkan pesanan"] delegate:self];
        [alert show];
        
        if (_orders.count == 0) {
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
            NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
            _tableView.tableFooterView = noResultView;
        }
    }
}

#pragma mark - Bar button item

- (UIBarButtonItem *)backBarButton {
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
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

#pragma mark - Refresh control

- (UIRefreshControl *)refreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    return refreshControl;
}

#pragma mark - Note view

- (NSAttributedString *)alertAttributedString {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName: [UIColor blackColor],
        NSFontAttributeName: [UIFont microTheme],
        NSParagraphStyleAttributeName: style,
    };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_alertLabel.text
                                                                                    attributes:attributes];
    return attributedString;
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _orders.count;
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
    
    OrderTransaction *order = [_orders objectAtIndex:indexPath.row];

    cell.invoiceNumberLabel.text = order.order_detail.detail_invoice;

    if (order.order_payment.payment_process_day_left == 1) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:145.0/255.0
                                                                   blue:0.0/255.0
                                                                  alpha:1];
        cell.remainingDaysLabel.text = @"Besok";

    } else if (order.order_payment.payment_process_day_left == 0) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:59.0/255.0
                                                                   blue:48.0/255.0
                                                                  alpha:1];
        cell.remainingDaysLabel.text = @"Hari ini";

    } else if (order.order_payment.payment_process_day_left < 0) {
        
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
                                        (int)order.order_payment.payment_process_day_left];
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0
                                                                  green:121.0/255.0
                                                                   blue:255.0/255.0
                                                                  alpha:1];
    
    }
    
    cell.userNameLabel.text = order.order_customer.customer_name;
    cell.purchaseDateLabel.text = order.order_payment.payment_verify_date;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:order.order_customer.customer_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];

    [cell.userImageView setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           [cell.userImageView setImage:image];
                                           [cell.userImageView setContentMode:UIViewContentModeScaleAspectFill];
                                     } failure:nil];
    
    cell.paymentAmountLabel.text = order.order_detail.detail_open_amount_idr;
    cell.dueDateLabel.text = [NSString stringWithFormat:@"Batas Respon : %@", order.order_payment.payment_process_due_date];
    
    // Reset button style
    [cell.acceptButton.titleLabel setFont:[UIFont microTheme]];
    [cell.acceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    [cell.rejectButton.titleLabel setFont:[UIFont microTheme]];
    [cell.rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isLastIndexPath:indexPath] && _nextURL) {
        [self fetchLatestOrderData];
    }
}

#pragma mark - Action

- (void)didTapFilterButton:(UIBarButtonItem *)button {
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

- (void)tableViewCell:(UITableViewCell *)cell acceptOrderAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    if ([self isOrderNotExpired]) {
        if ([self isBuyerAcceptPartial]) {
            [self showAlertViewAcceptPartialConfirmation];
        } else {
            [self showAlertViewAcceptConfirmation];
        }
    } else {
        [self showAlertViewAcceptExpiredConfirmation];
    }
}

- (void)tableViewCell:(UITableViewCell *)cell rejectOrderAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    if ([self isBuyerAcceptPartial]) {
        [self showAlertViewRejectPartialConfirmation];
    } else {
        [self showRejectReason];
    }
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectPriceAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;

    OrderDetailViewController *controller = [[OrderDetailViewController alloc] init];
    controller.transaction = [_orders objectAtIndex:indexPath.row];
    controller.delegate = self;

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectUserAtIndexPath:(NSIndexPath *)indexPath {
    _selectedOrder = [_orders objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;

    NavigateViewController *controller = [NavigateViewController new];
    [controller navigateToProfileFromViewController:self withUserID:_selectedOrder.order_customer.customer_id];
}

-(void)showRejectReason{
    RejectReasonViewController *vc = [RejectReasonViewController new];
    vc.order = _selectedOrder;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [navigationController.navigationBar setTranslucent:NO];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Choose product delegate

- (void)didSelectProducts:(NSArray *)products {
    _selectedProducts = products;
    
    [self requestActionType:@"reject"
                     reason:@"Persediaan barang habis"
                   products:products
            productQuantity:nil];
    
    for (OrderProduct *product in products) {
        [ProductRequest moveProductToWarehouse:product.product_id setCompletionBlockWithSuccess:nil failure:nil];
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

- (void)didUpdateProductQuantity:(NSArray *)productQuantity explanation:(NSString *)explanation {
    [self requestActionType:@"partial"
                     reason:explanation
                   products:nil
            productQuantity:productQuantity];
}

#pragma mark - Filter delegate

- (void)didFinishFilterInvoice:(NSString *)invoice dueDate:(NSString *)dueDate {
    [_orders removeAllObjects];

    [_tableView reloadData];
    [_tableView setTableFooterView:nil];
    
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    
    _page = 1;
    _filter = invoice;
    _deadline = dueDate;
    
    [self fetchLatestOrderData];
}

#pragma mark - Alert view

- (void)showAlertViewAcceptConfirmation{
    __weak typeof(self) welf = self;
    UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"Terima Pesanan"
                                                       message:@"Apakah Anda yakin ingin menerima pesanan ini?"];
    [alert bk_setCancelButtonWithTitle:@"Batal" handler:^{
        //nope
    }];
    [alert bk_addButtonWithTitle:@"Terima Pesanan" handler:^{
        [welf requestActionType:@"accept" reason:nil products:nil productQuantity:nil];
    }];
    [alert show];
}

- (void)showAlertViewAcceptPartialConfirmation{
    __weak typeof(self) welf = self;
    UIAlertView *alert = [[UIAlertView alloc]bk_initWithTitle:@"Terima Pesanan" message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"];
    [alert bk_setCancelButtonWithTitle:@"Batal" handler:^{
        //nope
    }];
    [alert bk_addButtonWithTitle:@"Terima Pesanan" handler:^{
        [welf requestActionType:@"accept" reason:nil products:nil productQuantity:nil];
    }];
    [alert bk_addButtonWithTitle:@"Terima Sebagian" handler:^{
        [welf showManageProductQuantityPage];
    }];
    [alert show];
}

- (void)showAlertViewRejectPartialConfirmation{
    __weak typeof(self) welf = self;
    UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"Tolak Pesanan" message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"];
    [alert bk_setCancelButtonWithTitle:@"Batal" handler:^{
        //nope
    }];
    [alert bk_addButtonWithTitle:@"Tolak Pesanan" handler:^{
        [welf showRejectReason];
    }];
    [alert bk_addButtonWithTitle:@"Terima Sebagian" handler:^{
        [welf showManageProductQuantityPage];
    }];
    [alert show];
}

-(void)showAlertViewAcceptExpiredConfirmation{
    __weak typeof(self) welf = self;
    UIAlertView *alert = [[UIAlertView alloc]bk_initWithTitle:@"Pesanan Expired"
                                                      message:@"Pesanan ini telah melewati batas waktu respon (3 hari)"];
    [alert bk_setCancelButtonWithTitle:@"Batal" handler:^{
        //nope
    }];
    [alert bk_addButtonWithTitle:@"Tolak Pesanan" handler:^{
        [welf requestActionType:@"reject" reason:@"Order expired" products:_selectedOrder.order_products productQuantity:nil];
    }];
    [alert show];
}


- (void)showManageProductQuantityPage {
    ProductQuantityViewController *controller = [[ProductQuantityViewController alloc] init];
    OrderTransaction *order = [_orders objectAtIndex:_selectedIndexPath.row];
    controller.products = order.order_products;
    controller.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;

    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)showChooseAcceptedProductPage {
    ChooseProductViewController *controller = [[ChooseProductViewController alloc] init];
    controller.delegate = self;
    controller.products = _selectedOrder.order_products;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;

    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)showRejectOrderPage {
    OrderRejectExplanationViewController *controller = [[OrderRejectExplanationViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;

    [self.navigationController presentViewController:navigationController
                                            animated:YES
                                          completion:nil];
}

#pragma mark - Reskit methods

- (void)fetchLatestOrderData {
    _tableView.tableFooterView = _footerView;
    NSDictionary *parameters = @{
        @"deadline": _deadline,
        @"status": _filter,
        @"page": [NSNumber numberWithInteger:_page],
    };
    
    [_networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/myshop-order/get_order_new.pl"
                                     method:RKRequestMethodGET
                                  parameter:parameters
                                    mapping:[Order mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      Order *response = mappingResult.dictionary[@""];
                                      OrderResult *result = response.result;
                                      if ([response.status isEqualToString:@"OK"]) {
                                          if (_page == 1) {
                                              [_orders removeAllObjects];
                                          }
                                          [_orders addObjectsFromArray:result.list];
                                          if(_orders.count > 0){
                                              if (result.paging.uri_next) {
                                                  _nextURL = result.paging.uriNext;
                                                  if ([_nextURL.parameters objectForKey:@"page"]) {
                                                      _page = [_nextURL.parameters[@"page"] integerValue];
                                                  }
                                                  _tableView.tableFooterView = _footerView;
                                              } else {
                                                  _nextURL = nil;
                                                  _tableView.tableFooterView = nil;
                                              }
                                          }else{
                                              CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
                                              NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
                                              _tableView.tableFooterView = noResultView;
                                          }
                                          [_refreshControl endRefreshing];
                                          [_tableView reloadData];
                                      }else{
                                          StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Kendala pada server"] delegate:self];
                                          [alert show];
                                      }
                                  } onFailure:^(NSError *errorResult) {
                                      StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Kendala koneksi internet" ] delegate:self];
                                      [alert show];
                                  }];
    
}

#pragma mark - Reskit Actions

- (void)requestActionType:(NSString *)type
                   reason:(NSString *)reason
                 products:(NSArray *)products
          productQuantity:(NSArray *)productQuantity {

    NSString *productIds = @"";
    for (OrderProduct *product in products) {
        productIds = [NSString stringWithFormat:@"%@~%@", product.product_id, productIds];
    }

    NSString *productQuantities = @"";
    for (NSDictionary *quantity in productQuantity) {
        productQuantities = [NSString stringWithFormat:@"%@~%@*~*%@",
                             [quantity objectForKey:@"order_detail_id"],
                             [quantity objectForKey:@"product_quantity"],
                             productQuantities];
    }

    NSString *orderId = _selectedOrder.order_detail.detail_order_id;
    NSString *estimationShipping = _selectedOrder.order_last.last_est_shipping_left;
    
    NSDictionary *parameters = @{
        @"action_type": type,
        @"est_shipping": estimationShipping,
        @"list_product_id": productIds?:@"",
        @"order_id": orderId,
        @"qty_accept": productQuantities?:@"",
        @"reason": reason?:@"",
    };
    
    [_actionNetworkManager requestWithBaseUrl:[NSString v4Url]
                                             path:@"/v4/action/myshop-order/proceed_order.pl"
                                           method:RKRequestMethodPOST
                                        parameter:parameters
                                          mapping:[ActionOrder mapping]
                                        onSuccess:^(RKMappingResult *mappingResult,
                                                    RKObjectRequestOperation *operation) {
                                            [self didReceiveActionType:type orderId:orderId mappingResult:mappingResult];
                                        } onFailure:^(NSError *errorResult) {
                                            [self performSelector:@selector(restoreData:errorMessages:) withObject:orderId];
                                        }];
    
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
}

- (void)didReceiveActionType:(NSString *)actionType orderId:(NSString *)orderId mappingResult:(RKMappingResult *)mappingResult {
    ActionOrder *actionOrder = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [actionOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status && [actionOrder.result.is_success boolValue]) {
        
        _numberOfProcessedOrder++;
        [_orderInProcess removeObjectForKey:orderId];

        NSString *message;
        if ([actionType isEqualToString:@"accept"]) {
            message = @"Anda telah berhasil memproses transaksi.";
        } else if ([actionType isEqualToString:@"partial"]) {
            message = @"Anda telah berhasil memproses transaksi sebagian.";
        } else {
            message = @"Anda telah berhasil membatalkan transaksi.";
        }
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[message] delegate:self];
        [alert show];
        
        if (_orders.count == 0) {
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
            NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
            _tableView.tableFooterView = noResultView;
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

- (void)reloadData {
    [_tableView reloadData];
}

- (void)restoreData:(NSString *)orderId errorMessages:(NSArray *)errorMessages {
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
        
        [_orders insertObject:order atIndex:objectIndexPath.row];
        [_tableView insertRowsAtIndexPaths:@[objectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];

        [_orderInProcess removeObjectForKey:orderId];
    }
}

- (void)refreshData {
    _page = 1;
    _tableView.tableFooterView  = _footerView;
    [self fetchLatestOrderData];
}

- (BOOL)isOrderNotExpired{
    return _selectedOrder.order_payment.payment_process_day_left >= 0;
}

- (BOOL)isBuyerAcceptPartial{
    return _selectedOrder.order_detail.detail_partial_order == 1;
}

#pragma mark - Order detail delegate

- (void)didReceiveActionType:(NSString *)actionType
                      reason:(NSString *)reason
                    products:(NSArray *)products
             productQuantity:(NSArray *)productQuantity {
    [self requestActionType:actionType
                     reason:reason
                   products:products
            productQuantity:productQuantity];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:1];
}

@end