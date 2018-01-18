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
#import "TrackOrderViewController.h"
#import "Tokopedia-Swift.h"

@import SwiftOverlays;
@import NSAttributedString_DDHTML;

@interface TxOrderStatusDetailViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NavigateViewController *_navigate;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *askSellerButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *askSellerButtonHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *askSellerButtonTopConstraint;


@end

@implementation TxOrderStatusDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navigate = [NavigateViewController new];
    
    self.title = @"Detail Status";
    
    [self adjustButtonsView];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    _tableView.estimatedRowHeight = 125.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    if (!_order.canAskSeller) {
        _askSellerButton.enabled = NO;
        _askSellerButton.hidden = YES;
        _askSellerButtonHeightConstraint.constant = 0;
        _askSellerButtonTopConstraint.constant = 0;
        _toolbarHeightConstraint.constant = 51;
    }
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
    
    [headerView context].onTapTracking = ^(TxOrderStatusList *order){
        [weakSelf tapTrackOrder:order];
    };
    
    [headerView context].onTapReceivedOrder = ^(TxOrderStatusList *order){
        [weakSelf tapDone:order fromView:headerView];
    };
    
    [headerView context].onTapReorder = ^(TxOrderStatusList *order){
        [weakSelf tapReorderOrder:order];
    };
    
    [headerView context].onTapCancel = ^(TxOrderStatusList *order){
        [weakSelf tapRequestCancelOrder:order fromView:headerView];
    };
    
    [headerView context].onTapCancelReplacement = ^(TxOrderStatusList *order){
        [weakSelf tapCancelReplacement:order view:headerView];
    };
    
    [headerView context].onTapComplaint = ^(TxOrderStatusList *order) {
        [weakSelf tapComplaint:order fromView:headerView];
    };
    
    
    _tableView.tableHeaderView = headerView;

}

-(void)tapCancelReplacement:(TxOrderStatusList *)order view:(DetailOrderButtonsView *)view {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Batalkan Pencarian"
                                  message:@"Apakah Anda ingin melakukan pembatalan pencarian?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) wself = self;
    
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:@"Ya"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [wself doRequestCancelReplacementOrder:order view:view];
                              
                          }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Tidak"
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alert addAction:yes];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)doRequestCancelReplacementOrder:(TxOrderStatusList *)order view:(DetailOrderButtonsView *)view {
    __weak typeof(self) weakSelf = self;
    [RequestOrderAction cancelReplacementOrderId:order.order_detail.detail_order_id onSuccess:^{
        [view removeCancelReplacementButton];
        if (weakSelf.didCancelReplacement) {
            weakSelf.didCancelReplacement(order);
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(void)tapInvoiceOrder:(TxOrderStatusList*)order{
    [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:_order.order_detail.detail_pdf_uri];
}

-(void)tapComplaintNotReceivedOrder:(TxOrderStatusList*)order fromView:(DetailOrderButtonsView*)view{
    [self createComplainOrder:order isReceived:NO];
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
        [weakSelf createComplainOrder:order isReceived:YES];
    };
    
    confirmationAlert.didOK = ^{
        [AnalyticsManager moEngageTrackEventWithName:@"Shipping_Received_Confirmation" attributes:@{@"is_received" : @(YES)}];
        [AnalyticsManager trackEventName:@"clickReceived" category:GA_EVENT_CATEGORY_RECEIVED action:GA_EVENT_ACTION_CLICK label:@"Confirmation"];
        [weakSelf doRequestFinishOrder:order fromView:view];
    };
    
    [confirmationAlert show];
}

- (void)tapDone:(TxOrderStatusList *)order fromView:(DetailOrderButtonsView *)view {
    __weak typeof(self) weakSelf = self;
    
    NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringFromHTML:order.order_detail.detail_finish_popup_msg normalFont:[UIFont largeTheme] boldFont:[UIFont largeThemeMedium] italicFont:[UIFont largeTheme]]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:order.order_detail.detail_finish_popup_title
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *receivedAction = [UIAlertAction actionWithTitle:@"Selesai"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [AnalyticsManager trackEventName:@"clickReceived" category:GA_EVENT_CATEGORY_RECEIVED action:GA_EVENT_ACTION_CLICK label:@"Confirmation"];
                                                               [weakSelf doRequestFinishOrder:order fromView:view];
                                                           }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Kembali"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertController addAction:receivedAction];
    [alertController addAction:cancelAction];
    [alertController setValue:messageString forKey:@"attributedMessage"];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)tapComplaint:(TxOrderStatusList *)order fromView:(DetailOrderButtonsView *)view {
    __weak typeof(self) weakSelf = self;
    NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:@"Apakah pesanan dari "];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:15];
    NSAttributedString *boldToko = [[NSAttributedString alloc] initWithString:order.order_shop.shop_name attributes:@{NSFontAttributeName: boldFont}];
    [messageString appendAttributedString:boldToko];
    [messageString appendAttributedString:[[NSAttributedString alloc] initWithString:@" berkendala?"]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Komplain"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Batal"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    UIAlertAction *receivedAction = [UIAlertAction actionWithTitle:@"Ya"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [weakSelf createComplainOrder:order isReceived:YES];
                                                           }];
    [alertController addAction:cancelAction];
    [alertController addAction:receivedAction];
    [alertController setValue:messageString forKey:@"attributedMessage"];
    [self presentViewController:alertController animated:YES completion:nil];
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
        [weakSelf showAlertForReview];
        [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil];
        
        [view removeAcceptButton];
        [view removeComplaintButton];
        
        if (weakSelf.didReceivedOrder) {
            weakSelf.didReceivedOrder(order);
        }
        
    } failure:^(NSError *error, TxOrderStatusList* order) {
        
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
        
        [weakSelf showAlertForReview];
        [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil];
        
        if (weakSelf.didReceivedOrder) {
            weakSelf.didReceivedOrder(order);
        }
        
        [view removeAcceptButton];
        [view removeComplaintButton];
        
    } failure:^(NSError *error, TxOrderStatusList* order) {

    }];
}


-(void)tapTrackOrder:(TxOrderStatusList *)order {
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

-(IBAction)tapAskSellerOrder:(id)sender {
    SendChatViewController *vc = [[SendChatViewController alloc] initWithUserID:nil shopID:_order.order_shop.shop_id name:_order.order_shop.shop_name imageURL:_order.order_shop.shop_pic invoiceURL:_order.order_detail.detail_pdf_uri productURL:nil source:@"tx_ask_seller"];
    [self.navigationController pushViewController:vc animated:YES];
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
                             style:UIAlertActionStyleCancel
                             handler:nil];

    [alert addAction:yes];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)doRequestReorder:(TxOrderStatusList*)order{
    _tableView.tableHeaderView.userInteractionEnabled = NO;
    [SwiftOverlays showCenteredWaitOverlay:self.view];
    __weak typeof(self) weakSelf = self;
    [RequestOrderAction fetchReorder:order success:^(TxOrderStatusList *order, TransactionActionResult *data) {
        
        TransactionCartViewController *vc = [TransactionCartViewController new];
        if (weakSelf.didReorder){
            weakSelf.didReorder(order);
        }
        [self.navigationController pushViewController:vc animated:YES completion:^{
            _tableView.tableHeaderView.userInteractionEnabled = YES;
            [SwiftOverlays removeAllOverlaysFromView:self.view];
        }];
        
    } failure:^(NSError *error, TxOrderStatusList *order) {
        
        _tableView.tableHeaderView.userInteractionEnabled = YES;
        [SwiftOverlays removeAllOverlaysFromView:self.view];
    }];
}

-(void)createComplainOrder:(TxOrderStatusList*)order isReceived:(BOOL)isReceived {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ResolutionCenterCreate" bundle:nil];
    CreateComplainViewController *viewController = (CreateComplainViewController*)[storyboard instantiateInitialViewController];
    viewController.order = order;
    [self.navigationController pushViewController:viewController animated:YES];
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

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)){
        DetailShipmentStatusCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.statusLabel.text];
    }
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
    
    NSString *status = history.history_buyer_status;
    status = [status stringByAppendingString:history.history_comments];
    
    [cell setStatusLabelText:status];
    
    [cell setColorThemeForActionBy:history.history_action_by];
    
    BOOL isLastRow = (indexPath.row == (_order.order_history.count-1));
    cell.lineHidden = isLastRow;

    cell.backgroundColor = cell.contentView.backgroundColor;
    return cell;
}

-(void)tapSeeComplaintOrder:(TxOrderStatusList *)order fromView:(DetailOrderButtonsView*)view{

    NSDictionary *queries = [NSDictionary dictionaryFromURLString:order.order_button.button_res_center_url];
    
    NSString *resolutionID = [queries objectForKey:@"id"];
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *urlString = [auth webViewUrlFromUrl: [NSString stringWithFormat:@"%@/resolution/%@/mobile",[NSString mobileSiteUrl], resolutionID]];

    WKWebViewController *vc = [[WKWebViewController alloc] initWithUrlString: urlString];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tapDetailTransaction:(id)sender {
    TxOrderTransactionDetailViewController *vc = [TxOrderTransactionDetailViewController new];
    vc.order = _order;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
