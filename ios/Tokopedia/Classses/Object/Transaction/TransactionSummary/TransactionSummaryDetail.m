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
    NSArray *keys = @[
                      @"voucher_amount_idr",
                      @"deposit_after",
                      @"grand_total",
                      @"payment_left_idr",
                      @"confirmation_id",
                      @"step",
                      @"deposit_left",
                      @"data_partial",
                      @"use_deposit",
                      @"payment_id",
                      @"use_otp",
                      @"now_time",
                      @"emoney_code",
                      @"unik",
                      @"grand_total_idr",
                      @"deposit_amount_idr",
                      @"ga_data",
                      @"discount_gateway_idr",
                      @"user_deposit_idr",
                      @"msisdn_verified",
                      @"gateway",
                      @"conf_code",
                      @"dropship_list",
                      @"conf_due_date",
                      @"token",
                      @"processing",
                      @"grand_total_before_fee_idr",
                      @"discount_gateway",
                      @"gateway_name",
                      @"status_unik",
                      @"user_deposit",
                      @"lock_mandiri",
                      @"deposit_amount",
                      @"voucher_amount",
                      @"grand_total_before_fee",
                      @"conf_code_idr",
                      @"payment_left",
                      @"transaction_code",
                      @"bri_website_link",
                      @"klikbca_user",
                      @"lp_amount_idr",
                      @"lp_amount",
                      @"cashback_idr",
                      @"cashback"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"carts" toKeyPath:@"carts" withMapping:[TransactionCartList mapping]];
    [mapping addPropertyMapping:relMapping];
    
    RKRelationshipMapping *relInstallmentMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"installment_bank_option" toKeyPath:@"installment_bank_option" withMapping:[InstallmentBank mapping]];
    [mapping addPropertyMapping:relInstallmentMapping];
        
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"indomaret" toKeyPath:@"indomaret" withMapping:[IndomaretData mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"bca_param" toKeyPath:@"bca_param" withMapping:[TransactionSummaryBCAParam mapping]]];
    
    return mapping;
}


@end
