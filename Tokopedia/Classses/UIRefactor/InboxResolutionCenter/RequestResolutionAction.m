//
//  RequestResolutionAction.m
//  Tokopedia
//
//  Created by Renny Runiawati on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestResolutionAction.h"
#import "RequestObject.h"
#import "ImageResult.h"
#import "RequestGenerateHost.h"
#import "RequestUploadImage.h"
#import "StickyAlertView+NetworkErrorHandler.h"
#import "UploadImageHelper.h"

typedef void (^failedCompletionBlock)(NSError *error);

static failedCompletionBlock failedCreateReso;

@implementation RequestResolutionAction

+(void)fetchCancelResolutionID:(NSString*)resolutionID
                           success:(void(^) (ResolutionActionResult* data))success
                           failure:(void(^)(NSError* error))failure {
    
    NSDictionary* param = @{
                            @"resolution_id" : resolutionID?:@""
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/cancel_resolution.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success == 1) {
                                     [StickyAlertView showSuccessMessage:response.message_status?:@[@"Anda telah berhasil membatalkan komplain."]];
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membatalkan resolusi"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

#pragma mark - Request Create Resolution

+(void)fetchCreateResolutionUploadImages:(NSArray<DKAsset*>*)imageObjects
                                 success:(void(^)(NSArray<ImageResult *>*datas, GeneratedHost *host))success {
    
    [RequestGenerateHost fetchGenerateHostSuccess:^(GeneratedHost *host) {
        NSString *uploadImageBaseURL = [NSString stringWithFormat:@"https://%@",host.upload_host];
        
        NSMutableArray *uploadedDatas =[NSMutableArray new];
        __block NSInteger countImage = 0;
        
        for (int i = 0; i< imageObjects.count; i++) {
            
            UserAuthentificationManager *auth = [UserAuthentificationManager new];
            RequestObjectUploadImage *requestObject = [RequestObjectUploadImage new];
            requestObject.server_id = host.server_id;
            requestObject.user_id = [auth getUserId];
            
            [RequestUploadImage requestUploadImage:imageObjects[i].resizedImage
                                    withUploadHost:uploadImageBaseURL
                                              path:@"/web-service/v4/action/upload-image/upload_contact_image.pl"
                                              name:@"fileToUpload"
                                          fileName:imageObjects[i].fileName?:@"image.png"
                                     requestObject:requestObject
                                         onSuccess:^(ImageResult *imageResult) {
                                             
                                             [uploadedDatas addObject:imageResult];
                                             countImage+=1;
                                             if (countImage == imageObjects.count) {
                                                 success(uploadedDatas, host);
                                             }
                                             
                                         } onFailure:^(NSError *error) {
                                             failedCreateReso(error);
                                         }];
        }

        
    } failure:^(NSError *error) {
        failedCreateReso(error);
    }];
}

+(NSDictionary*)setParamCreateValidationWithID:(NSString *)orderID
                                  flagReceived:(NSString *)flagReceived
                                   troubleType:(NSString *)troubleType
                                      solution:(NSString *)solution
                                  refundAmount:(NSString *)refundAmount
                                        remark:(NSString *)remark
                                        photos:(NSArray <ImageResult*>*)photos
                                      serverID:(NSString *)serverID
{
    NSMutableArray *filePathPhotos = [NSMutableArray new];
    for (ImageResult *imageResult in photos) {
        [filePathPhotos addObject:imageResult.file_path?:@""];
    }
    NSString *photo = [[[filePathPhotos copy] valueForKey:@"description"]componentsJoinedByString:@"~"];
    
    NSDictionary *param = @{
                            @"order_id"          :orderID?:@"",
                            @"remark"            :remark?:@"",
                            @"photos"            :photo?:@"",
                            @"server_id"         :serverID?:@"",
                            @"solution"          :solution?:@"",
                            @"refund_amount"     :refundAmount?:@"",
                            @"flag_received"     :flagReceived?:@"",
                            @"trouble_type"      :troubleType?:@"",
                            @"app_new"           :@"1"              //harus kasi image buat create reso
                            };
    return param;
}

+(NSDictionary*)setParamCreateImageWithID:(NSString*)orderID
                              attachments:(NSArray <ImageResult*>*)attachments
                                 serverID:(NSString*)serverID
{
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    
    NSMutableArray *filePathPhotos = [NSMutableArray new];
    for (ImageResult *imageResult in attachments) {
        [filePathPhotos addObject:imageResult.file_path?:@""];
    }
    NSString *photo = [[[filePathPhotos copy] valueForKey:@"description"]componentsJoinedByString:@"~"];
    
    NSDictionary *param = @{
                            @"order_id"          :orderID?:@"",
                            @"file_path"         :photo?:@"",
                            @"attachment_string" :photo?:@"",
                            @"server_id"         :serverID?:@"",
                            @"user_id"           :[auth getUserId]?:@""
                            };
    return param;
}

+(NSDictionary*)setParamCreateSubmitWithID:(NSString*)orderID
                              fileUploaded:(NSString*)fileUploaded
                                 postKey:(NSString*)postKey
{
    NSDictionary *param = @{
                            @"file_uploaded"    :fileUploaded?:@"",
                            @"order_id"         :orderID?:@"",
                            @"post_key"         :postKey?:@"",
                            };
    return param;
}

+(void)fetchCreateResolutionValidationWithParam:(NSDictionary*)param
                                        success:(void(^) (NSString* postKey))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/create_resolution_validation.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[UploadImageValidation mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 UploadImageValidation *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if ([response.data.is_success integerValue] == 1) {
                                     success(response.data.post_key);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membuat komplain"]];
                                     failedCreateReso(nil);
                                 }
                                 
    } onFailure:^(NSError *errorResult) {
        failedCreateReso(errorResult);
    }];
    
}

+(void)fetchCreateResolutionFileUploadedWithParam:(NSDictionary*)param
                                       uploadHost:(NSString *)uploadHost
                                          success:(void(^) (NSString* fileUploaded))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    NSString *uploadImageBaseURL = [NSString stringWithFormat:@"https://%@",uploadHost];
    [networkManager requestWithBaseUrl:uploadImageBaseURL
                                  path:@"/web-service/v4/action/upload-image-helper/create_resolution_picture.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[UploadImageHelper mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 UploadImageHelper *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if ([response.data.is_success integerValue] == 1) {
                                     success(response.data.file_uploaded);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membuat komplain"]];
                                     failedCreateReso(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedCreateReso(errorResult);
                             }];
    
}

+(void)fetchCreateResolutionSubmitWithParam:(NSDictionary*)param
                                    success:(void(^) (ResolutionActionResult* data))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/create_resolution_submit.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membuat komplain"]];
                                     failedCreateReso(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedCreateReso(errorResult);
                             }];
    
}

+(void)fetchCreateResolutionOrderID:(NSString*)orderID
                       flagReceived:(NSString*)flagReceived
                        troubleType:(NSString*)troubleType
                           solution:(NSString*)solution
                       refundAmount:(NSString*)refundAmount
                             remark:(NSString*)remark
                             imageObjects:(NSArray<DKAsset*>*)imageObjects
                            success:(void(^) (ResolutionActionResult* data))success
                            failure:(void(^)(NSError* error))failure {
    
    failedCreateReso = failure;
    
    if (imageObjects.count == 0) {
        NSDictionary *paramValidation = [RequestResolutionAction setParamCreateValidationWithID:orderID
                                                                                   flagReceived:flagReceived
                                                                                    troubleType:troubleType
                                                                                       solution:solution
                                                                                   refundAmount:refundAmount
                                                                                         remark:remark
                                                                                         photos:@[]
                                                                                       serverID:@""];
        
        [RequestResolutionAction fetchCreateResolutionValidationWithParam:paramValidation success:^(NSString *postKey) {
            ResolutionActionResult *data = [ResolutionActionResult new];
            data.is_success = [postKey integerValue];
            success(data);
        }];

    } else {
        [RequestResolutionAction fetchCreateResolutionUploadImages:imageObjects success:^(NSArray<ImageResult *> *datas, GeneratedHost *host) {
            
            NSDictionary *paramValidation = [RequestResolutionAction setParamCreateValidationWithID:orderID
                                                                                       flagReceived:flagReceived
                                                                                        troubleType:troubleType
                                                                                           solution:solution
                                                                                       refundAmount:refundAmount
                                                                                             remark:remark
                                                                                             photos:datas
                                                                                           serverID:host.server_id?:@""];
            
            [RequestResolutionAction fetchCreateResolutionValidationWithParam:paramValidation success:^(NSString *postKey) {
                
                NSDictionary *paramImageHelper = [RequestResolutionAction setParamCreateImageWithID:orderID
                                                                                        attachments:datas
                                                                                           serverID:host.server_id?:@""];
                
                [RequestResolutionAction fetchCreateResolutionFileUploadedWithParam:paramImageHelper uploadHost:host.upload_host?:@"" success:^(NSString *fileUploaded) {
                    
                    NSDictionary *paramSubmit = [RequestResolutionAction setParamCreateSubmitWithID:orderID
                                                                                       fileUploaded:fileUploaded
                                                                                            postKey:postKey];
                    
                    [RequestResolutionAction fetchCreateResolutionSubmitWithParam:paramSubmit success:^(ResolutionActionResult *data) {
                        
                        success(data);
                        
                    }];
                }];
            }];
        }];
    }
    
}

@end
