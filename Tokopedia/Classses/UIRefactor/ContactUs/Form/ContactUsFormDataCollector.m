//
//  ContactUsFormDataCollector.m
//  Tokopedia
//
//  Created by Tokopedia on 9/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsFormDataCollector.h"

@implementation ContactUsFormDataCollector

- (id)init {
    self = [super init];
    if (self) {
        self.uploadedPhotosURL = [NSMutableArray array];
        self.uploadedPhotos = [NSMutableArray array];
        self.selectedImagesCameraController = [NSMutableArray array];
        self.selectedIndexPathCameraController = [NSMutableArray array];
    }
    return self;
}

- (NSString *)inboxTicketId {
    return _inboxTicketId?:@"";
}

- (NSString *)postKey {
    return _postKey?:@"";
}

- (NSArray *)getPhotosFromPhotoPickerData:(NSDictionary *)data {
    NSMutableArray *photos = [NSMutableArray new];
    for (NSDictionary *photoData in self.selectedImagesCameraController) {
        NSDictionary *photo = [photoData objectForKey:@"photo"];
        [photos addObject:[photo objectForKey:@"photo"]];
    }    
    return photos;
}

//- (void)setSelectedImagesCameraController:(NSArray *)selectedImagesCameraController {
//    NSMutableArray *selectedImages = [NSMutableArray new];
//    for (NSDictionary *selected in selectedImagesCameraController) {
//        if (![selected isEqual:@""]) [selectedImages addObject: selected];
//    }
//    _selectedImagesCameraController = selectedImages;
//}
//
//- (void)setSelectedIndexPathCameraController:(NSArray *)selectedIndexPathCameraController {
//    NSMutableArray *selectedIndexPaths = [NSMutableArray new];
//    for (NSIndexPath *selected in selectedIndexPathCameraController) {
//        if (![selected isEqual:@""]) [selectedIndexPaths addObject: selected];
//    }
//    _selectedIndexPathCameraController = selectedIndexPaths;
//}

- (void)addUploadedPhoto:(UIImage *)photo photoURL:(NSString *)url {
    if (![self.uploadedPhotos containsObject:photo]) {
        [self.uploadedPhotos addObject:photo];
        [self.uploadedPhotosURL addObject:url];
    }
}

- (BOOL)allPhotosUploaded {
    if (self.uploadedPhotosURL.count == self.attachments.count && !_failPhotoUpload) {
        return YES;
    }
    return NO;
}

- (NSString *)attachmentString {
    NSString *attachmentString = @"";
    for (NSString *url in _uploadedPhotosURL) {
        attachmentString = [NSString stringWithFormat:@"%@%@~", attachmentString, url];
    }
    return attachmentString;
}

- (void)addImageFromImageController:(NSDictionary *)imageData {
    [self.selectedImagesCameraController addObject:imageData];
}

- (void)addIndexPathFromImageController:(NSDictionary *)indexPath {
    [self.selectedIndexPathCameraController addObject:indexPath];
}

@end
