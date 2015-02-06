//
//  string_tx_order.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_tx_order_h
#define Tokopedia_string_tx_order_h

#define DATA_DETAIL_ORDER_CONFIRMATION_KEY @"data_detail_order"
#define DATA_SELECTED_ORDER_KEY @"selected_order"

#pragma mark - Action
#define ACTION_GET_TX_ORDER_PAYMENT_CONFIRMED @"get_tx_order_payment_confirmed"
#define ACTION_GET_TX_ORDER_PAYMENT_CONFIRMATION @"get_tx_order_payment_confirmation"
#define ACTION_CANCEL_PAYMENT @"cancel_payment"
#pragma mark -

#define API_ACTION_KEY @"action"
#define API_TOTAL_LOGISTIC_FEE_KEY @"cart_logistic_fee"

#pragma mark - String Alert
#define ALERT_TITLE_CANCEL_PAYMENT_CONFIRMATION @"Konfirmasi Pembatalan Pembayaran"
#define ALERT_DESCRIPTION_CANCEL_PAYMENT_CONFIRMATION @"Apakah anda yakin membatalkan transaksi ini? \n saldo Tokopedia yang akan dikembalikan adalah sebesar : 100" //TODO::

#define ALERT_TITLE_INVOICE_LIST @"Berikut Daftar Invoice dari Nomor Pembayaran %@"

#pragma mark - Order Confirmation
#define API_CONFIRMATION_KEY @"confirmation"
#define API_CONFIRMATION_LEFT_AMOUNT_KEY @"left_amount"
#define API_CONFIRMATION_STATUS_KEY @"status"
#define API_CONFIRMATION_PAY_DUE_DATE_KEY @"pay_due_date"
#define API_CONFIRMATION_CREATE_TIME_KEY @"create_time"
#define API_CONFIRMATION_OPEN_AMOUNT_BEFORE_FEE_KEY @"open_amount_before_fee"
#define API_CONFIRMATION_CONFIRMATION_ID_KEY @"confirmation_id"
#define API_CONFIRMATION_DEPOSIT_AMOUNT_KEY @"deposit_amount"
#define API_CONFIRMATION_OPEN_AMOUNT_KEY @"open_amount"
#define API_CONFIRMATION_DEPOSIT_AMOUNT_PLAIN_KEY @"deposit_amount_plain"
#define API_CONFIRMATION_VOUCHER_AMOUNT_KEY @"voucher_amount"
#define API_CONFIRMATION_COSTUMER_ID_KEY @"customer_id"
#define API_CONFIRMATION_PAYMENT_TYPE_KEY @"payment_type"
#define API_CONFIRMATION_TOTAL_ITEM_KEY @"total_item"
#define API_CONFIRMATION_SHOP_LIST_KEY @"shop_list"
#pragma mark -

#pragma mark - Order List
#define API_ORDER_LIST_KEY @"order_list"
#define API_ORDER_LIST_JOB_STATUS_KEY @"order_JOB_status"
#define API_ORDER_LIST_PRODUCTS_KEY @"order_products"
#define API_ORDER_LIST_SHOP_KEY @"order_shop"
#define API_ORDER_LIST_SHIPMENT_KEY @"order_shipment"
#define API_ORDER_LIST_DESTINATION_KEY @"order_destination"
#define API_ORDER_LIST_DETAIL_KEY @"order_detail"
#define API_ORDER_LIST_AUTO_RESI_KEY @"order_auto_resi"
#pragma mark -

#pragma mark - Order Products
#define API_PRODUCT_ORDER_DELIVERY_QUANTITY @"order_deliver_quantity"
#define API_PRODUCT_PICTURE @"product_picture"
#define API_PRODUCT_PRICE @"product_price"
#define API_PRODUCT_ORDER_DETAIL_ID @"order_detail_id"
#define API_PRODUCT_NOTES @"product_notes"
#define API_PRODUCT_STATUS @"product_status"
#define API_PRODUCT_ORDER_SUBTOTAL_PRICE @"order_subtotal_price"
#define API_PRODUCT_ID @"product_id"
#define API_PRODUCT_QUANTITY @"product_quantity"
#define API_PRODUCT_WEIGHT @"product_weight"
#define API_PRODUCT_ORDER_SUBTOTAL_PRICE_IDR @"order_subtotal_price_idr"
#define API_PRODUCT_REJECT_QUANTITY @"product_reject_quantity"
#define API_PRODUCT_NAME @"product_name"
#define API_PRODUCT_URL @"product_url"
#pragma mark -

#pragma mark - Order Shop
#define API_SHOP_URI_KEY @"shop_uri"
#define API_SHOP_ID_KEY @"shop_id"
#define API_SHOP_NAME_KEY @"shop_name"
#pragma mark -

#pragma mark - Order Shipment
#define API_ORDER_SHIPMENT_LOGO_KEY @"shipment_logo"
#define API_ORDER_SHIPMENT_PACKAGE_ID_KEY @"shipment_package_id"
#define API_ORDER_SHIPMENT_SHIPMENT_ID_KEY @"shipment_id"
#define API_ORDER_SHIPMENT_PRODUCT_KEY @"shipment_product"
#define API_ORDER_SHIPMENT_NAME_KEY @"shipment_name"
#pragma mark -

#pragma mark - Order Extra Fee
#define API_TOTAL_EXTRA_FEE_PLAIN @"total_extra_fee_plain"
#define API_TOTAL_EXTRA_FEE @"total_extra_fee"
#pragma mark -

#pragma mark - Order Destination
#define API_DESTINATION_RECEIVER_NAME               @"receiver_name"
#define API_DESTINATION_ADDRESS_COUNTRY             @"address_country"
#define API_DESTINATION_ADDRESS_POSTAL              @"address_postal"
#define API_DESTINATION_ADDRESS_DISTRICT            @"address_district"
#define API_DESTINATION_RECEIVER_PHONE              @"receiver_phone"
#define API_DESTINATION_ADDRESS_STREET              @"address_street"
#define API_DESTINATION_ADDRESS_CITY                @"address_city"
#define API_DESTINATION_ADDRESS_PROVINCE            @"address_province"

#pragma mark - Order Detail
#define API_DETAIL_INSURANCE_PRICE      @"detail_insurance_price"
#define API_DETAIL_OPEN_AMOUNT          @"detail_open_amount"
#define API_DETAIL_QUANTITY             @"detail_quantity"
#define API_DETAIL_PRODUCT_PRICE_IDR    @"detail_product_price_idr"
#define API_DETAIL_INVOICE              @"detail_invoice"
#define API_DETAIL_SHIPPING_PRICE_IDR   @"detail_shipping_price_idr"
#define API_DETAIL_PDF_PATH             @"detail_pdf_path"
#define API_DETAIL_ADDITIONAL_FEE_IDR   @"detail_additional_fee_idr"
#define API_DETAIL_PRODUCT_PRICE        @"detail_product_price"
#define API_DETAIL_FORCE_INSURANCE      @"detail_force_insurance"
#define API_DETAIL_ADDITIONAL_FEE       @"detail_additional_fee"
#define API_DETAIL_ORDER_ID             @"detail_order_id"
#define API_DETAIL_TOTAL_ADD_FEE_IDR    @"detail_total_add_fee_idr"
#define API_DETAIL_ORDER_DATE           @"detail_order_date"
#define API_DETAIL_SHIPPING_PRICE       @"detail_shipping_price"
#define API_DETAIL_PAY_DUE_DATE         @"detail_pay_due_date"
#define API_DETAIL_TOTAL_WEIGHT         @"detail_total_weight"
#define API_DETAIL_INSURANCE_PRICE_IDR  @"detail_insurance_price_idr"
#define API_DETAIL_PDF_URI              @"detail_pdf_uri"
#define API_DETAIL_SHIP_REF_NUM         @"detail_ship_ref_num"
#define API_DETAIL_FORCE_CANCEL         @"detail_force_cancel"
#define API_DETAIL_PRINT_ADDRESS_URI    @"detail_print_address_uri"
#define API_DETAIL_PDF                  @"detail_pdf"
#define API_DETAIL_ORDER_STATUS         @"detail_order_status"
#define API_DETAIL_TOTAL_ADD_FEE        @"detail_total_add_fee"
#define API_DETAIL_OPEN_AMOUNT_IDR      @"detail_open_amount_idr"
#define API_DETAIL_PARTIAL_ORDER        @"detail_partial_order"
#define API_DETAIL_DROPSHIP_NAME        @"detail_dropship_name"
#define API_DETAIL_DROPSHIP_TELP        @"detail_dropship_telp"
#pragma mark -

#pragma mark - Order Extra Fee
#define API_EXTRA_FEE_KEY @"extra_fee"
#define API_EXTRA_FEE_AMOUNT_KEY @"extra_fee_amount"
#define API_EXTRA_FEE_AMOUNT_IDR_KEY @"extra_fee_amount_idr"
#define API_EXTRA_FEE_TYPE_KEY @"extra_fee_type"
#pragma mark -

#pragma mark - Order Confirmed List
#define API_ORDER_COUNT_KEY @"order_count"
#define API_ORDER_USER_ACOUNT_NAME_KEY @"user_account_name"
#define API_ORDER_USER_BANK_NAME_KEY @"user_bank_name"
#define API_ORDER_PAYMENT_DATE_KEY @"payment_date"
#define API_ORDER_PAYMENT_REF_NUMBER_KEY @"payment_ref_num"
#define API_ORDER_USER_ACCOUNT_NO_KEY @"user_account_no"
#define API_ORDER_BANK_NAME_KEY @"bank_name"
#define API_ORDER_SYSTEM_ACCOUNT_NO_KEY @"system_account_no"
#define API_ORDER_PAYMENT_ID_KEY @"payment_id"
#define API_ORDER_BUTTON_KEY @"button"
#define API_ORDER_BUTTON_UPLOAD_PROOF_KEY @"button_upload_proof"
#define API_ORDER_HAS_USER_BANK_KEY @"has_user_bank"
#define API_ORDER_PAYMENT_AMOUNT_KEY @"payment_amount"
#pragma mark -


#pragma mark - Path
#define API_PATH_TX_ORDER @"tx-order.pl"
#define API_PATH_ACTION_TX_ORDER @"action/tx-order.pl"

#endif
