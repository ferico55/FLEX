//
//  Analytics.m
//  Tokopedia
//
//  Created by Tokopedia on 11/10/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TPAnalytics.h"
#import "SearchAWSProduct.h"
#import "ProductFeedList.h"
#import "WishListObjectList.h"
#import "List.h"
#import "PromoProduct.h"
#import "TransactionCartList.h"
#import "PromoResult.h"
#import "NSURL+Dictionary.h"

@interface TPAnalytics ()

@property (strong, nonatomic) TAGDataLayer *dataLayer;
@property (strong, nonatomic) UserAuthentificationManager *userManager;

@end

@implementation TPAnalytics

- (id)init {
    self = [super init];
    if (self) {
        self.dataLayer = [TAGManager instance].dataLayer;
        self.userManager = [[UserAuthentificationManager alloc] init];
        [self.dataLayer push:@{@"user_id" : [self.userManager getUserId]}];
    }
    return self;
}

+ (void)trackScreenName:(NSString *)screenName {
    TPAnalytics *analytics = [[self alloc] init];
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    if (auth.isLogin) {
        NSDictionary *authenticatedData = @{
        @"event": @"authenticated",
        @"contactInfo": @{
                @"userSeller": [auth.getShopId isEqualToString:@"0"]? @"0": @"1",
                @"userFullName": [auth.getUserLoginData objectForKey:@"full_name"]?:@"",
                @"userEmail": [auth.getUserLoginData objectForKey:@"user_email"]?:@"",
                @"userId": auth.getUserId,
                @"userMSISNVerified": [auth.getUserLoginData objectForKey:@"msisdn_is_verified"]?:@"",
                @"shopID": auth.getShopId
            },
        };
        [analytics.dataLayer push:authenticatedData];
        [analytics.dataLayer push:@{@"event": @"openScreen", @"screenName": screenName}];
    }
    
    [TPLocalytics trackScreenName:screenName];
}

+ (void)trackScreenName:(NSString *)screenName gridType:(NSInteger)gridType {
    if (!screenName || !gridType) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event" : @"openScreen",
        @"screenName" : screenName?:@"",
        @"gridType" : @(gridType)
    };
    [analytics.dataLayer push:data];
    
    [TPLocalytics trackScreenName:screenName];
}

+ (void)trackUserId {
    TPAnalytics *analytics = [[self alloc] init];
    if (analytics.userManager.isLogin) {
        [analytics.dataLayer push:@{@"user_id" : [analytics.userManager getUserId]?:@""}];
        [Localytics setValue:[analytics.userManager getUserId]?:@"" forProfileAttribute:@"user_id"];
        [Localytics setValue:[analytics.userManager getShopId]?:@"" forProfileAttribute:@"shop_id"];        
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
    }
    return list;
}

+ (void)trackProductImpressions:(NSArray *)products {
    if (!products) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSMutableArray *impressions = [NSMutableArray new];
    for (id product in products) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[product productFieldObjects]];
        NSString *listName = [analytics getProductListName:product];
        [dict setObject:listName forKey:@"list"];
        [impressions addObject:dict];
    }
    NSDictionary *data = @{
        @"ecommerce" : @{
            @"currencyCode" : @"IDR",
            @"impressions" : impressions
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackProductClick:(id)product {
    if (!product) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSString *list = [analytics getProductListName:product];
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
    [analytics.dataLayer push:data];
}

+ (void)trackProductView:(id)product {
    if (!product) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *productFieldObjects = [product productFieldObjects];
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
    [analytics.dataLayer push:data];
}

+ (void)trackAddToCart:(id)product {
    if (!product) return;
    TPAnalytics *analytics = [[self alloc] init];
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
    [analytics.dataLayer push:data];
}

+ (void)trackRemoveProductFromCart:(id)product {
    if (!product) return;
    TPAnalytics *analytics = [[self alloc] init];
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
    TPAnalytics *analytics = [[self alloc] init];
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

+ (void)trackPromoImpression:(NSArray *)products {
    if (!products) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSMutableArray *promotions = [NSMutableArray new];
    for (PromoProduct *product in products) {
        [promotions addObject:product.productFieldObjects];
    }
    NSDictionary *data = @{
        @"ecommerce" : @{
            @"promoView" : @{
                @"promotions" : promotions
            }
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackPromoClick:(PromoResult *)promoResult {
    if (!promoResult || !promoResult.product) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event" : @"promotionClick",
        @"ecommerce" : @{
            @"promoClick" : @{
                @"promotions" : @[promoResult.productFieldObjects]
            }
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackCheckout:(NSArray *)shops
                 step:(NSInteger)step
               option:(NSString *)option {
    if (!shops || !step || !option) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSMutableArray *products = [NSMutableArray new];
    for(TransactionCartList *list in shops) {
        for(ProductDetail *detailProduct in list.cart_products) {
            [products addObject:detailProduct.productFieldObjects];
        }
    }
    NSDictionary *data = @{
        @"ecommerce" : @{
            @"checkout" : @{
                @"actionField" : @{
                    @"step" : @(step)?:0,
                    @"option" : option?:@""
                },
                @"products" : products
            }
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackCheckoutOption:(NSString *)option step:(NSInteger)step {
    if (!option || !step) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event": @"checkoutOption",
        @"ecommerce" : @{
            @"checkout_option" : @{
                @"actionField" : @{
                    @"step" : @(step)?:0,
                    @"option" : option?:@""
                }
            }
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackPurchaseID:(NSString *)purchaseID carts:(NSArray *)carts coupon:(NSString *)coupon {
    if (!purchaseID || !carts) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSMutableArray *purchasedItems = [NSMutableArray array];
    NSInteger revenue = 0;
    NSInteger shipping = 0;
    for(TransactionCartList *list in carts) {
        for(ProductDetail *detailProduct in list.cart_products) {
            [purchasedItems addObject:@{
                @"name"     : detailProduct.product_name?:@"",
                @"sku"      : detailProduct.product_id?:@"",
                @"price"    : detailProduct.product_price?:@"",
                @"currency" : @"IDR",
                @"quantity" : detailProduct.product_quantity?:@""
            }];
            revenue += [list.cart_total_amount integerValue];
            shipping += [list.cart_shipping_rate integerValue];
        }
    }
    NSString *shippingString = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:shipping]];
    NSString *revenueString = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:revenue]];
    NSDictionary *data = @{
        @"event" : @"transaction",
        @"transactionId" : purchaseID?:@"",
        @"transactionTotal" : revenueString?:@"",
        @"transactionShipping" : shippingString?:@"",
        @"transactionCurrency" : @"IDR",
        @"transactionProducts" : purchasedItems?:@""
    };
    [analytics.dataLayer push:data];
    NSDictionary *purchaseData = @{
        @"event": @"purchase",
        @"transactionID": purchaseID,
        @"ecommerce": @{
            @"purchase": @{
                @"actionField": @{
                    @"id": purchaseID?:@"",
                    @"revenue": revenueString?:@"",
                    @"shipping": shippingString?:@"",
                    @"coupon": coupon?:@"",
                },
                @"products" : purchasedItems?:@""
            }
        }
    };
    [analytics.dataLayer push:purchaseData];
}

+ (void)trackLoginUserID:(NSString *)userID {
    if (!userID) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
       @"event" : @"login",
       @"eventCategory" : @"UX",
       @"eventAction" : @"User Sign In",
       @"eventLabel" : @"User ID",
       @"eventValue" : userID?:@""
    };
    [analytics.dataLayer push:data];
}

+ (void)trackExeptionDescription:(NSString *)description {
    if (!description) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                           @"event" : @"exception",
                           @"exception.description":description?:@""
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackOnBoardingClickButton:(NSString *)buttonName {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
            @"event" : @"onBoardingClick",
            @"buttonName" : buttonName?:@"",
    };
    [analytics.dataLayer push:data];
}

+ (void)trackSnapSearchCategory:(NSString *)categoryName {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event" : @"snapSearchCategory",
        @"categoryName" : categoryName?:@"",
    };
    [analytics.dataLayer push:data];
}

+ (void)trackSnapSearchAddToCart:(ProductDetail *)product {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event": @"snapSearchAddToCart",
        @"productId": product.product_id?:@"",
    };
    [analytics.dataLayer push:data];
}

+ (void)trackAuthenticatedWithLoginResult:(LoginResult *)result {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{@"event" : @"authenticated",
                           @"contactInfo" : @{@"userSeller" : result.seller_status?:@"",
                                              @"userFullName" : result.full_name?:@"",
                                              @"userEmail" : result.email?:@"",
                                              @"userId" : result.user_id?:@"",
                                              @"userMSISNVerified" : result.msisdn_is_verified?:@"",
                                              @"shopId" : result.shop_id?:@""
                                              }
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackSuccessSubmitReview:(NSInteger)status {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                           @"event": @"successSubmitReview",
						   @"submitReviewStatus": @(status)
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackSearchInboxReview {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                           @"event": @"searchInboxReview"
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackPushNotificationAccepted:(BOOL)accepted {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                            @"event": @"pushNotificationPermissionRequest",
                            @"pushNotificationAllowed": @(accepted)
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackOpenPushNotificationSetting {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                           @"event": @"openPushNotificationSetting"
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackCampaign:(NSURL *)url {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"utmSource": [url.parameters objectForKey:@"utm_source"]?:@"",
        @"utmMedium": [url.parameters objectForKey:@"utm_medium"]?:@"",
        @"utmCampaign": [url.parameters objectForKey:@"utm_campaign"]?:@"",
        @"utmContent": [url.parameters objectForKey:@"utm_content"]?:@"",
        @"utmTerm": [url.parameters objectForKey:@"utm_term"]?:@"",
        @"gclid": [url.parameters objectForKey:@"gclid"]?:@"",
    };
    [analytics.dataLayer push:data];
}

+ (void)trackClickEvent:(NSString *)event category:(NSString *)category label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event": event?:@"",
        @"eventCategory": category?:@"",
        @"eventLabel": label?:@""
    };
    [analytics.dataLayer push:data];
}

+ (void)trackSearchWithAction:(NSString *)action keyword:(NSString *)keyword {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickSearch",
                           @"eventCategory" : @"Search",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : keyword?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickRegisterOnPage:(NSString *)page {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickRegister",
                           @"eventCategory" : @"Register",
                           @"eventAction" : @"Click",
                           @"eventLabel" : page?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackSuccessRegisterWithChannel:(NSString *)channel {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"registerSuccess",
                           @"eventCategory" : @"Register",
                           @"eventAction" : @"Register Success",
                           @"eventLabel" : channel?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackErrorRegisterWithFieldName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"registerError",
                           @"eventCategory" : @"Register",
                           @"eventAction" : @"Register Error",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackAddToCartEvent:(NSString *)event action:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : event?:@"",
                           @"eventCategory" : @"Add to Cart",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickCartLabel:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickCheckout",
                           @"eventCategory" : @"Checkout",
                           @"eventAction" : @"Click",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickCategoryWithCategoryName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickCategory",
                           @"eventCategory" : @"Homepage",
                           @"eventAction" : @"Click",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickBuyFromWishlist {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickWishlist",
                           @"eventCategory" : @"Wishlist",
                           @"eventAction" : @"Click",
                           @"eventLabel" : @"Buy"
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackViewProductFromWishlistWithProductName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickWishlist",
                           @"eventCategory" : @"Wishlist",
                           @"eventAction" : @"View",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackFilterWithSelectedFilters:(NSArray<NSString *> *)filters {
    TPAnalytics *analytics = [[self alloc] init];
    
    for (NSString *filter in filters) {
        NSDictionary *data = @{
                               @"event" : @"clickFilter",
                               @"eventCategory" : @"Filter",
                               @"eventAction" : @"Click",
                               @"eventLabel" : filter?:@""
                               };
        
        [analytics.dataLayer push:data];
    }
}

+ (void)trackSortWithSortName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickSort",
                           @"eventCategory" : @"Sort",
                           @"eventAction" : @"Click",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickProductOnProductFeedWithProductName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickFeed",
                           @"eventCategory" : @"Feed",
                           @"eventAction" : @"Click",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickProductOnRecentlyViewedWithProductName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickRecent",
                           @"eventCategory" : @"Recently Viewed",
                           @"eventAction" : @"Click",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickShopOnFavoriteShopWithShopName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickFavorite",
                           @"eventCategory" : @"Favorite",
                           @"eventAction" : @"View",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickSearchResultTabWithName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickSearchResult",
                           @"eventCategory" : @"Search Result",
                           @"eventAction" : @"Click",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickHotlistProductWithName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickHotlist",
                           @"eventCategory" : @"Hotlist",
                           @"eventAction" : @"Click",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackGoToHomepageTabWithIndex:(NSInteger)index {
    TPAnalytics *analytics = [[self alloc] init];
    NSString *name = @"";
    
    switch (index) {
        case 1:
            name = @"Home";
            break;
        case 2:
            name = @"Product Feed";
            break;
        case 3:
            name = @"Wishlist";
            break;
        case 4:
            name = @"Last Seen";
            break;
        case 5:
            name = @"Favorite";
            break;
        default:
            break;
    }
    
    NSDictionary *data = @{
                           @"event" : @"clickHomepage",
                           @"eventCategory" : @"Homepage",
                           @"eventAction" : @"Click",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickTabBarItemWithName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickTabBar",
                           @"eventCategory" : @"Tab Bar",
                           @"eventAction" : @"Click",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickOnMorePageWithEventName:(NSString *)eventName eventLabel:(NSString *)eventLabel {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickMore",
                           @"eventCategory" : @"Tab Bar",
                           @"eventAction" : @"Click",
                           @"eventLabel" : eventLabel?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickNotificationWithEventName:(NSString *)eventName eventLabel:(NSString *)eventLabel {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickTopedIcon",
                           @"eventCategory" : @"Toped Icon",
                           @"eventAction" : @"Click",
                           @"eventLabel" : eventLabel?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackPaymentEvent:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : event?:@"",
                           @"eventCategory" : category?:@"",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackProductDetailPageWithEvent:(NSString *)event action:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : event?:@"",
                           @"eventCategory" : @"Product Detail Page",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackAbandonRegisterWithFieldName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"registerAbandon",
                           @"eventCategory" : @"Register",
                           @"eventAction" : @"Register Abandon",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackLoginCTAButton {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickLogin",
                           @"eventCategory" : @"Login",
                           @"eventAction" : @"Click",
                           @"eventLabel" : @"CTA"
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackSuccessLoginWithChannel:(NSString *)channel {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"loginSuccess",
                           @"eventCategory" : @"Login",
                           @"eventAction" : @"Login Success",
                           @"eventLabel" : channel?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackErrorLoginWithFieldName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"loginError",
                           @"eventCategory" : @"Login",
                           @"eventAction" : @"Login Error",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackAbandonLoginWithFieldName:(NSString *)name {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"loginAbandon",
                           @"eventCategory" : @"Login",
                           @"eventAction" : @"Login Abandon",
                           @"eventLabel" : name?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackRegisterThroughLogin {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"registerLogin",
                           @"eventCategory" : @"Login",
                           @"eventAction" : @"Register",
                           @"eventLabel" : @"Register"
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackSearchNoResultWithKeyword:(NSString *)keyword {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"noSearchResult",
                           @"eventCategory" : @"No Search Result",
                           @"eventAction" : @"No Result",
                           @"eventLabel" : keyword?:@""
                           };
    
    [analytics.dataLayer push:data];
}
+ (void)trackAddToWishlist {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickWishlist",
                           @"eventCategory" : @"Product Detail Page",
                           @"eventAction" : @"Click",
                           @"eventLabel" : @"Add to Wishlist"
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackInboxMessageAction:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickMessage",
                           @"eventCategory" : @"Message",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackInboxTalkAction:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickProductDiscussion",
                           @"eventCategory" : @"Product Discussion",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackInboxReviewAction:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickReview",
                           @"eventCategory" : @"Review",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackInboxResolutionAction:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickResolution",
                           @"eventCategory" : @"Resolution",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackEtalaseAction:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickEtalase",
                           @"eventCategory" : @"Etalase",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickCheckoutCTAButton {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickCheckout",
                           @"eventCategory" : @"Checkout",
                           @"eventAction" : @"Click",
                           @"eventLabel" : @"Checkout"
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackForgetPasswordEvent:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : event?:@"",
                           @"eventCategory" : category?:@"",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackSecurityQuestionEvent:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : event?:@"",
                           @"eventCategory" : category?:@"",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackClickCreateShop {
    TPAnalytics *analytics = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"clickCreateShop",
                           @"eventCategory" : @"Create Shop",
                           @"eventAction" : @"Click",
                           @"eventLabel" : @"Create"
                           };
    
    [analytics.dataLayer push:data];
}

@end
