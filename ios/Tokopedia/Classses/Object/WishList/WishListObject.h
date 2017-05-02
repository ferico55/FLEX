//
//  WishListObject.h
//  Tokopedia
//
//  Created by Tokopedia on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WishListObjectResult.h"

@interface WishListObject : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) WishListObjectResult *data;
@property (nonatomic, strong) WishListObjectResult *result;

@end
