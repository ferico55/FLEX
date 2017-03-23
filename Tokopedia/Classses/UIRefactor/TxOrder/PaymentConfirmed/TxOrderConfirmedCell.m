//
//  TxOrderConfirmedCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedCell.h"
#import "TxOrderConfirmedList.h"

@interface TxOrderConfirmedCell()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UIButton *totalInvoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *imagePayementProofButton;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadProofButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actUploadProof;

@property (weak, nonatomic) IBOutlet UILabel *userBankLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieverNomorRekLabel;
@property (strong, nonatomic) IBOutlet UIView *buttonView;

@end

@implementation TxOrderConfirmedCell {
    TxOrderConfirmedList *_order;
}

#pragma mark - Factory methods

+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"TxOrderConfirmedCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)setupViewWithOrder:(TxOrderConfirmedList*)order {
    
    _order = order;
    
    _dateLabel.text = order.payment_date;
    _totalPaymentLabel.text = order.payment_amount;
    [_totalInvoiceButton setTitle:[NSString stringWithFormat:@"%@ Invoice", order.order_count] forState:UIControlStateNormal];
    _imagePayementProofButton.hidden = ([order.img_proof_url isEqualToString:@""]||order.img_proof_url == nil)?YES:NO;
    NSString *accountNumber = (![order.system_account_no isEqualToString:@""] && order.system_account_no != nil && ![order.system_account_no isEqualToString:@"0"])?order.system_account_no:@"";
    [_recieverNomorRekLabel setCustomAttributedText:[NSString stringWithFormat:@"%@ %@",order.bank_name, accountNumber]];
    _userBankLabel.text = order.userBankFullName;
    _uploadProofButton.hidden = ([[order.button objectForKey:@"button_upload_proof"] integerValue] != 1);
    _buttonView.hidden = (([[order.button objectForKey:@"button_upload_proof"] integerValue] != 1) && [order.system_account_no integerValue] == 0);
}

- (IBAction)tapInvoiceButton:(id)sender {
    if (_didTapInvoice) {
        _didTapInvoice(_order);
    }
}

- (IBAction)tapImgPaymentProof:(id)sender {
    if (_didTapPaymentProof) {
        _didTapPaymentProof(_order);
    }
}

- (IBAction)tapUploadProof:(id)sender {
    if (_didTapUploadProof) {
        _didTapUploadProof(_order);
    }
}

- (IBAction)tapEditPayment:(id)sender {
    if (_didTapEditPayment) {
        _didTapEditPayment(_order);
    }
}


@end
