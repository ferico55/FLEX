//
//  UploadImageResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadImageImage.h"
@class Upload;

@interface UploadImageResult : NSObject

@property (nonatomic, strong) NSString *pic_id;
@property (nonatomic, strong) NSString *file_path;
@property (nonatomic, strong) NSString *file_th;
@property (nonatomic, strong) NSString *pic_obj;
@property (nonatomic, strong) NSString *file_name;
@property (nonatomic, strong) Upload *upload;
@property (nonatomic, strong) NSString *file_uploaded;
@property (nonatomic, strong) UploadImageImage *image;

@end