//
//  TPLocalytics.m
//  Tokopedia
//
//  Created by Tokopedia on 6/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "TPLocalytics.h"
#import "SearchAWSResult.h"
#import "Paging.h"
#import "Breadcrumb.h"
#import "NSNumberFormatter+IDRFormater.h"

@implementation TPLocalytics

+ (void)trackCartView:(TransactionCartResult *)cartResult {
    NSInteger itemsInCart = 0;
    for(TransactionCartList *cart in cartResult.list) {
        for(ProductDetail *detailProduct in cart.cart_products) {
            itemsInCart += [detailProduct.product_quantity integerValue];
        }
    }
    NSDictionary *attributes = @{
        @"Items in Cart": [NSNumber numberWithInt:itemsInCart],
        @"Value of Cart": cartResult.grand_total_idr,
    };
    [Localytics tagEvent:@"Cart Viewed" attributes:attributes];
}

+ (void)trackAddToCart:(ProductDetail*)product {
    NSString *productId = product.product_id;
    NSNumber *price = [[NSNumberFormatter IDRFormarter] numberFromString:product.product_price];
    NSInteger totalPrice = [product.product_total_price integerValue];
    NSString *total = [NSString stringWithFormat:@"%zd", totalPrice];
    NSString *productQuantity = product.product_quantity;
    
    NSDictionary *attributes = @{
        @"Product Id" : productId,
        @"Category" : product.product_cat_name?:@"",
        @"Price" : price?:@(0),
        @"Value of Cart" : total?:@"",
        @"Items in Cart" : productQuantity?:@""
    };
    
    [Localytics tagEvent:@"Product Added to Cart" attributes:attributes];
    
    NSString *profileAttribute = @"Profile : Last date has product in cart";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    [Localytics setValue:currentDate forProfileAttribute:profileAttribute withScope:LLProfileScopeApplication];
}

+ (void)trackProductView:(Product *)response {
    if (response.data.breadcrumb.count == 0) {
        return;
    }
    
    NSNumber *price = [[NSNumberFormatter IDRFormarter] numberFromString:response.data.info.product_price];
    
    Breadcrumb *category = response.data.breadcrumb[response.data.breadcrumb.count - 1];

    NSDictionary *attributes = @{
        @"Product ID": response.data.info.product_id,
        @"Category": category.department_name,
        @"Price": price?:@(0),
        @"Price Alert": response.data.info.product_price_alert?:@"",
        @"Wishlist": response.data.info.product_already_wishlist?:@""
    };
    [Localytics tagEvent:@"Product Viewed" attributes:attributes];
}

+ (void)trackRegistrationWithProvider:(NSString *)provider success:(BOOL)success {
    
    NSString *method = @"";
    if ([provider isEqualToString:@"1"]) {
        method = @"Facebook";
    } else if ([provider isEqualToString:@"2"]) {
        method = @"Google";
    } else if ([provider isEqualToString:@"0"]) {
        method = @"Email";
    } else if ([provider isEqualToString:@"4"]) {
        method = @"Yahoo";
    }
    
    NSDictionary *attributes = @{
                                 @"Success": success? @"Yes": @"No",
                                 @"Previous Screen": @"Login",
                                 @"Method": method
                                 };
    
    [Localytics tagEvent:@"Registration Summary" attributes:attributes];
}

+ (void)trackLoginStatus:(BOOL)status {
    [Localytics setValue:status?@"Yes": @"No" forProfileAttribute:@"Is Login"];
    [Localytics tagEvent:@"Login" attributes:@{@"success": status?@"Yes": @"No"}];
}

+ (void)trackScreenName:(NSString *)screenName {
    [Localytics tagScreen:screenName];
}

@end
