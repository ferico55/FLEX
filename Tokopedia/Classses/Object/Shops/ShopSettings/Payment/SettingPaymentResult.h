//
//  SettingPaymentResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Payment.h"

@interface SettingPaymentResult : NSObject

@property (nonatomic, strong) NSArray *note;
@property (nonatomic, strong) NSDictionary *loc;
@property (nonatomic) NSInteger shop_id;
@property (nonatomic, strong) NSArray *shop_payment;
@property (nonatomic, strong) NSArray *payment_options;

+ (RKObjectMapping *)mapping;

@end
