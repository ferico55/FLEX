//
//  IndomaretData.h
//  Tokopedia
//
//  Created by Renny Runiawati on 7/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IndomaretData : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *charge_idr;
@property (nonatomic, strong) NSString *total_charge_real_idr;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *charge_real;
@property (nonatomic, strong) NSString *charge;
@property (nonatomic, strong) NSString *payment_code;
@property (nonatomic, strong) NSString *charge_real_idr;
@property (nonatomic, strong) NSString *total_idr;

@end
