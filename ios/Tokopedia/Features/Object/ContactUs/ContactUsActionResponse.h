//
//  ContactUsActionResponse.h
//  Tokopedia
//
//  Created by Tokopedia on 8/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsActionResult.h"

@interface ContactUsActionResponse : NSObject

@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) ContactUsActionResult *result;

@end
