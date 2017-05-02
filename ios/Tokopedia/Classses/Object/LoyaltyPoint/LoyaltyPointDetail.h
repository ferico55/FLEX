//
//  LoyaltyPointDetail.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TKPObjectMapping.h"

@interface LoyaltyPointDetail : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *is_expired;
@property (nonatomic, strong) NSString *has_lp;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) NSString *expire_time;

@end
