//
//  CameraController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CameraController;

@protocol CameraControllerDelegate <NSObject>
@optional
- (void)didDismissCameraController:(CameraController*)controller withUserInfo:(NSDictionary*)userinfo;
@end

@interface CameraController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TOKOPEDIA_MINIMUMIOSVERSION
@property (weak, nonatomic) id<CameraControllerDelegate> delegate;
#else
@property (assign, nonatomic) id<CameraControllerDelegate> delegate;
#endif
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) UIImage* snappedImage;
@property NSInteger tag;
@property BOOL isTakePicture;

-(void)snap;

@end
