//
//  TPLocalytics.h
//  Tokopedia
//
//  Created by Tokopedia on 6/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Localytics.h"
#import "TransactionCartResult.h"
#import "Product.h"
#import "SearchAWS.h"

typedef NS_ENUM(NSInteger, RegistrationPlatform) {
    RegistrationPlatformFacebook,
    RegistrationPlatformGoogle,
    RegistrationPlatformEmail,
};

@interface TPLocalytics : NSObject

+ (void)trackCartView:(TransactionCartResult *)cart;
+ (void)trackAddToCart:(ProductDetail *)product;
+ (void)trackProductView:(Product *)product;

+ (void)trackRegistrationWith:(RegistrationPlatform)platform success:(BOOL)success;
+ (void)trackLoginStatus:(BOOL)status;
+ (void)trackAddProductPriceAlert:(ProductDetail *)product price:(NSString *)price success:(BOOL)isSuccess;

@end
