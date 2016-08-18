//
//  AddProductValidation.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddProductValidationResult.h"

@interface AddProductValidation : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) AddProductValidationResult *data;

@end
