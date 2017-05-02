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

@property (nonatomic, strong) NSString *pic_id;
@property (nonatomic, strong) NSString *src;
@property (nonatomic, strong) NSString *file_path;
@property (nonatomic, strong) NSString *file_th;
@property (nonatomic, strong) NSString *pic_obj;
@property (nonatomic, strong) NSString *pic_src;
@property (nonatomic, strong) NSString *file_name;
@property (nonatomic, strong) Upload *upload;
@property (nonatomic, strong) NSString *file_uploaded;
@property (nonatomic, strong) UploadImageImage *image;

@property (nonatomic, strong) NSString *is_success;

@end