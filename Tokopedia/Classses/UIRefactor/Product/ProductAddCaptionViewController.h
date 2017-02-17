//
//  ProductAddCaptionViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailReputationReview.h"
@class AttachedPicture;

@class ProductAddCaptionViewController, GeneratedHost, DKAsset;

@protocol ProductAddCaptionDelegate <NSObject>
@optional
- (void)updateSelectedAssets:(NSMutableArray *)selectedAssets
              uploadedPictures:(NSMutableArray *)uploadedPictures;
@end

@interface ProductAddCaptionViewController : UIViewController

- (instancetype)initWithSelectedAssets:(NSMutableArray<DKAsset*>*)selectedAssets isEdit:(BOOL)isEdit uploadedPicture:(NSMutableArray<AttachedPicture*>*)uploadedPicture selectedImageIndex:(int)selectedImageIndex delegate:(id<ProductAddCaptionDelegate>)delegate;

@property (weak, nonatomic) id<ProductAddCaptionDelegate> delegate;
@property NSInteger selectedImageTag;
@property NSInteger numberOfUploadedImages;
@property BOOL isEdit;

@property (nonatomic, strong) DetailReputationReview *review;
@property (nonatomic, strong) NSArray *selectedImages;
@property (nonatomic, strong) NSArray *selectedIndexPaths;
@property (nonatomic, strong) NSArray *imagesCaptions;
@property (nonatomic, strong) NSMutableArray<DKAsset*> *selectedAssets;

@property (nonatomic, strong) NSMutableArray *deletedIndexes;

-(void)addImageFromAsset;

@end
