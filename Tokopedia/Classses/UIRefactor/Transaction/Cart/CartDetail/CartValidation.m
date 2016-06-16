//
//  CartValidation.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CartValidation.h"
#import "NSNumberFormatter+IDRFormater.h"
#import "string_transaction.h"
#import "Tokopedia-Swift.h"

@implementation CartValidation

+(BOOL)isValidInputVoucherCode:(NSString*)voucherCode
{
    BOOL isValid = YES;
    
    NSMutableArray *errorMessages = [NSMutableArray new];
    
    if (!(voucherCode) || [voucherCode isEqualToString:@""]) {
        isValid = NO;
        [errorMessages addObject:@"Masukkan kode voucher terlebih dahulu."];
    }
    
    if (!isValid) {
//        [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:errorMessages]
//                                                 type:0
//                                             duration:4.0
//                                          buttonTitle:nil
//                                          dismissable:YES
//                                               action:nil];
    }
    
    return  isValid;
}


+(BOOL)isValidInputCCCart:(TransactionCartResult*)cart {
    BOOL isvalid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    if ([cart.grand_total integerValue] < [CartValidation minimumPaymentCC]) {
        [errorMessage addObject:[CartValidation errorMessageMinimumPaymenCC]];
        isvalid = NO;
    }
    
    if (!isvalid) {
        [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:errorMessage]
                                                 type:0
                                             duration:4.0
                                          buttonTitle:@"Belanja Lagi"
                                          dismissable:YES
                                               action:^{
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
                                               }];
    }
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenCC{
    NSString *minimum = [[NSNumberFormatter IDRFormarter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentCC]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk kartu kredit adalah %@.",minimum];
}

+(NSInteger)minimumPaymentCC{
    return 50000;
}

+(BOOL)isValidInputKlikBCACart:(TransactionCartResult*)cart {
    BOOL isvalid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    if ([cart.grand_total integerValue] < [CartValidation minimumPaymentKlikBCA]) {
        [errorMessage addObject:[CartValidation errorMessageMinimumPaymenKlikBCA]];
        isvalid = NO;
    }
    
    if (!isvalid) {
        [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:errorMessage]
                                                 type:0
                                             duration:4.0
                                          buttonTitle:@"Belanja Lagi"
                                          dismissable:YES
                                               action:^{
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
                                               }];
    }
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenKlikBCA{
    NSString *minimum = [[NSNumberFormatter IDRFormarter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentKlikBCA]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk Klik BCA adalah %@.",minimum];
}


+(NSInteger)minimumPaymentKlikBCA{
    return 50000;
}

+(BOOL)isValidInputIndomaretCart:(TransactionCartResult*)cart
{
    BOOL isvalid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    if ([cart.grand_total integerValue] <[CartValidation minimumPaymentIndomaret]) {
        [errorMessage addObject:[CartValidation errorMessageMinimumPaymenIndomaret]];
        isvalid = NO;
    }
    
    if (!isvalid) {
        [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:errorMessage]
                                                 type:0
                                             duration:4.0
                                          buttonTitle:@"Belanja Lagi"
                                          dismissable:YES
                                               action:^{
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
                                               }];
    }
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenIndomaret{
    NSString *minimum = [[NSNumberFormatter IDRFormarter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentIndomaret]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk kartu kredit adalah %@ .",minimum];
}

+(NSInteger)minimumPaymentIndomaret{
    return 10000;
}

@end
