//
//  TPLocalytics.h
//  Tokopedia
//
//  Created by Tokopedia on 6/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionCartResult.h"
#import "Product.h"
#import "SearchAWS.h"

@interface TPLocalytics : NSObject

+ (void)trackCartView:(TransactionCartResult *)cart;
+ (void)trackAddToCart:(ProductDetail *)product;
+ (void)trackProductView:(Product *)product;

+ (void)trackRegistrationWithProvider:(NSString *)provider success:(BOOL)success;
+ (void)trackLoginStatus:(BOOL)status;
+ (void)trackScreenName:(NSString *)screenName;
+ (void)trackAddProductPriceAlert:(ProductDetail *)product price:(NSString *)price success:(BOOL)isSuccess;

@end
