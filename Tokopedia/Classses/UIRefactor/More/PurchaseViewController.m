//
//  PurchaseViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "PurchaseViewController.h"

@interface PurchaseViewController ()
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
    _paymentConfirmationValueLabel.text = _notification.result.purchase.purchase_payment_confirm?:@"0";
    _orderStatusValueLabel.text = _notification.result.purchase.purchase_order_status?:@"0";
    _receiveConfirmationValueLabel.text = _notification.result.purchase.purchase_delivery_confirm?:@"0";
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1],
                                 };
    
    _paymentConfirmationLabel.attributedText = [[NSAttributedString alloc] initWithString:_paymentConfirmationLabel.text
                                                                               attributes:attributes];

    _orderStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:_orderStatusLabel.text
                                                                       attributes:attributes];

    _receiveStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:_receiveStatusLabel.text
                                                                         attributes:attributes];
    
    _transactionListLabel.attributedText = [[NSAttributedString alloc] initWithString:_transactionListLabel.text
                                                                           attributes:attributes];
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
