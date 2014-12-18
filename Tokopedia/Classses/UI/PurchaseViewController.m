//
//  PurchaseViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "PurchaseViewController.h"

@interface PurchaseViewController ()
@property (weak, nonatomic) IBOutlet UILabel *paymentConfirmationLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveConfirmationLabel;

@property (weak, nonatomic) IBOutlet UIView *paymentConfirmationView;
@property (weak, nonatomic) IBOutlet UIView *orderStatusView;
@property (weak, nonatomic) IBOutlet UIView *receiveConfirmationView;
@property (weak, nonatomic) IBOutlet UIView *transactionListView;

@end

@implementation PurchaseViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    _paymentConfirmationLabel.text = _notification.result.purchase.purchase_payment_confirm?:@"0";
    _orderStatusLabel.text = _notification.result.purchase.purchase_order_status?:@"0";
    _receiveConfirmationLabel.text = _notification.result.purchase.purchase_delivery_confirm?:@"0";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)paymentConfirmationDidTap:(id)sender {
}

- (IBAction)orderStatusDidTap:(id)sender {
}

- (IBAction)receiveConfirmationDidTap:(id)sender {
}

- (IBAction)listTransactionDidTap:(id)sender {
}

@end
