//
//  AnalyticsManager.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "AnalyticsManager.h"
#import "SearchAWSProduct.h"
#import "ProductFeedList.h"
#import "WishlistObjectList.h"
#import "List.h"
#import "Breadcrumb.h"
#import "NSURL+Dictionary.h"
#import "NSNumberFormatter+IDRFormater.h"
#import "TKPDTabViewController.h"
#import "ProductAddEditViewController.h"
#import "GAIDictionaryBuilder.h"
#import "search.h"
#import "Tokopedia-Swift.h"
#import "GAIEcommerceFields.h"

typedef NS_ENUM(NSInteger, EventCategoryType) {
    EventCategoryTypeHomepage,
    EventCategoryTypeRegister,
    
};

@interface AnalyticsManager()

@property (strong, nonatomic) TAGDataLayer *dataLayer;
@property (strong, nonatomic) UserAuthentificationManager *userManager;

@end

@implementation AnalyticsManager

- (id)init {
    self = [super init];
    if (self) {
        _dataLayer = [TAGManager instance].dataLayer;
        _userManager = [UserAuthentificationManager new];
        [_dataLayer push:@{@"user_id" : [_userManager getUserId]?:@""}];
    }
    
    return self;
}

#pragma mark - Google Analytics Trackers

+ (NSDictionary*)getEventName:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label {
    return @{
             @"event" : event?:@"",
             @"eventCategory" : category?:@"",
             @"eventAction" : action?:@"",
             @"eventLabel" : label?:@""
             };
}

+ (void)trackScreenName:(NSString *)name {
    AnalyticsManager *manager = [[self alloc] init];
    
    if ([manager.userManager isLogin]) {
        NSDictionary *data = @{
                               @"event" : @"authenticated",
                               @"contactInfo" : @{
                                       @"userSeller": [[manager.userManager getShopId] isEqualToString:@"0"]? @"0": @"1",
                                       @"userFullName": [[manager.userManager getUserLoginData] objectForKey:@"full_name"]?:@"",
                                       @"userEmail": [[manager.userManager getUserLoginData] objectForKey:@"user_email"]?:@"",
                                       @"userId": [manager.userManager getUserId],
                                       @"userMSISNVerified": [[manager.userManager getUserLoginData] objectForKey:@"msisdn_is_verified"]?:@"",
                                       @"shopID": [manager.userManager getShopId]
                                       }
                               };
        
        [manager.dataLayer push:data];
    }
    
    [manager.dataLayer push:@{@"event" : @"openScreen",
                              @"screenName" : name?:@"",
                              @"appsflyerID" : [[AppsFlyerTracker sharedTracker] getAppsFlyerUID]?:@"",
                              @"environment": @"iOS",
                              @"login" : [manager.userManager isLogin]?@"Logged In":@"Non Logged In"}];
    
    [self moEngageTrackEventWithName:@"iOS Screen Launched"
                          attributes:@{
                                       @"screen_name": name ?: @""
                                       }];
}

+ (void)trackScreenName:(NSString *)name gridType:(NSInteger)gridType {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"openScreen",
                           @"screenName" : name?:@"",
                           @"gridType" : @(gridType)
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackScreenName:(NSString *)name customDataLayer:(NSDictionary *)dataLayer {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSMutableDictionary *layer = [[NSMutableDictionary alloc] initWithDictionary:@{@"event": @"openScreen",
                                                                                   @"screenName": name ?: @"",
                                                                                   @"appsflyerID": [[AppsFlyerTracker sharedTracker] getAppsFlyerUID] ?: @"",
                                                                                   @"environment": @"iOS",
                                                                                   @"login": [manager.userManager isLogin] ? @"Logged In" : @"Non Logged In"}];
    
    [layer addEntriesFromDictionary:dataLayer];
    
    [manager.dataLayer push:layer];
}

+ (void)trackUserInformation {
    AnalyticsManager *manager = [[self alloc] init];
    
    if ([manager.userManager isLogin]) {
        [manager.dataLayer push:@{@"user_id" : [manager.userManager getUserId]?:@""}];
    }
}

- (NSString *)getProductListName:(id)product {
    NSString *list = @"";
    if ([product isKindOfClass:[SearchAWSProduct class]]) {
        list = @"Search Results";
    } else if ([product isKindOfClass:[ProductFeedList class]]) {
        list = @"Product Feed";
    } else if ([product isKindOfClass:[WishListObjectList class]]) {
        list = @"Wish List";
    } else if ([product isKindOfClass:[List class]]) {
        list = @"Shop Product";
    } else if ([product isKindOfClass:[FeaturedProduct class]]) {
        list = @"Featured Product";
    }
    return list;
    
}

+ (void)trackProductImpressions:(NSArray *)products {
    AnalyticsManager *manager = [[self alloc] init];
    NSMutableArray *impressions = [NSMutableArray new];
    
    for (id product in products) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[product productFieldObjects]];
        NSString *listName = [manager getProductListName:product];
        [dict setObject:listName forKey:@"list"];
        [impressions addObject:dict];
    }
    
    NSDictionary *data = @{
                           @"ecommerce" : @{
                                   @"currencyCode" : @"IDR",
                                   @"impressions" : impressions
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackProductClick:(id)product {
    if (!product) return;
    AnalyticsManager *manager = [[self alloc] init];
    NSString *list = [manager getProductListName:product];
    NSDictionary *productFieldObjects = [product productFieldObjects];
    NSDictionary *data = @{
                           @"event" : @"productClick",
                           @"ecommerce" : @{
                                   @"click" : @{
                                           @"actionField" : @{
                                                   @"list" : list
                                                   },
                                           @"products" : @[productFieldObjects]
                                           }
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackProductView:(Product *)product {
    if (!product) return;
    if (product.data.breadcrumb.count == 0) return;
    
    // GA Tracking
    AnalyticsManager *manager = [[self alloc] init];
    NSDictionary *productFieldObjects = [product.data.info productFieldObjects];
    
    NSDictionary *data = @{
                           @"ecommerce" : @{
                                   @"detail" : @{
                                           @"actionField" : @{
                                                   @"list" : @"Produk Detail"
                                                   },
                                           @"products" : @[productFieldObjects]
                                           }
                                   }
                           };
    
    [manager.dataLayer push:data];
    
    // AppsFlyer Tracking
    NSNumber *price = [[NSNumberFormatter IDRFormatter] numberFromString:product.data.info.price?:product.data.info.product_price];
    
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventContentView
                                      withValues:@{
                                                   AFEventParamPrice : price?:@"",
                                                   AFEventParamContentId : product.data.info.product_id?:@"",
                                                   AFEventParamCurrency : @"IDR",
                                                   AFEventParamContentType : @"Product"
                                                   }];
}

+ (void)trackProductAddToCart:(ProductDetail *)product {
    if (!product) return;
    AnalyticsManager *manager = [[self alloc] init];
    NSDictionary *productFieldObjects = [product productFieldObjects];
    NSDictionary *data = @{
                           @"event" : @"addToCart",
                           @"ecommerce" : @{
                                   @"currencyCode" : @"IDR",
                                   @"add" : @{
                                           @"products" : @[productFieldObjects]
                                           }
                                   }
                           };
    [manager.dataLayer push:data];
    
    NSString *productID = product.product_id;
    NSString *productName = product.product_name;
    NSNumber *price = [[NSNumberFormatter IDRFormatter] numberFromString:product.product_price];
    
    NSArray *categories = [product.product_cat_name componentsSeparatedByString:@" - "];
    
    [AnalyticsManager moEngageTrackEventWithName:@"Product_Added_To_Cart_Marketplace"
                                      attributes:@{@"product_id" : productID ?: @"0",
                                                   @"product_name" : productName ?: @"",
                                                   @"product_price" : price ?: @"0",
                                                   @"product_url" : product.product_url ?: @"",
//                                                   @"is_official_store" : @"",
                                                   @"category_id" : product.product_cat_id ?: @(0),
                                                   @"category" : (categories.count > 0) ? categories[0] : @"",
//                                                   @"subcategory_id" : @"",
                                                   @"subcategory" : (categories.count > 1) ? categories[1] : @""}];
}

+ (void)trackRemoveProductFromCart:(id)product {
    if (!product) return;
    AnalyticsManager *analytics = [[self alloc] init];
    NSDictionary *productFieldObjects = [product productFieldObjects];
    NSDictionary *data = @{
                           @"event" : @"removeFromCart",
                           @"ecommerce" : @{
                                   @"currencyCode" : @"IDR",
                                   @"remove" : @{
                                           @"products" : @[productFieldObjects]
                                           }
                                   }
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackRemoveProductsFromCart:(NSArray *)shops {
    if (!shops) return;
    AnalyticsManager *analytics = [[self alloc] init];
    NSMutableArray *products = [NSMutableArray new];
    for(TransactionCartList *list in shops) {
        for(ProductDetail *detailProduct in list.cart_products) {
            [products addObject:detailProduct.productFieldObjects];
        }
    }
    
    NSDictionary *data = @{
                           @"event" : @"removeFromCart",
                           @"ecommerce" : @{
                                   @"currencyCode" : @"IDR",
                                   @"remove" : @{
                                           @"products" : products
                                           }
                                   }
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackPromoClick:(PromoResult *)promoResult {
    if (!promoResult || !promoResult.product) return;
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"promotionClick",
                           @"ecommerce" : @{
                                   @"promoClick" : @{
                                           @"promotions" : @[promoResult.productFieldObjects]
                                           }
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackPromoClickWithDictionary:(NSDictionary *)promotionsDict {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"promotionClick",
                           @"ecommerce" : @{
                                   @"promoClick" : @{
                                           @"promotions" : @[promotionsDict]
                                           }
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackCheckout:(NSArray *)shops step:(NSInteger)step option:(NSString *)option {
    if (!shops || !step || !option) return;
    AnalyticsManager *manager = [[self alloc] init];
    NSMutableArray *products = [NSMutableArray new];
    
    for (TransactionCartList *shop in shops) {
        for (ProductDetail *product in shop.cart_products) {
            [products addObject:product.productFieldObjects];
        }
    }
    
    NSDictionary *data = @{
                           @"ecommerce" : @{
                                   @"checkout" : @{
                                           @"actionField" : @{
                                                   @"step" : @(step)?:@(0),
                                                   @"option" : option?:@""
                                                   },
                                           @"products" : products
                                           }
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackPurchaseID:(NSString *)purchaseID carts:(NSArray *)carts coupon:(NSString *)coupon {
    if (!purchaseID || !carts) return;
    AnalyticsManager *manager = [[self alloc] init];
    NSMutableArray *purchasedItems = [NSMutableArray array];
    NSInteger revenue = 0;
    NSInteger shipping = 0;
    
    for (TransactionCartList *cart in carts) {
        for (ProductDetail *product in cart.cart_products) {
            [purchasedItems addObject:@{
                                        @"name" : product.product_name?:@"",
                                        @"sku" : product.product_id?:@"",
                                        @"price" : product.product_price?:@"",
                                        @"currency" : @"IDR",
                                        @"quantity" : product.product_quantity?:@""
                                        }];
            revenue = revenue + [cart.cart_total_amount integerValue];
            shipping = shipping + [cart.cart_shipping_rate integerValue];
        }
    }
    
    NSString *shippingString = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:shipping]];
    NSString *revenueString = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:revenue]];
    
    NSDictionary *transactionData = @{
                                      @"event" : @"transaction",
                                      @"transactionId" : purchaseID?:@"",
                                      @"transactionTotal" : revenueString?:@"",
                                      @"transactionShipping" : shippingString?:@"",
                                      @"transactionCurrency" : @"IDR",
                                      @"transactionProducts" : purchasedItems?:@""
                                      };
    
    NSDictionary *purchaseData = @{
                                   @"event" : @"purchase",
                                   @"transactionID" : purchaseID,
                                   @"ecommerce" : @{
                                           @"purchase" : @{
                                                   @"actionField" : @{},
                                                   @"products" : purchasedItems?:@""}
                                           }
                                   };
    
    [manager.dataLayer push:transactionData];
    [manager.dataLayer push:purchaseData];
}

+ (void)trackLoginUserID:(NSString *)userID {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"login",
                           @"eventCategory" : @"UX",
                           @"eventAction" : @"User Sign In",
                           @"eventLabel" : @"User ID",
                           @"eventValue" : userID?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackExceptionDescription:(NSString *)description {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"exception",
                           @"exception.description" : description?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackOnBoardingClickButton:(NSString *)buttonName {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"onBoardingClick",
                           @"buttonName" : buttonName?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackSnapSearchCategory:(NSString *)categoryName {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"snapSearchCategory",
                           @"categoryName" : categoryName?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackSnapSearchAddToCart:(ProductDetail *)product {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"snapSearchAddToCart",
                           @"productId" : product.product_id?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackAuthenticatedWithLoginResult:(LoginResult *)result {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"authenticated",
                           @"contactInfo" : @{
                                   @"userSeller" : result.seller_status?:@"",
                                   @"userFullName" : result.full_name?:@"",
                                   @"userEmail" : result.email?:@"",
                                   @"userId" : result.user_id?:@"",
                                   @"userMSISNVerified" : result.msisdn_is_verified?:@"",
                                   @"shopId" : result.shop_id?:@""
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackSuccessSubmitReview:(NSInteger)status {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"successSubmitReview",
                           @"submitReviewStatus" : @(status)?:@(0)
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackSearchInboxReview {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"searchInboxReview"
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackPushNotificationAccepted:(BOOL)accepted {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"pushNotificationPermissionRequest",
                           @"pushNotificationAllowed" : @(accepted)
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackOpenPushNotificationSetting {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"openPushNotificationSetting"
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackCampaign:(NSURL *)url {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"openCampaign",
                           @"utmSource" : [url.parameters objectForKey:@"utm_source"]?:@"",
                           @"utmMedium" : [url.parameters objectForKey:@"utm_medium"]?:@"",
                           @"utmCampaign" : [url.parameters objectForKey:@"utm_campaign"]?:@"",
                           @"utmContent" : [url.parameters objectForKey:@"utm_content"]?:@"",
                           @"utmTerm" : [url.parameters objectForKey:@"utm_term"]?:@"",
                           @"gclid" : [url.parameters objectForKey:@"gclid"]?:@""
                           };
    
    if ([[data objectForKey:@"utmSource"] length] != 0 && [[data objectForKey:@"utmMedium"] length] != 0 && [[data objectForKey:@"utmCampaign"] length] != 0 ) {
        [manager.dataLayer push:data];
    }
}

+ (void)trackEventName:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = [self getEventName:event category:category action:action label:label];
    [manager.dataLayer push:data];
}

#pragma mark - MoEngage trackers
+ (void)moEngageTrackEventWithName:(NSString *)eventName attributes:(NSDictionary *)attributes {
    [[MoEngage sharedInstance] trackEvent:eventName andPayload:[NSMutableDictionary dictionaryWithDictionary:attributes]];
}

+ (void)moEngageTrackLogout {
    [[MoEngage sharedInstance] resetUser];
}

+ (void)moEngageTrackUserAttributes {
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    
    if ([userManager isLogin]) {
        MoEngage *moEngage = [MoEngage sharedInstance];
        [moEngage setUserUniqueID:[userManager getUserId]];
        [moEngage setUserName:[userManager getUserFullName]];
        [moEngage setUserFirstName:[userManager getUserShortName]];
        [moEngage setUserEmailID:[userManager getUserEmail]];
        
        [moEngage setUserMobileNo:[userManager getUserPhoneNumber]];
        [moEngage setUserAttribute:[userManager isUserPhoneVerified]?@"true":@"false" forKey:@"is_verified"];
        
        [moEngage setUserAttribute:[userManager userHasShop]?@"true":@"false" forKey:@"is_seller"];
        [moEngage setUserAttribute:[userManager getShopId] forKey:@"shop_id"];
        [moEngage setUserAttribute:[userManager getShopName] forKey:@"shop_name"];
        [moEngage setUserAttribute:[userManager userIsGoldMerchant]?@"true":@"false" forKey:@"is_gold_merchant"];
        
        [moEngage setUserDateOfBirth:[userManager convertStringToDateWithLocaleID:[userManager getDOB]]];
        [moEngage setUserAttribute:[userManager getTotalItemSold] forKey:@"total_sold_item"];
        [moEngage setUserAttribute:[userManager getShopLocation] forKey:@"shop_location"];
        int gender = [[userManager getGender] isEqualToString:@""] ? -1 : [[userManager getGender] isEqualToString:@"male"] ? MALE : FEMALE;
        [moEngage setUserGender:gender];
        [moEngage setUserAttribute:[userManager userIsSeller]?@"true":@"false" forKey:@"is_seller"];
        [moEngage setUserAttribute:[userManager getCity] forKey:@"city"];
        [moEngage setUserAttribute:[userManager getProvince] forKey:@"province"];
        [moEngage setUserAttribute:[userManager getRegistrationDate] forKey:@"registration_date"];
        [moEngage setUserAttribute:[userManager userIsTokocashActive]?@"true":@"false" forKey:@"is_tokocash_active"];
        [moEngage setUserAttribute:[userManager getTokocashAmount] forKey:@"tokocash_amt"];
        [moEngage setUserAttribute:[userManager getSaldoAmount] forKey:@"saldo_amt"];
        [moEngage setUserAttribute:[userManager getTopAdsAmount] forKey:@"topads_amount"];
        [moEngage setUserAttribute:[userManager userIsTopAdsUser]?@"true":@"false" forKey:@"is_topads_user"];
        [moEngage setUserAttribute:[userManager userHasPurchasedMarketplace]?@"true":@"false" forKey:@"has_purchased_marketplace"];
        [moEngage setUserAttribute:[userManager userHasPurchasedDigital]?@"true":@"false" forKey:@"has_purchased_digital"];
        [moEngage setUserAttribute:[userManager userHasPurchasedTicket]?@"true":@"false" forKey:@"has_purchased_tiket"];
        [moEngage setUserAttribute:[userManager getLastTransactionDate] forKey:@"last_transaction_date"];
        [moEngage setUserAttribute:[userManager getTotalActiveProduct] forKey:@"total_active_product"];
        [moEngage setUserAttribute:[userManager getShopScore] forKey:@"shop_score"];
        
        [moEngage syncNow];
    }
}

+ (void) moEngageTrackEvent: (NSString*) name {
    [[MoEngage sharedInstance] trackEvent:name andPayload:nil];
}

#pragma mark - Specific trackers

+ (void)trackLogin:(Login *)login {
    // GA Tracking
    [self trackAuthenticatedWithLoginResult:login.result];
    
    // AppsFlyer Tracking
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIUserId value:login.result.user_id];
}

+ (void)trackSegmentedControlTapped:(NSInteger)inboxType label:(NSString *)label {
    
    if (inboxType == InboxTypeTalk) {
        [self trackEventName:@"clickProductDiscussion" category:GA_EVENT_CATEGORY_INBOX_TALK action:GA_EVENT_ACTION_CLICK label:label];
    } else if (inboxType == InboxTypeTicket) {
        [self trackEventName:@"clickHelp" category:GA_EVENT_CATEGORY_INBOX_TICKET action:GA_EVENT_ACTION_CLICK label:label];
    }
}

+ (void)trackInboxTicketClickWithType:(InboxCustomerServiceType)type {
    NSString *inboxType = @"";
    if (type == InboxCustomerServiceTypeAll) {
        inboxType = @"Semua";
    } else if (type == InboxCustomerServiceTypeClosed) {
        inboxType = @"Ditutup";
    } else {
        inboxType = @"Dalam Proses";
    }
    
    [self trackEventName:@"clickHelp" category:GA_EVENT_CATEGORY_INBOX_TICKET action:GA_EVENT_ACTION_CLICK label:inboxType];
}

+ (void)trackAddProductType:(NSInteger)type {
    if (type == TYPE_ADD_EDIT_PRODUCT_ADD) {
        [self trackEventName:@"clickProduct" category:GA_EVENT_CATEGORY_SHOP_PRODUCT action:GA_EVENT_ACTION_CLICK label:@"Add"];
    } else {
        [self trackEventName:@"clickProduct" category:GA_EVENT_CATEGORY_SHOP_PRODUCT action:GA_EVENT_ACTION_COPY label:@"Product"];
    }
}

+ (void)trackGiveRatingReviewWithRole:(NSString *)role {
    NSString *type = @"";
    
    if ([role isEqualToString:@"2"]) {
        type = @"Smiley Buyer";
    } else {
        type = @"Smiley Seller";
    }
    
    [self trackEventName:@"clickReview" category:GA_EVENT_CATEGORY_INBOX_REVIEW action:GA_EVENT_ACTION_CLICK label:type];
}

+ (void)trackIfSelectedAddressChanged:(AddressFormList *)oldAddress to:(AddressFormList *)newAddress {
    if (oldAddress && newAddress && (oldAddress != newAddress)) {
        [self trackEventName:@"clickATC" category:GA_EVENT_CATEGORY_ATC action:GA_EVENT_ACTION_CLICK label:@"Change Address"];
    }
}

+ (void)trackInboxMessageClick:(NSString *)label {
    [self trackEventName:@"clickMessage" category:GA_EVENT_CATEGORY_INBOX_MESSAGE action:GA_EVENT_ACTION_CLICK label:label];
}

+ (NSString *)searchActionWithID:(NSString *)searchID {
    NSString *actionForTracker = @"search product";
    if ([self isSearchIDEqualToSearchSuggestion: searchID]) {
        actionForTracker = @"search product - suggestion";
    } else if ([searchID isEqualToString:@"recent_search"]) {
        actionForTracker = @"search product - recent";
    } else if ([searchID isEqualToString:@"popular_search"]) {
        actionForTracker = @"search product - popular";
    } else if ([searchID isEqualToString:@"hotlist"]) {
        actionForTracker = @"Search Hotlist";
    } else if ([searchID isEqualToString:@"shop"]) {
        actionForTracker = @"search shop";
    }
    
    return actionForTracker;
}

+ (void)trackSearch:(NSString *)type keyword:(NSString *)keyword {
    NSString *searchAction = [self searchActionWithID:type];
    [self trackEventName:GA_EVENT_NAME_EVENT_TOP_NAV category:GA_EVENT_CATEGORY_TOP_NAV action:searchAction label:keyword];
}

+ (void)trackClickSales:(NSString *)label {
    [self trackEventName:@"clickSales" category:GA_EVENT_CATEGORY_SALES action:GA_EVENT_ACTION_CLICK label:label];
}

+ (void)trackClickNavigateFromMore:(NSString *)page parent:(NSString *)parent {
    [self trackEventName:GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE category:GA_EVENT_CATEGORY_HOMEPAGE_NON_CAPITAL action:[NSString stringWithFormat: @"other - click %@ item", parent] label:page];
}

+ (void)trackHomeBanner:(Slide *) slide index:(NSInteger) index type:(HomeBannerPromotionTrackerType) type {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSString *promoAction = type == HomeBannerPromotionTrackerTypeView ? @"promoView" : @"promoClick";
    
    NSDictionary *ecommercePromoDataLayer = @{
                           @"ecommerce": @{
                                   promoAction : @{
                                           @"promotions": @[@{
                                                                @"id": slide.slideId,
                                                                @"name": slide.bannerTitle,
                                                                @"creative": [slide.bannerTitle stringByReplacingOccurrencesOfString:@" " withString:@"-"],
                                                                @"position": [NSString stringWithFormat:@"slide_banner_%ld",(long)index]
                                                                }]
                                           }
                                   }
                           };
    
    if (type == HomeBannerPromotionTrackerTypeClick) {
        ecommercePromoDataLayer = [ecommercePromoDataLayer mergedWithDictionary:@{@"event": @"promotionClick"}];
    }

    NSDictionary* eventDataLayer = [self
                                 getEventName: @"InternalPromo"
                                 category: @"Internal Promotions"
                                 action: type == HomeBannerPromotionTrackerTypeView ? @"view" : @"click"
                                 label: slide.bannerTitle];
    
    
    [manager.dataLayer push:eventDataLayer];
    [manager.dataLayer push:ecommercePromoDataLayer];

}

+ (BOOL) isSearchIDEqualToSearchSuggestion: (NSString *) searchID {
    if ([searchID isEqualToString:kTKPDSEARCH_AUTOCOMPLETE] || [searchID isEqualToString:kTKPDSEARCH_IN_CATEGORY]) {
        return YES;
    }
    
    return NO;
}

@end
