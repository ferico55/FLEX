//
//  string_new_order.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_order_h
#define Tokopedia_string_order_h

#define API_PAGE_KEY                    @"page"
#define API_LIST_KEY                    @"list"
#define API_PAGING_KEY                  @"paging"
#define API_ORDER_KEY                   @"order"
#define API_ACTION_KEY                  @"action"

#define API_NEW_ORDER_PATH              @"myshop-order.pl"
#define API_NEW_ORDER_ACTION_PATH       @"action/myshop-order.pl"
#define API_GET_NEW_ORDER_KEY           @"get_order_new"
#define API_GET_NEW_ORDER_PROCESS_KEY   @"get_order_process"
#define API_PROCEED_ORDER_KEY           @"proceed_order"

#define API_ACTION_TYPE_KEY             @"action_type"
#define API_ORDER_ID_KEY                @"order_id"
#define API_REASON_KEY                  @"reason"
#define API_LIST_PRODUCT_ID_KEY         @"list_product_id"
#define API_PRODUCT_QUANTITY_KEY        @"qty_accept"

#define API_USER_ID_KEY                 @"user_id"

#define API_LIST_ORDER_JOB_STATUS       @"order_JOB_status"
#define API_LIST_ORDER_CUSTOMER         @"order_customer"
#define API_LIST_ORDER_PAYMENT          @"order_payment"
#define API_LIST_ORDER_DETAIL           @"order_detail"
#define API_LIST_ORDER_AUTO_RESI        @"order_auto_resi"
#define API_LIST_ORDER_DEADLINE         @"order_deadline"
#define API_LIST_ORDER_AUTO_AWB         @"order_auto_awb"
#define API_LIST_ORDER_PRODUCTS         @"order_products"
#define API_LIST_ORDER_SHIPMENT         @"order_shipment"
#define API_LIST_ORDER_LAST             @"order_last"
#define API_LIST_ORDER_HISTORY          @"order_history"
#define API_LIST_ORDER_DESTINATION      @"order_destination"

#define API_PAGING_URI_NEXT             @"uri_next"
#define API_PAGING_URI_PREVIOUS         @"uri_previous"

#define API_ORDER_IS_ALLOW_MANAGE_TX    @"is_allow_manage_tx"
#define API_ORDER_SHOP_NAME             @"shop_name"
#define API_ORDER_IS_GOLD_SHOP          @"is_gold_shop"

#define API_CUSTOMER_URL                @"customer_url"
#define API_CUSTOMER_ID                 @"customer_id"
#define API_CUSTOMER_NAME               @"customer_name"
#define API_CUSTOMER_IMAGE              @"customer_image"

#define API_PAYMENT_PROCESS_DUE_DATE    @"payment_process_due_date"
#define API_PAYMENT_KOMISI              @"payment_komisi"
#define API_PAYMENT_VERIFY_DATE         @"payment_verify_date"
#define API_PAYMENT_SHIPPING_DUE_DATE   @"payment_shipping_due_date"
#define API_PAYMENT_PROCESS_DAY_LEFT    @"payment_process_day_left"
#define API_PAYMENT_GATEWAY_ID          @"payment_gateway_id"
#define API_PAYMENT_GATEWAY_IMAGE       @"payment_gateway_image"
#define API_PAYMENT_SHIPPING_DAY_LEFT   @"payment_shipping_day_left"
#define API_PAYMENT_GATEWAY_NAME        @"payment_gateway_name"

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
#define API_DETAIL_TOTAL_ADD_FEE        @"detail_total_add_fee"
#define API_DETAIL_OPEN_AMOUNT_IDR      @"detail_open_amount_idr"
#define API_DETAIL_FORCE_CANCEL         @"detail_force_cancel"

#define API_DEADLINE_PROCESS_DAY_LEFT   @"deadline_process_day_left"
#define API_DEADLINE_SHIPPING_DAY_LEFT  @"deadline_shipping_day_left"

#define API_ORDER_DELIVERY_QUANTITY     @"order_deliver_quantity"
#define API_PRODUCT_PICTURE             @"product_picture"
#define API_PRODUCT_PRICE               @"product_price"
#define API_ORDER_DETAIL_ID             @"order_detail_id"
#define API_PRODUCT_NOTES               @"product_notes"
#define API_PRODUCT_STATUS              @"product_status"
#define API_ORDER_SUBTOTAL_PRICE        @"order_subtotal_price"
#define API_PRODUCT_ID                  @"product_id"
#define API_PRODUCT_QUANTITY            @"product_quantity"
#define API_PRODUCT_WEIGHT              @"product_weight"
#define API_ORDER_SUBTOTAL_PRICE_IDR    @"order_subtotal_price_idr"
#define API_PRODUCT_REJECT_QUANTITY     @"product_reject_quantity"
#define API_PRODUCT_NAME                @"product_name"
#define API_PRODUCT_URL                 @"product_url"

#define API_SHIPMENT_LOGO               @"shipment_logo"
#define API_SHIPMENT_PACKAGE_ID         @"shipment_package_id"
#define API_SHIPMENT_ID                 @"shipment_id"
#define API_SHIPMENT_PRODUCT            @"shipment_product"
#define API_SHIPMENT_NAME               @"shipment_name"

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

#define API_HISTORY_STATUS_DATE         @"history_status_date"
#define API_HISTORY_STATUS_DATE_FULL    @"history_status_date_full"
#define API_HISTORY_ORDER_STATUS        @"history_order_status"
#define API_HISTORY_COMMENTS            @"history_comments"
#define API_HISTORY_ACTION_BY           @"history_action_by"
#define API_HISTORY_BUYER_STATUS        @"history_buyer_status"
#define API_HISTORY_SELLER_STATUS       @"history_seller_status"

#define API_RECEIVER_NAME               @"receiver_name"
#define API_ADDRESS_COUNTRY             @"address_country"
#define API_ADDRESS_POSTAL              @"address_postal"
#define API_ADDRESS_DISTRICT            @"address_district"
#define API_RECEIVER_PHONE              @"receiver_phone"
#define API_ADDRESS_STREET              @"address_street"
#define API_ADDRESS_CITY                @"address_city"
#define API_ADDRESS_PROVINCE            @"address_province"

#endif