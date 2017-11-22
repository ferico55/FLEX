//
//  ShipmentStatusViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//


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
#import "ReactOrderManager.h"

@interface ShipmentStatusViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    ShipmentStatusCellDelegate,
    FilterShipmentStatusDelegate,
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
    
    _tableView.estimatedRowHeight = 218;
    _tableView.rowHeight = UITableViewAutomaticDimension;
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
    
    cell.order = order;
    
    if (order.order_detail.detail_ship_ref_num) {
        
        [cell hideAllButton];
        
        if (order.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED) {
            [cell showTrackButtonOnTap:^(OrderTransaction *order) {
                [self didTapTrackOrder:order];
            }];
            
            __weak typeof(self) wself = self;
            [cell showAskBuyerButtonOnTap:^(OrderTransaction *order) {
                [wself doAskBuyerWithOrder:order];
            }];
        } else if (order.order_detail.detail_order_status == ORDER_SHIPPING) {
            [cell showTrackButtonOnTap:^(OrderTransaction *order) {
                [self didTapTrackOrder:order];
            }];
            
            __weak typeof(self) wself = self;
            [cell showAskBuyerButtonOnTap:^(OrderTransaction *order) {
                [wself doAskBuyerWithOrder:order];
            }];
            
            if (order.order_shipping_retry) {
                [cell showRetryButtonOnTap:^(OrderTransaction *order) {
                    [self didTapRetryPickup:order];
                }];
            } else {
                if (order.order_is_pickup != 1) {
                    [cell showEditResiButtonOnTap:^(OrderTransaction *order) {
                        [self didTapReceiptOrder:order];
                    }];
                }
            }
        } else if (
            order.order_detail.detail_order_status == ORDER_SHIPPING_WAITING ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_TRACKER_INVALID ||
            order.order_detail.detail_order_status == ORDER_SHIPPING_REF_NUM_EDITED) {
            [cell showTrackButtonOnTap:^(OrderTransaction *order) {
                [self didTapTrackOrder:order];
            }];
            
            __weak typeof(self) wself = self;
            [cell showAskBuyerButtonOnTap:^(OrderTransaction *order) {
                [wself doAskBuyerWithOrder:order];
            }];
            
            if (order.order_shipping_retry == 1) {
                [cell showRetryButtonOnTap:^(OrderTransaction *order) {
                    [self didTapRetryPickup:order];
                }];
            } else {
                if (order.order_is_pickup != 1) {
                    [cell showEditResiButtonOnTap:^(OrderTransaction *order) {
                        [self didTapReceiptOrder:order];
                    }];
                }
            }
        }
    }
    
    if (order.order_history.count > 0) {
        OrderHistory *history = [order.order_history objectAtIndex:0];
        NSString *status = history.history_seller_status;
        NSArray *arrStatus = [status componentsSeparatedByString: @"\n"];
        if (arrStatus.count > 0) {
            [cell setStatusLabelText:arrStatus[0]];
        } else {
            [cell setStatusLabelText:@"-"];
        }
    } else {
        [cell setStatusLabelText:@"-"];
    }

    cell.invoiceDateLabel.text = order.order_payment.payment_verify_date;
    cell.finishLabel.text = order.deadline_string;
    cell.dateFinishLabel.text = order.deadline_label;
    cell.finishLabel.hidden = order.deadline_hidden;
    cell.dateFinishLabel.hidden = order.deadline_hidden;
    cell.finishLabel.backgroundColor = [UIColor fromHexString:order.order_deadline.deadline_color];
    
    if (order.driver_info!=nil && [order.driver_info.driver_name length]!=0) {
        DriverInfo *driver = order.driver_info;
        [cell.driverPhotoView setImageWithURL:[NSURL URLWithString: driver.driver_photo]];
        cell.driverNameLabel.text = driver.driver_name;
        NSString *license = [driver.license_number length]!=0 ? [@" | " stringByAppendingString:driver.license_number] : @"";
        cell.driverPhoneLicenseLabel.text = [driver.driver_phone stringByAppendingString:license];
        cell.driverInfoContainerView.hidden = false;
        [cell.driverInfoViewConst setConstant:93];
        
        __weak typeof(self) weakself = self;
        cell.onTapDriverInfo = ^(){
            UIAlertController *popup = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *call = [UIAlertAction
                                   actionWithTitle:@"Telepon"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", driver.driver_phone]];
                                       if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
                                           [[UIApplication sharedApplication] openURL:phoneURL];
                                       }
                                   }];
            
            UIAlertAction *message = [UIAlertAction
                                      actionWithTitle:@"Kirim Pesan"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          NSString *message = [NSString stringWithFormat:@"sms://%@", driver.driver_phone];
                                          NSURL *messageURL = [NSURL URLWithString:[message stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
                                          if ([[UIApplication sharedApplication] canOpenURL:messageURL]) {
                                              [[UIApplication sharedApplication] openURL:messageURL];
                                          }
                                      }];
            
            UIAlertAction *cancel = [UIAlertAction
                                     actionWithTitle:@"Batal"
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction * action) {
                                         [popup dismissViewControllerAnimated:YES completion:nil];
                                     }];
            
            [popup addAction: call];
            [popup addAction: message];
            [popup addAction: cancel];
            
            [weakself presentViewController:popup animated:YES completion:nil];
        };
    } else {
        cell.driverInfoContainerView.hidden = true;
        [cell.driverInfoViewConst setConstant:0];
    }

    return cell;
}

-(void)doAskBuyerWithOrder:(OrderTransaction*)order{
    SendChatViewController *vc = [[SendChatViewController alloc] initWithUserID:order.order_customer.customer_id shopID:nil name:order.order_customer.customer_name imageURL:order.order_customer.customer_image invoiceURL:order.order_detail.detail_pdf_uri productURL:nil source:@"tx_ask_buyer"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isLastIndexPath:indexPath] && self.nextURL) {
        self.tableView.tableFooterView = _footerView;
        [self fetchOrderData];
    } else {
        self.tableView.tableFooterView = nil;
    }
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


#pragma mark - Cell delegate

- (void)didTapTrackOrder:(OrderTransaction *)order{
    [AnalyticsManager trackEventName:@"clickStatus" category:GA_EVENT_CATEGORY_ORDER_STATUS action:GA_EVENT_ACTION_CLICK label:@"Track"];
    _selectedOrder = order;
    
    TrackOrderViewController *controller = [TrackOrderViewController new];
    controller.order = _selectedOrder;
    controller.hidesBottomBarWhenPushed = YES;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}   

- (void)didTapRetryPickup:(OrderTransaction *)order {
    _selectedOrder = order;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Konfirmasi Retry Pickup" message:@"Lakukan Retry Pickup?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ya" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [RetryPickupRequest retryPickupOrderWithOrderId:order.order_detail.detail_order_id onSuccess:^(V4Response<GeneralActionResult *> * _Nonnull data) {
            [self didReceiveResult:data];
        } onFailure:^{
            
        }];
        
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Batal" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:actionCancel];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)didTapReceiptOrder:(OrderTransaction *)order {
    _selectedOrder = order;
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];

    ChangeReceiptNumberViewController *controller = [ChangeReceiptNumberViewController new];
    controller.orderID = _selectedOrder.order_detail.detail_order_id;
    controller.receiptNumber = _selectedOrder.order_detail.detail_ship_ref_num;
    
    __weak typeof(self) wself = self;
    controller.didSuccessEditReceipt = ^(NSString *newReceipt){
        [wself didSuccessEditReceiptWithNewReceipt:newReceipt];
    };
    
    navigationController.viewControllers = @[controller];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(void)didSuccessEditReceiptWithNewReceipt:(NSString*)newReceipt{
    
    [AnalyticsManager trackEventName:@"clickStatus" category:GA_EVENT_CATEGORY_TRACKING action:GA_EVENT_ACTION_EDIT label:@"Receipt Number"];
    
    NSString *historyComments = [NSString stringWithFormat:@"Ubah dari %@ menjadi %@",
                                 _selectedOrder.order_detail.detail_ship_ref_num,
                                 newReceipt];
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatFull = [[NSDateFormatter alloc] init];
    [dateFormatFull setDateFormat:@"d MM yyyy HH:mm"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d/MM/yyyy HH:mm"];
    
    OrderHistory *newHistory = [OrderHistory new];
    newHistory.history_status_date = [dateFormat stringFromDate:now];
    newHistory.history_status_date_full = [dateFormatFull stringFromDate:now];
    newHistory.history_order_status = @"530";
    newHistory.history_comments = historyComments;
    newHistory.history_action_by = @"Seller";
    newHistory.history_buyer_status = @"Perubahan nomor resi pengiriman";
    newHistory.history_seller_status = @"Perubahan nomor resi pengiriman";
    
    NSMutableArray *history = [NSMutableArray arrayWithArray:_selectedOrder.order_history];
    [history insertObject:newHistory atIndex:0];
    _selectedOrder.order_detail.detail_ship_ref_num = newReceipt;
    _selectedOrder.order_history = history;
    
    [self.tableView reloadData];
}

- (void)didTapStatusAtIndexPath:(NSIndexPath *)indexPath {
    [AnalyticsManager trackEventName:@"clickStatus" category:GA_EVENT_CATEGORY_ORDER_STATUS action:GA_EVENT_ACTION_CLICK label:@"Invoice"];
    OrderTransaction *order = [self.orders objectAtIndex:indexPath.row];
    _selectedOrder = order;
    _selectedIndexPath = indexPath;
    
    [ReactOrderManager setCurrentOrder:_selectedOrder];
    NSString* urlString = [NSString stringWithFormat:@"tokopedia://order/detail/%@/2", _selectedOrder.order_detail.detail_order_id];
    [TPRoutes routeURL:[NSURL URLWithString: urlString]];
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

- (void) popUpMessagesClose:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController;
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Tutup" style:UIAlertActionStyleCancel handler:nil];
    alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)didReceiveResult:(V4Response<GeneralActionResult*> *)result {
    if ([result.data.is_success isEqualToString:@"1"]) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:result.message_status delegate:self];
        [alert show];
        _selectedOrder.order_shipping_retry = 0;
        [self.tableView reloadData];
        
    } else {
        NSString *title = result.message_error[0];
        NSString *message = result.message_error[1];
        [self popUpMessagesClose:title message:message];
    }
    
}

@end
