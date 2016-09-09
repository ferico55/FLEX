//
//  PurchaseViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "PurchaseViewController.h"

#import "TxOrderTabViewController.h"
#import "TxOrderStatusViewController.h"
#import "NotificationManager.h"

@interface PurchaseViewController ()<NotificationManagerDelegate>
{
    NotificationManager *_notificationManager;
}

@property (weak, nonatomic) IBOutlet UILabel *paymentConfirmationValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveConfirmationValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *paymentConfirmationLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionListLabel;

@property (weak, nonatomic) IBOutlet UIView *paymentConfirmationView;
@property (weak, nonatomic) IBOutlet UIView *orderStatusView;
@property (weak, nonatomic) IBOutlet UIView *receiveConfirmationView;
@property (weak, nonatomic) IBOutlet UIView *transactionListView;

@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateValues:)
                                                name:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME
                                              object:nil];
    
    [self setValues];

    [Localytics triggerInAppMessage:@"Pembelian Screen"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [TPAnalytics trackScreenName:@"Purchase Page"];
    self.screenName = @"Purchase Page";
    
    self.hidesBottomBarWhenPushed = YES;
    
    _notificationManager = [NotificationManager new];
    [_notificationManager initNotificationRequest];
    _notificationManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)paymentConfirmationDidTap:(id)sender {
    TxOrderTabViewController *vc = [TxOrderTabViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)orderStatusDidTap:(id)sender {
    TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
    vc.action = @"get_tx_order_status";
    vc.viewControllerTitle = @"Status Pemesanan";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)receiveConfirmationDidTap:(id)sender {
    TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
    vc.action = @"get_tx_order_deliver";
    vc.viewControllerTitle = @"Konfirmasi Penerimaan";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)listTransactionDidTap:(id)sender {
    TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
    vc.action = @"get_tx_order_list";
    vc.viewControllerTitle = @"Daftar Transaksi";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)setValues
{
    NSInteger totalPaymentConfirmation = [_notification.result.purchase.purchase_payment_conf integerValue] +        [_notification.result.purchase.purchase_payment_confirm integerValue];
    
    _paymentConfirmationValueLabel.text = [NSString stringWithFormat:@"%zd",totalPaymentConfirmation]?:@"0";
    _orderStatusValueLabel.text = _notification.result.purchase.purchase_order_status?:@"0";
    _receiveConfirmationValueLabel.text = _notification.result.purchase.purchase_delivery_confirm?:@"0";
}

#pragma mark - Notification Manager Delegate

-(void)updateValues:(NSNotification*)notification
{
    _notificationManager = [NotificationManager new];
    [_notificationManager initNotificationRequest];
    _notificationManager.delegate = self;
    
    //NSDictionary* userInfo = notification.userInfo;
    //
    //NSString *paymentConfirmationValue = [userInfo objectForKey:DATA_PAYMENT_CONFIRMATION_COUNT_KEY]?:_notification.result.purchase.purchase_payment_conf;
    //_notification.result.purchase.purchase_payment_conf = paymentConfirmationValue;
    //
    //NSString *orderStatusValue = [userInfo objectForKey:DATA_STATUS_COUNT_KEY]?:_notification.result.purchase.purchase_order_status;
    //_notification.result.purchase.purchase_order_status = orderStatusValue;
    //
    //NSString *confirmDeliveryValue = [userInfo objectForKey:DATA_CONFIRM_DELIVERY_COUNT_KEY]?:_notification.result.purchase.purchase_delivery_confirm;
    //_notification.result.purchase.purchase_delivery_confirm = confirmDeliveryValue;
    
    [self setValues];
}

- (void)didReceiveNotification:(Notification *)notification
{
    _notification = notification;
    [self setValues];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
