//
//  RequestUploadImage.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestUploadImage.h"

#import "StickyAlertView.h"
#import "NSString+HTML.h"
#import "detail.h"
#import "camera.h"
#import "Upload.h"
#import "TKPMappingManager.h"
#import "RequestObject.h"
#import "StickyAlertView+NetworkErrorHandler.h"
#import "Tokopedia-Swift.h"
#import "NSOperationQueue+SharedQueue.h"
@import Photos;

@implementation RequestUploadImage

+ (void)requestUploadImage:(UIImage*)image
            withUploadHost:(NSString*)host
                      path:(NSString*)path
                      name:(NSString*)name
                  fileName:(NSString*)fileName
             requestObject:(id)object
                 onSuccess:(void (^)(ImageResult *imageResult))success
                 onFailure:(void (^)(NSError *errorResult))failure {
    
    RKObjectManager *objectManager = [TKPMappingManager objectManagerUploadImageWithBaseURL:host
                                                                                pathPattern:path];
    NSData *resizedImageData = [image compressImageDataWithMaxSizeInMB:3];
    if (resizedImageData == nil) {
        [StickyAlertView showErrorMessage:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."]];
        return;
    }
    // Serialize the Article attributes then attach a file
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:object
                                                                          method:RKRequestMethodPOST
                                                                            path:path
                                                                      parameters:nil
                                                       constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:resizedImageData
                                                                                       name:name
                                                                                   fileName:fileName
                                                                                   mimeType:@"image/png"];
                                                           
                                                       }];
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        UploadImage *response = [mappingResult.dictionary objectForKey:@""];
        if (response.message_error.count > 0){
            [StickyAlertView showErrorMessage:response.message_error?:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."]];
            failure(nil);
        }
        if (response.data) {
            success(response.data);
        } else {
            [StickyAlertView showErrorMessage:response.message_error?:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."]];
            failure(nil);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [StickyAlertView showNetworkError:error];
        failure(error);
    }];
    
    [objectManager enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
}

+ (void)requestUploadImageResolution:(UIImage*)image
            withUploadHost:(NSString*)host
                      path:(NSString*)path
                      name:(NSString*)name
                  fileName:(NSString*)fileName
             requestObject:(id)object
                 onSuccess:(void (^)(ImageResult *imageResult))success
                 onFailure:(void (^)(NSError *errorResult))failure {
    
    RKObjectManager *objectManager = [TKPMappingManager resolutionObjectManagerWithBaseURL:host pathPattern:path];
    NSData *resizedImageData = [image compressImageDataWithMaxSizeInMB:3];
    if (resizedImageData == nil) {
        [StickyAlertView showErrorMessage:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."]];
        return;
    }
    // Serialize the Article attributes then attach a file
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:object
                                                                          method:RKRequestMethodPOST
                                                                            path:path
                                                                      parameters:nil
                                                       constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:resizedImageData
                                                                                       name:name
                                                                                   fileName:fileName
                                                                                   mimeType:@"image/png"];
                                                           
                                                       }];
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        ImageResult *response = [mappingResult.dictionary objectForKey:@""];
        if (![response.success isEqualToString:@"1"]){
            [StickyAlertView showErrorMessage:response.message_error?:response.message_error];
            failure(nil);
            return;
        }
        
        if (response.pic_obj) {
            success(response);
        } else {
            [StickyAlertView showErrorMessage:response.message_error?:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."]];
            failure(nil);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [StickyAlertView showNetworkError:error];
        failure(error);
    }];
    
    [objectManager enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
}

+ (void)requestUploadVideo:(NSURL*)videoUrl
                      withUploadHost:(NSString*)host
                                path:(NSString*)path
                                name:(NSString*)name
                            fileName:(NSString*)fileName
                       requestObject:(id)object
                           onSuccess:(void (^)(ImageResult *imageResult))success
                           onFailure:(void (^)(NSError *errorResult))failure {
    RKObjectManager *objectManager = [TKPMappingManager resolutionObjectManagerWithBaseURL:host pathPattern:path];
    // Serialize the Article attributes then attach a file
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:object
                                                                          method:RKRequestMethodPOST
                                                                            path:path
                                                                      parameters:nil
                                                       constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
                                                           NSData* data = [NSData dataWithContentsOfURL:videoUrl];
                                                           if (data.length > 0) {
                                                               NSString* mimeType = [self mimeTypeWithExtension:videoUrl.pathExtension];
                                                               [formData appendPartWithFileData:data
                                                                                           name:name
                                                                                       fileName:fileName
                                                                                       mimeType:mimeType];
                                                           }
                                                       }];
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        ImageResult *response = [mappingResult.dictionary objectForKey:@""];
        if (![response.success isEqualToString:@"1"]){
            [StickyAlertView showErrorMessage:response.message_error?:response.message_error];
            failure(nil);
            return;
        }
        if (response.pic_obj) {
            success(response);
        } else {
            [StickyAlertView showErrorMessage:response.message_error?:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."]];
            failure(nil);
        }        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [StickyAlertView showNetworkError:error];
        failure(error);
    }];
    [objectManager enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
}
+(NSString *)mimeTypeWithExtension:(NSString *)extension {
    if ([extension isEqualToString:@"mp4"]) {
        return @"video/mp4";
    } else if ([extension isEqualToString:@"mov"]) {
        return @"video/quicktime";
    }
    return [NSString stringWithFormat:@"video/%@",extension];
}
@end
