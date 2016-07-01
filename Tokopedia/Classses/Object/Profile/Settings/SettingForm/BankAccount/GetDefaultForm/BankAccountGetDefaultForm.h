//
//  BankAccountGetDefaultForm.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BankAccountGetDefaultFormResult.h"

@interface BankAccountGetDefaultForm : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) BankAccountGetDefaultFormResult *result;

+ (RKObjectMapping *)mapping;

@end
