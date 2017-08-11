//
//  EditShopTypeViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopTypeViewCell.h"

@implementation EditShopTypeViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)initializeInterfaceWithGoldMerchantStatus:(BOOL)isGoldMerchant{
    [self initializeInterfaceWithGoldMerchantStatus:isGoldMerchant expiryDate:@""];
}

-(void)initializeInterfaceWithGoldMerchantStatus:(BOOL)isGoldMerchant expiryDate:(NSString *)expiryDate{
    if(isGoldMerchant){
        [_goldMerchantBadgeView setHidden:NO];
        [_merchantStatusLabel setText:@"Gold Merchant"];
        [_merchantDescriptionLabel setText:[NSString stringWithFormat:@"Berlaku Sampai: %@", expiryDate]];
        [_merchantInfoButton setTitle:@"Perpanjang Keanggotaan" forState:UIControlStateNormal];
    }else{
        [_goldMerchantBadgeView setHidden:YES];
        [_merchantStatusLabel setText:@"Regular Merchant"];
        [_merchantDescriptionLabel setText:@"Anda belum berlangganan Gold Merchant"];
        [_merchantInfoButton setTitle:@"Tentang Gold Merchant" forState:UIControlStateNormal];
    }
}

- (IBAction)merchantInfoButtonTap:(id)sender {
    [_delegate merchantInfoButtonTapped];
}

@end
