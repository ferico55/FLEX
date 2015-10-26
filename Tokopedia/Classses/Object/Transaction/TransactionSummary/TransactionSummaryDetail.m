//
//  TransactionSummaryDetail.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionSummaryDetail.h"
#import <objc/runtime.h>
#import "string_transaction.h"

@implementation TransactionSummaryDetail


NSString *const TkpCartSummary = @"carts";
//
//NSString *const TkpCartVoucherAmountIDR = @"voucher_amount_idr";
//NSString *const TkpCartDepositAfter     = @"deposit_after";
//NSString *const TkpCartGrandTotal       = @"grand_total";
//NSString *const TkpCartPaymentLeftIDR   = @"payment_left_idr";
//NSString *const TkpCartConfirmID        = @"confirmation_id";
//NSString *const TkpCartStep             = @"step";
//NSString *const TkpCartDepositLeft      = @"deposit_left";
//NSString *const TkpCartDataPartial      = @"data_partial";
//NSString *const TkpCartUseDeposite      = @"use_deposit";
//NSString *const TkpCartPaymentID        = @"payment_id";
NSString *const TkpCartBCAParam         = @"bca_param";
//NSString *const NSString *use_otp;
//NSString *const NSString *now_time;
//NSString *const NSString *emoney_code;
//NSString *const NSString *unik;
//NSString *const NSString *grand_total_idr;
//NSString *const NSString *deposit_amount_idr;
//NSString *const NSString *ga_data;
//NSString *const NSString *discount_gateway_idr;
//NSString *const NSString *user_deposit_idr;
//NSString *const NSString *msisdn_verified;
//NSString *const NSNumber *gateway;
//NSString *const NSString *conf_code;
//NSString *const NSDictionary *dropship_list;
//NSString *const NSString *conf_due_date;
//NSString *const NSString *token;
//NSString *const NSString *processing;
//NSString *const NSString *grand_total_before_fee_idr;
//NSString *const NSString *discount_gateway;
//NSString *const NSString *gateway_name;
//NSString *const NSString *status_unik;
//NSString *const NSString *user_deposit;
//NSString *const NSString *lock_mandiri;
//NSString *const NSString *deposit_amount;
//NSString *const NSString *voucher_amount;
//NSString *const NSString *grand_total_before_fee;
//NSString *const NSString *conf_code_idr;
//NSString *const NSString *payment_left;
//
NSString *const TkpCartCreditCard = @"credit_card";
//@property (nonatomic, strong) IndomaretData *indomaret;
//NSString *const NSString *klikbca_user;
//
//NSString *const NSString *lp_amount_idr;
//NSString *const NSString *lp_amount;
//NSString *const NSString *cashback_idr;
//NSString *const NSString *cashback;
//
//@property (nonatomic, strong) NSArray *installment_bank_option;

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[API_CONFIRMATION_CODE_KEY,
                      API_SUMMARY_GRAN_TOTAL_BEFORE_FEE_IDR_KEY,
                      API_PROCESSING_KEY,
                      API_DISCOUNT_GATEWAY_KEY,
                      API_USER_DEPOSIT_KEY,
                      API_STATUS_UNIK_KEY,
                      API_LOCK_MANDIRI_KEY,
                      API_DEPOSIT_AMOUNT_KEY,
                      API_VOUCHER_AMOUNT_KEY,
                      API_GRAND_TOTAL_BEFORE_FEE_KEY,
                      API_CONFIRMATION_CODE_IDR_KEY,
                      API_PAYMENT_LEFT_KEY,
                      API_VOUCHER_AMOUNT_IDR_KEY,
                      API_CONFIRMATION_DUE_DATE_KEY,
                      API_DEPOSIT_AFTER_KEY,
                      API_GRAND_TOTAL_KEY,
                      API_PAYMENT_LEFT_IDR_KEY,
                      API_CONFIRMATION_ID_KEY,
                      API_DEPOSIT_LEFT_KEY,
                      API_DATA_PARTIAL_KEY,
                      API_IS_USE_DEPOSIT_KEY,
                      API_PAYMENT_ID_KEY,
                      API_IS_USE_OTP_KEY,
                      API_NOW_DATE_KEY,
                      API_EMONEY_CODE_KEY,
                      API_UNIK_KEY,
                      API_GRAND_TOTAL_IDR_KEY,
                      API_DEPOSIT_AMOUNT_ID_KEY,
                      API_GA_DATA_KEY,
                      API_DISCOUNT_GATEWAY_IDR_KEY,
                      API_USER_DEFAULT_IDR_KEY,
                      API_MSISDN_VERIFIED_KEY,
                      API_GATEWAY_LIST_NAME_KEY,
                      API_GATEWAY_LIST_ID_KEY,
                      API_TOKEN_KEY,
                      API_STEP_KEY,
                      API_DROPSHIP_LIST_KEY,
                      @"klikbca_user",
                      @"cashback_idr",
                      @"cashback",
                      @"lp_amount_idr",
                      @"lp_amount"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
//    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TkpCartSummary toKeyPath:TkpCartSummary withMapping:[TransactionCartList mapping]]];
    return mapping;
}


@end
