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
        [errorMessages addObject:ERRORMESSAGE_NULL_VOUCHER_CODE];
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
        [alert show];
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
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenCC{
    NSString *minimum = [[NSNumberFormatter IDRFormarter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentCC]]];
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
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return isvalid;
}

+(NSString *)errorMessageMinimumPaymenKlikBCA{
    NSString *minimum = [[NSNumberFormatter IDRFormarter] stringFromNumber:[NSNumber numberWithInteger:[CartValidation minimumPaymentKlikBCA]]];
    return [NSString stringWithFormat:@"Minimum pembayaran untuk kartu kredit adalah %@ .",minimum];
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
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
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
