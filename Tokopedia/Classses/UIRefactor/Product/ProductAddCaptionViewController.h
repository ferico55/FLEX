//
//  ProductAddCaptionViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailReputationReview.h"

@class ProductAddCaptionViewController, GeneratedHost;

@protocol ProductAddCaptionDelegate <NSObject>
@optional
- (void)updateAttachedPictures:(NSArray*)attachedPictures
                selectedAssets:(NSArray*)selectedAssets
              uploadedPictures:(NSArray*)uploadedPictures
          tempUploadedPictures:(NSArray*)tempUploadedPictures;
@end

@interface ProductAddCaptionViewController : UIViewController

@property (weak, nonatomic) id<ProductAddCaptionDelegate> delegate;
@property NSInteger selectedImageTag;
@property NSInteger numberOfUploadedImages;
@property BOOL isEdit;

@property (nonatomic, strong) DetailReputationReview *review;
@property (nonatomic, strong) NSArray *selectedImages;
@property (nonatomic, strong) NSArray *selectedIndexPaths;
@property (nonatomic, strong) NSArray *imagesCaptions;
@property (nonatomic, strong) NSArray *selectedAssets;

@property (nonatomic, strong) NSMutableArray *attachedImagesArray;
@property (nonatomic, strong) NSMutableArray *deletedIndexes;
@property (nonatomic, strong) NSMutableArray *attachedPictureImages;
@property (nonatomic, strong) NSMutableArray *attachedPictures;
@property (nonatomic, strong) NSMutableArray *uploadedPictures;
@property (nonatomic, strong) NSMutableArray *tempUploadedPictures;

@end
