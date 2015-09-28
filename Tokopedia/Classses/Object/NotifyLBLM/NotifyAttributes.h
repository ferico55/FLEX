//
//  NotifyAttributes.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TKPObjectMapping.h"

@interface NotifyAttributes : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *notify_buyer;
@property (nonatomic, strong) NSString *expiry_time_loyal_buyer;
@property (nonatomic, strong) NSString *notify_seller;
@property (nonatomic, strong) NSString *expiry_time_loyal_seller;

@end
