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
        
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[UploadImage class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[UploadImageResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY,
                                                        kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY:kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY,
                                                        @"file_name" : @"file_name",
                                                        @"pic_id" : @"pic_id",
                                                        @"pic_obj" : @"pic_obj",
                                                        @"file_uploaded" : @"file_uploaded",
                                                        @"pic_src" : @"pic_src"
                                                        }];
    

    RKObjectMapping *subResultMapping = [RKObjectMapping mappingForClass:[Upload class]];
    [subResultMapping addAttributeMappingsFromDictionary:@{kTKPD_SRC:kTKPD_SRC}];
    
    RKObjectMapping *imageResultMapping = [RKObjectMapping mappingForClass:[UploadImageImage class]];
    [imageResultMapping addAttributeMappingsFromDictionary:@{@"pic_code":@"pic_code",
                                                           @"pic_src":@"pic_src"}];
    
    
    // Relationship Mapping
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIUPLOADKEY toKeyPath:kTKPD_APIUPLOADKEY withMapping:subResultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image" toKeyPath:@"image" withMapping:imageResultMapping]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerUploadPhoto addResponseDescriptor:responseDescriptor];
}


- (void)cancelActionUploadPhoto
{
    _requestActionUploadPhoto = nil;
    
    [_operationQueue cancelAllOperations];
    _objectManagerUploadPhoto = nil;
}

- (void)requestActionUploadPhoto
{
    NSDictionary *selectedImage = [_imageObject objectForKey:DATA_SELECTED_PHOTO_KEY];
    NSDictionary* photo = [selectedImage objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    NSData* imageData = [photo objectForKey:DATA_CAMERA_IMAGEDATA]?:@"";
    NSString* imageName = [[photo objectForKey:DATA_CAMERA_IMAGENAME] lowercaseString]?:@"";
    NSString *serverID = _generateHost.result.generated_host.server_id?:@"0";
    NSString *userID = [NSString stringWithFormat:@"%d", _generateHost.result.generated_host.user_id];
    NSString *newAdd = [NSString stringWithFormat:@"%d", _isNotUsingNewAdd?0:1];

    NSDictionary *param = @{ kTKPDDETAIL_APIACTIONKEY           : _action,
                             kTKPDGENERATEDHOST_APISERVERIDKEY  : serverID,
                             kTKPD_USERIDKEY                    : userID,
                             @"product_id"                      : _productID?:@"",
                             @"new_add"                         : newAdd,
                             @"payment_id"                      : _paymentID?:@"",
                             @"upload_version"                  :@"2"
                         };
    
    
    _requestActionUploadPhoto = [NSMutableURLRequest requestUploadImageData:imageData
                                                                   withName:_fieldName
                                                                andFileName:imageName
                                                      withRequestParameters:param
                                 uploadHost:_generateHost.result.generated_host.upload_host
                                 ];
    
    NSLog(@"%@",_requestActionUploadPhoto);
    NSLog(@"param %@ field name %@ ImageName %@",param,_fieldName,imageName);
    
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
//               StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."] delegate:_delegate];
//               [alert show];
               [_delegate failedUploadErrorMessage:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."]];
               [_delegate failedUploadObject:_imageObject];
               NSLog(@"parser error");
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
                       [_delegate successUploadObject:_imageObject withMappingResult:images];
                   }
                   else
                   {
                       NSArray *array = images.message_error;
                      [self showErrorMessages:array?:@[]];
                       [_delegate failedUploadObject:_imageObject];
                   }
               }
               else
               {
                   [self showErrorMessages:@[]];
                   [_delegate failedUploadObject:_imageObject];
               }
           }
           else
           {
               [self showErrorMessages:@[]];
               [_delegate failedUploadObject:_imageObject];
           }
       }
       else
       {
           if ([error code] == NSURLErrorNotConnectedToInternet)
               [self showErrorMessages:@[@"Tidak ada koneksi internet"]];
           else
               [self showErrorMessages:@[]];
           [_delegate failedUploadObject:_imageObject];
       }
                               
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
    
    [_delegate failedUploadErrorMessage:messagesError];
//    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:messagesError delegate:_delegate];
//    [alert show];
}

- (BOOL)string:(NSString*)string containsString:(NSString*)other {
    NSRange range = [string rangeOfString:other];
    return range.length != 0;
}

-(void)requesttimeoutUploadPhoto
{
    //[self cancelActionUploadPhoto];
}

@end
