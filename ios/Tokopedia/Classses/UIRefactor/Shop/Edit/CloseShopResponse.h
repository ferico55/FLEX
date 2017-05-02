//
//  CloseShopResponse.h
//  Tokopedia
//
//  Created by Johanes Effendi on 5/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloseShopResult.h"

@interface CloseShopResponse : NSObject
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) CloseShopResult *data;

+(RKObjectMapping *)mapping;
@end
