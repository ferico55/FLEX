//
//  TransactionCartCostView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartCostView.h"
#import "AlertInfoView.h"
#import "NSNumberFormatter+IDRFormater.h"

@implementation TransactionCartCostView

#pragma mark - Factory Method
+ (id)newview
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    for (id view in views) {
        if ([view isKindOfClass:[self class]]) {
            return view;
        }
    }
    return nil;
}
- (IBAction)tap:(id)sender {
    AlertInfoView *alertInfo = [AlertInfoView newview];
    alertInfo.text = @"Info Biaya Tambahan";
    alertInfo.detailText = @"Biaya tambahan termasuk biaya asuransi dan biaya administrasi pengiriman";
    [alertInfo show];
}

-(void)setViewModel:(CartModelView*)viewModel{
    self.biayaInsuranceLabel.text = ([viewModel.logiscticFee integerValue]==0)?@"Biaya Asuransi":@"Biaya Tambahan";
    self.infoButton.hidden = ([viewModel.logiscticFee integerValue]==0);
    [self.subtotalLabel setText:viewModel.totalProductPriceIDR animated:YES];
    NSInteger aditionalFeeValue = [viewModel.logiscticFee integerValue]+[viewModel.insuranceFee integerValue];
    NSString *formatAdditionalFeeValue = [[NSNumberFormatter IDRFormarter] stringFromNumber:@(aditionalFeeValue)];
    [self.insuranceLabel setText:formatAdditionalFeeValue animated:YES];
    [self.shippingCostLabel setText:viewModel.shippingRateIDR animated:YES];
    [self.totalLabel setText:viewModel.totalProductPriceIDR animated:YES];
}

@end
