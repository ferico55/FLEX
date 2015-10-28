//
//  string_inbox_ticket.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_inbox_ticket_h
#define Tokopedia_string_inbox_ticket_h

#define API_PATH                    @"inbox-ticket.pl"
#define API_PATH_ACTION             @"action/ticket.pl"
#define API_PATH_ACTION_UPLOAD_IMAGE    @"action/upload-image-helper.pl"
#define API_ACTION_KEY              @"action"
#define API_GET_INBOX_TICKET        @"get_inbox_ticket"
#define API_GET_INBOX_TICKET_DETAIL @"get_inbox_ticket_detail"
#define API_GET_INBOX_TICKET_VIEW_MORE  @"get_inbox_ticket_view_more"
#define API_ACTION_GIVE_RATING      @"give_rating"
#define API_RATE_KEY                @"rate"
#define API_NEW_TICKET_STATUS_KEY   @"new_ticket_status"

#define API_STATUS_KEY              @"status"
#define API_CONFIG_KEY              @"config"
#define API_SERVER_PROCESS_TIME_KEY @"server_process_time"
#define API_RESULT_KEY              @"result"

#define API_PAGING_KEY              @"paging"
#define API_PAGING_URI_NEXT_KEY     @"uri_next"
#define API_PAGING_URI_PREV_KEY     @"uri_previous"

#define API_TICKET_INBOX_ID_KEY     @"ticket_inbox_id"

#define API_FILTER_KEY              @"filter"

#define API_LIST_KEY                @"list"

#define API_LIST_TICKET_CREATE_TIME_KEY         @"ticket_create_time"
#define API_LIST_TICKET_CREATE_TIME_FMT_KEY     @"ticket_create_time_fmt"
#define API_LIST_TICKET_CREATE_TIME_FMT2_KEY    @"ticket_create_time_fmt2"
#define API_LIST_TICKET_UPDATE_TIME_FMT_KEY     @"ticket_update_time_fmt"
#define API_LIST_TICKET_UPDATE_TIME_FMT2_KEY    @"ticket_update_time_fmt2"
#define API_LIST_TICKET_FIRST_MESSAGE_NAME_KEY  @"ticket_first_message_name"
#define API_LIST_TICKET_STATUS_KEY              @"ticket_status"
#define API_LIST_TICKET_READ_STATUS_KEY         @"ticket_read_status"
#define API_LIST_TICKET_UPDATE_IS_CS_KEY        @"ticket_update_is_cs"
#define API_LIST_TICKET_INBOX_ID_KEY            @"ticket_inbox_id"
#define API_LIST_TICKET_UPDATE_BY_URL_KEY       @"ticket_update_by_url"
#define API_LIST_TICKET_CATEGORY_KEY            @"ticket_category"
#define API_LIST_TICKET_TITLE_KEY               @"ticket_title"
#define API_LIST_TICKET_TOTAL_MESSAGE_KEY       @"ticket_total_message"
#define API_LIST_TICKET_SHOW_MORE_KEY           @"ticket_show_more"
#define API_LIST_TICKET_RESPOND_STATUS_KEY      @"ticket_respond_status"
#define API_LIST_TICKET_IS_REPLIED_KEY          @"ticket_is_replied"
#define API_LIST_TICKET_URL_DETAIL_KEY          @"ticket_url_detail"
#define API_LIST_TICKET_USER_INVOLVE_KEY        @"ticket_user_involve"
#define API_LIST_TICKET_FULL_NAME_KEY           @"full_name"
#define API_LIST_TICKET_UPDATE_BY_ID_KEY        @"ticket_update_by_id"
#define API_LIST_TICKET_ID_KEY                  @"ticket_id"
#define API_LIST_TICKET_UPDATE_BY_NAME_KEY      @"ticket_update_by_name"
#define API_LIST_TICKET_CATEGORY_ID_KEY         @"ticket_category_id"
#define API_LIST_TICKET_ATTACHMENT_KEY          @"ticket_attachment"
#define API_LIST_TICKET_INVOICE_REF_NUM_KEY     @"ticket_invoice_ref_num"

#define API_TICKET_KEY                          @"ticket"

#define API_TICKET_SHOW_REOPEN_BTN_KEY          @"ticket_show_reopen_btn"
#define API_TICKET_USER_LABEL_ID_KEY            @"ticket_user_label_id"
#define API_TICKET_USER_LABEL_KEY               @"ticket_user_label"
#define API_TICKET_FIRST_MESSAGE_IMAGE_KEY      @"ticket_first_message_image"
#define API_TICKET_FIRST_MESSAGE_KEY            @"ticket_first_message"

#define API_TICKET_REPLY_KEY                    @"ticket_reply"
#define API_TICKET_REPLY_DATA_KEY               @"ticket_reply_data"

#define API_TICKET_DETAIL_ID_KEY                @"ticket_detail_id"
#define API_TICKET_DETAIL_CREATE_TIME_KEY       @"ticket_detail_create_time"
#define API_TICKET_DETAIL_CREATE_TIME_FMT_KEY   @"ticket_detail_create_time_fmt"
#define API_TICKET_DETAIL_USER_NAME_KEY         @"ticket_detail_user_name"
#define API_TICKET_DETAIL_NEW_RATING_KEY        @"ticket_detail_new_rating"
#define API_TICKET_DETAIL_IS_CS_KEY             @"ticket_detail_is_cs"
#define API_TICKET_DETAIL_USER_URL_KEY          @"ticket_detail_user_url"
#define API_TICKET_DETAIL_USER_LABEL_ID_KEY     @"ticket_detail_user_label_id"
#define API_TICKET_DETAIL_USER_LABEL_KEY        @"ticket_detail_user_label"
#define API_TICKET_DETAIL_USER_IMAGE_KEY        @"ticket_detail_user_image"
#define API_TICKET_DETAIL_USER_ID_KEY           @"ticket_detail_user_id"
#define API_TICKET_DETAIL_NEW_STATUS_KEY        @"ticket_detail_new_status"
#define API_TICKET_DETAIL_MESSAGE_KEY           @"ticket_detail_message"
#define API_TICKET_DETAIL_ATTACHMENT_KEY        @"ticket_detail_attachment"

#define API_TICKET_DETAIL_IMG_SRC_KEY           @"img_src"
#define API_TICKET_DETAIL_IMG_LINK_KEY          @"img_link"

#define API_TICKET_REPLY_TOTAL_DATA_KEY         @"ticket_reply_total_data"
#define API_TICKET_REPLY_TOTAL_PAGE_KEY         @"ticket_reply_total_page"

#define API_TICKET_REPLY_TICKET_VALIDATION_KEY  @"reply_ticket_validation"
#define API_TICKET_REPLY_TICKET_ID_KEY          @"ticket_id"
#define API_TICKET_REPLY_MESSAGE_KEY            @"ticket_reply_message"
#define API_TICKET_REPLY_ATTACHMENT_STRING_KEY  @"attachment_string"
#define API_TICKET_REPLY_NEW_TICKET_STATUS_KEY  @"new_ticket_status"
#define API_TICKET_REPLY_RATE_KEY               @"rate"
#define API_TICKET_REPLY_SERVER_ID_KEY          @"server_id"

#define API_TICKET_REPLY_VALIDATION             @"reply_ticket_validation"
#define API_TICKET_REPLY_PICTURE                @"reply_ticket_picture"
#define API_TICKET_REPLY_SUBMIT                 @"reply_ticket_submit"

#define API_TICKET_REPLY_IS_SUCCESS_KEY         @"is_success"
#define API_TICKET_REPLY_POST_KEY               @"post_key"
#define API_TICKET_REPLY_FILE_UPLOADED_KEY      @"file_uploaded"

#define API_UPLOAD_CONTACT_IMAGE_KEY            @"upload_contact_image"
#define API_FILE_TO_UPLOAD_KEY  @"fileToUpload"

#endif
