//
//  RequestRates.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RateResponse.h"
#import "ShippingInfoShipments.h"

@interface RequestRates : NSObject

+(void)fetchRateWithName:(NSString *)name origin:(NSString*)origin destination:(NSString *)destination weight:(NSString*)weight token:(NSString*)token ut:(NSString*)ut insurance:(NSString*)insurance catID:(NSNumber*)catID orderValue:(NSString*)orderValue productInsurance:(NSString*)productInsurance shipmentAvailable:(NSArray*)shipmentAvailable isShowOKE:(NSString*)isShowOKE onSuccess:(void(^)(RateData* rateData))success onFailure:(void(^)(NSError* errorResult)) error;

@end
