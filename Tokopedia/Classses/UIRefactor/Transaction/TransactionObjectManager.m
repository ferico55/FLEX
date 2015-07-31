//
//  TransactionObjectManager.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionObjectManager.h"

#import "TransactionObjectMapping.h"

@interface TransactionObjectManager ()
{
    TransactionObjectMapping *_mapping;
}

@end

@implementation TransactionObjectManager

-(TransactionObjectMapping*)mapping
{
    if (!_mapping) {
        _mapping = [TransactionObjectMapping new];
    }
    
    return _mapping;
}

- (RKObjectManager *)objectManagerCart
{
    RKObjectManager *objectManagerCart = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionCart class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionCartResult class]];
    [resultMapping addAttributeMappingsFromArray:@[API_TOKEN_KEY,
                                                   API_DEPOSIT_IDR_KEY,
                                                   API_GRAND_TOTAL_KEY,
                                                   API_GRAND_TOTAL_IDR_KEY,
                                                   API_GATEWAY_LIST_ID_KEY]];
    
    RKObjectMapping *listMapping = [[self mapping] transactionCartListMapping];
    RKObjectMapping *productMapping = [[self mapping] productMapping];
    RKObjectMapping *addressMapping = [[self mapping] addressMapping];
    RKObjectMapping *gatewayMapping = [[self mapping] gatewayMapping];
    RKObjectMapping *shipmentsMapping = [[self mapping] shipmentsMapping];
    RKObjectMapping *shopinfoMapping = [[self mapping] shopInfoMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRelationshipMapping];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_DESTINATION_KEY toKeyPath:API_CART_DESTINATION_KEY withMapping:addressMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHOP_KEY toKeyPath:API_CART_SHOP_KEY withMapping:shopinfoMapping]];
    
    RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_PRODUCTS_KEY toKeyPath:API_CART_PRODUCTS_KEY withMapping:productMapping];
    [listMapping addPropertyMapping:productRel];
    
    RKRelationshipMapping *gatewayRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_GATEAWAY_LIST_KEY toKeyPath:API_GATEAWAY_LIST_KEY withMapping:gatewayMapping];
    [resultMapping addPropertyMapping:gatewayRel];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHIPMENTS_KEY toKeyPath:API_CART_SHIPMENTS_KEY withMapping:shipmentsMapping];
    [listMapping addPropertyMapping:shipmentRel];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManagerCart addResponseDescriptor:responseDescriptor];
    
    return objectManagerCart;
}

-(RKObjectManager *)objectManagerCancelCart
//-(void)configureRestKitActionCancelCart
{
    RKObjectManager *objectManagerActionCancelCart = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_ACTION_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManagerActionCancelCart addResponseDescriptor:responseDescriptor];
    
    return objectManagerActionCancelCart;
}


-(RKObjectManager*)objectManagerCheckout
{
    RKObjectManager *objectManagerActionCheckout = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionSummary class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionSummaryResult class]];
    [resultMapping addAttributeMappingsFromArray:@[@"year_now"]];
    
    RKObjectMapping *transactionMapping = [[self mapping] transactionDetailSummaryMapping];
    RKObjectMapping *listMapping        = [[self mapping] transactionCartListMapping];
    RKObjectMapping *productMapping     = [[self mapping] productMapping];
    RKObjectMapping *addressMapping     = [[self mapping] addressMapping];
    RKObjectMapping *shipmentsMapping   = [[self mapping] shipmentsMapping];
    RKObjectMapping *shopinfoMapping    = [[self mapping] shopInfoMapping];
    RKObjectMapping *ccMapping          = [[self mapping] transactionCCDataMapping];
    RKObjectMapping *veritransMapping   = [[self mapping] veritransDataMapping];
    RKObjectMapping *ccFeeMapping       = [[self mapping] ccFeeMapping];
    
    if(_gatewayID == TYPE_GATEWAY_CLICK_BCA){
        RKObjectMapping *BCAParamMapping = [[self mapping] BCAParamMapping];
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
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET
                                                                                                 toKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET
                                                                                               withMapping:listMapping];
    [transactionMapping addPropertyMapping:listRelationshipMapping];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_DESTINATION_KEY
                                                                                toKeyPath:API_CART_DESTINATION_KEY
                                                                              withMapping:addressMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHOP_KEY
                                                                                toKeyPath:API_CART_SHOP_KEY
                                                                              withMapping:shopinfoMapping]];
    
    RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_PRODUCTS_KEY
                                                                                    toKeyPath:API_CART_PRODUCTS_KEY
                                                                                  withMapping:productMapping];
    [listMapping addPropertyMapping:productRel];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHIPMENTS_KEY
                                                                                     toKeyPath:API_CART_SHIPMENTS_KEY
                                                                                   withMapping:shipmentsMapping];
    [listMapping addPropertyMapping:shipmentRel];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                toKeyPath:kTKPD_APIRESULTKEY
                                                                              withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_TRANSACTION_PATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManagerActionCheckout addResponseDescriptor:responseDescriptor];
    
    return objectManagerActionCheckout;
}

-(RKObjectManager *)objectManagerBuy
{
    RKObjectManager *objectManagerActionBuy = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionBuy class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionBuyResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY,
                                                   API_LINK_MANDIRI_KEY]];
    
    RKObjectMapping *systemBankMapping  = [[self mapping] systemBankMapping];
    RKObjectMapping *transactionMapping = [[self mapping] transactionDetailSummaryMapping];
    RKObjectMapping *listMapping        = [[self mapping] transactionCartListMapping];
    RKObjectMapping *productMapping     = [[self mapping] productMapping];
    RKObjectMapping *addressMapping     = [[self mapping] addressMapping];
    RKObjectMapping *shipmentsMapping   = [[self mapping] shipmentsMapping];
    RKObjectMapping *shopinfoMapping    = [[self mapping] shopInfoMapping];
    RKObjectMapping *ccFeeMapping       = [[self mapping] ccFeeMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_KEY toKeyPath:API_TRANSACTION_SUMMARY_KEY withMapping:transactionMapping]];
    
    RKRelationshipMapping *systemBankRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_SYSTEM_BANK_KEY toKeyPath:API_SYSTEM_BANK_KEY withMapping:systemBankMapping];
    [resultMapping addPropertyMapping:systemBankRel];
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET toKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET withMapping:listMapping];
    [transactionMapping addPropertyMapping:listRelationshipMapping];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_DESTINATION_KEY toKeyPath:API_CART_DESTINATION_KEY withMapping:addressMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHOP_KEY toKeyPath:API_CART_SHOP_KEY withMapping:shopinfoMapping]];
    
    RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_PRODUCTS_KEY toKeyPath:API_CART_PRODUCTS_KEY withMapping:productMapping];
    [listMapping addPropertyMapping:productRel];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHIPMENTS_KEY toKeyPath:API_CART_SHIPMENTS_KEY withMapping:shipmentsMapping];
    [listMapping addPropertyMapping:shipmentRel];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    if(_gatewayID == TYPE_GATEWAY_CC){
        [transactionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"credit_card"
                                                                                           toKeyPath:@"credit_card"
                                                                                         withMapping:ccFeeMapping]];
    }
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManagerActionBuy addResponseDescriptor:responseDescriptor];
    
    return objectManagerActionBuy;
}


-(RKObjectManager*)objectManagerVoucher
{
    RKObjectManager *objectManagerActionVoucher = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionVoucher class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionVoucherResult class]];
    
    RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[TransactionVoucherData class]];
    [dataMapping addAttributeMappingsFromArray:@[API_DATA_VOUCHER_AMOUNT_KEY,
                                                 API_DATA_VOUCHER_EXPIRED_KEY,
                                                 API_DATA_VOUCHER_ID_KEY,
                                                 API_DATA_VOUCHER_MINIMAL_AMOUNT_KEY,
                                                 API_DATA_VOUCHER_STATUS_KEY
                                                 ]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_DATA_VOUCHER_KEY toKeyPath:API_DATA_VOUCHER_KEY withMapping:dataMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_CHECK_VOUCHER_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManagerActionVoucher addResponseDescriptor:responseDescriptor];
    
    return objectManagerActionVoucher;
}

-(RKObjectManager*)objectMangerEditProduct
{
    RKObjectManager *objectManagerActionEditProductCart = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_IS_SUCCESS_KEY:API_IS_SUCCESS_KEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_ACTION_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManagerActionEditProductCart addResponseDescriptor:responseDescriptor];
    
    return objectManagerActionEditProductCart;
}

-(RKObjectManager *)objectManagerEMoney
{
    RKObjectManager *objectManagerEMoney = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TxEmoney class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TxEMoneyResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_IS_SUCCESS_KEY:API_IS_SUCCESS_KEY}];
    
    RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[TxEMoneyData class]];
    [resultMapping addAttributeMappingsFromArray:@[API_TRACE_NUM_KEY,
                                                   API_STATUS_KEY,
                                                   API_NOMOR_HP_KEY,
                                                   API_TRX_ID_KEY,
                                                   API_ID_EMONEY_KEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_EMONEY_DATA_KEY toKeyPath:API_EMONEY_DATA_KEY withMapping:dataMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_EMONEY_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManagerEMoney addResponseDescriptor:responseDescriptor];
    
    return objectManagerEMoney;
}


-(RKObjectManager*)objectManagerBCAClickPay
{
    RKObjectManager *objectManagerBCAClickPay = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionBuy class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionBuyResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    RKObjectMapping *systemBankMapping  = [[self mapping] systemBankMapping];
    RKObjectMapping *transactionMapping = [[self mapping] transactionDetailSummaryMapping];
    RKObjectMapping *listMapping        = [[self mapping] transactionCartListMapping];
    RKObjectMapping *productMapping     = [[self mapping] productMapping];
    RKObjectMapping *addressMapping     = [[self mapping] addressMapping];
    RKObjectMapping *shipmentsMapping   = [[self mapping] shipmentsMapping];
    RKObjectMapping *shopinfoMapping    = [[self mapping] shopInfoMapping];
    RKObjectMapping *ccFeeMapping       = [[self mapping] ccFeeMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_KEY toKeyPath:API_TRANSACTION_SUMMARY_KEY withMapping:transactionMapping]];
    
    RKRelationshipMapping *systemBankRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_SYSTEM_BANK_KEY toKeyPath:API_SYSTEM_BANK_KEY withMapping:systemBankMapping];
    [resultMapping addPropertyMapping:systemBankRel];
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET toKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET withMapping:listMapping];
    [transactionMapping addPropertyMapping:listRelationshipMapping];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_DESTINATION_KEY toKeyPath:API_CART_DESTINATION_KEY withMapping:addressMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHOP_KEY toKeyPath:API_CART_SHOP_KEY withMapping:shopinfoMapping]];
    
    RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_PRODUCTS_KEY toKeyPath:API_CART_PRODUCTS_KEY withMapping:productMapping];
    [listMapping addPropertyMapping:productRel];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHIPMENTS_KEY toKeyPath:API_CART_SHIPMENTS_KEY withMapping:shipmentsMapping];
    [listMapping addPropertyMapping:shipmentRel];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    if(_gatewayID == TYPE_GATEWAY_CC){
        [transactionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"credit_card"
                                                                                       toKeyPath:@"credit_card"
                                                                                     withMapping:ccFeeMapping]];
    }
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_BCA_KLICK_PAY_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManagerBCAClickPay addResponseDescriptor:responseDescriptor];
    
    return objectManagerBCAClickPay;
}


-(RKObjectManager*)objectManagerCC
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionCC class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionCCResult class]];
    
    RKObjectMapping *dataCreditMapping = [[self mapping] dataCreditMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data_credit" toKeyPath:@"data_credit" withMapping:dataCreditMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_ACTION_CC_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

@end
