//
//  ContactUsFormDataCollector.h
//  Tokopedia
//
//  Created by Tokopedia on 9/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicketCategory.h"
#import "GenerateHost.h"

@interface ContactUsFormDataCollector : NSObject

@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic, strong, readonly) NSString *attachmentString;

@property (nonatomic, strong) NSString *inboxTicketId;

@property (nonatomic, strong) NSMutableArray *selectedImagesCameraController;
@property (nonatomic, strong) NSMutableArray *selectedIndexPathCameraController;

@property (nonatomic, strong) NSMutableArray *uploadedPhotos;
@property (nonatomic, strong) NSMutableArray *uploadedPhotosURL;

@property (nonatomic, strong) NSString *postKey;
@property (nonatomic, strong) NSString *fileUploaded;

@property BOOL failPhotoUpload;

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *invoice;
@property (nonatomic, strong) TicketCategory *ticketCategory;
@property (nonatomic, strong) GeneratedHost *generateHost;

- (NSArray *)getPhotosFromPhotoPickerData:(NSDictionary *)data;
- (void)addUploadedPhoto:(UIImage *)photo photoURL:(NSString *)url;
- (BOOL)allPhotosUploaded;

- (void)addImageFromImageController:(NSDictionary *)imageData;
- (void)addIndexPathFromImageController:(NSDictionary *)indexPath;

@end
