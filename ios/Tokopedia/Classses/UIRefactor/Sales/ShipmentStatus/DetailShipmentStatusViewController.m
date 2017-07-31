//
//  DetailShipmentStatusViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_order.h"

#import "ActionOrder.h"
#import "DetailShipmentStatusViewController.h"
#import "DetailShipmentStatusCell.h"
#import "OrderDetailViewController.h"
#import "ChangeReceiptNumberViewController.h"
#import "LabelMenu.h"
#import "StickyAlertView.h"
#import "NavigateViewController.h"

@interface DetailShipmentStatusViewController ()
<
    LabelMenuDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    OrderDetailDelegate
>
{
    RKObjectManager *_actionObjectManager;
    RKManagedObjectRequestOperation *_actionRequest;
    RKResponseDescriptor *_responseActionDescriptorStatus;
    
    NSOperationQueue *_operationQueue;
    
    NSArray *_history;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonTransactionDetail;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeReceiptButton;
@property (weak, nonatomic) IBOutlet UIView *receiptNumberView;
@property (weak, nonatomic) IBOutlet UIView *retryView;

@end

@implementation DetailShipmentStatusViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:nil
                                                                 action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;

    _buttonTransactionDetail.layer.cornerRadius = 2;
    
    _tableView.tableHeaderView = _topView;
    _tableView.estimatedRowHeight = 125.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    _invoiceNumberLabel.text = _order.order_detail.detail_invoice;
    _paymentMethodLabel.text = _order.order_payment.payment_gateway_name;
    labelReceiptNumber.text = _order.order_detail.detail_ship_ref_num;
    labelReceiptNumber.userInteractionEnabled = YES;
    labelReceiptNumber.delegate = self;
    [labelReceiptNumber addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    
    _operationQueue = [NSOperationQueue new];

    
    if (_is_allow_manage_tx && _order.order_detail.detail_ship_ref_num) {
        if (_order.order_detail.detail_order_status == ORDER_SHIPPING ||
            _order.order_detail.detail_order_status == ORDER_SHIPPING_WAITING ||
            _order.order_detail.detail_order_status == ORDER_SHIPPING_TRACKER_INVALID ||
            _order.order_detail.detail_order_status == ORDER_SHIPPING_REF_NUM_EDITED) {
            _changeReceiptButton.enabled = YES;
        } else {
            _changeReceiptButton.enabled = NO;
            _changeReceiptButton.layer.opacity = 0.5;
        }
    } else {
        _changeReceiptButton.enabled = NO;
        _changeReceiptButton.layer.opacity = 0.5;
    }
    
    if (_is_allow_manage_tx && _order.order_detail.detail_ship_ref_num) {
        if (_order.order_detail.detail_order_status >= ORDER_SHIPPING &&
            _order.order_detail.detail_order_status <= ORDER_SHIPPING_REF_NUM_EDITED) {
            _changeReceiptButton.enabled = YES;
        } else {
            _changeReceiptButton.enabled = NO;
        }
    } else {
        _changeReceiptButton.enabled = NO;
    }
    
    if (_order.order_is_pickup == 1) {
        _changeReceiptButton.hidden = YES;
    }
    
    
    _history = _order.order_history;
    [self hideRetry];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Shipment Status Detail Page"];
    self.title = @"Detail Status";

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            [AnalyticsManager trackEventName:@"clickStatus" category:GA_EVENT_CATEGORY_ORDER_STATUS action:GA_EVENT_ACTION_CLICK label:@"Detail"];
            self.title = @"";
            OrderDetailViewController *controller = [OrderDetailViewController new];
            controller.transaction = _order;
            controller.delegate = self;
            controller.onSuccessRetry = ^ (BOOL isSuccess) {
                if (isSuccess) {
                    [self hideRetry];
                    if (_onSuccessRetry) {
                        _onSuccessRetry(isSuccess);
                    }
                }
            };
            [self.navigationController pushViewController:controller animated:YES];

        } else if (button.tag == 2) {

            UINavigationController *navigationController = [[UINavigationController alloc] init];
            
            ChangeReceiptNumberViewController *controller = [ChangeReceiptNumberViewController new];
            controller.receiptNumber = _order.order_detail.detail_ship_ref_num;
            controller.orderID = _order.order_detail.detail_order_id;
            navigationController.viewControllers = @[controller];
            
            __weak typeof(self) wself = self;
            controller.didSuccessEditReceipt = ^(NSString *newReceipt){
                [wself didSuccessEditReceiptWithNewReceipt:newReceipt];
            };
            
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        
        } else if (button.tag == 3) {
            [AnalyticsManager trackEventName:@"clickTransaction" category:GA_EVENT_CATEGORY_TRANSACTION action:GA_EVENT_ACTION_VIEW label:@"Invoice"];
            [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:_order.order_detail.detail_pdf_uri];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _history.count;
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
    
    OrderHistory *history = [_history objectAtIndex:indexPath.row];
    
    [cell setSubjectLabelText:history.history_action_by];
    cell.dateLabel.text = history.history_status_date_full;
    
    NSString *status = [history.history_seller_status stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br><br>"];
    status = [status stringByAppendingString:history.history_comments];

    [cell setStatusLabelText:status];
    
    [cell setColorThemeForActionBy:history.history_action_by];
    
    BOOL isLastRow = (indexPath.row == (_order.order_history.count-1));
    cell.lineHidden = isLastRow;
    
    cell.backgroundColor = cell.contentView.backgroundColor;
    return cell;
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
                                                        kTKPD_APIERRORMESSAGEKEY        : kTKPD_APIERRORMESSAGEKEY
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

-(void)didSuccessEditReceiptWithNewReceipt:(NSString *)newReceipt{
    [AnalyticsManager trackEventName:@"clickStatus" category:GA_EVENT_CATEGORY_TRACKING action:GA_EVENT_ACTION_EDIT label:@"Receipt Number"];
    
    labelReceiptNumber.text = newReceipt;
    
    NSString *historyComments = [NSString stringWithFormat:@"Ubah dari %@ menjadi %@",
                                 _order.order_detail.detail_ship_ref_num,
                                 newReceipt];
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatFull = [[NSDateFormatter alloc] init];
    [dateFormatFull setDateFormat:@"d MM yyyy HH:mm"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d/MM/yyyy HH:mm"];
    
    OrderHistory *history = [OrderHistory new];
    history.history_status_date = [dateFormat stringFromDate:now];
    history.history_status_date_full = [dateFormatFull stringFromDate:now];
    history.history_order_status = @"530";
    history.history_comments = historyComments;
    history.history_action_by = @"Seller";
    history.history_buyer_status = @"Perubahan nomor resi pengiriman";
    history.history_seller_status = @"Perubahan nomor resi pengiriman";
    
    NSMutableArray *histories = [NSMutableArray arrayWithArray:_history];
    [histories insertObject:history atIndex:0];
    _history = histories;
    
    [self.tableView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(successChangeReceiptWithOrderHistory:)]) {
        _order.order_detail.detail_ship_ref_num = newReceipt;
        [self.delegate successChangeReceiptWithOrderHistory:history];
    }
}

#pragma mark - Method
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state==UIGestureRecognizerStateBegan) {
        UILabel *lblResi = (UILabel *)sender.view;
        [lblResi becomeFirstResponder];
        
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:lblResi.frame inView:lblResi.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

#pragma mark - LabelMenu Delegate
- (void)duplicate:(int)tag
{
    [UIPasteboard generalPasteboard].string = labelReceiptNumber.text;    
}

- (IBAction)actionRetryPickup:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Konfirmasi Retry Pickup" message:@"Lakukan Retry Pickup?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ya" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [RetryPickupRequest retryPickupOrderWithOrderId:_order.order_detail.detail_order_id onSuccess:^(V4Response<GeneralActionResult *> * _Nonnull data) {
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

-(void) hideRetry {
    if (_order.order_shipping_retry != 1) {
        _retryView.hidden = YES;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, _retryView.frame.size.height, 0);
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
        _order.order_shipping_retry = 0;
        [self hideRetry];
        
    } else {
        NSString *title = result.message_error[0];
        NSString *message = result.message_error[1];
        [self popUpMessagesClose:title message:message];
    }
    if (_onSuccessRetry) {
        _onSuccessRetry([result.data.is_success boolValue]);
    }
}

@end
