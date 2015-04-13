//
//  CameraCollectionViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraCollectionViewController;

#import <AssetsLibrary/AssetsLibrary.h>

@protocol CameraCollectionViewControllerDelegate <NSObject>
@optional
- (void)didDismissController:(CameraCollectionViewController*)controller withUserInfo:(NSDictionary *)userinfo;
- (void)didRemoveImageDictionary:(NSDictionary*)removedImage;
@end

@interface CameraCollectionViewController : UIViewController
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TOKOPEDIA_MINIMUMIOSVERSION
@property (weak, nonatomic) id<CameraCollectionViewControllerDelegate> delegate;
#else
@property (assign, nonatomic) id<CameraCollectionViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property NSInteger tag;
@property BOOL isCameraSource;
@property NSArray *selectedImagesArray;
@property(nonatomic, strong) NSMutableArray *selectedIndexPath;

@end
