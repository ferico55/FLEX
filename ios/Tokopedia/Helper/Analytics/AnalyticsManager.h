//
//  AnalyticsManager.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAGDataLayer.h"
#import "TAGManager.h"
#import "PromoResult.h"
#import "Product.h"
#import "ProductDetail.h"
#import "LoginResult.h"
#import "Login.h"
#import "TransactionCartResult.h"
#import "InboxTicketViewController.h"
#import "string_product.h"
#import "AddressFormList.h"
#import <MoEngage_iOS_SDK/MoEngage.h>
#import <MoEngage_iOS_SDK/MOInbox.h>
#import <MoEngage_iOS_SDK/MOEHelperConstants.h>
#import <MoEngage_iOS_SDK/MOGeofenceHandler.h>
#import "Slide.h"

typedef NS_ENUM(NSInteger, HomeBannerPromotionTrackerType) {
    HomeBannerPromotionTrackerTypeView,
    HomeBannerPromotionTrackerTypeClick,
};

@interface AnalyticsManager : NSObject

// Google Analytics (via GTM)
+ (void)trackScreenName:(NSString *)name;
+ (void)trackScreenName:(NSString *)name gridType:(NSInteger)gridType;
+ (void)trackScreenName:(NSString *)name customDataLayer:(NSDictionary *)dataLayer;
+ (void)trackUserInformation;
+ (void)trackProductImpressions:(NSArray *)products;
+ (void)trackProductClick:(id)product;
+ (void)trackProductView:(Product *)product;
+ (void)trackProductAddToCart:(ProductDetail *)product;
+ (void)trackRemoveProductFromCart:(id)product;
+ (void)trackRemoveProductsFromCart:(NSArray *)shops;
+ (void)trackPromoClick:(PromoResult *)promoResult;
+ (void)trackPromoClickWithDictionary:(NSDictionary *)promotionsDict;
+ (void)trackCheckout:(NSArray *)shops step:(NSInteger)step option:(NSString *)option;
+ (void)trackPurchaseID:(NSString *)purchaseID carts:(NSArray *)carts coupon:(NSString *)coupon;
+ (void)trackLoginUserID:(NSString *)userID;
+ (void)trackExceptionDescription:(NSString *)description;
+ (void)trackOnBoardingClickButton:(NSString *)buttonName;
+ (void)trackSnapSearchCategory:(NSString *)categoryName;
+ (void)trackSnapSearchAddToCart:(ProductDetail *)product;
+ (void)trackAuthenticatedWithLoginResult:(LoginResult *)result;
+ (void)trackSuccessSubmitReview:(NSInteger)status;
+ (void)trackSearchInboxReview;
+ (void)trackPushNotificationAccepted:(BOOL)accepted;
+ (void)trackOpenPushNotificationSetting;
+ (void)trackCampaign:(NSURL *)url;
+ (void)trackEventName:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label;

// MoEngage
+ (void)moEngageTrackEventWithName:(NSString *)eventName attributes:(NSDictionary *)attributes;
+ (void)moEngageTrackLogout;
+ (void)moEngageTrackUserAttributes;
+ (void)moEngageTrackEvent;

// Specific trackers
+ (void)trackLogin:(Login *)login;
+ (void)trackSegmentedControlTapped:(NSInteger)inboxType label:(NSString*)label;
+ (void)trackInboxTicketClickWithType:(InboxCustomerServiceType)type;
+ (void)trackAddProductType:(NSInteger)type;
+ (void)trackGiveRatingReviewWithRole:(NSString *)role;
+ (void)trackIfSelectedAddressChanged:(AddressFormList *)oldAddress to:(AddressFormList *)newAddress;
+ (void)trackInboxMessageClick:(NSString *)label;
+ (void)trackSearch:(NSString *)type keyword:(NSString *)keyword;
+ (void)trackClickSales:(NSString *)label;
+ (void)trackClickNavigateFromMore:(NSString *)page;
+ (void)trackHomeBanner:(Slide *) slide index:(NSInteger) index type:(HomeBannerPromotionTrackerType) type;

@end
