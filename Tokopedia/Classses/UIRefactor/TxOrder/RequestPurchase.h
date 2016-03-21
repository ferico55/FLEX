//
//  RequestPurchase.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TxOrderStatus.h"

@interface RequestPurchase : NSObject
+(void)fetchListPuchasePage:(NSInteger)page
                     action:(NSString*)action
                    invoice:(NSString*)invoice
                  startDate:(NSString*)startDate
                    endDate:(NSString*)endDate
                     status:(NSString*)status
                    success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                    failure:(void (^)(NSError *error))failure;
@end
