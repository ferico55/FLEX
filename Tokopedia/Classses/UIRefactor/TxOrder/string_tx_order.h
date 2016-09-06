//
//  string_tx_order.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_tx_order_h
#define Tokopedia_string_tx_order_h

#import "string_alert.h"

typedef enum
{
    TAG_BAR_BUTTON_TRANSACTION_BACK = 10,
    TAG_BAR_BUTTON_TRANSACTION_DONE = 11
}TAG_BAR_BUTTON_TRANSACTION;

typedef enum
{
    TYPE_PAYMENT_DEFAULT,
    TYPE_PAYMENT_TRANSFER_ATM = 2,
    TYPE_PAYMENT_INTERNET_BANKING = 3,
    TYPE_PAYMENT_MOBILE_BANKING = 4,
    TYPE_PAYMENT_SALDO_TOKOPEDIA = 5,
    TYPE_PAYMENT_CASH_TRANSFER = 6
}TYPE_PAYMENT;

typedef enum
{
    TX_ORDER_STATUS_DEFAULT
}TX_ORDER_STATUS;

#define TITLE_PAYMENT_CONFIRMATION_FORM @"Konfirmasi Pembayaran"
#define TITLE_PAYMENT_EDIT_CONFIRMATION_FORM @"Ubah Konfirmasi Pembayaran"

#define DATA_DETAIL_ORDER_CONFIRMATION_KEY @"data_detail_order"
#define DATA_DETAIL_ORDER_CONFIRMED_KEY @"data_detail_order_confirmed"
#define DATA_SELECTED_ORDER_KEY @"selected_order"
#define DATA_INDEXPATH_SELECTED_ORDER @"indexpath_selected_order"
#define DATA_SELECTED_SYSTEM_BANK_KEY @"selected_system_bank"
#define DATA_SELECTED_PAYMENT_METHOD_KEY @"selected_payment_method"
#define DATA_PAYMENT_DATE_KEY @"payment_date"
#define DATA_SELECTED_BANK_ACCOUNT_KEY @"selected_bank_account"
#define DATA_SELECTED_BANK_ACCOUNT_DEFAULT_KEY @"selected_bank_account_default"
#define DATA_INDEXPATH_SYSTEM_BANK_KEY @"indexpath_system_bank"
#define DATA_INDEXPATH_PAYMENT_METHOD_KEY @"indexpath_payment_method"
#define DATA_INDEXPATH_BANK_ACCOUNT_KEY @"indexpath_bank_account"
#define DATA_TOTAL_PAYMENT_KEY @"total_payment"
#define DATA_PASSWORD_KEY @"password"
#define DATA_DEPOSITOR_KEY @"depositor"
#define DATA_MARK_KEY @"mark"
#define DATA_ORDER_DELIVERY_CONFIRM @"order_delivery_confirm"
#define DATA_INDEXPATH_DELIVERY_CONFIRM @"indexpath_delivery_confirm"
#define DATA_REQUEST_DELIVERY_CONFIRM @"request_delivery_confirm"


#pragma mark - Action
#define ACTION_GET_TX_ORDER_PAYMENT_CONFIRMED @"get_tx_order_payment_confirmed"
#define ACTION_GET_TX_ORDER_PAYMENT_CONFIRMATION @"get_tx_order_payment_confirmation"
#define ACTION_GET_TX_ORDER_STATUS @"get_tx_order_status"
#define ACTION_CANCEL_PAYMENT @"cancel_payment"
#define ACTION_GET_CANCEL_PAYMENT_FORM @"get_cancel_payment_form"
#define ACTION_GET_CONFIRM_PAYMENT_FORM @"get_confirm_payment_form"
#define ACTION_GET_EDIT_PAYMENT_FORM @"get_edit_payment_form"
#define ACTION_GET_TX_ORDER_PAYMENT_CONFIRMED_DETAIL @"get_tx_order_payment_confirmed_detail"
#define ACTION_CONFIRM_PAYMENT @"confirm_payment"
#define ACTION_EDIT_PAYMENT @"edit_payment"
#define ACTION_UPLOAD_PROOF_BY_ORDER_ID @"upload_payment_proof"
#define ACTION_UPLOAD_PROOF_BY_PAYMENT_ID @"upload_proof_by_payment"
#define ACTION_UPLOAD_PROOF_IMAGE @"upload_proof_image"
#define ACTION_DELIVERY_FINISH_ORDER @"delivery_finish_order"
#define ACTION_GET_TX_ORDER_DELIVER @"get_tx_order_deliver"
#define ACTION_GET_TX_ORDER_LIST @"get_tx_order_list"
#define ACTION_RE_ORDER @"reorder"
#define ACTION_DETIVERY_CONFIRM @"delivery_confirm"
#define ACTION_CONFIRM_PAYMENT_VALIDATION @"validate_confirm_payment"
#pragma mark -

#define API_ACTION_KEY @"action"
#define API_TOTAL_LOGISTIC_FEE_KEY @"cart_logistic_fee"
#define API_FORM_KEY @"form"
#define API_TOKEN_KEY @"token"

#define API_FORM_FIELD_NAME_PROOF @"payment_image"

#pragma mark - String Alert
#define ALERT_TITLE_CANCEL_PAYMENT_CONFIRMATION @"Konfirmasi Pembatalan Pembayaran"
#define ALERT_DESCRIPTION_CANCEL_PAYMENT_CONFIRMATION @"Apakah anda yakin membatalkan transaksi ini? \n saldo Tokopedia yang akan dikembalikan adalah sebesar : %@" //TODO::

#define ALERT_TITLE_INVOICE_LIST @"Berikut Daftar Invoice dari Nomor Pembayaran \n%@"

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
#define API_ORDER_LIST_JOB_DETAIL_KEY @"order_JOB_detail"
#define API_ORDER_LIST_PRODUCTS_KEY @"order_products"
#define API_ORDER_LIST_SHOP_KEY @"order_shop"
#define API_ORDER_LIST_BUTTON_KEY @"order_button"
#define API_ORDER_LIST_SHIPMENT_KEY @"order_shipment"
#define API_ORDER_LIST_DESTINATION_KEY @"order_destination"
#define API_ORDER_LIST_DETAIL_KEY @"order_detail"
#define API_ORDER_LIST_AUTO_RESI_KEY @"order_auto_resi"
#define API_ORDER_LIST_AUTO_AWB_KEY @"order_auto_awb"
#define API_ORDER_LIST_DEADLINE_KEY @"order_deadline"
#define API_ORDER_LIST_LAST_KEY @"order_last"
#define API_ORDER_LIST_HISTORY_KEY @"order_history"
#define API_ORDER_LIST_DESTINATION_KEY @"order_destination"
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
#define API_SHOP_PIC_KEY @"shop_pic"
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

#pragma mark - Order Deadline
#define API_DEADLINE_PROCESS_DAY_LEFT_KEY @"deadline_process_day_left"
#define API_DEADLINE_SHIPPING_DAY_LEFT_KEY @"deadline_shipping_day_left"

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

#pragma mark - System Bank
#define API_SYSTEM_BANK_LIST_KEY @"sysbank_list"
#define API_SYSTEM_BANK_KEY @"sysbank_account"
#define API_SYSTEM_BANK_ACCOUNT_NUMBER_KEY @"sysbank_account_number"
#define API_SYSTEM_BANK_ACCOUNT_NAME_KEY @"sysbank_account_name"
#define API_SYSTEM_BANK_NAME_KEY @"sysbank_name"
#define API_SYSTEM_BANK_NOTE_KEY @"sysbank_note"
#define API_SYSTEM_BANK_ID_KEY @"sysbank_id"
#define API_SYSTEM_BANK_ID_CHOOSEN_KEY @"sysbank_id_chosen"
#pragma mark -

#pragma mark - Method Payment
#define API_METHOD_LIST_KEY @"method_list"
#define API_METHOD_KEY @"method"
#define API_METHOD_ID_KEY @"method_id"
#define API_METHOD_NAME_KEY @"method_name"
#define API_METHOD_ID_CHOOSEN_KEY @"method_id_chosen"
#pragma mark -

#pragma mark - Payment Confirmation
#define API_PAYMENT_DAY_KEY @"payment_day"
#define API_PAYMENT_MONTH_KEY @"payment_month"
#define API_PAYMENT_YEAR_KEY @"payment_year"
#define API_PAYMENT_COMMENT_KEY @"comments"
#define API_PASSWORD_KEY @"password"
#define API_PASSWORD_DEPOSIT_KEY @"password_deposit"
#define API_DEPOSITOR_KEY @"depositor"

#pragma mark - Bank Account
#define API_BANK_ACCOUNT_LIST_KEY @"bank_account_list"
#define API_BANK_ACCOUNT_KEY @"bank_account"
#define API_BANK_ID_KEY @"bank_id"
#define API_BANK_NAME_KEY @"bank_name"
#define API_BANK_ACCOUNT_NAME_KEY @"bank_account_name"
#define API_BANK_ACCOUNT_BRANCH_KEY @"bank_account_branch"
#define API_BANK_ACCOUNT_NUMBER_KEY @"bank_account_number"
#define API_BANK_ACCOUNT_ID_KEY @"bank_account_id"
#define API_BANK_ACCOUNT_ID_CHOOSEN_KEY @"bank_account_id_chosen"

#define API_CANCEL_FORM_VOUCHER_USED_KEY @"voucher_used"
#define API_CANCEL_FORM_REFUND_KEY @"refund"
#define API_CANCEL_FORM_VOUCHERS_KEY @"vouchers"
#define API_CANCEL_FORM_TOTAL_REFUND_KEY @"total_refund"

#pragma mark - Path
#define API_PATH_TX_ORDER @"tx-order.pl"
#define API_PATH_ACTION_TX_ORDER @"action/tx-order.pl"
#pragma mark -

#pragma mark - Error Message
#define ERRORMESSAGE_NILL_BANK_NAME @"Nama Bank harus diisi"
#define ERRORMESSAGE_NILL_BANK_ACCOUNT_NAME @"Nama Pemilik Akun Bank harus diisi"
#define ERRORMESSAGE_NILL_BANK_ACCOUNT_NUMBER @"Nomor Rekening harus diisi"
#define ERRORMESSAGE_NILL_PASSWORD_TOKOPEDIA @"Kata sandi harus diisi"
#define ERRORMESSAGE_NILL_SYSTEM_BANK @"Bank Tujuan belum dipilih"
#define ERRORMESSAGE_NILL_BANK_ACCOUNT @"Akun Bank belum dipilih"
#define ERRORMESSAGE_INVALID_PAYMENT_AMOUNT @"Jumlah pembayaran yang diinput tidak mencukupi. Total Pembayaran sebesar Rp %zd,-"
#define ERRORMESSAGE_NILL_DEPOSITOR @"Nama Penyetor harus diisi"

#pragma mark - Order Form
#define API_ORDER_FORM_KEY @"order"
#define API_ORDER_FORM_PAYMENT_KEY @"payment"
#define API_ORDER_FORM_LEFT_AMOUNT_IDR_KEY @"order_left_amount_idr"
#define API_ORDER_FORM_DEPOSIT_USED_IDR_KEY @"order_deposit_used_idr"
#define API_ORDER_FORM_INVOICE_KEY @"order_invoice"
#define API_ORDER_FORM_CONFIRMATION_CODE_IDR_KEY @"order_confirmation_code_idr"
#define API_ORDER_FORM_GRAND_TOTAL_IDR_KEY @"order_grand_total_idr_key"
#define API_ORDER_FORM_LEFT_AMOUNT_KEY @"order_left_amount"
#define API_ORDER_FORM_CONFIRMATION_CODE_KEY @"order_confirmation_code"
#define API_ORDER_FORM_DEPOSIT_USED_KEY @"deposit_used"
#define API_ORDER_FORM_DEPOSITABLE_KEY @"order_depositable"
#define API_ORDER_FORM_GRAND_TOTAL_KEY @"order_grand_total"
#define API_ORDER_FORM_PAYMENT_AMOUNT_KEY @"order_payment_amount"
#define API_ORDER_FORM_PAYMENT_DAY_KEY @"order_payment_day"
#define API_ORDER_FORM_PAYMENT_MONTH_KEY @"order_payment_month"
#define API_ORDER_FORM_PAYMENT_YEAR_KEY @"order_payment_year"

#pragma mark - Order Last
#define API_LAST_ORDER_ID               @"last_order_id"
#define API_LAST_SHIPMENT_ID            @"last_shipment_id"
#define API_LAST_EST_SHIPPING_LEFT      @"last_est_shipping_left"
#define API_LAST_ORDER_STATUS           @"last_order_status"
#define API_LAST_ORDER_STATUS_DATE      @"last_status_date"
#define API_LAST_POD_CODE               @"last_pod_code"
#define API_LAST_POD_DESC               @"last_pod_desc"
#define API_LAST_SHIPPING_REF_NUM       @"last_shipping_ref_num"
#define API_LAST_POD_RECEIVER           @"last_pod_receiver"
#define API_LAST_COMMENTS               @"last_comments"
#define API_LAST_BUYER_STATUS           @"last_buyer_status"
#define API_LAST_STATUS_DATE_WIB        @"last_status_date_wib"
#define API_LAST_SELLER_STATUS          @"last_seller_status"

#pragma mark - Order History
#define API_HISTORY_STATUS_DATE         @"history_status_date"
#define API_HISTORY_STATUS_DATE_FULL    @"history_status_date_full"
#define API_HISTORY_ORDER_STATUS        @"history_order_status"
#define API_HISTORY_COMMENTS            @"history_comments"
#define API_HISTORY_ACTION_BY           @"history_action_by"
#define API_HISTORY_BUYER_STATUS        @"history_buyer_status"
#define API_HISTORY_SELLER_STATUS       @"history_seller_status"

#pragma mark - Order Button
#define API_BUTTON_OPEN_DISPUTE_KEY @"button_open_dispute"
#define API_BUTTON_RES_CENTER_URL_KEY @"button_res_center_url"
#define API_BUTTON_OPEN_TIME_LEFT_KEY @"button_open_time_left"
#define API_BUTTON_RES_CENTER_GO_TO_KEY @"button_res_center_go_to"
#define API_BUTTON_UPLOAD_PROOF_KEY @"button_upload_proof"

#define API_ACTION_KEY @"action"
#define API_IS_SUCCESS_KEY @"is_success"
#define API_ORDER_ID_KEY @"order_id"

#pragma mark - Confirmed
#define API_ORDER_DETAIL_KEY @"tx_order_detail"
#define API_DETAIL_KEY @"detail"
#define API_PAYMENT_KEY @"payment"
#define API_INVOICE_KEY @"invoice"
#define API_INVOICE_STRING_KEY @"order_invoice_string"
#define API_INVOICE_LIST_KEY @"order_invoice"
#define API_URL_KEY @"url"
#define API_PAYMENT_ID_KEY @"payment_id"
#define API_PAYMENT_REF_KEY @"payment_ref"
#define API_PAYMENT_DATE_KEY @"payment_date"

#define API_TRANSACTION_STATUS_KEY @"status"
#define API_TRANSACTION_START_DATE_KEY @"start"
#define API_TRANSACTION_END_DATE_KEY @"end"

#define COLOR_STATUS_CANCEL_3DAYS [UIColor colorWithRed:0/255.f green:121.f/255.f blue:255.f/255.f alpha:1]
#define COLOR_STATUS_CANCEL_TOMORROW [UIColor colorWithRed:255.f/255.f green:145.f/255.f blue:0/255.f alpha:1]
#define COLOR_STATUS_CANCEL_TODAY [UIColor colorWithRed:255.f/255.f green:59.f/255.f blue:48.f/255.f alpha:1]
#define COLOR_STATUS_EXPIRED [UIColor colorWithRed:158.f/255.f green:158.f/255.f blue:158.f/255.f alpha:1]

#define ALERT_DELIVERY_CONFIRM_FORMAT @"Sudah Diterima\nApakah Anda yakin pesanan dari toko %@ sudah diterima?"
#define ALERT_DELIVERY_CONFIRM_FORMAT_FREE_RETURN @"Sudah Diterima"

#define ALERT_DELIVERY_CONFIRM_DESCRIPTION @"Klik Selesai untuk menyelesaikan transaksi dan meneruskan dana ke penjual.\nKlik Komplain jika pesanan yang diterima berkendala (kurang/rusak/ lain-lain)."

#define ALERT_DELIVERY_CONFIRM_DESCRIPTION_FREE_RETURN @"Transaksi ini difasilitasi fitur Free Returns dan akan otomatis selesai dalam waktu 3 hari. Dalam jangka waktu tersebut, Anda bisa menyampaikan komplain lewat Pusat Resolusi untuk mengajukan retur produk."

#define ALERT_REORDER_TITLE @"Pemesanan Ulang"
#define ALERT_REORDER_DESCRIPTION @"Apakah Anda ingin melakukan pemesanan ulang terhadap produk ini ?"

#pragma mark - Array
//#define ARRAY_PAYMENT_METHOD @[@{DATA_NAME_KEY :@"Transfer ATM",DATA_VALUE_KEY:@(TYPE_PAYMENT_TRANSFER_ATM)},@{DATA_NAME_KEY :@"Internet Banking",DATA_VALUE_KEY:@(TYPE_PAYMENT_INTERNET_BANKING)}, @{DATA_NAME_KEY :@"Mobile Banking",DATA_VALUE_KEY:@(TYPE_PAYMENT_MOBILE_BANKING)}, @{DATA_NAME_KEY :@"Saldo Tokopedia",DATA_VALUE_KEY:@(TYPE_PAYMENT_SALDO_TOKOPEDIA)},@{DATA_NAME_KEY :@"Setoran/ Transfer Tunai",DATA_VALUE_KEY:@(TYPE_PAYMENT_CASH_TRANSFER)}]
//
#endif
