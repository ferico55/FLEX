//
//  TransactionObjectMapping.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionObjectMapping.h"

#import "string_transaction.h"
#import "string_product.h"
#import "detail.h"
#import "profile.h"

#import "TransactionCartList.h"
#import "ProductDetail.h"
#import "TransactionSummary.h"
#import "TransactionSystemBank.h"

#import <objc/runtime.h>

@implementation TransactionObjectMapping

#pragma mark - Cart

-(RKObjectMapping*)transactionCartListMapping
{
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TransactionCartList class]];
    [listMapping addAttributeMappingsFromArray:@[API_CART_TOTAL_LOGISTIC_FEE_KEY,
                                                 API_TOTAL_CART_COUNT_KEY,
                                                 API_CART_TOTAL_LOGISTIC_FEE_IDR_KEY,
                                                 API_CART_CAN_PROCESS_KEY,
                                                 API_TOTAL_PRODUCT_PRICE_KEY,
                                                 API_INSURANCE_PRICE_KEY,
                                                 API_CART_TOTAL_TOTAL_PRODUCT_PRICE_IDR_KEY,
                                                 API_CART_TOTAL_WEIGHT_KEY,
                                                 API_CART_CUTOMER_ID_KEY,
                                                 API_CART_INSURANCE_PRODUCT_KEY,
                                                 API_TOTAL_AMOUNT_IDR_KEY,
                                                 API_SHIPPING_RATE_IDR_KEY,
                                                 API_IS_ALLOW_CHECKOUT_KEY,
                                                 API_PRODUCT_TYPE_KEY,
                                                 API_FORCE_INSURANCE_KEY ,
                                                 API_CANNOT_INSURANCE_KEY ,
                                                 API_TOTAL_PRODUCT_KEY,
                                                 API_INSURANCE_PRICE_IDR_KEY,
                                                 API_TOTAL_TOTAL_AMOUNT_KEY,
                                                 API_TOTAL_SHIPPING_RATE_KEY,
                                                 API_TOTAL_LOGISTIC_FEE_KEY,
                                                 API_CART_ERROR_1,
                                                 API_CART_ERROR_2,
                                                 @"cart_is_price_changed"
                                                 ]];
    return listMapping;
}

-(RKObjectMapping*)productMapping
{
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[ProductDetail class]];
    [productMapping addAttributeMappingsFromArray: @[API_PRODUCT_NAME_KEY,
                                                     API_PRODUCT_WEIGHT_UNIT_KEY,
                                                     API_PRODUCT_DESCRIPTION_KEY,
                                                     API_PRODUCT_PRICE_KEY,
                                                     API_PRODUCT_INSURANCE_KEY,
                                                     API_PRODUCT_CONDITION_KEY,
                                                     API_PRODUCT_MINIMUM_ORDER_KEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTURLKEY,
                                                     API_PRODUCT_PRICE_IDR_KEY,
                                                     API_PRODUCT_TOTAL_PRICE_IDR_KEY,
                                                     API_PRODUCT_TOTAL_PRICE_KEY,
                                                     API_PRODUCT_PICTURE_KEY,
                                                     API_PRODUCT_WEIGHT_KEY,
                                                     API_PRODUCT_QUANTITY_KEY,
                                                     API_PRODUCT_CART_ID_KEY,
                                                     API_PRODUCT_TOTAL_WEIGHT_KEY,
                                                     API_PRODUCT_NOTES_KEY,
                                                     API_PRICE_KEY,
                                                     API_PRODUCT_ERROR_MESSAGE_KEY,
                                                     API_PRODUCT_MUST_INSURANCE_KEY,
                                                     @"product_price_last"
                                                     ]];
    return productMapping;
}

-(RKObjectMapping*)addressMapping
{
    RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[AddressFormList class]];
    [addressMapping addAttributeMappingsFromArray:@[kTKPDPROFILESETTING_APICOUNTRYNAMEKEY,
                                                         kTKPDPROFILESETTING_APIRECEIVERNAMEKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSNAMEKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSIDKEY,
                                                         kTKPDPROFILESETTING_APIRECEIVERPHONEKEY,
                                                         kTKPDPROFILESETTING_APIPROVINCENAMEKEY,
                                                         API_POSTAL_CODE_CART_KEY,
                                                        @""
                                                         kTKPDPROFILESETTING_APIADDRESSSTATUSKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSSTREETKEY,
                                                         kTKPDPROFILESETTING_APIDISTRICNAMEKEY,
                                                         kTKPDPROFILESETTING_APICITYNAMEKEY,
                                                         kTKPDPROFILESETTING_APICITYIDKEY,
                                                         kTKPDPROFILESETTING_APIPROVINCEIDKEY,
                                                         kTKPDPROFILESETTING_APIDISTRICTIDKEY,
                                                        API_ADDRESS_COUNTRY,
                                                    API_ADDRESS_DISTRICT,
                                                    API_ADDRESS_CITY,
                                                    API_ADDRESS_PROVINCE,
                                                    @"longitude",
                                                    @"latitude",
                                                    @"postal_code"
                                                         ]];
    return addressMapping;
}

-(RKObjectMapping*)gatewayMapping
{
    RKObjectMapping *gatewayMapping = [RKObjectMapping mappingForClass:[TransactionCartGateway class]];
    [gatewayMapping addAttributeMappingsFromDictionary:@{API_GATEWAY_LIST_IMAGE_KEY:API_GATEWAY_LIST_IMAGE_KEY,
                                                         API_GATEWAY_LIST_NAME_KEY:API_GATEWAY_LIST_NAME_KEY,
                                                         API_GATEWAY_LIST_ID_KEY:API_GATEWAY_LIST_ID_KEY
                                                         }];
    return gatewayMapping;
}

-(RKObjectMapping*)shipmentsMapping
{
    RKObjectMapping *shipmentsMapping = [RKObjectMapping mappingForClass:[ShippingInfoShipments class]];
    [shipmentsMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APISHIPMENTNAMEKEY:kTKPDSHOPSHIPMENT_APISHIPMENTNAMEKEY,
                                                           kTKPDSHOPSHIPMENT_APISHIPMENTIDKEY:kTKPDSHOPSHIPMENT_APISHIPMENTIDKEY,
                                                           kTKPDSHOPSHIPMENT_APISHIPMENTIMAGEKEY:kTKPDSHOPSHIPMENT_APISHIPMENTIMAGEKEY,
                                                           API_SHIPMENT_PACKAGE_NAME:API_SHIPMENT_PACKAGE_NAME,
                                                           API_SHIPMENT_PACKAGE_ID:API_SHIPMENT_PACKAGE_ID
                                                           }];
    return shipmentsMapping;
}

-(RKObjectMapping*)shopInfoMapping
{
    RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
    [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY,
                                                          @"lucky_merchant" : @"lucky_merchant"
                                                          }];
    return shopinfoMapping;
}


-(RKObjectMapping*)transactionDetailSummaryMapping
{
    RKObjectMapping *transactionMapping = [RKObjectMapping mappingForClass:[TransactionSummaryDetail class]];
//    [transactionMapping addAttributeMappingsFromArray:[self allPropertyNames]];
    [transactionMapping addAttributeMappingsFromArray:@[API_CONFIRMATION_CODE_KEY,
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
                                                        @"lp_amount",
                                                        @"bri_website_link",
                                                        @"transaction_code"
                                                        ]];
    return transactionMapping;
}

- (NSArray *)allPropertyNames
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([TransactionSummaryDetail class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

-(RKObjectMapping*)BCAParamMapping
{
    RKObjectMapping *bcaParamMapping = [RKObjectMapping mappingForClass:[TransactionSummaryBCAParam class]];
    [bcaParamMapping addAttributeMappingsFromArray:@[API_BCA_DESRIPTION_KEY,
                                                     API_BCA_CODE_KEY,
                                                     API_BCA_AMOUNT_KEY,
                                                     API_BCA_URL_KEY,
                                                     API_BCA_CURRENCY_KEY,
                                                     API_BCA_MISC_FEE_KEY,
                                                     API_BCA_DATE_KEY,
                                                     API_BCA_SIGNATURE_KEY,
                                                     API_BCA_CALLBACK_KEY,
                                                     API_BCA_PAYMENT_ID_KEY,
                                                     API_BCA_TYPE_PAYMENT_KEY
                                                     ]];
    return bcaParamMapping;
}

-(RKObjectMapping*)installmentBankMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[InstallmentBank class]];
    [mapping addAttributeMappingsFromArray:@[@"percentage",
                                             @"bank_id",
                                             @"bank_name"
                                            ]];
    return mapping;
}

-(RKObjectMapping*)installmentTermMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[InstallmentTerm class]];
    [mapping addAttributeMappingsFromArray:@[
                                             @"total_price",
                                             @"monthly_price",
                                             @"total_price_idr",
                                             @"admin_price_idr",
                                             @"monthly_price_idr",
                                             @"bunga",
                                             @"duration",
                                             @"is_zero",
                                             @"interest_price_idr",
                                             @"interest_price",
                                             @"admin_price"
                                             ]];
    return mapping;
}

-(RKObjectMapping*)systemBankMapping
{
    RKObjectMapping *sbMapping = [RKObjectMapping mappingForClass:[TransactionSystemBank class]];
    [sbMapping addAttributeMappingsFromArray:@[API_SYSTEM_BANK_BANK_CABANG_KEY,
                                               API_SYSTEM_BANK_PICTURE_KEY,
                                               API_SYSTEM_BANK_INFO_KEY,
                                               API_SYSTEM_BANK_BANK_NAME_KEY,
                                               API_SYSTEM_BANK_ACCOUNT_NUMBER_KEY,
                                               API_SYSTEM_BANK_ACCOUNT_NAME_KEY
                                               ]];
    return sbMapping;
}

-(RKObjectMapping*)shipmentPackageMapping
{
    RKObjectMapping *shipmentspackageMapping = [RKObjectMapping mappingForClass:[ShippingInfoShipmentPackage class]];
    [shipmentspackageMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APIDESCKEY:kTKPDSHOPSHIPMENT_APIDESCKEY,
                                                                  kTKPDSHOPSHIPMENT_APIACTIVEKEY:kTKPDSHOPSHIPMENT_APIACTIVEKEY,
                                                                  kTKPDSHOPSHIPMENT_APINAMEKEY:kTKPDSHOPSHIPMENT_APINAMEKEY,
                                                                  kTKPDSHOPSHIPMENT_APISPIDKEY:kTKPDSHOPSHIPMENT_APISPIDKEY,
                                                                  API_SHIPMENT_PRICE:API_SHIPMENT_PRICE,
                                                                  API_SHIPMENT_PRICE_TOTAL:API_SHIPMENT_PRICE_TOTAL
                                                                  }];
    return shipmentspackageMapping;
}

#pragma mark - CC
-(RKObjectMapping *)transactionCCDataMapping
{
    RKObjectMapping *ccDataMapping = [RKObjectMapping mappingForClass:[CCData class]];
    [ccDataMapping addAttributeMappingsFromArray:@[@"city",
                                                   @"postal_code",
                                                   @"address",
                                                   @"phone",
                                                   @"state",
                                                   @"last_name",
                                                   @"first_name"]];
    return ccDataMapping;
}

-(RKObjectMapping *)veritransDataMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Veritrans class]];
    [mapping addAttributeMappingsFromArray:@[@"token_url",
                                             @"client_key"]];
    return mapping;
}

-(RKObjectMapping *)dataCreditMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[DataCredit class]];
    [mapping addAttributeMappingsFromArray:@[@"user_email",
                                             @"payment_id",
                                             @"cc_agent",
                                             @"cc_type",
                                             @"cc_card_bank_type"]];
    return mapping;
}

-(RKObjectMapping *)ccFeeMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[CCFee class]];
    [mapping addAttributeMappingsFromArray:@[@"charge",
                                             @"charge_idr",
                                             @"total_idr",
                                             @"total",
                                             @"charge_25"
                                             ]
     ];
    return mapping;
}

-(RKObjectMapping *)indomaretMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[IndomaretData class]];
    [mapping addAttributeMappingsFromArray:@[@"charge_idr",
                                             @"total_charge_real_idr",
                                             @"total",
                                             @"charge_real",
                                             @"charge",
                                             @"payment_code",
                                             @"charge_real_idr",
                                             @"total_idr"
                                             ]
     ];
    return mapping;
}

@end
