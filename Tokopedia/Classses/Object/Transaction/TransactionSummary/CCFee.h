//
//  CCFee.h
//  Tokopedia
//
//  Created by Renny Runiawati on 7/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCFee : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *charge;
@property (nonatomic, strong) NSString *charge_idr;
@property (nonatomic, strong) NSString *total_idr;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *charge_25;

@end
