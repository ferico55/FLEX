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
    UIModalTransitionStyle _transitionStyle;
    __weak UIActivityIndicatorView *_spinner;
    __weak UIImagePickerController *_picker;
}

// MARK: Initialisation

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController pickerTransistionStyle:(UIModalTransitionStyle)transitionStyle {
    self = [super init];
    if (self != nil) {
        _parentViewController = parentViewController;
        _transitionStyle = transitionStyle;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIActionSheet *actionSheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Camera", nil];
            [actionSheet showInView:_parentViewController.parentViewController.view];
        } else {
            [self presentPickerWithCamera:NO];
        }
        
        _data = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (instancetype)initWithSourceType:(UIImagePickerControllerSourceType)sourceType parentViewController:(UIViewController *)controller pickerTransitionStyle:(UIModalTransitionStyle)transitionStyle {
    self = [super init];
    if (self != nil) {
        _parentViewController = controller;
        _transitionStyle = transitionStyle;
        
        if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
            [self presentPickerWithCamera:(sourceType == UIImagePickerControllerSourceTypeCamera)];
            _data = [[NSMutableDictionary alloc] init];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Camera not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    return self;
}

// MARK: Public methods

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

// MARK: Private methods

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
    
    if (_spinner == nil) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [imagePicker.view addSubview:spinner];
        [spinner setHidesWhenStopped:YES];
        [spinner sizeToFit];
        [spinner setCenter:imagePicker.view.center];
        _spinner = spinner;
    }
    
    _picker = imagePicker;

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

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    __weak typeof(self) wself = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.parentViewController dismissViewControllerAnimated:NO completion:nil];
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_spinner startAnimating];
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage* rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        UIImagePickerControllerSourceType sourceType = picker.sourceType;
        NSURL *imagePath = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        float actualHeight = rawImage.size.height;
        float actualWidth = rawImage.size.width;
        float imgRatio = actualWidth/actualHeight;
        float widthView = kTKPDCAMERA_MAXIMAGESIZE.width;//wself.parentViewController.view.frame.size.width;
        float heightView = kTKPDCAMERA_MAXIMAGESIZE.height;//wself.parentViewController.view.frame.size.height;
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
        
        CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        [rawImage drawInRect:rect];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
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
        
        [wself.data setValue:@{
                          kTKPDCAMERA_DATAMEDIATYPEKEY:mediaType?:@"",
                          kTKPDCAMERA_DATAPHOTOKEY:resizedImage?:@"",
                          DATA_CAMERA_IMAGENAME:imageName?:@"image.png",
                          DATA_CAMERA_IMAGEDATA:imageDataResizedImage?:@"",
                          DATA_CAMERA_SOURCE_TYPE:@(sourceType)?:@""
                          } forKey:kTKPDCAMERA_DATAPHOTOKEY];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.parentViewController dismissViewControllerAnimated:NO completion:nil];
            [wself.delegate photoPicker:wself didDismissCameraControllerWithUserInfo:wself.data];
        });
        
    });
}

@end
