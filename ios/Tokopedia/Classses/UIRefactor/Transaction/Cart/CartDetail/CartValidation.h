//
//  CartValidation.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionCartResult.h"

@interface CartValidation : NSObject

+(BOOL)isValidInputIndomaretCart:(TransactionCartResult*)cart;
+(BOOL)isValidInputKlikBCACart:(TransactionCartResult*)cart;
+(BOOL)isValidInputCCCart:(TransactionCartResult*)cart;
+(BOOL)isValidInputVoucherCode:(NSString*)voucherCode;

@end
