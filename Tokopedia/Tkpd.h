//
//  Tkpd.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_Tkpd_h
#define Tokopedia_Tkpd_h

#if DEBUG
    #define kTkpdBaseURLString @"http://www.tkpdevel-pg.api/ws"
#else
    #define kTkpdBaseURLString @"http://beta.tokopedia.com/ws"
#endif

#define kTkpdAPIkey @"8b0c367dd3ef0860f5730ec64e3bbdc9" //TODO:: Remove api key
#define kTKPD_AUTHKEY @"auth"

#define kTKPD_AUTHKEY @"auth"
#define kTKPD_ISLOGINKEY @"is_login"
#define kTKPD_USERIMAGEKEY @"user_image"
#define kTKPD_USERIDKEY @"user_id"
#define kTKPD_FULLNAMEKEY @"full_name"
#define kTKPD_SHOPIDKEY @"shop_id"
#define kTKPD_SHOPNAMEKEY @"shop_name"
#define kTKPD_SHOPIMAGEKEY @"shop_avatar"
#define kTKPD_SHOPISGOLD @"shop_is_gold"
#define kTKPD_NULLCOMMENTKEY @"0"

#define DATA_PAYMENT_CONFIRMATION_COUNT_KEY @"data_payment_conf"
#define DATA_STATUS_COUNT_KEY @"data_status"
#define DATA_CONFIRM_DELIVERY_COUNT_KEY @"data_confirm_delivery"

typedef enum {
    ORDER_CANCELED                       = 0,     // update by ADMIN/SYSTEM order canceled for some reason
    ORDER_CANCELED_CHECKOUT              = 1,     // update by BUYER        cancel checkout baru, apabila dia 2x checkout
    ORDER_REJECTED                       = 10,    // update by SELLER       seller rejected the order
    ORDER_CHECKOUT_STATE                 = 90,    // update by BUYER        order status sebelum checkout, tidak tampil dimana2
    ORDER_PENDING                        = 100,   // update by BUYER        checked out an item in the shopping cart
    ORDER_PENDING_UNIK                   = 101,   // update by SYSTEM       fail UNIK payment
    ORDER_CREDIT_CARD_CHALLENGE          = 102,   // update by BUYER        credit card payment status challenge
    ORDER_PENDING_DUE_DATE               = 120,   // update by SYSTEM       after order age > 3 days
    ORDER_PAYMENT_CONFIRM                = 200,   // update by BUYER        confirm a payment
    ORDER_PAYMENT_CONFIRM_UNIK           = 201,   // update by BUYER        confirm a payment for UNIK
    ORDER_PAYMENT_DUE_DATE               = 210,   // update by SYSTEM       after order age > 6 days
    ORDER_PAYMENT_VERIFIED               = 220,   // update by SYSTEM       payment received and verified, ready to process
    ORDER_PROCESS                        = 400,   // update by SELLER       seller accepted the order
    ORDER_PROCESS_PARTIAL                = 401,   // update by SELLER       seller accepted the order, partially
    ORDER_PROCESS_DUE_DATE               = 410,   // update by SYSTEM       untouch verified order after payment age > 3 days
    ORDER_SHIPPING                       = 500,   // update by SELLER       seller confirm for shipment
    ORDER_SHIPPING_DATE_EDITED           = 505,   // update by ADMIN        seller input an invalid shipping date
    ORDER_SHIPPING_DUE_DATE              = 510,   // update by SYSTEM       seller not confirm for shipment after order accepted and payment age > 5 days
    ORDER_SHIPPING_TRACKER_INVALID       = 520,   // update by SYSTEM       invalid shipping ref num
    ORDER_SHIPPING_REF_NUM_EDITED        = 530,   // update by ADMIN        requested by user for shipping ref number correction because false entry
    ORDER_DELIVERED                      = 600,   // update by TRACKER      tells that buyer received the packet
    ORDER_CONFLICTED                     = 601,   // update by BUYER        Buyer open a case to finish an order
    ORDER_DELIVERED_CONFIRM              = 610,   // update by BUYER        buyer confirm for delivery
    ORDER_DELIVERED_DUE_DATE             = 620,   // update by SYSTEM       no response after delivery age > 3 days
    ORDER_DELIVERY_FAILURE               = 630,   // update by BUYER        buyer claim that he/she does not received any package
    ORDER_FINISHED                       = 700,   // update by ADMIN        order complete Confirmed
    ORDER_FINISHED_BOUNCE_BACK           = 701,   // update by ADMIN        order yang dianggap selesai tetapi barang tidak sampai ke buyer
    ORDER_REFUND                         = 800,   // update by ADMIN        order refund to the buyer for some reason
    ORDER_ROLLBACK                       = 801,   // update by ADMIN        order rollback from finished
    ORDER_BAD                            = 900    // update by ADMIN        bad order occurs and need further investigation} ORDER_STATUS;
} ORDER_STATUS;

#define is4inch  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

#define kTkpdIndexSetStatusCodeOK [NSIndexSet indexSetWithIndex:200] //statuscode 200 = OK

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define iOS7_0 @"7.0"

#define TKPD_FADEANIMATIONDURATION 0.3

#define kTKPD_ETALASEPOSTNOTIFICATIONNAMEKEY @"setetalase"
#define kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY @"setuserinfo"
#define kTKPD_SETUSERSTICKYERRORMESSAGEKEY @"stickyerrormessage"
#define kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY @"stickysuccessmessage"

#define kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY @"setsegmentcontrol"
#define kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY @"setDepartmentID"

#define CATALOG_SELECTED_INDEXPATH_POST_NOTIFICATION_NAME @"choosenIndexPath"

#define kTKPD_CROPIMAGEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_CROPIMAGEPOSTNOTIFICATIONNAMEKEY"

#define kTKPD_ADDETALASEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDETALASEPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY @"tokopeida.kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY"
#define kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY"

#define ADD_PRODUCT_POST_NOTIFICATION_NAME @"tokopedia.ADDPRODUCTPOSTNOTIFICATIONNAME"

#define REFRESH_TX_ORDER_POST_NOTIFICATION_NAME @"tokopedia.REFRESH_TX_ORDER_POST_NOTIFICATION_NAME"

#define kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY"

#define kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION @"tokopedia.kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION"
#define kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION @"tokopedia.kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION"
#define kTKPD_INTERRUPTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_INTERRUPTNOTIFICATIONNAMEKEY"

#define EDIT_CART_POST_NOTIFICATION_NAME @"tokopedia.EDIT_CART_POST_NOTIFICATION_NAME"

#define UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME @"tokopedia.UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME"

#define kTKPD_APPLICATIONKEY @"application"
#define kTKPD_INSTALLEDKEY @"installed"

#define TKPD_ISLOGINNOTIFICATIONNAME @"setlogin"

#endif
