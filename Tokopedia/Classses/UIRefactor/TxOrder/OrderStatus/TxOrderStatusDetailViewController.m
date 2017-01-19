//
//  TxOrderStatusDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_tx_order.h"

#import "TransactionAction.h"

#import "TxOrderStatusDetailViewController.h"

#import "NavigateViewController.h"

#import "TxOrderTransactionDetailViewController.h"
#import "TrackOrderViewController.h"

#import "DetailShipmentStatusCell.h"
#import "InboxResolutionCenterOpenViewController.h"
#import "TransactionCartViewController.h"

#import "RequestResolutionData.h"
#import "RequestOrderData.h"
#import "DetailOrderButtonsView.h"
#import "SendMessageViewController.h"
#import "TrackOrderViewController.h"
#import "Tokopedia-Swift.h"
#import "ResolutionCenterCreateViewController.h"

@interface TxOrderStatusDetailViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NavigateViewController *_navigate;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TxOrderStatusDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navigate = [NavigateViewController new];
    
    self.title = @"Detail Status";
    
    [self adjustButtonsView];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:nil];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    _tableView.estimatedRowHeight = 125.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)adjustButtonsView{
    
    DetailOrderButtonsView *headerView = [[DetailOrderButtonsView alloc] initWithOrder:_order];
    CGRect headerFrame = CGRectMake(0, 0, self.view.bounds.size.width, 0);
    headerView.frame = headerFrame;
    [headerView sizeToFit];
    
    __weak typeof(self) weakSelf = self;
    
    [headerView context].onTapInvoice = ^(TxOrderStatusList *order){
        [weakSelf tapInvoiceOrder:order];
    };
    
    [headerView context].onTapSeeComplaint = ^(TxOrderStatusList *order){
        [weakSelf tapSeeComplaintOrder:order fromView:headerView];
    };
    
    [headerView context].onTapComplaintNotReceived = ^(TxOrderStatusList *order){
        [weakSelf tapComplaintNotReceivedOrder:order fromView:headerView];
    };
    
    [headerView context].onTapTracking = ^(TxOrderStatusList *order){
        [weakSelf tapTrackOrder:order];
    };
    
    [headerView context].onTapReceivedOrder = ^(TxOrderStatusList *order){
        [weakSelf tapConfirmDeliveryOrder:order fromView:headerView];
    };
    
    [headerView context].onTapReorder = ^(TxOrderStatusList *order){
        [weakSelf tapReorderOrder:order];
    };
    
    [headerView context].onTapCancel = ^(TxOrderStatusList *order){
        [weakSelf tapRequestCancelOrder:order fromView:headerView];
    };
    
    [headerView context].onTapAskSeller = ^(TxOrderStatusList *order){
        [weakSelf tapAskSellerOrder:order];
    };
    
    _tableView.tableHeaderView = headerView;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(void)tapInvoiceOrder:(TxOrderStatusList*)order{
    [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:_order.order_detail.detail_pdf_uri];
}

-(void)tapComplaintNotReceivedOrder:(TxOrderStatusList*)order fromView:(DetailOrderButtonsView*)view{
    [self createComplainOrder:order isReceived:NO fromView:view];
}

-(void)tapConfirmDeliveryOrder:(TxOrderStatusList*)order fromView:(DetailOrderButtonsView*)view
{
    OrderDeliveredConfirmationAlertView *confirmationAlert = [OrderDeliveredConfirmationAlertView newview];
    if (order.order_detail.detail_free_return == 1){
        confirmationAlert.title = @"Sudah Diterima";
        confirmationAlert.message = order.order_detail.detail_free_return_msg;
        confirmationAlert.isFreeReturn = YES;
    } else {
        confirmationAlert.title = [NSString stringWithFormat:ALERT_DELIVERY_CONFIRM_FORMAT,order.order_shop.shop_name];
        confirmationAlert.message = ALERT_DELIVERY_CONFIRM_DESCRIPTION;
        confirmationAlert.isFreeReturn = NO;
    }
    __weak typeof(self) weakSelf = self;
    confirmationAlert.didComplain = ^{
        [weakSelf createComplainOrder:order isReceived:YES fromView:view];
    };
    
    confirmationAlert.didOK = ^{
        [AnalyticsManager trackEventName:@"clickReceived" category:GA_EVENT_CATEGORY_RECEIVED action:GA_EVENT_ACTION_CLICK label:@"Confirmation"];
        [weakSelf doRequestFinishOrder:order fromView:view];
    };
    
    [confirmationAlert show];
}

#pragma mark - Request Delivery Finish Order
-(void)doRequestFinishOrder:(TxOrderStatusList*)order fromView:(DetailOrderButtonsView*)view{
    if ([order.type isEqualToString:ACTION_GET_TX_ORDER_DELIVER]) {
        [self confirmDeliveryOrderDeliver:order fromView:view];
    } else if ([order.type isEqualToString:ACTION_GET_TX_ORDER_STATUS]) {
        [self confirmDeliveryOrderStatus:order fromView:view];
    } else if ([order.type isEqualToString:ACTION_GET_TX_ORDER_LIST]) {
        if ([order fromShippingStatus]){
            [self confirmDeliveryOrderStatus:order fromView:view];
        } else {
            [self confirmDeliveryOrderDeliver:order fromView:view];
        }
    }
}

-(void)confirmDeliveryOrderStatus:(TxOrderStatusList*)order fromView:(DetailOrderButtonsView*)view{
    __weak typeof(self) weakSelf = self;
    [RequestOrderAction fetchConfirmDeliveryOrderStatus:order success:^(TxOrderStatusList *order, TransactionActionResult* data) {
        
        [AnalyticsManager localyticsTrackReceiveConfirmation:YES];
        [weakSelf showAlertForReview];
        [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil];
        
        [view removeAcceptButton];
        [view removeComplaintNotReceivedButton];
        
        if (weakSelf.didReceivedOrder) {
            weakSelf.didReceivedOrder(order);
        }
        
    } failure:^(NSError *error, TxOrderStatusList* order) {
        [AnalyticsManager localyticsTrackReceiveConfirmation:NO];
    }];
}

-(void)showAlertForReview{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:@"Transaksi Anda sudah selesai! Silakan berikan Rating & Review sesuai tingkat kepuasan Anda atas pelayanan toko. Terima kasih sudah berbelanja di Tokopedia!"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* OK = [UIAlertAction
                          actionWithTitle:@"OK"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [_navigate navigateToInboxReviewFromViewController:self withGetDataFromMasterDB:YES];
                          }];
    
    [alert addAction:OK];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)confirmDeliveryOrderDeliver:(TxOrderStatusList*)order fromView:(DetailOrderButtonsView*)view{
    
    __weak typeof(self) weakSelf = self;
    [RequestOrderAction fetchConfirmDeliveryOrderDeliver:order success:^(TxOrderStatusList *order, TransactionActionResult* data) {
        
        [AnalyticsManager localyticsTrackReceiveConfirmation:YES];
        [weakSelf showAlertForReview];
        [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil];
        
        if (weakSelf.didReceivedOrder) {
            weakSelf.didReceivedOrder(order);
        }
        
        [view removeAcceptButton];
        [view removeComplaintNotReceivedButton];
        
    } failure:^(NSError *error, TxOrderStatusList* order) {
        [AnalyticsManager localyticsTrackReceiveConfirmation:NO];

    }];
}


-(void)tapTrackOrder:(TxOrderStatusList*)order
{
    TrackOrderViewController *vc = [TrackOrderViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    vc.orderID = [order.order_detail.detail_order_id integerValue];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tapRequestCancelOrder:(TxOrderStatusList *)order fromView:(DetailOrderButtonsView*)view{
    __weak typeof(self) weakSelf = self;
    CancelOrderViewController *vc = [CancelOrderViewController new];
    vc.order = order;
    vc.didRequestCancelOrder = ^(TxOrderStatusList *order){
        if(weakSelf.didRequestCancel){
            weakSelf.didRequestCancel(order);
        }
        
        [view removeRequestCancelButton];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tapAskSellerOrder:(TxOrderStatusList *)order{
    
    SendMessageViewController *messageController = [SendMessageViewController new];
    messageController.data = @{
                               @"shop_id":order.order_shop.shop_id?:@"",
                               @"shop_name":order.order_shop.shop_name?:@""
                               };
    messageController.subject = order.order_detail.detail_invoice?:@"";
    messageController.message = [NSString stringWithFormat:@"INVOICE:\n%@\n\n\n",order.order_detail.detail_pdf_uri];
    [self.navigationController pushViewController:messageController animated:YES];
    
}

-(void)tapReorderOrder:(TxOrderStatusList*)order{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Pemesanan Ulang"
                                  message:@"Apakah Anda ingin melakukan pemesanan ulang terhadap produk ini ?"
                                  preferredStyle:UIAlertControllerStyleAlert];

    __weak typeof(self) wself = self;

    UIAlertAction* yes = [UIAlertAction
                         actionWithTitle:@"Ya"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [wself doRequestReorder:order];

                         }];

    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Tidak"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];

                             }];

    [alert addAction:yes];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)doRequestReorder:(TxOrderStatusList*)order{
    __weak typeof(self) weakSelf = self;
    [RequestOrderAction fetchReorder:order success:^(TxOrderStatusList *order, TransactionActionResult *data) {
        
        TransactionCartViewController *vc = [TransactionCartViewController new];
        if (weakSelf.didReorder){
            weakSelf.didReorder(order);
        }
        [self.navigationController pushViewController:vc animated:YES];
        
    } failure:^(NSError *error, TxOrderStatusList *order) {
        
    }];
}

-(void)createComplainOrder:(TxOrderStatusList*)order isReceived:(BOOL)isReceived fromView:(DetailOrderButtonsView*)headerView {
    ResolutionCenterCreateViewController *vc = [ResolutionCenterCreateViewController new];
    vc.order = order;
    vc.product_is_received = isReceived;
    
    __weak typeof(self) weakSelf = self;
    vc.didCreateComplaint = ^(TxOrderStatusList *order){
        [headerView removeComplaintNotReceivedButton];
        [headerView removeAcceptButton];
        if (weakSelf.didCreateComplaint) {
            weakSelf.didCreateComplaint(order);
        }
    };
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [navigationController.navigationBar setTranslucent:NO];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Purchase Detail Page"];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_order.order_history count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"DetailShipmentStatusCell";
    DetailShipmentStatusCell *cell = (DetailShipmentStatusCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DetailShipmentStatusCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    OrderHistory *history = [_order.order_history objectAtIndex:indexPath.row];
    
    [cell setSubjectLabelText:history.history_action_by];
    cell.dateLabel.text = history.history_status_date_full;
    
    NSString *status;
    if ([history.history_action_by isEqualToString:@"Buyer"]) {
        status = history.history_buyer_status;
    } else {
        NSRange range = [history.history_seller_status rangeOfString:@"Pesanan telah dikirim"];
        if(range.location != NSNotFound){
            status = [NSString stringWithFormat:@"%@\n\n%@",history.history_seller_status, _order.formattedStringRefNumber];
        }
        else
            status = history.history_seller_status;
        
    }
    if (![history.history_comments isEqualToString:@""]) {
        status = [status stringByAppendingString:[NSString stringWithFormat:@"\n\nKeterangan: \n%@", history.history_comments]];
    }
    
    [cell setStatusLabelText:status];
    
    [cell setColorThemeForActionBy:history.history_action_by];
    
    if (indexPath.row == (_order.order_history.count-1)) {
        [cell hideLine];
    }
    cell.backgroundColor = cell.contentView.backgroundColor;
    return cell;
}

-(void)tapSeeComplaintOrder:(TxOrderStatusList *)order fromView:(DetailOrderButtonsView*)view{

    NSDictionary *queries = [NSDictionary dictionaryFromURLString:order.order_button.button_res_center_url];
    
    NSString *resolutionID = [queries objectForKey:@"id"];
    
    ResolutionWebViewController *vc = [[ResolutionWebViewController alloc] initWithResolutionId:resolutionID];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tapDetailTransaction:(id)sender {
    TxOrderTransactionDetailViewController *vc = [TxOrderTransactionDetailViewController new];
    vc.order = _order;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
