//
//  TrackOrderDetail.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackOrderDetail : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *shipper_city;
@property (strong, nonatomic) NSString *shipper_name;
@property (strong, nonatomic) NSString *receiver_city;
@property (strong, nonatomic) NSString *send_date;
@property (strong, nonatomic) NSString *receiver_name;
@property (strong, nonatomic) NSString *service_code;
@property (strong, nonatomic) NSString *delivered;

@end
