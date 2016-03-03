//
//  Tkpd.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_Tkpd_h
#define Tokopedia_Tkpd_h

//#define kTkpdBaseURLString @"http://www.ft-feby.ndvl/ws"
//#define kTkpdBaseURLString @"http://www.tx-tonito.dvl/ws"
//#define kTkpdBaseURLString @"http://www.py-purnaresa.ndvl/ws"
//#define kTkpdBaseURLString @"http://staging.tokopedia.com/ws"


//#if DEBUG
//    #define kTkpdBaseURLString @"http://www.tkpdevel-pg.api/ws"
//#else
//    #define kTkpdBaseURLString @"http://www.tx-tonito.dvl/ws"
//#endif
//#define kTkpdBaseURLString @"http://new.ws-wendy.ndvl/ws"
//#define kTkpdBaseURLString @"http://new.ex-adreass.ndvl/ws"
//#define kTkpdBaseURLString @"http://new.at-alvin.ndvl/ws"
//#define kTkpdBaseURLString @"http://new.fp-farissa.ndvl/ws"
#define kTkpdBaseURLString @"http://www.tokopedia.com/ws"
//#define kTkpdBaseURLHttpsString @"https://ws.tokopedia.com/ws"
#define kTkpdBaseURLHttpsString @"https://ws-staging.tokopedia.com/ws"
//#define kTkpdBaseURLHttpsString @"http://new.ws-wendy.ndvl/ws"
//#define kTkpdBaseURLString @"http://www.ef-risky.dvl/ws"


#define kTKPD_AUTHKEY @"auth"
#define kTKPD_ISLOGINKEY @"is_login"
#define kTKPD_DEVICETOKENKEY @"device_token"
#define kTKPD_USERIMAGEKEY @"user_image"
#define kTKPD_USERIDKEY @"user_id"
#define kTKPD_TMP_USERIDKEY @"tmp_user_id"
#define kTKPD_FULLNAMEKEY @"full_name"
#define kTKPD_SHOPIDKEY @"shop_id"
#define kTKPD_PRODUCTIDKEY @"product_id"
#define kTKPD_SHOPNAMEKEY @"shop_name"
#define kTKPD_SHOPIMAGEKEY @"shop_avatar"
#define kTKPD_USEREMAIL @"user_email"
#define kTKPD_SHOPURL @"shop_url"
#define kTKPD_SHOPISGOLD @"shop_is_gold"
#define kTKPD_NULLCOMMENTKEY @"0"
#define kTKPD_SHOP_AVATAR @"shop_avatar"
#define LAST_CATEGORY_VALUE @"last_category_value"
#define LAST_CATEGORY_NAME @"last_category_name"

#define DATA_PAYMENT_CONFIRMATION_COUNT_KEY @"data_payment_conf"
#define DATA_STATUS_COUNT_KEY @"data_status"
#define DATA_CONFIRM_DELIVERY_COUNT_KEY @"data_confirm_delivery"

typedef enum {
    ORDER_CANCELED                       =   0,   // update by ADMIN/SYSTEM order canceled for some reason
    ORDER_CANCELED_CHECKOUT              =   1,   // update by BUYER        cancel checkout baru, apabila dia 2x checkout
    ORDER_REJECTED                       =  10,   // update by SELLER       seller rejected the order
    ORDER_CHECKOUT_STATE                 =  90,   // update by BUYER        order status sebelum checkout, tidak tampil dimana2
    ORDER_PENDING                        = 100,   // update by BUYER        checked out an item in the shopping cart
    ORDER_PENDING_UNIK                   = 101,   // update by SYSTEM       fail UNIK payment
    ORDER_CREDIT_CARD_CHALLENGE          = 102,   // update by BUYER        credit card payment status challenge
    ORDER_WAITING_THIRD_PARTY            = 103,   // update by BUYER        When using third party API where they will hit our API
    ORDER_PENDING_DUE_DATE               = 120,   // update by SYSTEM       after order age > 3 days
    ORDER_PAYMENT_CONFIRM                = 200,   // update by BUYER        confirm a payment
    ORDER_PAYMENT_CONFIRM_UNIK           = 201,   // update by BUYER        confirm a payment for UNIK
    ORDER_PAYMENT_DUE_DATE               = 210,   // update by SYSTEM       after order age > 6 days
    ORDER_PAYMENT_VERIFIED               = 220,   // update by SYSTEM       payment received and verified, ready to process
    ORDER_PROCESS                        = 400,   // update by SELLER       seller accepted the order
    ORDER_PROCESS_PARTIAL                = 401,   // update by SELLER       seller accepted the order, partially
    ORDER_PROCESS_DUE_DATE               = 410,   // update by SYSTEM       untouch verified order after payment age > 3 days
    ORDER_SHIPPING                       = 500,   // update by SELLER       seller confirm for shipment
    ORDER_SHIPPING_WAITING               = 501,   // update by ADMIN        status change to waiting resi have no input
    ORDER_SHIPPING_DATE_EDITED           = 505,   // update by ADMIN        seller input an invalid shipping date
    ORDER_SHIPPING_DUE_DATE              = 510,   // update by SYSTEM       seller not confirm for shipment after order accepted and payment age  >5 days
    ORDER_SHIPPING_TRACKER_INVALID       = 520,   // update by SYSTEM       invalid shipping ref num
    ORDER_SHIPPING_REF_NUM_EDITED        = 530,   // update by ADMIN        requested by user for shipping ref number correction because false entry
    ORDER_DELIVERED                      = 600,   // update by TRACKER      tells that buyer received the packet
    ORDER_CONFLICTED                     = 601,   // update by BUYER        Buyer open a case to finish an order
    ORDER_DELIVERED_CONFIRM              = 610,   // update by BUYER        buyer confirm for delivery
    ORDER_DELIVERED_DUE_DATE             = 620,   // update by SYSTEM       no response after delivery age > 3 days
    ORDER_DELIVERY_FAILURE               = 630,   // update by BUYER        buyer claim that he/she does not received any package
    ORDER_DELIVERED_DUE_LIMIT            = 699,   // update by SYSTEM       Order invalid/shipping > 30 days and payment dipending 5 hari/
    ORDER_FINISHED                       = 700,   // update by ADMIN        order complete verification
    ORDER_FINISHED_BOUNCE_BACK           = 701,   // update by ADMIN        order yang dianggap selesai tetapi barang tidak sampai ke buyer
    ORDER_FINISHED_REFUND_VOUCHER_PROMO  = 702,   // update by ADMIN        this is same like ORDER FINISHED, only this is flag that the order finished by refund the voucher to user because of failed payment
    ORDER_REFUND                         = 800,   // update by ADMIN        order refund to the buyer for some reason
    ORDER_ROLLBACK                       = 801,   // update by ADMIN        order rollback from finished
    ORDER_BAD                            = 900    // update by ADMIN        bad order occurs and need further investigation
} ORDER_STATUS;

typedef enum {
    RESOLUTION_CANCELED     = 0,
    RESOLUTION_OPEN         = 100,
    RESOLUTION_DO_ACTION    = 200,
    RESOLUTION_CS_ANSWERED  = 300,
    RESOLUTION_APPEAL       = 400,
    RESOLUTION_FINISHED     = 500
} DISPUTE_STATUS;

typedef enum {
    PRODUCT_STATE_DELETED       = 0,
    PRODUCT_STATE_ACTIVE        = 1,
    PRODUCT_STATE_BEST          = 2,
    PRODUCT_STATE_WAREHOUSE     = 3,
    PRODUCT_STATE_PENDING       = -1,
    PRODUCT_STATE_BANNED        = -2,
} PRODUCT_STATUS;

#define is4inch  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

#define kTkpdIndexSetStatusCodeOK [NSIndexSet indexSetWithIndex:200] //statuscode 200 = OK

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define iOS7_0 @"7.0"
#define iOS8_0 @"8.0"

#define TKPD_FADEANIMATIONDURATION 0.3

#define kTKPD_ETALASEPOSTNOTIFICATIONNAMEKEY @"setetalase"
#define kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY @"setuserinfo"
#define kTKPD_SETUSERSTICKYERRORMESSAGEKEY @"stickyerrormessage"
//#define kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY @"stickysuccessmessage"

#define kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY @"setsegmentcontrol"
#define kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY @"setDepartmentID"
#define kTKPD_CATEGORY_HIDE_TAB_BAR @"hideTabView"

#define CATALOG_SELECTED_INDEXPATH_POST_NOTIFICATION_NAME @"choosenIndexPath"

#define kTKPD_CROPIMAGEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_CROPIMAGEPOSTNOTIFICATIONNAMEKEY"

#define kTKPD_ADDETALASEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDETALASEPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY @"tokopeida.kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY"
#define kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY"

#define DID_CANCEL_COMPLAIN_NOTIFICATION_NAME @"DidCancelComplain"

#define ADD_PRODUCT_POST_NOTIFICATION_NAME @"tokopedia.ADDPRODUCTPOSTNOTIFICATIONNAME"
#define MOVE_PRODUCT_TO_ETALASE_NOTIFICATION @"tokopedia.MOVE_PRODUCT_TO_ETALASE_NOTIFICATION"
#define MOVE_PRODUCT_TO_WAREHOUSE_NOTIFICATION @"tokopedia.MOVE_PRODUCT_TO_WAREHOUSE_NOTIFICATION"

#define REFRESH_TX_ORDER_POST_NOTIFICATION_NAME @"tokopedia.REFRESH_TX_ORDER_POST_NOTIFICATION_NAME"

#define kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY"
#define EDIT_SHOP_AVATAR_NOTIFICATION_NAME @"tokopedia.EDIT_SHOP_AVATAR"

#define UPDATE_TABBAR @"UPDATE_TABBAR"

#define kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION @"tokopedia.kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION"
#define kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION @"tokopedia.kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION"
#define kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION @"tokopedia.kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION"
#define kTKPD_INTERRUPTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_INTERRUPTNOTIFICATIONNAMEKEY"

#define SHOULD_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME @"tokopedia.SHOULD_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME"
#define DID_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME @"tokopedia.DID_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME"

#define EDIT_CART_INSURANCE_POST_NOTIFICATION_NAME @"tokopedia.EDIT_CART_INSURANCE_POST_NOTIFICATION_NAME"
#define SHOULD_REFRESH_CART @"SHOULD_REFRESH_CART"

#define UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME @"tokopedia.UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME"

#define kTKPD_DIDTAPNAVIGATIONMENU_NOTIFICATION @"tokopedia.kTKPD_DIDTAPNAVIGATIONMENU_NOTIFICATION"

#define kTKPD_APPLICATIONKEY @"application"
#define kTKPD_INSTALLEDKEY @"installed"

#define TKPD_ISLOGINNOTIFICATIONNAME @"setlogin"

#define kTKPD_REMOVE_SEARCH_HISTORY @"tokopedia.kTKPD_REMOVE_SEARCH_HISTORY"

//#endif
#define kTKPD_REACHABILITYDELAY 3.0

#define kTKPD_APSKEY @"aps"
#define kTKPD_BADGEKEY @"badge"

#define kTKPDWINDOW_TINTLCOLOR [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]

#define kTKPDNAVIGATION_TABBARACTIVETITLECOLOR [UIColor blackColor]
#define kTKPDNAVIGATION_TABBARTITLECOLOR [UIColor blackColor]

#define kTKPDNAVIGATION_BACKGROUNDINSET UIEdgeInsetsZero
#define kTKPDNAVIGATION_TITLEFONT [UIFont fontWithName:@"Lato-Bold" size:16.0f]
#define kTKPDNAVIGATION_TITLECOLOR [UIColor whiteColor]
#define kTKPDNAVIGATION_TITLESHADOWCOLOR [UIColor clearColor]
#define kTKPDNAVIGATION_BUTTONINSET UIEdgeInsetsZero
#define kTKPDNAVIGATION_BACKBUTTONINSET UIEdgeInsetsMake(0.0f, 35.0f, 0.0f, 0.0f)
#define kTKPD_SETUSERSTICKYMESSAGEKEY @"stickymessage"

#define kTKPDNAVIGATION_NAVIGATIONBGCOLOR [UIColor colorWithRed:(66/255.0) green:(189/255.0) blue:(65/255.0) alpha:1]
#define kTKPDNAVIGATION_NAVIGATIONITEMCOLOR [UIColor whiteColor]

#define HelpshiftKey @"a61b53892e353d1828be5154db0ac6c2"
#define HelpshiftDomain @"tokopedia.helpshift.com"
#define HelpshiftAppid @"tokopedia_platform_20150407082530564-f41c14c841c644e"

#define GATrackingId @"UA-9801603-10"

#define TokopediaNotificationRedirect @"redirectNotification"
#define TokopediaNotificationReload @"reloadNotification"

#define productCollectionViewCellWidth6plus 192
#define productCollectionViewCellWidthNormal 145
#define productCollectionViewCellHeight6plus 250
#define productCollectionViewCellHeightNormal 205

#define TKPDUserDidLoginNotification        @"TKPDUserDidLoginNotification"
#define TKPDUserDidTappedTapBar @"TKPDUserDidTappedTapBar"
#define kTKPD_REMOVE_SEARCH_HISTORY @"tokopedia.kTKPD_REMOVE_SEARCH_HISTORY"

#define kTKPD_SHOW_RATING_ALERT         @"tokopedia.kTKPD_CHECKING_USER_REVIEW"
#define kTKPD_USER_REVIEW_DATA          @"tokopedia.kTKPD_USER_REVIEW_DATA"
#define kTKPD_USER_REVIEW_IDS           @"tokopedia.kTKPD_USER_REVIEW_IDS"
#define kTKPD_USER_REVIEW_DUE_DATE      @"tokopedia.kTKPD_USER_REVIEW_DUE_DATE"
#define kTKPD_ITUNES_APP_URL            @"http://itunes.apple.com/app/id1001394201"
#define kTKPD_ALWAYS_SHOW_RATING_ALERT  @"tokopedia.kTKPD_ALWAYS_SHOW_ALERT_RATING"

// GTM Value
#define GTMKeyInboxMessageBase @"inboxmessage_base_url"
#define GTMKeyInboxMessagePost @"inboxmessage_post_url"
#define GTMKeyActionInboxMessageBase @"inboxmessage_action_base_url"
#define GTMKeyActionInboxMessagePost @"inboxmessage_action_post_url"

#define GTMKeyInboxMessageFull @"inboxmessage_full_url"

#define GTMKeyInboxTalkBase @"inboxtalk_base_url"
#define GTMKeyInboxTalkPost @"inboxtalk_post_url"
#define GTMKeyInboxTalkFull @"inboxtalk_full_url"

#define GTMKeyInboxReviewBase @"inboxreview_base_url"
#define GTMKeyInboxReviewPost @"inboxreview_post_url"
#define GTMKeyInboxReviewFull @"inboxreview_full_url"

#define GTMKeyProductBase @"product_base_url"
#define GTMKeyProductPost @"product_post_url"
#define GTMKeyProductFull @"product_full_url"

#define GTMKeySearchBase @"search_base_url"
#define GTMKeySearchPost @"search_post_url"
#define GTMKeySearchFull @"search_full_url"

#define GTMKeyInboxReputationBase @"inbox_reputation_base_url"
#define GTMKeyInboxReputationPost @"inbox_reputation_post_url"

#define GTMKeyInboxActionReputationBase @"action_reputation_base_url"
#define GTMKeyInboxActionReputationPost @"action_reputation_post_url"

#define GTMKeyActionReviewBase @"action_review_base_url"
#define GTMKeyActionReviewPost @"action_review_post_url"

#define GTMKeyPromoBase @"promo_base_url"
#define GTMKeyPromoPost @"promo_post_url"
#define GTMKeyPromoFull @"promo_full_url"

#define GTMKeyPromoBaseAction   @"promo_base_action_url"
#define GTMKeyPromoPostAction   @"promo_post_action_url"
#define GTMKeyPromoFullAction   @"promo_full_action_url"

#define GTMKeyCancelPromoProductFeed  @"cancel_promo_product_feed"
#define GTMKeyCancelPromoHotlist      @"cancel_promo_hotlist"
#define GTMKeyCancelPromoSearch       @"cancel_promo_search"
#define GTMKeyCancelPromoShopFeed     @"cancel_promo_shop_feed"

#define GTMKeyNotifyLBLMBase @"notify_base_url"
#define GTMKeyNotifyLBLMPost @"notify_post_url"
#define GTMKeyNotifyLBLMFull @"notify_full_url"

#define GTMVeritransClientKey @"veritrans_client_key"

#define GTMHiddenPaymentKey @"hidden_payment_gateways"

#define GTMIsLuckyInstallmentAvailableKey @"is_installment_available"

#define GTMKeyComplainNotifString @"complain_notif_string"

#define kTKPDForceUpdateFacebookButton @"kTKPDForceUpdateFacebookButton"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define kTKPD_REDIRECT_TO_HOME  @"tokopedia.kTKPD_REDIRECT_TO_HOME"

#endif
