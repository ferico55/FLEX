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
#import "Tokopedia-Swift.h"

@interface SalesViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    NewOrderDelegate,
    ShipmentConfirmationDelegate
>
{
    NotificationManager *_notificationManager;
    NotificationData *_notification;
    UITableView *tableView;
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
    
    self.title = @"Penjualan";
    
    tableView = [UITableView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 64;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    tableView.backgroundColor = [UIColor tpBackground];
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(notificationLoaded:)
                                                name:@"NotificationLoaded"
                                              object:nil];
    
    _notificationManager = [NotificationManager sharedManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Sales Page"];
    
    self.hidesBottomBarWhenPushed = YES;    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_notificationManager loadNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)newOrderDidTap {
    [AnalyticsManager trackClickSales:@"New Order"];
    SalesNewOrderViewController *controller = [[SalesNewOrderViewController alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)shipmentConfirmationDidTap {
    [AnalyticsManager trackClickSales:@"Shipping"];
    ShipmentConfirmationViewController *controller = [[ShipmentConfirmationViewController alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)shipmentStatusDidTap {
    [AnalyticsManager trackClickSales:@"Status"];
    ShipmentStatusViewController *controller = [[ShipmentStatusViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)listTransactionDidTap {
    [AnalyticsManager trackClickSales:@"Transaction"];
    SalesTransactionListViewController *controller = [SalesTransactionListViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)itemReplacementDidTap {
    [AnalyticsManager trackEventName:@"clickPeluang" category:GA_EVENT_CATEGORY_REPLACEMENT action:GA_EVENT_ACTION_CLICK label:@"order peluang"];
    if(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad){
        ReplacementSplitViewController *controller = [ReplacementSplitViewController new];
        [self.navigationController pushViewController:controller animated:YES];
        
    } else {
        ReplacementListViewController *controller = [ReplacementListViewController new];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont title1Theme];
    cell.textLabel.textColor = [UIColor tpSecondaryBlackText];
    cell.detailTextLabel.font = [UIFont title1ThemeMedium];
    cell.detailTextLabel.textColor = [UIColor tpGreen];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Peluang";
            break;
        case 1:
            cell.textLabel.text = @"Pesanan Baru";
            cell.detailTextLabel.text = _notification.sales != nil && _notification.sales.newOrder > 0 ? [NSString stringWithFormat:@"%ld", _notification.sales.newOrder] : @"0";
            break;
        case 2:
            cell.textLabel.text = @"Konfirmasi Pengiriman";
            cell.detailTextLabel.text = _notification.sales != nil && _notification.sales.shippingConfirm > 0 ? [NSString stringWithFormat:@"%ld", _notification.sales.shippingConfirm] : @"0";
            break;
        case 3:
            cell.textLabel.text = @"Status Pengiriman";
            cell.detailTextLabel.text = _notification.sales != nil && _notification.sales.shippingStatus > 0 ? [NSString stringWithFormat:@"%ld", _notification.sales.shippingStatus] : @"0";
            break;
        case 4:
            cell.textLabel.text = @"Daftar Transaksi";
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self itemReplacementDidTap];
            break;
        case 1:
            [self newOrderDidTap];
            break;
        case 2:
            [self shipmentConfirmationDidTap];
            break;
        case 3:
            [self shipmentStatusDidTap];
            break;
        case 4:
            [self listTransactionDidTap];
            break;
            
        default:
            break;
    }
}

-(void)notificationLoaded:(NSNotification*)notification
{
    if (notification.userInfo != nil && [notification.userInfo objectForKey:@"notification"] != nil && [[notification.userInfo objectForKey:@"notification"] isKindOfClass:NotificationData.class]) {
        _notification = (NotificationData *)[notification.userInfo objectForKey:@"notification"];
        [tableView reloadData];
    }
}

#pragma mark - Delegate

- (void)viewController:(UIViewController *)viewController numberOfProcessedOrder:(NSInteger)totalOrder
{
    // do nothing
}

@end
