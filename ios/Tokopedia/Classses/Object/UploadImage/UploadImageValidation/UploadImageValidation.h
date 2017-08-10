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

@property (nonatomic, strong, nonnull) NSArray *message_status;
@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) UploadImageValidationResult *result;
@property (nonatomic, strong, nonnull) UploadImageValidationResult *data;

@end
