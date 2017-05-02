//
//  LoyaltyPointResult.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LoyaltyPointMerchant.h"
#import "LoyaltyPointDetail.h"
#import "LoyaltyPointBuyer.h"

#import "TKPObjectMapping.h"

@interface LoyaltyPointResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) LoyaltyPointMerchant *merchant;
@property (nonatomic, strong) LoyaltyPointDetail *loyalty_point;
@property (nonatomic, strong) LoyaltyPointBuyer *buyer;

@property (nonatomic, strong) NSString *uri;

@end
