//
//  AddProductSubmit.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddProductSubmitResult.h"

@interface AddProductSubmit : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) AddProductSubmitResult *result;

@end
