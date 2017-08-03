//
//  RequestCart.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TransactionAction.h"
#import "TransactionSummary.h"
#import "TransactionVoucher.h"

#import "TransactionObjectManager.h"
#import "string_transaction.h"

@interface RequestCart : NSObject

+(void)fetchCartData:(void(^)(TransactionCartResult *data))success error:(void (^)(NSError *error))error;

+(void)fetchToppayWithToken:(NSString *)token listDropship:(NSArray *)listDropship dropshipDetail:(NSDictionary *)dropshipDetail listPartial:(NSArray *)listPartial partialDetail:(NSDictionary *)partialDetail voucherCode:(NSString *)voucherCode donationAmount:(NSString*)donationAmount cartListRate:(NSDictionary *)cartListRate success:(void (^)(TransactionActionResult *data))success error:(void (^)(NSError *))error;

+(void)fetchVoucherCode:(NSString*)voucherCode isPromoSuggestion:(BOOL)isPromoSuggestion success:(void (^)(TransactionVoucher *data))success error:(void (^)(NSError *error))error;

+(void)fetchDeleteProduct:(ProductDetail*)product cart:(TransactionCartList*)cart withType:(NSInteger)type success:(void (^)(TransactionAction *data, ProductDetail* product, TransactionCartList* cart, NSInteger type))success error:(void (^)(NSError *error))error;

+(void)fetchEditProduct:(ProductDetail*)product success:(void (^)(TransactionAction *data))success error:(void (^)(NSError *error))error;

+(void)fetchToppayThanksCode:(NSString*)code success:(void (^)(TransactionActionResult *data))success error:(void (^)(NSError *error))error;

@end
