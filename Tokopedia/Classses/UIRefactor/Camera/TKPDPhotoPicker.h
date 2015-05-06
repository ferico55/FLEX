//
//  TKPDPhotoPicker.h
//  Tokopedia
//
//  Created by Harshad Dange on 06/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TKPDPhotoPickerDelegate;

@interface TKPDPhotoPicker : NSObject <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController pickerTransistionStyle:(UIModalTransitionStyle)transitionStyle;

@property (strong, nonatomic) NSDictionary *data;

@property (weak, nonatomic) id <TKPDPhotoPickerDelegate> delegate;

@end

@protocol TKPDPhotoPickerDelegate <NSObject>
@optional
- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo;
@end
