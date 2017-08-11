//
//  ImageResult.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadDataImage.h"

@interface ImageResult : NSObject

@property (nonatomic, strong, nonnull) NSString *success;
@property (nonatomic, strong, nonnull) NSArray *message_status;
@property (nonatomic, strong, nonnull) NSString *server_id;
@property (nonatomic, strong, nonnull) NSString *pic_src;
@property (nonatomic, strong, nonnull) NSString *pic_obj;
@property (nonatomic, strong, nonnull) NSString *file_uploaded;
@property (nonatomic, strong, nonnull) NSString *file_path;
@property (nonatomic, strong, nonnull) NSString *file_th;
@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSString *src;
@property (nonatomic, strong, nonnull) NSString *pic_id;
@property (nonatomic, strong, nonnull) NSString *is_success;
@property (nonatomic, strong, nonnull) UploadDataImage *image;
@property (nonatomic, strong, nonnull) UploadDataImage *upload;
@property (nonatomic, strong, nonnull) UploadDataImage *data;

+ (RKObjectMapping *_Nonnull)mapping;

@end
