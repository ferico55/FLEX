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

@implementation RequestUploadImage
{
    RKObjectManager *_objectManagerUploadPhoto;
    NSMutableURLRequest *_requestActionUploadPhoto;
    
    NSOperationQueue *_operationQueue;
}

-(void)configureRestkitUploadPhoto
{
    _operationQueue = [NSOperationQueue new];
    _requestActionUploadPhoto = [NSMutableURLRequest new];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@",_generateHost.result.generated_host.upload_host];
    
    _objectManagerUploadPhoto = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:urlString]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[UploadImage mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [_objectManagerUploadPhoto addResponseDescriptor:responseDescriptor];
}

- (void)requestActionUploadObject:(id)imageObject
                    generatedHost:(GeneratedHost*)generatedHost
                           action:(NSString*)action
                           newAdd:(NSInteger)newAdd
                        productID:(NSString*)productID
                        paymentID:(NSString*)paymentID
                        fieldName:(NSString*)fieldName
                          success:(void (^)(id imageObject, UploadImage*image))success
                          failure:(void(^)(id imageObject, NSError *error))failure
{
    [self configureRestkitUploadPhoto];
    
    NSDictionary *selectedImage = [imageObject objectForKey:DATA_SELECTED_PHOTO_KEY];
    NSDictionary* photo = [selectedImage objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    NSData* imageData = [photo objectForKey:DATA_CAMERA_IMAGEDATA]?:@"";
    NSString* imageName = [[photo objectForKey:DATA_CAMERA_IMAGENAME] lowercaseString]?:@"";
    NSString *serverID = generatedHost.server_id?:@"0";
    NSString *userID = [NSString stringWithFormat:@"%zd", generatedHost.user_id];
    NSString *newAddParam = [NSString stringWithFormat:@"%zd", newAdd];
    
    NSString *uploadVersion = (newAdd == 1)?@"2":@"0";
    
    NSDictionary *param = @{ kTKPDDETAIL_APIACTIONKEY           : action,
                             kTKPDGENERATEDHOST_APISERVERIDKEY  : serverID,
                             kTKPD_USERIDKEY                    : userID,
                             @"product_id"                      : productID?:@"",
                             @"new_add"                         : newAddParam,
                             @"payment_id"                      : paymentID?:@"",
                             @"upload_version"                  : uploadVersion
                             };
    
    
    _requestActionUploadPhoto = [NSMutableURLRequest requestUploadImageData:imageData
                                                                   withName:fieldName
                                                                andFileName:imageName
                                                      withRequestParameters:param
                                                                 uploadHost:generatedHost.upload_host?:@""
                                 ];
    
    NSLog(@"%@",_requestActionUploadPhoto);
    NSLog(@"param %@ field name %@ ImageName %@",param,fieldName,imageName);
    
    UIImageView *thumbProductImage = [_imageObject objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    thumbProductImage.alpha = 0.5f;
    thumbProductImage.userInteractionEnabled = NO;
    
    [NSURLConnection sendAsynchronousRequest:_requestActionUploadPhoto
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog(@"responsestring %@",responsestring);
                               
                               if ([httpResponse statusCode] == 200) {
                                   id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
                                   if (parsedData == nil && error) {
                                       [self showErrorMessages:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."]];
                                       failure(imageObject,error);
                                       return;
                                   }
                                   
                                   NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
                                   for (RKResponseDescriptor *descriptor in _objectManagerUploadPhoto.responseDescriptors) {
                                       [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
                                   }
                                   
                                   RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
                                   NSError *mappingError = nil;
                                   BOOL isMapped = [mapper execute:&mappingError];
                                   if (isMapped && !mappingError) {
                                       NSLog(@"result %@",[mapper mappingResult]);
                                       RKMappingResult *mappingresult = [mapper mappingResult];
                                       NSDictionary *result = mappingresult.dictionary;
                                       id stat = [result objectForKey:@""];
                                       UploadImage *images = stat;
                                       BOOL status = [images.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                       
                                       if (status) {
                                           if (images.result.file_path || (images.result.upload!=nil && images.result.upload.src)|| images.result.image.pic_src!=nil || images.result.pic_obj!=nil) {
                                               success(imageObject,images);
                                           }
                                           else
                                           {
                                               NSArray *array = images.message_error;
                                               [self showErrorMessages:array?:@[]];
                                               failure(imageObject,error);
                                           }
                                       }
                                       else
                                       {
                                           [self showErrorMessages:@[]];
                                           failure(imageObject, error);
                                       }
                                   }
                                   else
                                   {
                                       [self showErrorMessages:@[]];
                                       failure(imageObject, error);
                                   }
                               }
                               else
                               {
                                   if ([error code] == NSURLErrorNotConnectedToInternet)
                                       [self showErrorMessages:@[@"Tidak ada koneksi internet"]];
                                   else
                                       [self showErrorMessages:@[]];
                                   failure(imageObject, error);
                               }
                               
                           }];
}

- (void)requestActionUploadPhoto
{
    NSInteger newAdd = _isNotUsingNewAdd?0:1;
    
    [self requestActionUploadObject:_imageObject generatedHost:_generateHost.result.generated_host action:_action newAdd:newAdd productID:_productID paymentID:_paymentID fieldName:_fieldName success:^(id imageObject, UploadImage *image) {
        [_delegate successUploadObject:imageObject withMappingResult:image];
    } failure:^(id imageObject, NSError *error) {
        [_delegate failedUploadObject:imageObject];
    }];
}

-(void)showErrorMessages:(NSArray*)messages
{
    NSMutableArray *messagesError;
    if (messages.count == 0) {
        messagesError = [NSMutableArray new];
        [messagesError addObject:@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."];
    }
    else {
        messagesError = [NSMutableArray new];
        for(int i=0;i<messages.count;i++) {
            NSString *str = [NSString stringWithFormat:@"%@", [messages objectAtIndex:i]];
            str = [NSString convertHTML:str];
            
            if ([self string:str containsString:@"SMALL"]) {
                str = @"Ukuran file yang diunggah terlalu kecil";
            }
            else if ([self string:str containsString:@"BIG"])
            {
                str = @"Maksimum ukuran file yang diunggah adalah 500.000 bytes (500 Kilobytes)";
            }
            else if([self string:str containsString:@"SERVER_ERROR"])
            {
                str = @"Mohon maaf, terjadi kendala pada server. Mohon coba kembali";
            }
            [messagesError addObject:str];
        }
    }
    
    if ([_delegate isKindOfClass:[NSObject class]]) {
        NSDictionary *userInfo = @{kTKPD_SETUSERSTICKYERRORMESSAGEKEY:messagesError};
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY
                                                            object:self
                                                          userInfo:userInfo];
    } else {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:messagesError
                                                                      delegate:_delegate];
        [alert show];
    }
}

- (BOOL)string:(NSString*)string containsString:(NSString*)other {
    NSRange range = [string rangeOfString:other];
    return range.length != 0;
}

+ (void)requestUploadImage:(UIImage*)image
            withUploadHost:(NSString*)host
                      path:(NSString*)path
                      name:(NSString*)name
                  fileName:(NSString*)fileName
             requestObject:(id)object
                 onSuccess:(void (^)(ImageResult *imageResult))success
                 onFailure:(void (^)(NSError *errorResult))failure {
    
    RKObjectManager *objectManager = [TKPMappingManager objectManagerUploadReviewImageWithBaseURL:host
                                                                                      pathPattern:path];
    
    
    // Serialize the Article attributes then attach a file
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:object
                                                                          method:RKRequestMethodPOST
                                                                            path:path
                                                                      parameters:nil
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:UIImagePNGRepresentation(image)
                                                                                       name:name
                                                                                   fileName:fileName
                                                                                   mimeType:@"image/png"];
                                                           
                                                       }];
    
    
    
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request
                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                       NSLog(@"Request body %@", [[NSString alloc] initWithData:[operation.HTTPRequestOperation.request HTTPBody]  encoding:NSUTF8StringEncoding]);
                                                                                       NSDictionary *result = mappingResult.dictionary;
                                                                                       ImageResult *obj = [result objectForKey:@""];
                                                                                       if ([obj.success isEqualToString:@"1"]) {
                                                                                           success(obj);
                                                                                       } else {
                                                                                           StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:obj.message_error?:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."] delegate:nil];
                                                                                           [alert show];
                                                                                       }
                                                                                   }
                                                                                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                       NSLog(@"Request body %@", [[NSString alloc] initWithData:[operation.HTTPRequestOperation.request HTTPBody]  encoding:NSUTF8StringEncoding]);
                                                                                       
                                                                                       StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."] delegate:nil];
                                                                                       [alert show];
                                                                                       
                                                                                       failure(error);
                                                                                   }];
    
    [objectManager enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
}

@end
