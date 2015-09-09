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

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) ContactUsResult *result;

@end
