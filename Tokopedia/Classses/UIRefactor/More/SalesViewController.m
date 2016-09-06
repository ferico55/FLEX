//
//  PaymentViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SalesViewController.h"
#import "SalesNewOrderViewController.h"
#import "ShipmentConfirmationViewController.h"
#import "ShipmentStatusViewController.h"
#import "SalesTransactionListViewController.h"
#import "NotificationManager.h"

@interface SalesViewController ()
<
    NotificationManagerDelegate,
    NewOrderDelegate,
    ShipmentConfirmationDelegate
>
{
    NotificationManager *_notificationManager;
}

@property (weak, nonatomic) IBOutlet UILabel *orderCountValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipmentConfirmationValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipmentStatusValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipmentConfirmationLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipmentStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionListLabel;

@property (weak, nonatomic) IBOutlet UIView *orderView;
@property (weak, nonatomic) IBOutlet UIView *shipmentConfirmationView;
@property (weak, nonatomic) IBOutlet UIView *shipmentStatusView;
@property (weak, nonatomic) IBOutlet UIView *transactionListView;

@end

@implementation SalesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setValues];
    [Localytics triggerInAppMessage:@"Penjualan Screen"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [TPAnalytics trackScreenName:@"Sales Page"];
    self.screenName = @"Sales Page";
    
    self.hidesBottomBarWhenPushed = YES;    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _notificationManager = [NotificationManager new];
    [_notificationManager initNotificationRequest];
    _notificationManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)newOrderDidTap:(id)sender {
    SalesNewOrderViewController *controller = [[SalesNewOrderViewController alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)shipmentConfirmationDidTap:(id)sender {
    ShipmentConfirmationViewController *controller = [[ShipmentConfirmationViewController alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)shipmentStatusDidTap:(id)sender {
    ShipmentStatusViewController *controller = [[ShipmentStatusViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)listTransactionDidTap:(id)sender {
    SalesTransactionListViewController *controller = [SalesTransactionListViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setValues
{
    _orderCountValueLabel.text = _notification.result.sales.sales_new_order?:@"0";
    _shipmentStatusValueLabel.text = _notification.result.sales.sales_shipping_status?:@"0";
    _shipmentConfirmationValueLabel.text = _notification.result.sales.sales_shipping_confirm?:@"0";
}

#pragma mark - Notification Manager Delegate

- (void)didReceiveNotification:(Notification *)notification
{
    _notification = notification;
    [self setValues];
}

#pragma mark - Delegate

- (void)viewController:(UIViewController *)viewController numberOfProcessedOrder:(NSInteger)totalOrder
{
    if ([viewController isKindOfClass:[SalesNewOrderViewController class]]) {
        NSInteger salesNewOrder = [_notification.result.sales.sales_new_order integerValue];
        _notification.result.sales.sales_new_order = [NSString stringWithFormat:@"%@",
                                                      [NSNumber numberWithInteger:(salesNewOrder - totalOrder)]];
        [self setValues];
    } else if ([viewController isKindOfClass:[ShipmentConfirmationViewController class]]) {
        NSInteger shipmentConfirmation = [_notification.result.sales.sales_shipping_confirm integerValue];
        _notification.result.sales.sales_shipping_confirm = [NSString stringWithFormat:@"%@",
                                                             [NSNumber numberWithInteger:(shipmentConfirmation - totalOrder)]];
        [self setValues];
    }
}

@end
