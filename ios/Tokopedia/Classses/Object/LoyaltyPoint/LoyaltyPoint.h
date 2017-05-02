//
//  LoyaltyPoint.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoyaltyPointResult.h"

#import "TKPObjectMapping.h"

@interface LoyaltyPoint : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) LoyaltyPointResult *result;

@end
