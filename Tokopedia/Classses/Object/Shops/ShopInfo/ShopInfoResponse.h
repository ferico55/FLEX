//
//  ShopInfoResponse.h
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopInfoResult.h"

@interface ShopInfoResponse : NSObject

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *config;
@property (strong, nonatomic) NSString *server_process_time;
@property (strong, nonatomic) ShopInfoResult *data;

+ (RKObjectMapping *)mapping;

@end
