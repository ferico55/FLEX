//
//  RequestShipmentCourier.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestShipmentCourierDelegate <NSObject>

@optional;
- (void)didReceiveShipmentCourier:(NSArray *)couriers;
- (void)requestShipmentCourierError:(NSError *)error;

@end

@interface RequestShipmentCourier : NSObject

@property (weak, nonatomic) id<RequestShipmentCourierDelegate> delegate;

- (void)request;

@end

