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
    
    if (!(voucherCode) || [voucherCode isEqualToString:@""]) {
        isValid = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddErrorMessage"
                                                            object:nil
                                                          userInfo:@{@"errorMessage" : @"Masukkan kode voucher terlebih dahulu.",
                                                                     @"buttonTitle" : @""}];
        
        [UIViewController showNotificationWithMessage:@"Masukkan kode voucher terlebih dahulu"
                                                 type:NotificationTypeError
                                             duration:4.0
                                          buttonTitle:nil
                                          dismissable:YES
                                               action:nil];
    }
    
    
    
    return isValid;
}


+(BOOL)isValidInputCCCart:(TransactionCartResult*)cart {
    BOOL isvalid = YES;
    if ([cart.grand_total integerValue] < [CartValidation minimumPaymentCC]) {
        isvalid = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddErrorMessage"
                                                            object:nil
                                                          userInfo:@{@"errorMessage" : [CartValidation errorMessageMinimumPaymenCC],
                                                                     @"buttonTitle" : @"Belanja Lagi"}];
    }
    
    
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenCC{
    NSString *minimum = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentCC]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk kartu kredit adalah %@.",minimum];
}

+(NSInteger)minimumPaymentCC{
    return 50000;
}

+(BOOL)isValidInputKlikBCACart:(TransactionCartResult*)cart {
    BOOL isvalid = YES;
    if ([cart.grand_total integerValue] < [CartValidation minimumPaymentKlikBCA]) {
        isvalid = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddErrorMessage"
                                                            object:nil
                                                          userInfo:@{@"errorMessage" : [CartValidation errorMessageMinimumPaymenKlikBCA],
                                                                     @"buttonTitle" : @"Belanja Lagi"}];
    }
    
    
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenKlikBCA{
    NSString *minimum = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentKlikBCA]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk KlikBCA adalah %@.",minimum];
}


+(NSInteger)minimumPaymentKlikBCA{
    return 50000;
}

+(BOOL)isValidInputIndomaretCart:(TransactionCartResult*)cart
{
    BOOL isvalid = YES;
    if ([cart.grand_total integerValue] <[CartValidation minimumPaymentIndomaret]) {
        isvalid = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddErrorMessage"
                                                            object:nil
                                                          userInfo:@{@"errorMessage" : [CartValidation errorMessageMinimumPaymenIndomaret],
                                                                     @"buttonTitle" : @"Belanja Lagi"}];
    }
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenIndomaret{
    NSString *minimum = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentIndomaret]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk Indomaret adalah %@.",minimum];
}

+(NSInteger)minimumPaymentIndomaret{
    return 10000;
}

@end
