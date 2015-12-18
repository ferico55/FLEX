//
//  string_inbox_resolution_center.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_inbox_resolution_center_h
#define Tokopedia_string_inbox_resolution_center_h

typedef enum {
    SOLUTION_REFUND         = 1,
    SOLUTION_RETUR          = 2,
    SOLUTION_RETUR_REFUND   = 3,
    SOLUTION_SELLER_WIN     = 4,
    SOLUTION_SEND_REMAINING = 5,
    SOLUTION_CHECK_COURIER  = 6
}TYPE_LAST_SOLUTION;

typedef enum {
    TROUBLE_DIFF_DESCRIPTION    = 1,
    TROUBLE_BROKEN              = 2,
    TROUBLE_DIFF_QUANTITY       = 3,
    TROUBLE_DIFF_CARRIER        = 4
}TYPE_TROUBLE;

typedef enum {
    ACTION_BY_BUYER         = 1,
    ACTION_BY_SELLER        = 2,
    ACTION_BY_TOKOPEDIA     = 3
}TYPE_ACTION_BY;

#define API_ACTION_KEY @"action"
#define API_RESOLUTION_ID_KEY @"resolution_id"
#define API_SHIPPING_REF_KEY @"shipping_ref"
#define API_REPLAY_MESSAGE_KEY @"reply_msg"
#define API_REMARK_KEY @"remark"
#define API_SHIPMENT_KEY @"shipment"
#define API_SHIPMENT_ID_KEY @"shipment_id"
#define API_CONVERSATION_ID_KEY @"conversation_id"
#define API_LAST_UPDATE_TIME_KEY @"last_ut"
#define API_START_UPDATE_TIME_KEY @"start_ut"
#define API_STATUS_KEY @"status"
#define API_COMPLAIN_TYPE_KEY @"as"
#define API_UNREAD_KEY @"unread"
#define API_SORT_KEY @"sort_type"
#define API_PAGE_KEY @"page"
#define API_ORDER_ID_KEY @"order_id"
#define API_FLAG_RECIEVED_KEY @"flag_received"
#define API_TROUBLE_TYPE_KEY @"trouble_type"
#define API_SOLUTION_KEY @"solution"
#define API_REFUND_AMOUNT_KEY @"refund_amount"
#define API_REMARK_KEY @"remark"
#define API_PHOTOS_KEY @"photos"
#define API_SERVER_ID_KEY @"server_id"
#define API_EDIT_SOLUTION_FLAG_KEY @"edit_solution_flag"
#define API_UPLOAD_PRODUCT_IMAGE_DATA_NAME @"fileToUpload"

#define ACTION_GET_RESOLUTION_CENTER @"get_resolution_center"
#define ACTION_GET_RESOLUTION_CENTER_DETAIL @"get_resolution_center_detail"
#define ACTION_GET_RESOLUTION_CENTER_DETAIL_LOAD_MORE @"get_resolution_center_show_more"
#define ACTION_GET_SHIPMENT_LIST @"get_kurir_list"

#define ACTION_CREATE_RESOLUTION @"create_resolution"
#define ACTION_UPLOAD_CONTACT_IMAGE @"upload_contact_image"
#define ACTION_CANCEL_RESOLUTION @"cancel_resolution"
#define ACTION_INPUT_RECEIPT @"input_resi_resolution"
#define ACTION_EDIT_RECEIPT @"edit_resi_resolution"
#define ACTION_INPUT_RECEIPT @"input_resi_resolution"
#define ACTION_ACCEPT_SOLUTION @"accept_resolution"
#define ACTION_ACCEPT_ADMIN_SOLUTION @"accept_admin_resolution"
#define ACTION_FINISH_RESOLUTION @"finish_resolution_retur"
#define ACTION_REPLY_CONVERSATION @"reply_conversation_validation"
#define ACTION_APPEAL @"reject_admin_resolution_validation"
#define ACTION_REPORT_RESOLUTION @"report_resolution"

#define API_RESOLUTION_DETAIL_KEY @"resolution_detail"
#define API_RESOLUTION_DETAIL_CONVERSATION_KEY @"detail"

#pragma mark - Resolution last
#define API_RESOLUTION_LAST_KEY @"resolution_last"
#define API_LAST_RESOLUTION_ID_KEY @"last_resolution_id"
#define API_LAST_ACTION_BY_KEY @"last_action_by"
#define API_LAST_SHOW_APPEAL_BUTTON_KEY @"last_show_appeal_button"
#define API_LAST_RIVAL_ACCEPTED_KEY @"last_rival_accepted"
#define API_LAST_REFUND_AMOUNT_IDR_KEY @"last_refund_amt_idr"
#define API_LAST_REFUND_AMOUNT_KEY @"last_refund_amt"
#define API_LAST_USER_NAME_KEY @"last_user_name"
#define API_LAST_SOLUTION_KEY @"last_solution"
#define API_LAST_USER_URL_KEY @"last_user_url"
#define API_LAST_CREATE_TIME_STR_KEY @"last_create_time_str"
#define API_LAST_TROUBLE_TYPE_KEY @"last_trouble_type"
#define API_LAST_SHOW_ACCEPT_ADMIN_BUTTON_KEY @"last_show_accept_admin_button"
#define API_LAST_CREATE_TIME_KEY @"last_create_time"
#define API_LAST_FLAG_RECIEVED_KEY @"last_flag_received"
#define API_LAST_SHOW_ACCEPT_BUTTON_KEY @"last_show_accept_button"
#define API_LAST_SHOW_INPUT_RESI_BUTTON_KEY @"last_show_input_resi_button"
#define API_LAST_SHOW_FINISH_BUTTON_KEY @"last_show_finish_button"

#pragma mark - Resolution Order
#define API_RESOLUTION_ORDER_KEY @"resolution_order"
#define API_ORDER_PDF_URL_KEY @"order_pdf_url"
#define API_ORDER_SHIPPING_PRICE_IDR_KEY @"order_shipping_price_idr"
#define API_ORDER_OPEN_AMOUNT_IDR_KEY @"order_open_amount_idr"
#define API_ORDER_SHIPPING_PRICE_KEY @"order_shipping_price"
#define API_ORDER_OPEN_AMOUNT_KEY @"order_open_amount"
#define API_ORDER_INVOICE_REF_NUM_KEY @"order_invoice_ref_num"

#pragma mark - Resolution By
#define API_RESOLUTION_BY_KEY @"resolution_by"
#define API_BY_CUSTOMER_KEY @"by_customer"
#define API_BY_SELLER_KEY @"by_seller"
#define API_BY_USER_LABEL @"user_label"
#define API_BY_USER_LABEL_ID @"user_label_id"

#pragma mark - Resolution Shop
#define API_RESOLUTION_SHOP_KEY @"resolution_shop"
#define API_SHOP_IMAGE_KEY @"shop_image"
#define API_SHOP_NAME_KEY @"shop_name"
#define API_SHOP_URL_KEY @"shop_url"
#define API_SHOP_ID_KEY @"shop_id"

#pragma mark - Resolution Customer
#define API_RESOLUTION_CUSTOMER_KEY @"resolution_customer"
#define API_CUSTOMER_URL_KEY @"customer_url"
#define API_CUSTOMER_NAME_KEY @"customer_name"
#define API_CUSTOMER_IMAGE_KEY @"customer_image"

#pragma mark - Resolution Disute
#define API_RESOLUTION_DISPUTE_KEY @"resolution_dispute"
#define API_DISPUTE_UPDATE_TIME_KEY @"dispute_update_time"
#define API_DISPUTE_IS_RESPONDED_KEY @"dispute_is_responded"
#define API_DISPUTE_CREATE_TIME_KEY @"dispute_create_time"
#define API_DISPUTE_IS_EXPIRED_KEY @"dispute_is_expired"
#define API_DISPUTE_UPDATE_TIME_SHORT_KEY @"dispute_update_time_short"
#define API_DISPUTE_IS_CALL_ADMINT_KEY @"dispute_is_call_admin"
#define API_DISPUTE_CREATE_TIME_SHORT_KEY @"dispute_create_time_short"
#define API_DISPUTE_STATUS_KEY @"dispute_status"
#define API_DISPUTE_DEADLINE_KEY @"dispute_deadline"
#define API_DISPUTE_RESOLUTION_ID_KEY @"dispute_resolution_id"
#define API_DISPUTE_DETAIL_URL_KEY @"dispute_detail_url"
#define API_DISPUTE_30_DAYS_KEY @"dispute_30_days"

#pragma mark - Resolution Conversation
#define API_RESOLUTION_CONVERSATION_KEY @"resolution_conversation"
#define API_CONVERSATION_REMARK_KEY @"remark"
#define API_CONVERSATION_ID_KEY @"conversation_id"
#define API_CONVERSATION_TIME_AGO_KEY @"time_ago"
#define API_CONVERSATION_CREATE_TIME_KEY @"create_time"
#define API_CONVERSATION_REFUND_AMOUNT_KEY @"refund_amt"
#define API_CONVERSATION_FLAG_RECEIVED_KEY @"flag_received"
#define API_CONVERSATION_USER_URL_KEY @"user_url"
#define API_CONVERSATION_CREATE_TIME_WIB_KEY @"create_time_wib"
#define API_CONVERSATION_USER_NAME_KEY @"user_name"
#define API_CONVERSATION_USER_IMAGE_KEY @"user_img"
#define API_CONVERSATION_SOLUTION_KEY @"solution"
#define API_CONVERSATION_REMARK_STRING_KEY @"remark_str"
#define API_CONVERSATION_TROUBLE_TYPE_KEY @"trouble_type"
#define API_CONVERSATION_REFUND_AMOUNT_IDR_KEY @"refund_amt_idr"
#define API_CONVERSATION_ACTION_BY_KEY @"action_by"
#define API_CONVERSATION_SOLUTION_FLAG_KEY @"solution_flag"
#define API_CONVERSATION_SYSTEM_FLAG_KEY @"system_flag"
#define API_CONVERSATION_LEFT_COUNT_KEY @"left_count"
#define API_CONVERSATION_FLAG_VIEW_MORE_KEY @"view_more"
#define API_CONVERSATION_RESI_NUMBER_KEY @"input_resi"
#define API_CONVERSATION_SHIPMENT_NAME_KEY @"kurir_name"
#define API_CONVERSATION_SHIPMENT_KEY @"input_kurir"
#define API_CONVERSATION_SHOW_TRACK_BUTTON_KEY @"show_track_button"
#define API_CONVERSATION_SHOW_EDIT_RESI_BUTTON_KEY @"show_edit_resi_button"

#pragma mark - Resolution Attachment
#define API_RESOLUTION_ATTACHMENT_KEY @"attachment"
#define API_ATTACHMENT_REAL_FILE_URL_KEY @"real_file_url"
#define API_ATTACHMENT_FILE_URL_KEY @"file_url"

#pragma mark - Resolution Button
#define API_RESOLUTION_BUTTON_KEY @"resolution_button"
#define API_BUTTON_REPORT_KEY @"button_report"
#define API_BUTTON_NO_BUTTON_KEY @"button_no_btn"
#define API_BUTTON_EDIT_KEY @"button_edit"
#define API_BUTTON_CANCEL_KEY @"button_cancel"

#define API_FLAG_CAN_CONVERSATION_KEY @"resolution_can_conversation"
#define API_RESOLUTION_CONFERSATION_COUNT_KEY @"resolution_conversation_count"

#define API_RESOLUTION_READ_STATUS_KEY @"resolution_read_status"

#define API_PATH_INBOX_RESOLUTION_CENTER @"inbox-resolution-center.pl"
#define API_PATH_ACTION_RESOLUTION_CENTER @"action/resolution-center.pl"

#define COLOR_STATUS_PROCESSING [UIColor colorWithRed:255.f/255.f green:145.f/255.f blue:0.f/255.f alpha:1]
#define COLOR_STATUS_DONE [UIColor colorWithRed:117.f/255.f green:117.f/255.f blue:117.f/255.f alpha:1]

#define COLOR_BUYER [UIColor colorWithRed:255.f/255.f green:145.f/255.f blue:0.f/255.f alpha:1]
#define COLOR_SELLER [UIColor colorWithRed:18.f/255.f green:199.f/255.f blue:0.f/255.f alpha:1]
#define COLOR_TOKOPEDIA [UIColor colorWithRed:117.f/255.f green:117.f/255.f blue:117.f/255.f alpha:1]

#define COLOR_BLUE_DEFAULT [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:255.f/255.f alpha:1]
#define COLOR_PENDING_AMOUNT [UIColor colorWithRed:255.f/255.f green:85.f/255.f blue:0.f/255.f alpha:1]


#define ERRORMESSAGE_NULL_REMARK @"Alasan harus diisi."
#define ERRORMESSAGE_NULL_REFUND @"Jumlah Pengembalian harus diisi."
#define ERRORMESSAGE_NULL_MESSAGE @"Pesan diskusi harus diisi"

#define ERRORMESSAGE_INVALID_REFUND @"Nominal maksimal pengembalian dana adalah %@."

#define ARRAY_FILTER_PROCESS @[@"Dalam Proses",@"Komplain > 10 hari",@"Sudah Selesai",@"Semua"]
#define ARRAY_FILTER_UNREAD @[@"Semua Status",@"Belum Ditanggapi",@"Belum dibaca"]
#define ARRAY_FILTER_SORT @[@"Waktu dibuat",@"Perubahan Terbaru"]

#define ARRAY_PROBLEM_COMPLAIN @[@"Barang tidak sesuai deskripsi", @"Barang rusak", @"Barang tidak lengkap", @"Agen kurir yang digunakan tidak sesuai permintaan"]

#define ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION @[@"Kembalikan Dana",@"Tukar barang sesuai pesanan",@"Retur barang dan kembalikan dana"]
#define ARRAY_SOLUTION_PRODUCT_IS_BROKEN ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION
#define ARRAY_SOLUTION_DIFFERENT_QTY @[@"Kembalikan Dana",@"Kirim barang sisanya",@"Retur barang dan kembalikan dana"]
#define ARRAY_SOLUTION_DIFFERENT_SHIPPING_AGENCY @[]

#define ARRAY_SOLUTION_PACKAGE_NOT_RECEIVED_CHANGE_SOLUTION @[@"Kembalikan Dana"]
#define ARRAY_SOLUTION_PACKAGE_NOT_RECEIVED @[@"Kembalikan Dana",@"Minta bantuan penjual cek ke kurir"]

#endif
