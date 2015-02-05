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
                                                 API_CART_ERROR_2
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
                                                     API_PRICE_KEY
                                                     ]];
    return productMapping;
}

-(RKObjectMapping*)addressMapping
{
    RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[AddressFormList class]];
    [addressMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILESETTING_APICOUNTRYNAMEKEY:kTKPDPROFILESETTING_APICOUNTRYNAMEKEY,
                                                         kTKPDPROFILESETTING_APIRECEIVERNAMEKEY:kTKPDPROFILESETTING_APIRECEIVERNAMEKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSNAMEKEY:kTKPDPROFILESETTING_APIADDRESSNAMEKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSIDKEY:kTKPDPROFILESETTING_APIADDRESSIDKEY,
                                                         kTKPDPROFILESETTING_APIRECEIVERPHONEKEY :kTKPDPROFILESETTING_APIRECEIVERPHONEKEY,
                                                         kTKPDPROFILESETTING_APIPROVINCENAMEKEY:kTKPDPROFILESETTING_APIPROVINCENAMEKEY,
                                                         API_POSTAL_CODE_CART_KEY:kTKPDPROFILESETTING_APIPOSTALCODEKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSSTATUSKEY:kTKPDPROFILESETTING_APIADDRESSSTATUSKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSSTREETKEY:kTKPDPROFILESETTING_APIADDRESSSTREETKEY,
                                                         kTKPDPROFILESETTING_APIDISTRICNAMEKEY:kTKPDPROFILESETTING_APIDISTRICNAMEKEY,
                                                         kTKPDPROFILESETTING_APICITYNAMEKEY:kTKPDPROFILESETTING_APICITYNAMEKEY,
                                                         kTKPDPROFILESETTING_APICITYIDKEY:kTKPDPROFILESETTING_APICITYIDKEY,
                                                         kTKPDPROFILESETTING_APIPROVINCEIDKEY:kTKPDPROFILESETTING_APIPROVINCEIDKEY,
                                                         kTKPDPROFILESETTING_APIDISTRICTIDKEY:kTKPDPROFILESETTING_APIDISTRICTIDKEY
                                                         }];
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
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY
                                                          }];
    return shopinfoMapping;
}

-(RKObjectMapping*)transactionDetailSummaryMapping
{
    RKObjectMapping *transactionMapping = [RKObjectMapping mappingForClass:[TransactionSummaryDetail class]];
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
                                                        API_STEP_KEY
                                                        ]];
    return transactionMapping;
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


#pragma mark - Order
-(RKObjectMapping*)confirmationDetailMapping
{
    RKObjectMapping *confirmationMapping = [RKObjectMapping mappingForClass:[OrderConfirmationDetail class]];
    [confirmationMapping addAttributeMappingsFromArray:@[
                                                         API_CONFIRMATION_KEY,
                                                         API_CONFIRMATION_LEFT_AMOUNT_KEY,
                                                         API_CONFIRMATION_STATUS_KEY,
                                                         API_CONFIRMATION_PAY_DUE_DATE_KEY,
                                                         API_CONFIRMATION_CREATE_TIME_KEY,
                                                         API_CONFIRMATION_OPEN_AMOUNT_BEFORE_FEE_KEY,
                                                         API_CONFIRMATION_CONFIRMATION_ID_KEY,
                                                         API_CONFIRMATION_DEPOSIT_AMOUNT_KEY,
                                                         API_CONFIRMATION_OPEN_AMOUNT_KEY,
                                                         API_CONFIRMATION_DEPOSIT_AMOUNT_PLAIN_KEY,
                                                         API_CONFIRMATION_VOUCHER_AMOUNT_KEY,
                                                         API_CONFIRMATION_COSTUMER_ID_KEY,
                                                         API_CONFIRMATION_PAYMENT_TYPE_KEY,
                                                         API_CONFIRMATION_TOTAL_ITEM_KEY,
                                                         API_CONFIRMATION_SHOP_LIST_KEY
                                                          ]];
    return confirmationMapping;
}

-(RKObjectMapping*)orderListMapping
{
    RKObjectMapping *orderListMapping = [RKObjectMapping mappingForClass:[TransactionOrderConfirmationListOrder class]];
    [orderListMapping addAttributeMappingsFromArray:@[API_ORDER_LIST_JOB_STATUS_KEY,
                                                      API_ORDER_LIST_AUTO_RESI_KEY
                                                      ]];
    return orderListMapping;
}

-(RKObjectMapping*)orderExtraFeeMapping
{
    RKObjectMapping *extraFeeMapping = [RKObjectMapping mappingForClass:[OrderExtraFee class]];
    [extraFeeMapping addAttributeMappingsFromArray:@[API_EXTRA_FEE_KEY,
                                                     API_EXTRA_FEE_AMOUNT_KEY,
                                                     API_EXTRA_FEE_AMOUNT_IDR_KEY,
                                                     API_EXTRA_FEE_TYPE_KEY
                                                     ]];
    return extraFeeMapping;
}

-(RKObjectMapping*)orderProductsMapping
{
    RKObjectMapping *orderProductMapping = [RKObjectMapping mappingForClass:[OrderProduct class]];
    [orderProductMapping addAttributeMappingsFromArray:@[API_PRODUCT_ORDER_DELIVERY_QUANTITY,
                                                         API_PRODUCT_PICTURE,
                                                         API_PRODUCT_PRICE,
                                                         API_PRODUCT_ORDER_DETAIL_ID,
                                                         API_PRODUCT_NOTES,
                                                         API_PRODUCT_STATUS,
                                                         API_PRODUCT_ORDER_SUBTOTAL_PRICE,
                                                         API_PRODUCT_ID,
                                                         API_PRODUCT_QUANTITY,
                                                         API_PRODUCT_WEIGHT,
                                                         API_PRODUCT_ORDER_SUBTOTAL_PRICE_IDR,
                                                         API_PRODUCT_REJECT_QUANTITY,
                                                         API_PRODUCT_NAME,
                                                         API_PRODUCT_URL
                                                         ]];
    return orderProductMapping;
}

-(RKObjectMapping*)orderShopMapping
{
    RKObjectMapping *orderShopMapping = [RKObjectMapping mappingForClass:[OrderShop class]];
    [orderShopMapping addAttributeMappingsFromArray:@[API_SHOP_URI_KEY,
                                                      API_SHOP_ID_KEY,
                                                      API_SHOP_NAME_KEY
                                                      ]];
    return orderShopMapping;
}

-(RKObjectMapping*)orderShipmentsMapping
{
    RKObjectMapping *shipmentsMapping = [RKObjectMapping mappingForClass:[OrderShipment class]];
    [shipmentsMapping addAttributeMappingsFromArray:@[API_ORDER_SHIPMENT_LOGO_KEY,
                                                      API_ORDER_SHIPMENT_PACKAGE_ID_KEY,
                                                      API_ORDER_SHIPMENT_SHIPMENT_ID_KEY,
                                                      API_ORDER_SHIPMENT_PRODUCT_KEY,
                                                      API_ORDER_SHIPMENT_NAME_KEY
                                                     ]];
    return shipmentsMapping;
}

-(RKObjectMapping *)orderDestinationMapping
{
    RKObjectMapping *destinationMapping = [RKObjectMapping mappingForClass:[OrderDestination class]];
    [destinationMapping addAttributeMappingsFromArray:@[API_DESTINATION_RECEIVER_NAME,
                                                        API_DESTINATION_ADDRESS_COUNTRY,
                                                        API_DESTINATION_ADDRESS_POSTAL,
                                                        API_DESTINATION_ADDRESS_DISTRICT,
                                                        API_DESTINATION_RECEIVER_PHONE,
                                                        API_DESTINATION_ADDRESS_STREET,
                                                        API_DESTINATION_ADDRESS_CITY,
                                                        API_DESTINATION_ADDRESS_PROVINCE
                                                        ]];
    return destinationMapping;
}

-(RKObjectMapping *)orderDetailMapping
{
    RKObjectMapping *orderDetailMapping = [RKObjectMapping mappingForClass:[OrderDetail class]];
    [orderDetailMapping addAttributeMappingsFromArray:@[API_DETAIL_INSURANCE_PRICE,
                                                        API_DETAIL_OPEN_AMOUNT,
                                                        API_DETAIL_QUANTITY,
                                                        API_DETAIL_PRODUCT_PRICE_IDR,
                                                        API_DETAIL_INVOICE,
                                                        API_DETAIL_SHIPPING_PRICE_IDR,
                                                        API_DETAIL_PDF_PATH,
                                                        API_DETAIL_ADDITIONAL_FEE_IDR,
                                                        API_DETAIL_PRODUCT_PRICE,
                                                        API_DETAIL_FORCE_INSURANCE,
                                                        API_DETAIL_ADDITIONAL_FEE,
                                                        API_DETAIL_ORDER_ID,
                                                        API_DETAIL_TOTAL_ADD_FEE_IDR,
                                                        API_DETAIL_ORDER_DATE,
                                                        API_DETAIL_SHIPPING_PRICE,
                                                        API_DETAIL_PAY_DUE_DATE,
                                                        API_DETAIL_TOTAL_WEIGHT,
                                                        API_DETAIL_INSURANCE_PRICE_IDR,
                                                        API_DETAIL_PDF_URI,
                                                        API_DETAIL_SHIP_REF_NUM,
                                                        API_DETAIL_FORCE_CANCEL,
                                                        API_DETAIL_PRINT_ADDRESS_URI,
                                                        API_DETAIL_PDF,
                                                        API_DETAIL_ORDER_STATUS,
                                                        API_DETAIL_TOTAL_ADD_FEE,
                                                        API_DETAIL_OPEN_AMOUNT_IDR,
                                                        API_DETAIL_PARTIAL_ORDER,
                                                        API_DETAIL_DROPSHIP_NAME,
                                                        API_DETAIL_DROPSHIP_TELP
                                                        ]];
    return orderDetailMapping;
}

@end
