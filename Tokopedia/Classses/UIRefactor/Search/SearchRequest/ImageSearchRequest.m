//
//  ImageSearchRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 2/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ImageSearchRequest.h"
#import "RequestUploadImage.h"
#import "RequestGenerateHost.h"

@interface ImageSearchRequest()<
RequestUploadImageDelegate,
GenerateHostDelegate,
TokopediaNetworkManagerDelegate
>
@end

@implementation ImageSearchRequest{
    GeneratedHost *generatedHost;
    RequestGenerateHost *requestGenerateHost;
    RequestUploadImage *requestUploadImage;
    NSString *uploadedImageURL;
    NSDictionary* imageQueryInfo;
    TokopediaNetworkManager *networkManager;
    RKObjectManager *_objectmanager;
}
-(instancetype)init{
    self = [super init];
    if(self){
        requestGenerateHost = [RequestGenerateHost new];
        [requestGenerateHost configureRestkitGenerateHost];
        requestGenerateHost.delegate = self;
        
        requestUploadImage = [RequestUploadImage new];
        requestUploadImage.delegate = self;
        
        networkManager = [TokopediaNetworkManager new];
        networkManager.delegate = self;
        networkManager.isUsingHmac = YES;
        networkManager.isParameterNotEncrypted = YES;
    }
    return self;
}

#pragma mark - Public Method

-(void)requestSearchbyImage:(NSDictionary *)imageInfo{
    [requestGenerateHost requestGenerateHost];
    imageQueryInfo = imageInfo;
}

#pragma mark - RequestGenerateHost Delegate
-(void)successGenerateHost:(GenerateHost *)generateHost {
    generatedHost = generateHost.result.generated_host;
    
    UIImage *chosenImage = imageQueryInfo[UIImagePickerControllerEditedImage];
    NSString *mediaType = imageQueryInfo[UIImagePickerControllerMediaType];
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    
    NSDictionary *data = @{
                           @"data_selected_photo" : @{
                                   @"photo" : @{
                                           @"cameraimagedata" : imageData,
                                           @"cameraimagename" : @"image.png",
                                           @"mediatype" : mediaType,
                                           @"photo" : chosenImage,
                                           @"source_type" : @"1",
                                           },
                                   },
                           };
    
    [requestUploadImage requestActionUploadObject:data
                             generatedHost:generatedHost
                                    action:@"upload_product_image"
                                    newAdd:1
                                 productID:@""
                                 paymentID:@""
                                 fieldName:@"fileToUpload"
                                   success:^(id imageObject, UploadImage *image) {
                                       [self successUploadObject:imageObject withMappingResult:image];
                                   } failure:^(id imageObject, NSError *error) {
                                       [self failedUploadObject:imageObject];
                                   }];
    
}

-(void)failedGenerateHost:(NSArray *)errorMessages{
    [_delegate failToReceiveImageSearchResult:@"Gagal tersambung ke server. Mohon periksa koneksi internet Anda atau coba kembali"];
}

#pragma mark - RequestUploadImage delegate
-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage{
    uploadedImageURL = uploadImage.result.file_path;
    [_delegate didReceiveUploadedImageURL:uploadedImageURL];
}
-(void)failedUploadObject:(id)object{
    [_delegate failToReceiveImageSearchResult:@"error_upload_image"];
}

#pragma mark Tokopedia Network Manager Delegate
- (NSDictionary*)getParameter:(int)tag{
    return @{@"image_url" : uploadedImageURL};
}
- (NSString*)getPath:(int)tag{
    return nil;
}

- (int)getRequestMethod:(int)tag{
    return RKRequestMethodGET;
}

- (id)getObjectManager:(int)tag{
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    return ((ImageSearchResponse*)stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag{
    
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag{
}


@end
