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

#import "TxOrderTransactionDetailViewController.h"
#import "TrackOrderViewController.h"

#import "DetailShipmentStatusCell.h"
#import "InboxResolutionCenterOpenViewController.h"
#import "TransactionCartRootViewController.h"

#define TAG_ALERT_REORDER 10
#define TAG_ALERT_COMPLAIN 11
#define TAG_ALERT_CONFIRMATION 12

@interface TxOrderStatusDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *headerTwoButton;
@property (strong, nonatomic) IBOutlet UIView *headerOneButtonComplain;
@property (strong, nonatomic) IBOutlet UIView *headerOneButton;
@property (strong, nonatomic) IBOutlet UIView *headerViewWithoutButton;
@property (weak, nonatomic) IBOutlet UIButton *transactionDetailButton;
@property (strong, nonatomic) IBOutlet UIView *headerReorderView;
@property (weak, nonatomic) IBOutlet UILabel *invoiceLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TxOrderStatusDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.title = @"Detail Status";
    
    switch (_buttonHeaderCount) {
        case 0:
            _tableView.tableHeaderView = _headerViewWithoutButton;
            break;
        case 1:
            _tableView.tableHeaderView = _headerOneButton;
            break;
        case 2:
            _tableView.tableHeaderView = _headerTwoButton;
            break;
        default:
            break;
    }
    if (_isComplain) {
        _tableView.tableHeaderView = _headerOneButtonComplain;
    }
    if (_reOrder) {
        _tableView.tableHeaderView = _headerReorderView;
    }
    
    _invoiceLabel.text = _order.order_detail.detail_invoice;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    if (_buttonHeaderCount >0) {
        UIBarButtonItem *trackBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lacak" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [trackBarButtonItem setTintColor:[UIColor blackColor]];
        self.navigationItem.rightBarButtonItem = trackBarButtonItem;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.title = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_order.order_history count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderHistory *history = [_order.order_history objectAtIndex:indexPath.row];
    NSString *status;
    if ([history.history_action_by isEqualToString:@"Buyer"]) {
        status = history.history_buyer_status;
    } else {
        status = history.history_seller_status;
    }
    if (![history.history_comments isEqualToString:@"0"]) {
        status = [status stringByAppendingString:[NSString stringWithFormat:@"\n\nKeterangan: \n%@", history.history_comments]];
    }
    CGSize messageSize = [DetailShipmentStatusCell messageSize:status];
    return messageSize.height;
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
        status = history.history_seller_status;
    }
    if (![history.history_comments isEqualToString:@"0"]) {
        status = [status stringByAppendingString:[NSString stringWithFormat:@"\n\nKeterangan: \n%@", history.history_comments]];
    }
    [cell setStatusLabelText:status];
    
    [cell setColorThemeForActionBy:history.history_action_by];
    
    if (indexPath.row == (_order.order_history.count-1)) {
        [cell hideLine];
    }
    
    return cell;
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        TrackOrderViewController *vc = [TrackOrderViewController new];
        vc.orderID = [_order.order_detail.detail_order_id integerValue];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        UIButton *button = (UIButton *)sender;
        if (button.tag == 10) {
            //Confirm Delivery
            UIAlertView *alertConfirmation = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:ALERT_DELIVERY_CONFIRM_FORMAT,_order.order_shop.shop_name] message:@"Klik Selesai untuk menyelesaikan transaksi dan meneruskan dana ke penjual.\nKlik Komplain jika pesanan yang diterima berkendala (kurang/rusak/ lain-lain)." delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"Selesai",@"Komplain", nil];
            alertConfirmation.tag = TAG_ALERT_CONFIRMATION;
            [alertConfirmation show];
        }
        else if (button.tag == 11)
        {
            //Complain
            [self showAlertViewOpenComplain];
        }
        else if (button.tag == 12)
        {
            //lihat complain
        }
        else if (button.tag == 13)
        {
            //Pesan ulang
            UIAlertView *alertConfirmation = [[UIAlertView alloc]initWithTitle:ALERT_REORDER_TITLE
                                                                       message:ALERT_REORDER_DESCRIPTION
                                                                      delegate:self
                                                             cancelButtonTitle:@"Tidak"
                                                             otherButtonTitles:@"Ya", nil];
            alertConfirmation.tag = TAG_ALERT_REORDER;
            [alertConfirmation show];
        }
        else{
            //Transaction Detail
            TxOrderTransactionDetailViewController *vc = [TxOrderTransactionDetailViewController new];
            vc.order = _order;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

-(void)showAlertViewOpenComplain
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Buka Komplain" message:@"Apakah Anda sudah menerima barang yang dipesan?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Tidak", @"Ya", nil];
    alert.tag = TAG_ALERT_COMPLAIN;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_REORDER) {
        if (buttonIndex == 1) {
            [_delegate reOrder:_order atIndexPath:_indexPath];
        }
    }
    else if (alertView.tag == TAG_ALERT_COMPLAIN)
    {
        InboxResolutionCenterOpenViewController *vc = [InboxResolutionCenterOpenViewController new];
        if (buttonIndex == 0) {
            //Tidak Terima Barang
            vc.isGotTheOrder = NO;
        }
        else if (buttonIndex ==1)
        {
            //Terima barang
            vc.isGotTheOrder = YES;
            
        }
        vc.order = _order;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (alertView.tag == TAG_ALERT_CONFIRMATION)
    {
        switch (buttonIndex) {
            case 1://Selesai
            {
                [_delegate confirmDelivery:_order atIndexPath:_indexPath];
            }
                break;
            case 2://Complain
            {
                [self showAlertViewOpenComplain];
            }
                break;
            default:
                break;
        }
    }
}

@end
