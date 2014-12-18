//
//  PaymentViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SalesViewController.h"

@interface SalesViewController ()

@property (weak, nonatomic) IBOutlet UILabel *orderCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipmentConfirmationLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipmentStatusLabel;

@property (weak, nonatomic) IBOutlet UIView *orderView;
@property (weak, nonatomic) IBOutlet UIView *shipmentConfirmationView;
@property (weak, nonatomic) IBOutlet UIView *shipmentStatusView;
@property (weak, nonatomic) IBOutlet UIView *transactionListView;

@end

@implementation SalesViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    _orderCountLabel.text = _notification.result.sales.sales_new_order?:@"0";
    _shipmentStatusLabel.text = _notification.result.sales.sales_shipping_status?:@"0";
    _shipmentConfirmationLabel.text = _notification.result.sales.sales_shipping_confirm?:@"0";
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)newOrderDidTap:(id)sender {
}

- (IBAction)shipmentConfirmationDidTap:(id)sender {
}

- (IBAction)shipmentStatusDidTap:(id)sender {
}

- (IBAction)listTransactionDidTap:(id)sender {
}


@end
