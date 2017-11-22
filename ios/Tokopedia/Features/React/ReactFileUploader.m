//
//  ReactFileUploader.m
//  Tokopedia
//
//  Created by Ferico Samuel on 9/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactFileUploader.h"
#import "RequestObject.h"
#import "RequestUploadImage.h"
#import "UIApplication+React.h"
#import "Tokopedia-Swift.h"
#import <React/RCTView.h>
#import <React/RCTUIManager.h>

@implementation ReactFileUploader

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(uploadImage:(NSString*) host urlString: (NSString *) urlString imageId:(NSString *) imageId callback:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    RequestObjectUploadImage *requestObject = [RequestObjectUploadImage new];
    requestObject.image_id = imageId;
    requestObject.token = @"";
    requestObject.user_id = [[UserAuthentificationManager new] getUserId];
    requestObject.web_service = @"1";
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    [RequestUploadImage requestUploadImage:img
                            withUploadHost:host
                                      path:@"/upload/attachment"
                                      name:@"fileToUpload"
                                  fileName:@"image.png"
                             requestObject:requestObject
                                 onSuccess:^(ImageResult *imageResult) {
                                     NSLog(@"%@", imageResult.pic_obj);
                                     resolve(imageResult.pic_obj);
                                 }
                                 onFailure:^(NSError *errorResult) {
                                     reject(@"upload_failed", @"Failed to upload image", nil);
                                 }];
}

@end
