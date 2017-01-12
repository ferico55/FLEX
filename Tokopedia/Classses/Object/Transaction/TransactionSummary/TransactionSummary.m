//
//  TransactionSummary.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionSummary.h"

#import "TransactionObjectMapping.h"

@implementation TransactionSummary

//+(NSDictionary *)attributeMappingDictionary
//{
//    NSArray *keys = @[@"message_error",
//                      @"message_status",
//                      @"status",
//                      @"server_process_time"];
//    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
//}
//
//+(RKObjectMapping*)mapping
//{
//    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
//    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
//    
//    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[TransactionSummaryResult mapping]]];
//
//    return mapping;
//}


-(RKObjectMapping *)mapping
{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionSummary class]];
    [statusMapping addAttributeMappingsFromArray:@[
                                                    @"message_error",
                                                    @"message_status",
                                                    @"status",
                                                    @"server_process_time"
                                                    ]];
     
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionSummaryResult class]];
    [resultMapping addAttributeMappingsFromArray:@[@"year_now"]];
        
    RKObjectMapping *transactionMapping = [RKObjectMapping mappingForClass:[TransactionSummaryDetail class]];
    [transactionMapping addAttributeMappingsFromArray:@[
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
    
    RKObjectMapping *listMapping        = [TransactionCartList mapping];
    RKObjectMapping *indomaretMapping   = [IndomaretData mapping];
    
    RKObjectMapping *installmentBankMapping =[InstallmentBank mapping];
    
    if(_gatewayID == TYPE_GATEWAY_BCA_CLICK_PAY){
        RKObjectMapping *BCAParamMapping = [TransactionSummaryBCAParam mapping];
        RKRelationshipMapping *bcaParamRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_BCA_PARAM_KEY
                                                                                         toKeyPath:API_BCA_PARAM_KEY
                                                                                       withMapping:BCAParamMapping];
        [transactionMapping addPropertyMapping:bcaParamRel];
    }
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_KEY
                                                                                  toKeyPath:API_TRANSACTION_SUMMARY_KEY
                                                                                withMapping:transactionMapping]];
    if(_gatewayID == TYPE_GATEWAY_INDOMARET){
        [transactionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"indomaret"
                                                                                           toKeyPath:@"indomaret"
                                                                                         withMapping:indomaretMapping]];
    }
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET
                                                                                                 toKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET
                                                                                               withMapping:listMapping];
    [transactionMapping addPropertyMapping:listRelationshipMapping];
    
    RKRelationshipMapping *installmentBankRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"installment_bank_option"
                                                                                                            toKeyPath:@"installment_bank_option"
                                                                                                          withMapping:installmentBankMapping];
    [transactionMapping addPropertyMapping:installmentBankRelationshipMapping];
    return statusMapping;
    
}

@end
