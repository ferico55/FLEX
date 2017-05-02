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


@property (weak, nonatomic) id<CameraControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) UIImage* snappedImage;
@property NSInteger tag;
@property BOOL isTakePicture;

-(void)snap;

@end
