//
//  DetailShipmentStatusViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailShipmentStatusViewController.h"
#import "DetailShipmentStatusCell.h"
#import "OrderDetailViewController.h"

@interface DetailShipmentStatusViewController () <UITableViewDataSource, UITableViewDelegate, OrderDetailDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonTransactionDetail;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiptNumberLabel;

@end

@implementation DetailShipmentStatusViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:nil
                                                                 action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;

    _buttonTransactionDetail.layer.cornerRadius = 2;
    
    _tableView.tableHeaderView = _topView;
    
    _invoiceNumberLabel.text = _order.order_detail.detail_invoice;
    _paymentMethodLabel.text = _order.order_payment.payment_gateway_name;
    _receiptNumberLabel.text = _order.order_detail.detail_ship_ref_num;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Detail Status";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tap:(id)sender {
    self.title = @"";
    OrderDetailViewController *controller = [OrderDetailViewController new];
    controller.transaction = _order;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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

@end
