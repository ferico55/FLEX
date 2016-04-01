//
//  string_transaction.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_transaction_h
#define Tokopedia_string_transaction_h

typedef enum
{
    TAG_BUTTON_TRANSACTION_DEFAULT = 0,
    TAG_BUTTON_TRANSACTION_QUANTITY = 2,
    TAG_BUTTON_TRANSACTION_NOTE = 3,
    //Section1
    TAG_BUTTON_TRANSACTION_ADDRESS = 0,
    TAG_BUTTON_TRANSACTION_PIN_LOCATION = 2,
    TAG_BUTTON_TRANSACTION_SHIPPING_AGENT = 3,
    TAG_BUTTON_TRANSACTION_SERVICE_TYPE = 4,
    TAG_BUTTON_TRANSACTION_INSURANCE = 5,
    //Section2
    TAG_BUTTON_TRANSACTION_PRODUCT_FIRST_PRICE = 0,
    TAG_BUTTON_TRANSACTION_PRODUCT_PRICE = 1,
    TAG_BUTTON_TRANSACTION_SHIPMENT_COST = 2,
    TAG_BUTTON_TRANSACTION_TOTAL = 3,
    TAG_BUTTON_TRANSACTION_BUY = 14
}TAG_BUTTON_TRANSACTION;

typedef enum
{
    TAG_BAR_BUTTON_TRANSACTION_BACK = 10,
    TAG_BAR_BUTTON_TRANSACTION_DONE = 11
}TAG_BAR_BUTTON_TRANSACTION;

typedef enum
{
    TYPE_TRANSACTION_SHIPMENT_DEFAULT = 0,
    TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY,
    TYPE_TRANSACTION_SHIPMENT_SERVICE_TYPE
}TYPE_TRANSACTION_SHIPMENT;

typedef enum
{
    TYPE_CANCEL_CART_PRODUCT = 10,
    TYPE_CANCEL_CART_SHOP = 11
}TYPE_CANCEL_CART;

typedef enum
{
    TYPE_GATEWAY_TOKOPEDIA,
    TYPE_GATEWAY_TRANSFER_BANK = 1,
    TYPE_GATEWAY_MANDIRI_CLICK_PAY = 4,
    TYPE_GATEWAY_MANDIRI_E_CASH = 6,
    TYPE_GATEWAY_BCA_CLICK_PAY = 7,
    TYPE_GATEWAY_BCA_KLIK_BCA = 9,
    TYPE_GATEWAY_CC = 8,
    TYPE_GATEWAY_INDOMARET = 10,
    TYPE_GATEWAY_BRI_EPAY = 11,
    TYPE_GATEWAY_INSTALLMENT = 12,
    TYPE_GATEWAY_SEVEL = 13
}TYPE_GATEWAY;

typedef enum
{
    TYPE_CART_DETAIL,
    TYPE_CART_SUMMARY
}TYPE_CART;

#define STEP_CHECKOUT 1
#define STEP_BUY 2

#define TITLE_CART @"Keranjang Belanja"

#define TITLE_TABLE_SHIPMENT @"      Kurir Pengiriman"
#define TITLE_TABLE_SHIPMENT_PACKAGE @"      Paket Pengiriman"

#define TITLE_FORM_MANDIRI_CLICK_PAY @"Form Mandiri Click Pay"

#define STRING_DEFAULT_PAYMENT @"Pilih"
#define STRING_TOTAL_TAGIHAN @"Total Tagihan"
#define STRING_JUMLAH_YANG_SUDAH_DIBAYAR @"Jumlah yang sudah dibayar"
#define STRING_SALDO_TOKOPEDIA_TERPAKAI @"Saldo Tokopedia terpakai"
#define STRING_SALDO_TOKOPEDIA_TERSISA @"Saldo Tokopedia yang tersisa"
#define STRING_JUMLAH_YANG_HARUS_DIBAYAR @"Jumlah yang harus dibayar"
#define STRING_BIAYA_ADMINISTRASI_INDOMARET @"Biaya Administrasi Indomaret"
#define STRING_METODE_PEMBAYARAN @"Metode Pembayaran"
#define STRING_TOTAL_TAGIHAN @"Total Tagihan"
#define STRING_PENGGUNAAN_KUPON @"Penggunaan Voucher"
#define STRING_LOYALTY_POINT @"TopPoints Terpakai"
#define STRING_PAYMENT

#define DATA_DETAIL_PRODUCT_KEY @"product"
#define DATA_SHIPMENT_KEY @"shipment"
#define DATA_SHIPMENT_PACKAGE_KEY @"shipment_package"
#define DATA_INDEXPATH_KEY @"indexpath"
#define DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY @"indexpath_selected_product_cart"
#define DATA_SELECTED_GATEWAY_CART_KEY @"selected_gateway"
#define DATA_ADDRESS_INDEXPATH_KEY @"indexpathAddress"
#define DATA_SELECTED_INDEXPATH_SHIPMENT_KEY @"indexpathShipment"
#define DATA_SELECTED_SHIPMENT_KEY @"selectedShipment"
#define DATA_SELECTED_SHIPMENT_PACKAGE_KEY @"selectedShipmentPackage"
#define DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY @"indexpathShipmentPackage"
#define DATA_TYPE_KEY @"type"
#define DATA_CANCEL_TYPE_KEY @"type_cancel_cart"
#define DATA_TODO_CALCULATE @"paramdo"
#define DATA_CART_PRODUCT_KEY @"cart_product"
#define DATA_CART_GATEWAY_KEY @"cart_gateway"
#define DATA_CC_KEY @"cart_cc_data"
#define DATA_CART_SHIPPING_KEY @"cart_shipping"
#define DATA_CART_ADDRESS_KEY @"cart_address"
#define DATA_CART_DETAIL_LIST_KEY @"cart_list_detail"
#define DATA_INSURANCE_NAME_KEY @"insurance_name"
#define DATA_IF_STOCK_AVAILABLE_PARTIALLY_NAME_KEY @"if_stock_available_partially_name"
#define DATA_IF_STOCK_AVAILABLE_PARTIALLY_ID_KEY @"if_stock_available_partially_id"
#define DATA_DROPSHIPPER_LIST_KEY @"dropshipper_list"
#define DATA_DROPSHIPPER_NAME_KEY @"dropshipper_name"
#define DATA_DROPSHIPPER_PHONE_KEY @"dropshipper_phone"
#define DATA_PARTIAL_LIST_KEY @"partial_list"
#define DATA_CART_SUMMARY_KEY @"cart_summary"
#define DATA_CART_SUMMARY_LIST_KEY @"cart_summary_list"
#define DATA_CART_RESULT_KEY @"data_cart_result"
#define DATA_KEY @"data"
#define DATA_USED_SALDO_KEY @"saldo_is_used"
#define DATA_NAME_KEY @"name"
#define DATA_VALUE_KEY @"value"
#define DATA_DETAIL_ORDER_CONFIRMATION @"data_detail_order"


#pragma mark - String Action
#define ACTION_ADD_TO_CART @"add_to_cart"
#define ACTION_ADD_TO_CART_FORM @"get_add_to_cart_form"
#define ACTION_SHIPMENT_FORM @"get_edit_address_shipping_form"
#define ACTION_CALCULATE_PRICE @"calculate_cart"
#define ACTION_CANCEL_CART @"cancel_cart"
#define ACTION_EDIT_PRODUCT_CART @"edit_product"
#define ACTION_EDIT_ADDRESS_CART @"edit_address"
#define ACTION_EDIT_INSURANCE @"edit_insurance"
#define ACTION_CECK_VOUCHER_CODE @"check_voucher_code"
#define ACTION_VALIDATE_CODE_EMONEY @"validate_code"
#define ACTION_START_UP_EMONEY @"startup"
#pragma mark -

#define API_VOUCHER_CODE_KEY @"voucher_code"
#define API_ACTION_KEY @"action"
#define API_MANDIRI_ID_KEY @"mandiri_id"
#define API_INSURANCE_KEY @"insurance"
#define API_IS_SUCCESS_KEY @"is_success"


#define API_AVAILABLE_COUNT_KEY @"available_count"
#define API_PRODUCT_DETAIL_KEY @"product_detail"
#define API_PRODUCT_KEY @"product"
#define API_LIST_PRODUCT_CART @"cart_details"
#define API_DESTINATION_KEY @"destination"

#define API_PRODUCT_INSURANCE @"product_insurance"

#define API_PRODUCT_ID_KEY @"product_id"
#define API_ADDRESS_ID_KEY @"address_id"
#define API_OLD_ADDRESS_ID_KEY @"old_address_id"
#define API_OLD_SHIPMENT_ID_KEY @"old_shipment_id"
#define API_OLD_SHIPMENT_PACKAGE_ID_KEY @"old_shipment_package_id"
#define API_SHIPMENT_PACKAGE_ID_KEY @"shipment_package_id"
#define API_CHANGE_KEY @"change"
#define API_DISTRICT_ID_KEY @"district_id"
#define API_ADDRESS_NAME_KEY @"address_name"
#define API_ADDRESS_STREET_KEY @"address_street"
#define API_ADDRESS_PROVINCE_KEY @"address_province"
#define API_PROVINCE_ID @"province_id"
#define API_CITY_ID_KEY @"city_id"

#define API_ADDRESS_CITY_KEY @"address_city"
#define API_ADDRESS_DISTRICT_KEY @"address_district"
#define API_ADDRESS_POSTAL_CODE_KEY @"address_postal_code"
#define API_POSTAL_CODE_KEY @"postal_code"
#define API_QUANTITY_KEY @"quantity"
#define API_INSURANCE_KEY @"insurance"
#define API_SHIPMENT_ID_KEY @"shipment_id"
#define API_SHIPPING_ID_KEY @"shipping_id"
#define API_SHIPPING_PRODUCT_KEY @"shipping_product"
#define API_NOTES_KEY @"notes"
#define API_RECIEVER_NAME_KEY @"receiver_name"
#define API_RECIEVER_PHONE_KEY @"receiver_phone"
#define API_FORM_KEY @"form"
#define API_DO_KEY @"do"
#define API_CALCULATE_QUANTTITY_KEY @"qty"
#define API_CALCULATE_WEIGHT_KEY @"weight"

#define API_CART_TOTAL_LOGISTIC_FEE_KEY @"cart_total_logistic_fee"
#define API_GATEAWAY_LIST_KEY @"gateway_list"
#define API_CART_SHIPMENTS_KEY @"cart_shipments"
#define API_CART_PRODUCTS_KEY @"cart_products"
#define API_CART_DESTINATION_KEY @"cart_destination"
#define API_TOTAL_CART_COUNT_KEY @"cart_total_cart_count"
#define API_CART_TOTAL_LOGISTIC_FEE_IDR_KEY @"cart_total_logistic_fee_idr"
#define API_CART_CAN_PROCESS_KEY @"cart_can_process"
#define API_TOTAL_PRODUCT_PRICE_KEY @"cart_total_product_price"
#define API_INSURANCE_PRICE_KEY @"cart_insurance_price"
#define API_CART_TOTAL_TOTAL_PRODUCT_PRICE_IDR_KEY @"cart_total_product_price_idr"
#define API_CART_TOTAL_WEIGHT_KEY @"cart_total_weight"
#define API_CART_CUTOMER_ID_KEY @"cart_customer_id"
#define API_CART_INSURANCE_PRODUCT_KEY @"cart_insurance_prod"
#define API_TOTAL_AMOUNT_IDR_KEY @"cart_total_amount_idr"
#define API_SHIPPING_RATE_IDR_KEY @"cart_shipping_rate_idr"
#define API_IS_ALLOW_CHECKOUT_KEY @"cart_is_allow_checkout"
#define API_PRODUCT_TYPE_KEY @"cart_product_type"
#define API_FORCE_INSURANCE_KEY @"cart_force_insurance"
#define API_CANNOT_INSURANCE_KEY @"cart_cannot_insurance"
#define API_TOTAL_PRODUCT_KEY @"cart_total_product"
#define API_INSURANCE_PRICE_IDR_KEY @"cart_insurance_price_idr"
#define API_TOTAL_TOTAL_AMOUNT_KEY @"cart_total_amount"
#define API_TOTAL_SHIPPING_RATE_KEY @"cart_shipping_rate"
#define API_TOTAL_LOGISTIC_FEE_KEY @"cart_logistic_fee"
#define API_CART_ERROR_1 @"cart_error_message_1"
#define API_CART_ERROR_2 @"cart_error_message_2"
#define API_CART_SHOP_KEY @"cart_shop"
#define API_SHOP_PAY_GATEWAY_KEY @"shop_pay_gateway"
#define API_CART_PRODUCT_NOTES_KEY @"product_notes"
#define API_STEP_KEY @"step"

#define API_GATEWAY_LIST_IMAGE_KEY @"gateway_image"
#define API_GATEWAY_LIST_NAME_KEY @"gateway_name"
#define API_GATEWAY_LIST_ID_KEY @"gateway"

#pragma mark - System Bank
#define API_SYSTEM_BANK_KEY @"system_bank"
#define API_SYSTEM_BANK_BANK_CABANG_KEY @"sb_bank_cabang"
#define API_SYSTEM_BANK_PICTURE_KEY @"sb_picture"
#define API_SYSTEM_BANK_INFO_KEY @"sb_info"
#define API_SYSTEM_BANK_BANK_NAME_KEY @"sb_bank_name"
#define API_SYSTEM_BANK_ACCOUNT_NUMBER_KEY @"sb_account_no"
#define API_SYSTEM_BANK_ACCOUNT_NAME_KEY @"sb_account_name"
#pragma mark -

#pragma mark - BCA Param
#define API_BCA_DESRIPTION_KEY @"bca_descp"
#define API_BCA_CODE_KEY @"bca_code"
#define API_BCA_AMOUNT_KEY @"bca_amt"
#define API_BCA_URL_KEY @"bca_url"
#define API_BCA_CURRENCY_KEY @"currency"
#define API_BCA_MISC_FEE_KEY @"miscFee"
#define API_BCA_DATE_KEY @"bca_date"
#define API_BCA_SIGNATURE_KEY @"signature"
#define API_BCA_CALLBACK_KEY @"callback"
#define API_BCA_PAYMENT_ID_KEY @"payment_id"
#define API_BCA_TYPE_PAYMENT_KEY @"payType"
#pragma mark -

#define API_DROPSHIP_STRING_KEY @"dropship_str"
#define API_PARTIAL_STRING_KEY @"partial_str"
#define API_USE_DEPOSIT_KEY @"use_deposit"
#define API_DEPOSIT_AMT_KEY @"deposit_amt"

#define API_MANDIRI_TOKEN_KEY @"mandiri_token"
#define API_CARD_NUMBER_KEY @"card_no"

#define API_PASSWORD_KEY @"password"

#define API_BCA_USER_ID_KEY @"bca_user_id"

#define API_VOUCHER_AMOUNT_IDR_KEY @"voucher_amount_idr"
#define API_DEPOSIT_AFTER_KEY @"deposit_after"
#define API_DEPOSIT_IDR_KEY @"deposit_idr"
#define API_E_CACH_FLAG_KEY @"ecash_flag"
#define API_GRAND_TOTAL_KEY @"grand_total"
#define API_PAYMENT_LEFT_IDR_KEY @"payment_left_idr"
#define API_CONFIRMATION_ID_KEY @"confirmation_id"
#define API_DEPOSIT_LEFT_KEY @"deposit_left"
#define API_DATA_PARTIAL_KEY @"data_partial"
#define API_IS_USE_DEPOSIT_KEY @"use_deposit"
#define API_PAYMENT_ID_KEY @"payment_id"
#define API_BCA_PARAM_KEY @"bca_param"
#define API_IS_USE_OTP_KEY @"use_otp"
#define API_NOW_DATE_KEY @"now_time"
#define API_EMONEY_CODE_KEY @"emoney_code"
#define API_UNIK_KEY @"unik"
#define API_GRAND_TOTAL_IDR_KEY @"grand_total_idr"
#define API_DEPOSIT_AMOUNT_ID_KEY @"deposit_amount_idr"
#define API_GA_DATA_KEY @"ga_data"
#define API_DISCOUNT_GATEWAY_IDR_KEY @"discount_gateway_idr"
#define API_USER_DEFAULT_IDR_KEY @"user_deposit_idr"
#define API_MSISDN_VERIFIED_KEY @"msisdn_verified"
#define API_CONFIRMATION_CODE_KEY @"conf_code"
#define API_CONFIRMATION_DUE_DATE_KEY @"conf_due_date"
#define API_PROCESSING_KEY @"processing"
#define API_SUMMARY_GRAN_TOTAL_BEFORE_FEE_IDR_KEY @"grand_total_before_fee_idr"
#define API_DISCOUNT_GATEWAY_KEY @"discount_gateway"
#define API_STATUS_UNIK_KEY @"status_unik"
#define API_USER_DEPOSIT_KEY @"user_deposit"
#define API_LOCK_MANDIRI_KEY @"lock_mandiri"
#define API_DEPOSIT_AMOUNT_KEY @"deposit_amount"
#define API_VOUCHER_AMOUNT_KEY @"voucher_amount"
#define API_GRAND_TOTAL_BEFORE_FEE_KEY @"grand_total_before_fee"
#define API_CONFIRMATION_CODE_IDR_KEY @"conf_code_idr"
#define API_PAYMENT_LEFT_KEY @"payment_left"
#define API_DROPSHIP_LIST_KEY @"dropship_list"

#define API_TRANSACTION_SUMMARY_KEY @"transaction"
#define API_TRANSACTION_SUMMARY_PRODUCT_KET @"carts"
#define API_TRANSACTION_DATA_SHOW_KEY @"data_show"

#define API_DATA_VOUCHER_KEY @"data_voucher"
#define API_DATA_VOUCHER_AMOUNT_KEY @"voucher_amount"
#define API_DATA_VOUCHER_ID_KEY @"voucher_id"
#define API_DATA_VOUCHER_STATUS_KEY @"voucher_status"
#define API_DATA_VOUCHER_EXPIRED_KEY @"voucher_expired_time"
#define API_DATA_VOUCHER_MINIMAL_AMOUNT_KEY @"voucher_minimal_amount"

#define API_EMONEY_DATA_KEY @"data"
#define API_TRACE_NUM_KEY @"trace_num"
#define API_STATUS_KEY @"status"
#define API_NOMOR_HP_KEY @"no_hp"
#define API_TRX_ID_KEY @"trx_id"
#define API_ID_EMONEY_KEY @"id_emoney"

#define API_LINK_MANDIRI_KEY @"link_mandiri"

#pragma mark - Credit Card
#define API_CC_EDIT_FLAG_KEY @"credit_card_edit_flag"
#define API_CC_FIRST_NAME_KEY @"first_name"
#define API_CC_LAST_NAME_KEY @"last_name"
#define API_CC_CITY_KEY @"city"
#define API_CC_POSTAL_CODE_KEY @"postal_code"
#define API_CC_ADDRESS_KEY @"address_street"
#define API_CC_PHONE_KEY @"phone"
#define API_CC_STATE_KEY @"state"
#define API_CC_CARD_NUMBER_KEY @"card_number"
#define API_CC_EXP_MONTH_KEY @"card_exp_month"
#define API_CC_EXP_YEAR_KEY @"card_exp_year"
#define API_CC_CVV_KEY @"card_cvv"
#define API_CC_OWNER_KEY @"card_owner"
#define API_CC_TOKEN_ID_KEY @"credit_card_token"
#define API_CC_BANK_INSTALLMENT_KEY @"installment_bank"
#define API_CC_DURATION_INSTALLMENT_KEY @"installment_term"

#define CALCULATE_PRODUCT @""
#define CALCULATE_ADDRESS @"calculate_address_shipping"
#define CALCULATE_SHIPMENT @"calculate_shipping"
#define CALCULATE_CART @"calculate_cart"

#define API_TRANSACTION_PATH @"tx.pl"
#define API_TRANSACTION_CART_PATH @"tx-cart.pl"
#define API_ACTION_TRANSACTION_PATH @"action/tx-cart.pl"
#define API_CHECK_VOUCHER_PATH @"tx-voucher.pl"
#define API_EMONEY_PATH @"tx-payment-emoney.pl"
#define API_BCA_KLICK_PAY_PATH @"tx-payment-bcaklikpay.pl"
#define API_ACTION_CC_PATH @"action/tx.pl"

#define TRANSACTION_STANDARDTABLEVIEWCELLIDENTIFIER @"cell"
#define TRANSACTION_NODATACELLTITLE @"no data"
#define TRANSACTION_NODATACELLDESCS @"no data description"

#define PLACEHOLDER_NOTE_ATC @"Contoh : Warna hitam"

#define TITLE_ALERT_CANCEL_CART @"Konfirmasi Pembatalan Transaksi"
#define DESCRIPTION_ALERT_CANCEL_CART_PRODUCT FORMAT_CANCEL_CART_PRODUCT
#define TITLE_BUTTON_CANCEL_DEFAULT @"Tidak"
#define TITLE_BUTTON_OK_DEFAULT @"Ya"

#define FORMAT_CANCEL_CART_PRODUCT @"Pembatalan transaksi dari toko %@ untuk produk %@ senilai %@"
#define FORMAT_CANCEL_CART @"Pembatalan transaksi dari toko %@ senilai %@"
#define FORMAT_SALDO_TOKOPEDIA @"(Saldo Tokopedia Anda %@)"
#define FORMAT_PAYMENT_METHOD @"Metode Pembayaran : %@"

#define FORMAT_CART_DROPSHIP_NAME_KEY @"dropship_name-%zd-%zd-%zd-%zd"
#define FORMAT_CART_DROPSHIP_PHONE_KEY @"dropship_telp-%zd-%zd-%zd-%zd"
#define FORMAT_CART_CANCEL_PARTIAL_KEY @"fcancel_partial-%zd-%zd-%zd"
#define FORMAT_CART_DROPSHIP_STR_KEY @"%zd~%zd~%zd~%zd"
#define FORMAT_CART_DROPSHIP_STR_CART_SUMMARY_KEY @"%zd-%zd-%zd-%zd"
#define FORMAT_CART_PARTIAL_STR_KEY @"%zd~%zd~%zd"
#define FORMAT_CART_PARTIAL_STR_CART_SUMMARY_KEY @"%zd-%zd-%zd"
#define FORMAT_TOKO_TUTUP @"Toko tutup sampai tanggal : %@"
#define FORMAT_SUCCESS_BUY @"Terima kasih, Anda telah berhasil melakukan checkout pemesanan dengan memilih pembayaran %@"
#define FORMAT_TOKO_TUTUP @"Toko tutup sampai tanggal : %@"

#define ERRORMESSAGE_NULL_ADDRESS @"Alamat harus diisi."
#define ERRORMESSAGE_NULL_CART_SHIPPING_AGENT @"Agen kurir harus diisi."
#define ERRORMESSAGE_NULL_CART_PAYMENT @"Pilih Metode Pembayaran yang ingin digunakan terlebih dahulu."
#define ERRORMESSAGE_NULL_CART_PASSWORD @"Kata Sandi harus diisi."
#define ERRORMESSAGE_NULL_CART_USERID @"User ID harus diisi."

#define ERRORMESSAGE_NULL_VOUCHER_CODE @"Masukkan kode voucher terlebih dahulu."
#define ERRORMESSAGE_VOUCHER_CODE_LENGHT @"Kode voucher minimal 11 karakter."

#define ERRORMESSAGE_SENDER_NAME_NILL @"Nama pengirim harus diisi"
#define ERRORMESSAGE_SENDER_PHONE_NILL @"Telepon pengirim harus diisi"
#define ERRORMESSAGE_INVALID_PHONE_NUMBER @"Nomor Telephon Harus Lebih Dari 6 Karakter"

#define ARRAY_INSURACE @[@{DATA_NAME_KEY:@"Ya", DATA_VALUE_KEY:@(1)}, @{DATA_NAME_KEY:@"Tidak", DATA_VALUE_KEY:@(0)}]
#define ARRAY_IF_STOCK_AVAILABLE_PARTIALLY @[@{DATA_NAME_KEY:@"Batalkan keseluruhan pesanan", DATA_VALUE_KEY:@(0)}, @{DATA_NAME_KEY:@"Kirimkan stok yang tersedia", DATA_VALUE_KEY:@(1)}]

#define TAG_BUTTON_VOUCHER 12

#endif
