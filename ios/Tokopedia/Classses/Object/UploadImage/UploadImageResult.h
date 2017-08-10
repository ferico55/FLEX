//
//  UploadImageResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadImageImage.h"
#import "Upload.h"

@interface UploadImageResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *pic_id;
@property (nonatomic, strong, nonnull) NSString *src;
@property (nonatomic, strong, nonnull) NSString *file_path;
@property (nonatomic, strong, nonnull) NSString *file_th;
@property (nonatomic, strong, nonnull) NSString *pic_obj;
@property (nonatomic, strong, nonnull) NSString *pic_src;
@property (nonatomic, strong, nonnull) NSString *file_name;
@property (nonatomic, strong, nonnull) Upload *upload;
@property (nonatomic, strong, nonnull) NSString *file_uploaded;
@property (nonatomic, strong, nonnull) UploadImageImage *image;

@property (nonatomic, strong, nonnull) NSString *is_success;

@end
