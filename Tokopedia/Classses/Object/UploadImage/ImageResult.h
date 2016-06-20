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

@property (nonatomic, strong) NSString *success;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *server_id;
@property (nonatomic, strong) NSString *pic_src;
@property (nonatomic, strong) NSString *pic_obj;
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *src;
@property (nonatomic, strong) UploadDataImage *image;
@property (nonatomic, strong) UploadDataImage *upload;
@property (nonatomic, strong) UploadDataImage *data;

+ (RKObjectMapping*)mapping;

@end
