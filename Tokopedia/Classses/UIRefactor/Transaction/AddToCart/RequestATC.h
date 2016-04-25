//
//  RequestATC.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionATCForm.h"
#import "TransactionAction.h"
#import "TransactionCalculatePrice.h"
#import "RateResponse.h"
#import "RequestRates.h"
#import "RequestEditAddress.h"
#import "RequestAddAddress.h"

@interface RequestATC : NSObject

+(void)fetchFormProductID:(NSString*)productID
                addressID:(NSString*)addressID
                  success:(void(^)(TransactionATCFormResult* data))success
                   failed:(void(^)(NSError * error))failed;

+(void)fetchATCProduct:(ProductDetail*)product address:(AddressFormList*)address shipment:(RateAttributes*)shipment shipmentPackage:(RateProduct*)shipmentPackage quantity:(NSString*)qty remark:(NSString *)remark success:(void(^)(TransactionAction* data))success failed:(void(^)(NSError * error))failed;

+(void)fetchCalculateProduct:(ProductDetail*)product qty:(NSString*)qty insurance:(NSString*)insurance shipment:(RateAttributes*)shipment shipmentPackage:(RateProduct*)shipmentPackage address:(AddressFormList*)address success:(void(^)(TransactionCalculatePriceResult* data))success failed:(void(^)(NSError * error))failed;

@end
