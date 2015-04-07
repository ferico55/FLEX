//
//  RequestUploadImage.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadImage.h"
#import "GenerateHost.h"

#define DATA_SELECTED_IMAGE_VIEW_KEY @"data_selected_image_view"
#define DATA_SELECTED_PHOTO_KEY @"data_selected_photo"
#define DATA_SELECTED_INDEXPATH_KEY @"data_selected_indexpath"

@protocol RequestUploadImageDelegate <NSObject>
@required
- (void)successUploadObject:(id)object withMappingResult:(UploadImage*)uploadImage;
- (void)failedUploadObject:(id)object;

@end

@interface RequestUploadImage : NSObject

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<RequestUploadImageDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<RequestUploadImageDelegate> delegate;
#endif

-(void)configureRestkitUploadPhoto;
- (void)requestActionUploadPhoto;

@property GenerateHost *generateHost;
@property id imageObject;
@property NSString *action;
@property NSString *fieldName;
@property NSString *productID;

@end
