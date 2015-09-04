//
//  ContactUsResponse.h
//  Tokopedia
//
//  Created by Tokopedia on 8/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsResult.h"

@interface ContactUsResponse : NSObject

@property (strong, nonatomic) NSArray *message_error;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *server_process_time;
@property (strong, nonatomic) ContactUsResult *result;

@end
