//
//  CameraCollectionViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailReputationReview.h"

@class CameraCollectionViewController;

#import <AssetsLibrary/AssetsLibrary.h>

@protocol CameraCollectionViewControllerDelegate <NSObject>
@optional
- (void)didDismissController:(CameraCollectionViewController*)controller withUserInfo:(NSDictionary *)userinfo;
- (void)startUploadingImageWithUserInfo:(NSDictionary*)userInfo;
- (void)didReceiveImageWithSelectedImages:(NSArray*)selectedImages
                       selectedIndexPaths:(NSArray*)selectedIndexPaths;
- (void)didRemoveImageDictionary:(NSDictionary*)removedImage;
@end

@interface CameraCollectionViewController : UIViewController

@property (weak, nonatomic) id<CameraCollectionViewControllerDelegate> delegate;

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property NSInteger tag;
@property BOOL isCameraSource;
@property NSArray *selectedImagesArray;
@property(nonatomic, strong) NSMutableArray *selectedIndexPath;
@property(nonatomic, strong) DetailReputationReview *review;
@property NSInteger maxSelected;

@property BOOL isAddEditProduct;
@property BOOL isAddReviewImage;
@property BOOL isAddMoreReviewImage;

@end
