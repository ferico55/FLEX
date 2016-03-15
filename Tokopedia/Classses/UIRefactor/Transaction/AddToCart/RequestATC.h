//
//  RequestATC.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionATCForm.h"

@interface RequestATC : NSObject

+(void)fetchFormProductID:(NSString*)productID
                addressID:(NSString*)addressID
                  success:(void(^)(TransactionATCFormResult* data))success
                   failed:(void(^)(NSError * error))failed;

@end
