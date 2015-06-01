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


@property (nonatomic, weak) IBOutlet id<RequestUploadImageDelegate> delegate;

-(void)configureRestkitUploadPhoto;
- (void)requestActionUploadPhoto;
- (void)cancelActionUploadPhoto;
@property GenerateHost *generateHost;
@property id imageObject;
@property NSString *action;
@property NSString *fieldName;
@property NSString *productID;
@property BOOL isNotUsingNewAdd;

@end
