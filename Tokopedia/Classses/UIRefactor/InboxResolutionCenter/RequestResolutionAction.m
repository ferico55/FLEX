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
#import "ResolutionCenterCreatePOSTRequest.h"
#import "Tokopedia-Swift.h"

typedef void (^failedCompletionBlock)(NSError *error);

static failedCompletionBlock failedRequest;

@implementation RequestResolutionAction

#pragma mark - Cancel Complain
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
                                method:RKRequestMethodPOST
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

#pragma mark - Upload Images

+(void)fetchResolutionUploadImages:(NSArray<DKAsset*>*)imageObjects
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
                                             failedRequest(error);
                                         }];
        }

        
    } failure:^(NSError *error) {
        failedRequest(error);
    }];
}

+(void)fetchResolutionFileUploadedWithParam:(NSDictionary*)param
                                       uploadHost:(NSString *)uploadHost
                                          success:(void(^) (ResolutionActionResult* dataImageHelper))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    NSString *uploadImageBaseURL = [NSString stringWithFormat:@"https://%@",uploadHost];
    [networkManager requestWithBaseUrl:uploadImageBaseURL
                                  path:@"/web-service/v4/action/upload-image-helper/create_resolution_picture.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success == 1) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membuat komplain"]];
                                     failedRequest(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedRequest(errorResult);
                             }];
    
}

#pragma mark - Request Create Resolution

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
                            @"trouble_type"      :troubleType?:@"",  //trouble id
                            @"app_new"           :@"1"              //harus kasi image buat create reso
                            };
    return param;
}

+(NSDictionary*)setParamCreateNewValidationWithID:(NSString *)orderID
                                  flagReceived:(NSString *)flagReceived
                                     troubleId:(NSString *)troubleId
                                      solution:(NSString *)solution
                                  refundAmount:(NSString *)refundAmount
                                        remark:(NSString *)remark
                                        photos:(NSArray <ImageResult*>*)photos
                                      serverID:(NSString *)serverID
                             categoryTroubleId:(NSString *)categoryTroubleId
                         possibleTroubleObject:(ResolutionCenterCreatePOSTRequest*)possibleTrouble
{
    NSMutableArray *filePathPhotos = [NSMutableArray new];
    for (ImageResult *imageResult in photos) {
        [filePathPhotos addObject:imageResult.file_path?:@""];
    }
    NSString *photo = [[[filePathPhotos copy] valueForKey:@"description"]componentsJoinedByString:@"~"];
    
    NSString* jsonString = @"{\"data\" : [";
    for(ResolutionCenterCreatePOSTProduct* product in possibleTrouble.product_list){
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[ResolutionCenterCreatePOSTProduct mapping] inverseMapping]
                                                                                       objectClass:[ResolutionCenterCreatePOSTProduct class]
                                                                                       rootKeyPath:nil
                                                                                            method:RKRequestMethodPOST];
        
        NSDictionary *paramForObject = [RKObjectParameterization parametersWithObject:product
                                                                    requestDescriptor:requestDescriptor
                                                                                error:nil];
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:paramForObject
                                                           options:0
                                                             error:&error];
        if(jsonData){
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [[jsonString stringByAppendingString:jsonStr] stringByAppendingString:@","];
        }
    }
    jsonString = [jsonString substringToIndex:[jsonString length]-1];
    jsonString = [jsonString stringByAppendingString:@"]}"];
    
    NSDictionary *param = @{
                            @"order_id"          :orderID?:@"",
                            @"remark"            :remark?:@"",
                            @"photos"            :photo?:@"",
                            @"server_id"         :serverID?:@"",
                            @"solution"          :solution?:@"",
                            @"refund_amount"     :refundAmount?:@"",
                            @"flag_received"     :flagReceived?:@"",
                            @"trouble_id"        :troubleId?:@"",  //trouble id
                            @"app_new"           :@"1",              //harus kasi image buat create reso
                            @"category_trouble_id":categoryTroubleId,
                            @"product_list"        : jsonString
                            };
    return param;
    return nil;
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
                                        success:(void(^) (ResolutionActionResult* dataValidation))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/create_resolution_validation.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success == 1) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membuat komplain"]];
                                     failedRequest(nil);
                                 }
                                 
    } onFailure:^(NSError *errorResult) {
        failedRequest(errorResult);
    }];
    
}

+(void)fetchCreateNewResolutionValidationWithParam:(NSDictionary*)param
                                        success:(void(^) (ResolutionActionResult* dataValidation))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/create_resolution_validation_new.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success == 1) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membuat komplain"]];
                                     failedRequest(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedRequest(errorResult);
                             }];
    
}

+(void)fetchCreateResolutionSubmitWithParam:(NSDictionary*)param
                                    success:(void(^) (ResolutionActionResult* data))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/create_resolution_submit.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membuat komplain"]];
                                     failedRequest(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedRequest(errorResult);
                             }];
    
}

+(void)fetchCreateResolutionOrderID:(NSString*)orderID
                       flagReceived:(NSString*)flagReceived
                        troubleType:(NSString*)troubleType
                           solution:(NSString*)solution
                       refundAmount:(NSString*)refundAmount
                             remark:(NSString*)remark
                             imageObjects:(NSArray<DKAsset*>*)imageObjects
                            success:(void(^) (ResolutionActionResult* dataValidation))success
                            failure:(void(^)(NSError* error))failure {
    
    failedRequest = failure;
    
    if (imageObjects.count == 0) {
        NSDictionary *paramValidation = [RequestResolutionAction setParamCreateValidationWithID:orderID
                                                                                   flagReceived:flagReceived
                                                                                    troubleType:troubleType
                                                                                       solution:solution
                                                                                   refundAmount:refundAmount
                                                                                         remark:remark
                                                                                         photos:@[]
                                                                                       serverID:@""];
        
        [RequestResolutionAction fetchCreateNewResolutionValidationWithParam:paramValidation success:^(ResolutionActionResult *dataValidation) {
            success(dataValidation);
        }];

    } else {
        [RequestResolutionAction fetchResolutionUploadImages:imageObjects success:^(NSArray<ImageResult *> *datas, GeneratedHost *host) {
            
            NSDictionary *paramValidation = [RequestResolutionAction setParamCreateValidationWithID:orderID
                                                                                       flagReceived:flagReceived
                                                                                        troubleType:troubleType
                                                                                           solution:solution
                                                                                       refundAmount:refundAmount
                                                                                             remark:remark
                                                                                             photos:datas
                                                                                           serverID:host.server_id?:@""];
            
            [RequestResolutionAction fetchCreateNewResolutionValidationWithParam:paramValidation success:^(ResolutionActionResult *dataValidation) {
                
                NSDictionary *paramImageHelper = [RequestResolutionAction setParamCreateImageWithID:orderID
                                                                                        attachments:datas
                                                                                           serverID:host.server_id?:@""];
                
                [RequestResolutionAction fetchResolutionFileUploadedWithParam:paramImageHelper uploadHost:host.upload_host?:@"" success:^(ResolutionActionResult *dataImageHelper) {
                    
                    NSDictionary *paramSubmit = [RequestResolutionAction setParamCreateSubmitWithID:orderID
                                                                                       fileUploaded:dataImageHelper.file_uploaded
                                                                                            postKey:dataValidation.post_key];
                    
                    [RequestResolutionAction fetchCreateResolutionSubmitWithParam:paramSubmit success:^(ResolutionActionResult *data) {
                        
                        success(data);
                        
                    }];
                }];
            }];
        }];
    }
}

//YANG INI YANG BARU

//trouble id digunakan hanya jika category trouble bukan termasuk category trouble yang product-related
//jika category trouble adalah product related, letakkan trouble id di possible trouble object, per produk
+(void)fetchCreateNewResolutionOrderID:(NSString*)orderID
                          flagReceived:(NSString*)flagReceived
                             troubleId:(NSString*)troubleId
                              solution:(NSString*)solution
                          refundAmount:(NSString*)refundAmount
                                remark:(NSString*)remark
                     categoryTroubleId:(NSString*)categoryTroubleId
                 possibleTroubleObject:(ResolutionCenterCreatePOSTRequest*)possibleTrouble
                          imageObjects:(NSArray<DKAsset*>*)imageObjects
                               success:(void(^) (ResolutionActionResult* data))success
                               failure:(void(^)(NSError* error))failure {
    
    failedRequest = failure;
    
    if (imageObjects.count == 0) {
        NSDictionary *paramValidation = [RequestResolutionAction setParamCreateNewValidationWithID:orderID
                                                                                         flagReceived:flagReceived
                                                                                            troubleId:troubleId
                                                                                             solution:solution
                                                                                         refundAmount:refundAmount
                                                                                               remark:remark
                                                                                               photos:@[]
                                                                                             serverID:@""
                                                                                    categoryTroubleId:categoryTroubleId
                                                                                possibleTroubleObject:possibleTrouble];
        
        [RequestResolutionAction fetchCreateNewResolutionValidationWithParam:paramValidation success:^(ResolutionActionResult *dataValidation) {
            success(dataValidation);
        }];
        
    } else {
        [RequestResolutionAction fetchResolutionUploadImages:imageObjects success:^(NSArray<ImageResult *> *datas, GeneratedHost *host) {
            NSDictionary *paramValidation = [RequestResolutionAction setParamCreateNewValidationWithID:orderID
                                                                                          flagReceived:flagReceived
                                                                                             troubleId:troubleId
                                                                                              solution:solution
                                                                                          refundAmount:refundAmount
                                                                                                remark:remark
                                                                                                photos:datas
                                                                                              serverID:host.server_id?:@""
                                                                                     categoryTroubleId:categoryTroubleId
                                                                                 possibleTroubleObject:possibleTrouble];
            
            [RequestResolutionAction fetchCreateNewResolutionValidationWithParam:paramValidation success:^(ResolutionActionResult *dataValidation) {
                
                NSDictionary *paramImageHelper = [RequestResolutionAction setParamCreateImageWithID:orderID
                                                                                        attachments:datas
                                                                                           serverID:host.server_id?:@""];
                
                [RequestResolutionAction fetchResolutionFileUploadedWithParam:paramImageHelper uploadHost:host.upload_host?:@"" success:^(ResolutionActionResult *dataImageHelper) {
                    
                    NSDictionary *paramSubmit = [RequestResolutionAction setParamCreateSubmitWithID:orderID
                                                                                       fileUploaded:dataImageHelper.file_uploaded
                                                                                            postKey:dataValidation.post_key];
                    
                    [RequestResolutionAction fetchCreateResolutionSubmitWithParam:paramSubmit success:^(ResolutionActionResult *data) {
                        
                        success(data);
                        
                    }];
                }];
            }];
        }];
    }
}


+(void)createResolutionValidationWithOrderId:(NSString*)orderId
                                      photos:(NSArray<ImageResult*>*)photos
                                refundAmount:(NSString*)refundAmount
                                    serverId:(NSString*)serverId
                                    solution:(NSString*)solution
                                flagReceived:(NSString*)flagReceived
                           categoryTroubleId:(NSString*)categoryTroubleId
                           possibleTroubleId:(NSString*)possibleTroubleId{
    NSMutableArray *filePathPhotos = [NSMutableArray new];
    for (ImageResult *imageResult in photos) {
        [filePathPhotos addObject:imageResult.file_path?:@""];
    }
    NSString *photo = [[[filePathPhotos copy] valueForKey:@"description"]componentsJoinedByString:@"~"];
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"get_resolution_validation_new"
                                method:RKRequestMethodPOST
                             parameter:@{@"order_id":orderId,
                                         @"photos":photo,
                                         @"refund_amount":refundAmount,
                                         @"server_id":serverId,
                                         @"solution":solution,
                                         @"flag_received":flagReceived,
                                         @"category_trouble_id":categoryTroubleId,
                                         @"trouble_id":possibleTroubleId
                                         }
                               mapping:nil
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                             }
                             onFailure:^(NSError *errorResult) {
                                 
                             }];
}


#pragma mark - Request Resolution Reply

+(NSDictionary*)setParamReplyValidationWithID:(NSString *)resolutionID
                                  flagReceived:(NSString *)flagReceived
                                   troubleType:(NSString *)troubleType
                                      solution:(NSString *)solution
                                  refundAmount:(NSString *)refundAmount
                                        message:(NSString *)message
                                        photos:(NSArray <ImageResult*>*)photos
                                     serverID:(NSString *)serverID
                               isEditSolution:(NSString *)isEditSolution
{
    NSMutableArray *filePathPhotos = [NSMutableArray new];
    for (ImageResult *imageResult in photos) {
        [filePathPhotos addObject:imageResult.file_path?:@""];
    }
    NSString *photo = [[[filePathPhotos copy] valueForKey:@"description"]componentsJoinedByString:@"~"];
    
    NSDictionary *param = @{
                            @"edit_solution_flag"   :@([isEditSolution integerValue])?:@(0),
                            @"flag_received"        :flagReceived?:@"",
                            @"photos"               :photo?:@"",
                            @"refund_amount"        :refundAmount?:@"",
                            @"reply_msg"            :message?:@"",
                            @"resolution_id"        :resolutionID?:@"",
                            @"server_id"            :serverID?:@"",
                            @"solution"             :solution?:@"",
                            @"trouble_type"         :troubleType?:@""
                            };
    return param;
}

+(NSDictionary*)setParamReplyImageWithID:(NSString*)orderID
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

+(NSDictionary*)setParamReplySubmitWithID:(NSString*)resolutionID
                              fileUploaded:(NSString*)fileUploaded
                                   postKey:(NSString*)postKey
{
    NSDictionary *param = @{
                            @"file_uploaded"    :fileUploaded?:@"",
                            @"resolution_id"    :resolutionID?:@"",
                            @"post_key"         :postKey?:@"",
                            };
    return param;
}

+(void)fetchReplyResolutionValidationWithParam:(NSDictionary*)param
                                        success:(void(^) (ResolutionActionResult* dataValidattion))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/reply_conversation_validation.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success == 1) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membalas komplain"]];
                                     failedRequest(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedRequest(errorResult);
                             }];
    
}


+(void)fetchReplyResolutionSubmitWithParam:(NSDictionary*)param
                                    success:(void(^) (ResolutionActionResult* dataSubmit))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/reply_conversation_submit.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membalas komplain"]];
                                     failedRequest(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedRequest(errorResult);
                             }];
    
}


+(void)fetchReplyResolutionID:(NSString *)resolutionID
                 flagReceived:(NSString *)flagReceived
                  troubleType:(NSString *)troubleType
                     solution:(NSString *)solution
                 refundAmount:(NSString *)refundAmount
                      message:(NSString *)message
               isEditSolution:(NSString *)isEditSolution
                 imageObjects:(NSArray<DKAsset*>*)imageObjects
                      success:(void(^) (ResolutionActionResult* data))success
                      failure:(void(^)(NSError* error))failure {
    
    failedRequest = failure;
    
    if (imageObjects.count == 0) {
        NSDictionary *paramValidation = [RequestResolutionAction setParamReplyValidationWithID:resolutionID
                                                                                  flagReceived:flagReceived
                                                                                   troubleType:troubleType
                                                                                      solution:solution
                                                                                  refundAmount:refundAmount
                                                                                       message:message
                                                                                        photos:@[]
                                                                                      serverID:@""
                                                                                isEditSolution:isEditSolution];
        
        [RequestResolutionAction fetchReplyResolutionValidationWithParam:paramValidation success:^(ResolutionActionResult *dataValidation) {
            success(dataValidation);
        }];
        
    } else {
        [RequestResolutionAction fetchResolutionUploadImages:imageObjects success:^(NSArray<ImageResult *> *datas, GeneratedHost *host) {
            NSDictionary *paramValidation = [RequestResolutionAction setParamReplyValidationWithID:resolutionID
                                                                                      flagReceived:flagReceived
                                                                                       troubleType:troubleType
                                                                                          solution:solution
                                                                                      refundAmount:refundAmount
                                                                                           message:message
                                                                                            photos:datas
                                                                                          serverID:host.server_id
                                                                                    isEditSolution:isEditSolution];
            
            [RequestResolutionAction fetchReplyResolutionValidationWithParam:paramValidation success:^(ResolutionActionResult *dataValidation) {
                
                NSDictionary *paramImageHelper = [RequestResolutionAction setParamReplyImageWithID:resolutionID
                                                                                        attachments:datas
                                                                                           serverID:host.server_id?:@""];
                
                [RequestResolutionAction fetchResolutionFileUploadedWithParam:paramImageHelper uploadHost:host.upload_host?:@"" success:^(ResolutionActionResult *dataImageHelper) {
                    
                    NSDictionary *paramSubmit = [RequestResolutionAction setParamReplySubmitWithID:resolutionID
                                                                                      fileUploaded:dataImageHelper.file_uploaded?:@""
                                                                                           postKey:dataValidation.post_key?:@""];
                    
                    [RequestResolutionAction fetchReplyResolutionSubmitWithParam:paramSubmit success:^(ResolutionActionResult *dataSubmit) {
                        
                        success(dataSubmit);
                        
                    }];
                }];
            }];
        }];
    }
}

#pragma mark - Request Resolution Appeal

+(NSDictionary*)setParamAppealValidationWithID:(NSString *)resolutionID
                                     solution:(NSString *)solution
                                 refundAmount:(NSString *)refundAmount
                                      message:(NSString *)message
                                       photos:(NSArray <ImageResult*>*)photos
                                     serverID:(NSString *)serverID
{
    NSMutableArray *filePathPhotos = [NSMutableArray new];
    for (ImageResult *imageResult in photos) {
        [filePathPhotos addObject:imageResult.file_path?:@""];
    }
    NSString *photo = [[[filePathPhotos copy] valueForKey:@"description"]componentsJoinedByString:@"~"];
    
    NSDictionary *param = @{
                            @"photos"               :photo?:@"",
                            @"refund_amount"        :refundAmount?:@"",
                            @"reply_msg"            :message?:@"",
                            @"resolution_id"        :resolutionID?:@"",
                            @"server_id"            :serverID?:@"",
                            @"solution"             :solution?:@"",
                            };
    return param;
}

+(NSDictionary*)setParamAppealImageWithID:(NSString*)orderID
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

+(NSDictionary*)setParamAppealSubmitWithID:(NSString*)resolutionID
                             fileUploaded:(NSString*)fileUploaded
                                  postKey:(NSString*)postKey
{
    NSDictionary *param = @{
                            @"file_uploaded"    :fileUploaded?:@"",
                            @"resolution_id"    :resolutionID?:@"",
                            @"post_key"         :postKey?:@"",
                            };
    return param;
}

+(void)fetchAppealResolutionValidationWithParam:(NSDictionary*)param
                                       success:(void(^) (ResolutionActionResult* dataValidattion))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/reject_admin_resolution_validation.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success == 1) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal naik banding"]];
                                     failedRequest(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedRequest(errorResult);
                             }];
    
}


+(void)fetchAppealResolutionSubmitWithParam:(NSDictionary*)param
                                   success:(void(^) (ResolutionActionResult* dataSubmit))success {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/reject_admin_resolution_submit.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal naik banding"]];
                                     failedRequest(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedRequest(errorResult);
                             }];
    
}


+(void)fetchAppealResolutionID:(NSString *)resolutionID
                     solution:(NSString *)solution
                 refundAmount:(NSString *)refundAmount
                      message:(NSString *)message
                 imageObjects:(NSArray<DKAsset*>*)imageObjects
                      success:(void(^) (ResolutionActionResult* data))success
                      failure:(void(^)(NSError* error))failure {
    
    failedRequest = failure;
    
    if (imageObjects.count == 0) {
        NSDictionary *paramValidation = [RequestResolutionAction setParamAppealValidationWithID:resolutionID
                                                                                      solution:solution
                                                                                  refundAmount:refundAmount
                                                                                       message:message
                                                                                        photos:@[]
                                                                                      serverID:@""];
        
        [RequestResolutionAction fetchAppealResolutionValidationWithParam:paramValidation success:^(ResolutionActionResult *dataValidation) {
            success(dataValidation);
        }];
        
    } else {
        [RequestResolutionAction fetchResolutionUploadImages:imageObjects success:^(NSArray<ImageResult *> *datas, GeneratedHost *host) {
            NSDictionary *paramValidation = [RequestResolutionAction setParamAppealValidationWithID:resolutionID
                                                                                          solution:solution
                                                                                      refundAmount:refundAmount
                                                                                           message:message
                                                                                            photos:datas
                                                                                           serverID:host.server_id];
            
            [RequestResolutionAction fetchAppealResolutionValidationWithParam:paramValidation success:^(ResolutionActionResult *dataValidation) {
                
                NSDictionary *paramImageHelper = [RequestResolutionAction setParamAppealImageWithID:resolutionID
                                                                                       attachments:datas
                                                                                          serverID:host.server_id?:@""];
                
                [RequestResolutionAction fetchResolutionFileUploadedWithParam:paramImageHelper uploadHost:host.upload_host?:@"" success:^(ResolutionActionResult *dataImageHelper) {
                    
                    NSDictionary *paramSubmit = [RequestResolutionAction setParamAppealSubmitWithID:resolutionID
                                                                                      fileUploaded:dataImageHelper.file_uploaded?:@""
                                                                                           postKey:dataValidation.post_key?:@""];
                    
                    [RequestResolutionAction fetchAppealResolutionSubmitWithParam:paramSubmit success:^(ResolutionActionResult *dataSubmit) {
                        
                        success(dataSubmit);
                        
                    }];
                }];
            }];
        }];
    }
}


#pragma mark - Help/Report
+(void)fetchReportResolutionID:(NSString*)resolutionID
                       success:(void(^) (ResolutionActionResult* data))success
                       failure:(void(^) (NSError* error))failure {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/report_resolution.pl"
                                method:RKRequestMethodPOST
                             parameter:@{@"resolution_id": resolutionID?:@""}
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     [StickyAlertView showSuccessMessage:response.message_status?:@[@"Tokopedia akan mempelajari kasus ini terlebih dahulu dan memberikan resolusi dalam waktu 3 hari."]];
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal membuat bantuan"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
    
}

#pragma mark - Input Resi Resolution
+(void)fetchInputResiResolutionID:(NSString*)resolutionID
                       shipmentID:(NSString*)shipmentID
                      shippingRef:(NSString*)shippingRef
                       success:(void(^) (ResolutionActionResult* data))success
                       failure:(void(^) (NSError* error))failure {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    NSDictionary *param = @{
                            @"resolution_id":resolutionID?:@"",
                            @"shipment_id"  :shipmentID?:@"",
                            @"shipping_ref" :shippingRef?:@""
                            };
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/input_resi_resolution.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     [StickyAlertView showSuccessMessage:response.message_status?:@[@"Berhasil menambahkan resi."]];
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal menambahkan resi"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
    
}

#pragma mark - Edit Resi Resolution
+(void)fetchEditResiResolutionID:(NSString*)resolutionID
                  conversationID:(NSString*)conversationID
                       shipmentID:(NSString*)shipmentID
                      shippingRef:(NSString*)shippingRef
                          success:(void(^) (ResolutionActionResult* data))success
                          failure:(void(^) (NSError* error))failure {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    NSDictionary *param = @{
                            @"resolution_id":resolutionID?:@"",
                            @"conversation_id":conversationID?:@"",
                            @"shipment_id"  :shipmentID?:@"",
                            @"shipping_ref" :shippingRef?:@""
                            };
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/edit_resi_resolution.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     [StickyAlertView showSuccessMessage:response.message_status?:@[@"Berhasil merubah resi."]];
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal merubah resi"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
    
}

#pragma mark - Accept Resolution
+(void)fetchAcceptResolutionID:(NSString*)resolutionID
                         success:(void(^) (ResolutionActionResult* data))success
                         failure:(void(^) (NSError* error))failure {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    NSDictionary *param = @{
                            @"resolution_id":resolutionID?:@""
                            };
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/accept_resolution.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     [StickyAlertView showSuccessMessage:response.message_status?:@[@"Solusi telah diterima."]];
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal menerima solusi"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
    
}

+(void)fetchFinishReturResolutionID:(NSString*)resolutionID
                       success:(void(^) (ResolutionActionResult* data))success
                       failure:(void(^) (NSError* error))failure {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    NSDictionary *param = @{
                            @"resolution_id":resolutionID?:@""
                            };
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/finish_resolution_retur.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     [StickyAlertView showSuccessMessage:response.message_status?:@[@"Solusi telah diterima."]];
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal menerima solusi"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
    
}

+(void)fetchAcceptAdminSolutionResolutionID:(NSString*)resolutionID
                            success:(void(^) (ResolutionActionResult* data))success
                            failure:(void(^) (NSError* error))failure {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    NSDictionary *param = @{
                            @"resolution_id":resolutionID?:@""
                            };
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/resolution-center/accept_admin_resolution.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[ResolutionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success != 0) {
                                     [StickyAlertView showSuccessMessage:response.message_status?:@[@"Solusi telah diterima."]];
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Gagal menerima solusi"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
    
}

@end
