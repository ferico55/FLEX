//
//  Login.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LoginResult.h"

@interface Login : NSObject

@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) LoginResult *result;
@property (nonatomic, strong, nonnull) NSString *medium; // Added to help analytics

@property BOOL justRegistered;

+ (RKObjectMapping *_Nonnull)mapping;

@end
