//
//  TransactionBuy.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionBuy.h"
#import "string_transaction.h"

NSString *const TKPStatusBuyKey = @"status";
NSString *const TKPServerBuyKey = @"server_process_time";
NSString *const TKPResultBuyKey = @"result";

@implementation TransactionBuy

//#pragma mark - TKPRootObjectMapping methods
//+ (NSDictionary *)attributeMappingDictionary {
//    NSArray *keys = @[TKPStatusBuyKey,TKPServerBuyKey];
//    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
//}
//
//+ (RKObjectMapping *)mapping {
//    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
//    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
//    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPResultBuyKey toKeyPath:TKPResultBuyKey withMapping:[TransactionBuyResult mapping]]];
//    return mapping;
//}

-(RKObjectMapping *)mapping{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionBuy class]];
    [statusMapping addAttributeMappingsFromArray:@[
                                                   @"message_error",
                                                   @"message_status",
                                                   @"status",
                                                   @"server_process_time"
                                                   ]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionBuyResult class]];
    [resultMapping addAttributeMappingsFromArray:@[@"is_success",
                                                   @"link_mandiri"]];
    
    RKObjectMapping *systemBankMapping  = [TransactionSystemBank mapping];
    RKObjectMapping *transactionMapping = [RKObjectMapping mappingForClass:[TransactionSummaryDetail class]];
    [transactionMapping addAttributeMappingsFromArray:   @[
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
                                                           ]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"transaction" toKeyPath:@"transaction" withMapping:transactionMapping]];
    
    RKRelationshipMapping *systemBankRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"system_bank" toKeyPath:@"system_bank" withMapping:systemBankMapping];
    [resultMapping addPropertyMapping:systemBankRel];
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"carts" toKeyPath:@"carts" withMapping:[TransactionCartList mapping]];
    [transactionMapping addPropertyMapping:listRelationshipMapping];
    
    
    if(_gatewayID == TYPE_GATEWAY_CC){
        [transactionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"credit_card"
                                                                                           toKeyPath:@"credit_card"
                                                                                         withMapping:[CCFee mapping]]];
    }
    if(_gatewayID == TYPE_GATEWAY_INDOMARET){
        [transactionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"indomaret"
                                                                                           toKeyPath:@"indomaret"
                                                                                         withMapping:[IndomaretData mapping]]];
    }
    
    return statusMapping;
}

@end
