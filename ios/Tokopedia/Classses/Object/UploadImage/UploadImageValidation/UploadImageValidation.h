//
//  UploadImageValidation.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadImageValidationResult.h"
#import "TKPObjectMapping.h"

@interface UploadImageValidation : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) UploadImageValidationResult *result;
@property (nonatomic, strong) UploadImageValidationResult *data;

@end
