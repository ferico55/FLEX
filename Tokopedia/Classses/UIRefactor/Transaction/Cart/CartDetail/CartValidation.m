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

@implementation CartValidation

+(BOOL)isValidInputVoucherCode:(NSString*)voucherCode
{
    BOOL isValid = YES;
    
    NSMutableArray *errorMessages = [NSMutableArray new];
    
//    NSString *voucherCode = [_dataInput objectForKey:API_VOUCHER_CODE_KEY];
    if (!(voucherCode) || [voucherCode isEqualToString:@""]) {
        isValid = NO;
        [errorMessages addObject:@"Masukkan kode voucher terlebih dahulu."];
    }
    
    if (!isValid) {
        [StickyAlertView showErrorMessage:errorMessages];
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
        [StickyAlertView showErrorMessage:errorMessage];
    }
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenCC{
    NSString *minimum = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentCC]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk kartu kredit adalah %@ .",minimum];
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
        [StickyAlertView showErrorMessage:errorMessage];
    }
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenKlikBCA{
    NSString *minimum = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentKlikBCA]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk KlikBCA adalah %@ .",minimum];
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
        [StickyAlertView showErrorMessage:errorMessage];
    }
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenIndomaret{
    NSString *minimum = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentIndomaret]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk Indomaret adalah %@ .",minimum];
}

+(NSInteger)minimumPaymentIndomaret{
    return 10000;
}

@end
