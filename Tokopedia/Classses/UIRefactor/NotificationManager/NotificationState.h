//
//  NotificationState.h
//  Tokopedia
//
//  Created by Tokopedia on 1/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_NotificationState_h
#define Tokopedia_NotificationState_h

#define STATE_NEW_MESSAGE 101
#define STATE_NEW_TALK 102

#define STATE_NEW_REVIEW 103
#define STATE_EDIT_REVIEW 113
#define STATE_REPLY_REVIEW 123

#define STATE_NEW_REPSYS 202
#define STATE_EDIT_REPSYS 212

#define STATE_PURCHASE_PROCESS_PARTIAL 303
#define STATE_CONFIRM_PACKAGE_RECEIVED 305

#define STATE_RESCENTER_SELLER_REPLY 115
#define STATE_RESCENTER_BUYER_REPLY  125
#define STATE_RESCENTER_SELLER_AGREE 135
#define STATE_RESCENTER_BUYER_AGREE  145
#define STATE_RESCENTER_ADMIN_SELLER_REPLY 155
#define STATE_RESCENTER_ADMIN_BUYER_REPLY  165
#define STATE_EDIT_RESOLUTION 115

typedef NS_ENUM(NSUInteger, StateOrderSeller) {
    StateOrderSellerNewOrder         = 401,  //Seller received a new order
    StateOrderSellerInvalidResi      = 402,  //2 days after Seller entered invalid AWB
    StateOrderSellerFinishOrder      = 403,  //Buyer confirmed acceptance and finished the transaction OR auto-finish is applied to the order.
    StateOrderSellerAutoCancel2D     = 404,    //Seller ignored order and order is getting cancelled automatically after 2 days
    StateOrderSellerAutoCancel4D     = 405,    //AWB is not entered for accepted order and order is getting cancelled automatically after 4 (can go up to 6 if the last day falls on weekend) days since the payment date.
    StateOrderSellerOrderDelivered   = 406,    //Order has been confirmed as delivered by API
    StateOrderSellerReceivedComplain = 306,    //Buyer logged a complain
};

typedef NS_ENUM(NSUInteger,StateOrderBuyer) {
    StateOrderBuyerConfirmShipping      = 307,  //Seller entered AWB
    StateOrderBuyerFinishOrder          = 308,  //Buyer confirmed acceptance and finished the transaction OR auto-finish is applied to the order
    StateOrderBuyerDelivered            = 305,  //Order has been confirmed as delivered by API
    StateOrderBuyerNewOrder             = 310,  //Buyer placed a new order
    StateOrderBuyerRejected             = 304,  //Seller rejected the order
    StateOrderBuyerAutoCancel2D         = 311,  //Seller ignored order and order is getting cancelled automatically after 2 days
    StateOrderBuyerShippingRejected     = 312,  //Seller rejected order during input AWB stage
    StateOrderBuyerAutoCancel4D         = 313,  //AWB is not entered for accepted order and order is getting cancelled automatically after 4 (can go up to 6 if the last day falls on weekend) days since the payment date.
    StateOrderBuyerReminderFinishOrder  = 309   //Order has arrived at buyer's location (based on courier API), Order status is still not finished, Order is 1 day away from auto-finish.
};


#define IS_NOT_LOGIN @"0"

//GCM_MESSAGE         => 101,
//GCM_TALK            => 102,
//GCM_REVIEW          => 103,
//GCM_REVIEW_EDIT     => 113,
//GCM_REVIEW_REPLY    => 123,
//GCM_CONTACT         => 104,
//GCM_RC              => 105,
//GCM_NEWORDER        => 401,
//GCM_DRAWER_UPDATE   => 501,
//GCM_NOTIF_UPDATE    => 502,
//GCM_PEOPLE_PROFILE  => 601,
//GCM_PEOPLE_NOTIF_SETTING    => 602,
//GCM_PEOPLE_PRIVACY_SETTING  => 603,
//GCM_PEOPLE_ADDRESS_SETTING  => 604,
//GCM_SHOP_INFO       => 701,
//GCM_SHOP_PAYMENT    => 702,
//GCM_SHOP_ETALASE    => 703,
//GCM_SHOP_NOTES      => 704,
//GCM_PRODUCT_LIST    => 801



#endif
