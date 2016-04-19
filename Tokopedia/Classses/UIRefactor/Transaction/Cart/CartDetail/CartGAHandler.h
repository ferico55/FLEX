//
//  CartGAHandler.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "string_transaction.h"
#import "TransactionCart.h"

@interface CartGAHandler : NSObject

+ (void)sendingProductCart:(NSArray<TransactionCartList*>*)list page:(NSInteger)page gateway:(NSString*)gateway;

@end
