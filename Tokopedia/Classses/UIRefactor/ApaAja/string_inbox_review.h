//
//  string_inbox_talk.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_inbox_review_h
#define Tokopedia_string_inbox_review_h

/** key for param */
#define ACTION_API_KEY @"action"
#define NAV_API_KEY @"nav"
#define LIMIT_API_KEY @"limit"
#define PAGE_API_KEY @"page"
#define FILTER_API_KEY @"filter"
#define KEYWORD_API_KEY @"keyword"

#define GET_INBOX_REVIEW @"get_inbox_review"
#define INBOX_REVIEW_LIMIT_VALUE @5
#define TIMEOUT_TIMER_MAX 10.0

#define NAV_TALK @"inbox-talk"
#define NAV_TALK_MYPRODUCT @"inbox-talk-my-product"
#define NAV_TALK_FOLLOWING @"inbox-talk-following"

#define SEGMENT_INBOX_TALK 0
#define SEGMENT_INBOX_TALK_MY_PRODUCT 1
#define SEGMENT_INBOX_TALK_FOLLOWING 2

#define ALL_TALK @"Semua Diskusi"
#define UNREAD_TALK @"Belum Dibaca"

#define EDIT_TALK @"Edit"
#define COMMENT_TALK @"Comment"

#define PAGE_TO_CACHE 1

#define PROMPT_DELETE_TALK @"Apakah Anda yakin ingin menghapus diskusi ini ?"
#define PROMPT_DELETE_TALK_MESSAGE @"Diskusi yg sudah dihapus, tidak dapat dikembalikan"
#define BUTTON_CANCEL @"Tidak"
#define BUTTON_OK @"Ya"

#define ADD_REVIEW_PATH @"action/review.pl"
#define STATE_PRODUCT_BANNED @"-2"
#define STATE_PRODUCT_DELETED @"0"

#endif