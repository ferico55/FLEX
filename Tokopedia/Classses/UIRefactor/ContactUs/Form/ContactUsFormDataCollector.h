//
//  ContactUsFormDataCollector.h
//  Tokopedia
//
//  Created by Tokopedia on 9/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactUsFormDataCollector : NSObject

@property (nonatomic, strong) NSArray *selectedImagesCameraController;
@property (nonatomic, strong) NSArray *selectedIndexPathCameraController;

- (NSArray *)getPhotosFromPhotoPickerData:(NSDictionary *)data;

@end
