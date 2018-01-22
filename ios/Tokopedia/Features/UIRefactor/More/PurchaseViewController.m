//
//  PurchaseViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "PurchaseViewController.h"

#import <Masonry/Masonry.h>
#import "TxOrderConfirmedViewController.h"
#import "TxOrderStatusViewController.h"
#import "Tokopedia-Swift.h"

@interface PurchaseViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NotificationManager *_notificationManager;
    NotificationData *_notification;
    UITableView *tableView;
}

@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Pembelian";
    
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
                                            selector:@selector(updateValues:)
                                                name:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(notificationLoaded:)
                                                name:@"NotificationLoaded"
                                              object:nil];
    
    _notificationManager = [NotificationManager sharedManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Purchase Page"];
    
    self.hidesBottomBarWhenPushed = YES;
    
    [_notificationManager loadNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)paymentConfirmationDidTap {
    TxOrderConfirmedViewController *vc = [TxOrderConfirmedViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)orderStatusDidTap{
    TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
    vc.action = @"get_tx_order_status";
    vc.viewControllerTitle = @"Status Pemesanan";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)receiveConfirmationDidTap{
    TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
    vc.action = @"get_tx_order_deliver";
    vc.viewControllerTitle = @"Konfirmasi Penerimaan";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)listTransactionDidTap {
    TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
    vc.action = @"get_tx_order_list";
    vc.viewControllerTitle = @"Daftar Transaksi";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
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
            cell.textLabel.text = @"Status Pembayaran";
            cell.detailTextLabel.text = _notification.purchase != nil && _notification.purchase.paymentConfirm > 0 ? [NSString stringWithFormat:@"%ld", _notification.purchase.paymentConfirm] : @"0";
            break;
        case 1:
            cell.textLabel.text = @"Status Pemesanan";
            cell.detailTextLabel.text = _notification.purchase != nil && _notification.purchase.orderStatus > 0 ? [NSString stringWithFormat:@"%ld", _notification.purchase.orderStatus] : @"0";
            break;
        case 2:
            cell.textLabel.text = @"Konfirmasi Penerimaan";
            cell.detailTextLabel.text = _notification.purchase != nil && _notification.purchase.deliveryConfirm > 0 ? [NSString stringWithFormat:@"%ld", _notification.purchase.deliveryConfirm] : @"0";
            break;
        case 3:
            cell.textLabel.text = @"Daftar Transaksi";
            cell.detailTextLabel.text = @"";
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self paymentConfirmationDidTap];
            break;
        case 1:
            [self orderStatusDidTap];
            break;
        case 2:
            [self receiveConfirmationDidTap];
            break;
        case 3:
            [self listTransactionDidTap];
            break;
            
        default:
            break;
    }
}


#pragma mark - Notification Manager Delegate

-(void)updateValues:(NSNotification*)notification
{
    [_notificationManager loadNotifications];
}

-(void)notificationLoaded:(NSNotification*)notification
{
    if (notification.userInfo != nil && [notification.userInfo objectForKey:@"notification"] != nil && [[notification.userInfo objectForKey:@"notification"] isKindOfClass:NotificationData.class]) {
        _notification = (NotificationData *)[notification.userInfo objectForKey:@"notification"];
        [tableView reloadData];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
