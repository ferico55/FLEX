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
    
    RKObjectMapping *transactionMapping = [TransactionSummaryDetail mapping];
    RKObjectMapping *listMapping        = [TransactionCartList mapping];
    RKObjectMapping *ccMapping          = [CCData mapping];
    RKObjectMapping *veritransMapping   = [Veritrans mapping];
    RKObjectMapping *ccFeeMapping       = [CCFee mapping];
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
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"credit_card_data"
                                                                                  toKeyPath:@"credit_card_data"
                                                                                withMapping:ccMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"veritrans"
                                                                                  toKeyPath:@"veritrans"
                                                                                withMapping:veritransMapping]];
    if(_gatewayID == TYPE_GATEWAY_CC){
        [transactionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"credit_card"
                                                                                           toKeyPath:@"credit_card"
                                                                                         withMapping:ccFeeMapping]];
    }
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
