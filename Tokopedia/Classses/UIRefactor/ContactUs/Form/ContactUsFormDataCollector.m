//
//  ContactUsFormDataCollector.m
//  Tokopedia
//
//  Created by Tokopedia on 9/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsFormDataCollector.h"

@implementation ContactUsFormDataCollector

- (NSArray *)getPhotosFromPhotoPickerData:(NSDictionary *)data {
    self.selectedImagesCameraController = [data objectForKey:@"selected_images"];
    self.selectedIndexPathCameraController = [data objectForKey:@"selected_indexpath"];
    NSMutableArray *photos = [NSMutableArray new];
    for (NSDictionary *photoData in self.selectedImagesCameraController) {
        NSDictionary *photo = [photoData objectForKey:@"photo"];
        [photos addObject:[photo objectForKey:@"photo"]];
    }    
    return photos;
}

- (void)setSelectedImagesCameraController:(NSArray *)selectedImagesCameraController {
    NSMutableArray *selectedImages = [NSMutableArray new];
    for (NSDictionary *selected in selectedImagesCameraController) {
        if (![selected isEqual:@""]) [selectedImages addObject: selected];
    }
    _selectedImagesCameraController = selectedImages;
}

- (void)setSelectedIndexPathCameraController:(NSArray *)selectedIndexPathCameraController {
    NSMutableArray *selectedIndexPaths = [NSMutableArray new];
    for (NSIndexPath *selected in selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) [selectedIndexPaths addObject: selected];
    }
    _selectedIndexPathCameraController = selectedIndexPaths;
}

@end
