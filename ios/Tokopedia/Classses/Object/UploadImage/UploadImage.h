//
//  UploadImage.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UploadImageResult.h"
#import "ImageResult.h"

@interface UploadImage : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSArray *message_status;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) UploadImageResult *result;
@property (nonatomic, strong, nonnull) ImageResult *data;

@end
