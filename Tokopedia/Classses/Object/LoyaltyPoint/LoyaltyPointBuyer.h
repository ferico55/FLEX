//
//  LoyaltyPointBuyer.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TKPObjectMapping.h"

@interface LoyaltyPointBuyer : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *is_lucky;
@property (nonatomic, strong) NSString *expire_time;

@end
