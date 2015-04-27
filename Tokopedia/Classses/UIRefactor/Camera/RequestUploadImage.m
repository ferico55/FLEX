//
//  RequestUploadImage.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestUploadImage.h"

#import "StickyAlertView.h"

#import "detail.h"
#import "camera.h"


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
                                                        @"pic_obj" : @"pic_obj"
                                                        }];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerUploadPhoto addResponseDescriptor:responseDescriptor];
    
    //[_objectManagerUploadPhoto setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    //[_objectManagerUploadPhoto setRequestSerializationMIMEType:RKMIMETypeJSON];
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
    NSInteger userID = _generateHost.result.generated_host.user_id;
    
    NSDictionary *param = @{ kTKPDDETAIL_APIACTIONKEY: _action,
                             kTKPDGENERATEDHOST_APISERVERIDKEY:serverID,
                             kTKPD_USERIDKEY : @(userID),
                             @"product_id" : _productID?:@"",
                             @"new_add" : @(1)
                             //@"is_temp" :@(1)
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
               StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."] delegate:_delegate];
               [alert show];
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
                   if (images.message_error) {
                       NSArray *array = images.message_error;
                       [self showErrorMessages:array?:@[]];
                       [_delegate failedUploadObject:_imageObject];
                   }
                   else if (images.result.file_path) {
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
               if (!([error code] == NSURLErrorCancelled)){
                   NSString *errorDescription = error.localizedDescription;
                   UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:_delegate cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                   [errorAlert show];
                   [_delegate failedUploadObject:_imageObject];
               }
           }
       }
       else
       {
           [self showErrorMessages:@[]];
           [_delegate failedUploadObject:_imageObject];
       }
                               
    }];
}

-(void)showErrorMessages:(NSArray*)messages
{
    NSArray *messagesError;
    if (messages.count == 0) {
        messagesError = @[@"Upload gambar gagal, mohon dicoba kembali atau gunakan gambar lain."];
    }
    else messagesError = messages;
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:messagesError delegate:_delegate];
    [alert show];
}

-(void)requesttimeoutUploadPhoto
{
    //[self cancelActionUploadPhoto];
}

@end
