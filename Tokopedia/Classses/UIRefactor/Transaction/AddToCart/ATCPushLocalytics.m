//
//  ATCPushLocalytics.m
//  Tokopedia
//
//  Created by Renny Runiawati on 4/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ATCPushLocalytics.h"
#import "Localytics.h"

@implementation ATCPushLocalytics

+ (void)pushLocalyticsATCProduct:(ProductDetail*)product {
    
    NSString *productId = product.product_id;
    NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
    NSString *productPrice = [[product.product_price componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSInteger totalPrice = [product.product_total_price integerValue];
    NSString *total = [NSString stringWithFormat:@"%zd", totalPrice];
    NSString *productQuantity = product.product_quantity;
    
    NSDictionary *attributes = @{
                                 @"Product Id" : productId,
                                 @"Product Category" : product.product_cat_name?:@"",
                                 @"Price Per Item" : productPrice,
                                 @"Price Total" : total,
                                 @"Quantity" : productQuantity
                                 };
    
    [Localytics tagEvent:@"Event : Add To Cart" attributes:attributes];
    
    NSString *profileAttribute = @"Profile : Last date has product in cart";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    [Localytics setValue:currentDate forProfileAttribute:profileAttribute withScope:LLProfileScopeApplication];
}

@end
