//
//  RequestUploadImage.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadImage.h"
#import "ImageResult.h"
#import "GenerateHost.h"
#import "RequestObject.h"

#define DATA_SELECTED_IMAGE_VIEW_KEY @"data_selected_image_view"
#define DATA_SELECTED_PHOTO_KEY @"data_selected_photo"
#define DATA_SELECTED_INDEXPATH_KEY @"data_selected_indexpath"

@interface RequestUploadImage : NSObject

+ (void)requestUploadImage:(UIImage*)image
            withUploadHost:(NSString*)host
                      path:(NSString*)path
                      name:(NSString*)name
                  fileName:(NSString*)fileName
             requestObject:(id)object
                 onSuccess:(void (^)(ImageResult *))success
                 onFailure:(void (^)(NSError *))failure;

+ (void)requestUploadImageResolution:(UIImage*)image
            withUploadHost:(NSString*)host
                      path:(NSString*)path
                      name:(NSString*)name
                  fileName:(NSString*)fileName
             requestObject:(id)object
                 onSuccess:(void (^)(ImageResult *))success
                 onFailure:(void (^)(NSError *))failure;
+ (void)requestUploadVideo:(NSURL*)videoUrl
            withUploadHost:(NSString*)host
                      path:(NSString*)path
                      name:(NSString*)name
                  fileName:(NSString*)fileName
             requestObject:(id)object
                 onSuccess:(void (^)(ImageResult *imageResult))success
                 onFailure:(void (^)(NSError *errorResult))failure;
@end
