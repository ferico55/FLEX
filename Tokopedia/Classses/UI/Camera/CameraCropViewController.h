//
//  CameraCropViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraCropViewController;

@protocol CameraCropViewControllerDelegate <NSObject>
@optional
- (void)CameraCropViewController:(UIViewController*)controller didFinishCroppingMediaWithInfo:(NSDictionary*)userinfo;
@end

#pragma mark - CameraCropViewController
@interface CameraCropViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= JURY_MINIMUMIOSVERSION
@property (weak, nonatomic) id<CameraCropViewControllerDelegate> delegate;
#else
@property (assign, nonatomic) id<CameraCropViewControllerDelegate> delegate;
#endif

@property (strong, nonatomic) NSDictionary* data;

@property (strong, nonatomic) UIImagePickerController *picker;

@end
