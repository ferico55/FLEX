//
//  TKPDPhotoPicker.m
//  Tokopedia
//
//  Created by Harshad Dange on 06/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDPhotoPicker.h"
#import "NSDictionaryCategory.h"
#import "camera.h"

@implementation TKPDPhotoPicker {
    __weak UIViewController *_parentViewController;
    UIModalTransitionStyle _transitionStyle;
}

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController pickerTransistionStyle:(UIModalTransitionStyle)transitionStyle {
    self = [super init];
    if (self != nil) {
        _parentViewController = parentViewController;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIActionSheet *actionSheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Camera", nil];
            [actionSheet showInView:_parentViewController.view];
        } else {
            [self presentPickerWithCamera:NO];
        }
        
        _data = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)setData:(NSDictionary *)data
{
    if(data)
    {
        _data = data;
        
        if(![_data isMutable])
        {
            _data = [_data mutableCopy];
        }
    }
}

- (void)presentPickerWithCamera:(BOOL)shouldPresentWithCamera {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.navigationBarHidden = NO;
    imagePicker.allowsEditing = NO;

    if (shouldPresentWithCamera) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
        imagePicker.allowsEditing = NO;
        imagePicker.showsCameraControls = YES;
        imagePicker.toolbarHidden = YES;
        imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        imagePicker.title = @"Select Photo";
        imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
        imagePicker.wantsFullScreenLayout = NO;
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
        imagePicker.navigationBar.translucent = NO;
    }

    [imagePicker setDelegate:self];
    [imagePicker setModalTransitionStyle:_transitionStyle];
    [_parentViewController presentViewController:imagePicker animated:YES completion:nil];

}

// MARK: UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        switch (buttonIndex) {
            case 0:
                // Library
                [self presentPickerWithCamera:NO];
                break;
                
            case 1:
                // Camera
                [self presentPickerWithCamera:YES];
                break;
                
            default:
                break;
        }
    }

}

// MARK: UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSURL *imagePath = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    float actualHeight = rawImage.size.height;
    float actualWidth = rawImage.size.width;
    float imgRatio = actualWidth/actualHeight;
    float widthView = _parentViewController.view.frame.size.width;
    float heightView = _parentViewController.view.frame.size.height;
    float maxRatio = widthView/heightView;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = heightView / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = heightView;
        }
        else{
            imgRatio = widthView / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = widthView;
        }
    }
    NSString *imageName;
    NSData* imageDataRawImage;
    if (imagePath) {
        imageName = [imagePath lastPathComponent];
        
        NSString *extensionOFImage =[imageName substringFromIndex:[imageName rangeOfString:@"."].location+1 ];
        if ([extensionOFImage isEqualToString:@"jpg"])
            imageDataRawImage =  UIImagePNGRepresentation(rawImage);
        else
            imageDataRawImage = UIImageJPEGRepresentation(rawImage, 1.0);
    }
    else{
        imageDataRawImage =  UIImagePNGRepresentation(rawImage);
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [rawImage drawInRect:rect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //NSString *imageName;
    NSData* imageDataResizedImage;
    if (imagePath) {
        imageName = [imagePath lastPathComponent];
        
        NSString *extensionOFImage =[imageName substringFromIndex:[imageName rangeOfString:@"."].location+1 ];
        if ([extensionOFImage isEqualToString:@"jpg"])
            imageDataResizedImage =  UIImagePNGRepresentation(resizedImage);
        else
            imageDataResizedImage = UIImageJPEGRepresentation(resizedImage, 1.0);
    }
    else{
        imageDataResizedImage =  UIImagePNGRepresentation(resizedImage);
    }
    
    [_data setValue:@{
                      kTKPDCAMERA_DATARAWPHOTOKEY:rawImage?:@"",
                      kTKPDCAMERA_DATAMEDIATYPEKEY:mediaType?:@"",
                      kTKPDCAMERA_DATAPHOTOKEY:resizedImage?:@"",
                      DATA_CAMERA_IMAGENAME:imageName?:@"image.png",
                      DATA_CAMERA_IMAGEDATA:imageDataResizedImage?:@""
                      } forKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    [_delegate photoPicker:self didDismissCameraControllerWithUserInfo:_data];
    
    [_parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
