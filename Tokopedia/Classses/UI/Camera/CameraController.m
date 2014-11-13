//
//  CameraController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "CameraController.h"

#import "CameraCropViewController.h"
#import "AlertCameraView.h"

#import "NSDictionaryCategory.h"

@interface CameraController () <TKPDAlertViewDelegate, CameraCropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL _isFirstTimeLaunch;
    
    UIImage* _snappedImage;
    
    UIImagePickerController *_picker;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation CameraController

@synthesize data = _data;
@synthesize imageView = _imageView;

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _isFirstTimeLaunch = YES;
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if(![_data isMutable])
    {
        _data = [_data mutableCopy];
    }
    
    if(_data == nil)
    {
        _data = [NSMutableDictionary new];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!_snappedImage)
    {
        [self snap];
        
        [_imageView setImage:_snappedImage];
    }
    else
    {
        [_imageView setImage:_snappedImage];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if(_isFirstTimeLaunch)
    {
        _isFirstTimeLaunch = !_isFirstTimeLaunch;
        
        if(!_picker)
        {
            _picker = [UIImagePickerController new];
            [_picker setDelegate:(id)self];
            _picker.navigationBar.translucent = YES;
        }
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            //TODO:: add alert choose type camera
            AlertCameraView *v = [AlertCameraView newview];
            v.delegate = self;
            v.tag = 10;
            [v show];
           
        }
        else
        {
            [_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            _picker.mediaTypes = @[(NSString*)kUTTypeImage];
        }
        
        if(_picker != nil)
        {
            [self presentViewController:_picker animated:YES completion:nil];
        }
    }
}

#pragma mark - Properties
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


#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    [_data setValue:@{
                      kTKPDCAMERA_DATARAWPHOTOKEY:rawImage,
                      kTKPDCAMERA_DATAMEDIATYPEKEY:mediaType
                      } forKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    CameraCropViewController *c = [CameraCropViewController new];
    [c setDelegate:self];
    [c setData:[_data copy]];
    [c setPicker:picker];
    
    [picker pushViewController:c animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^
     {
         [self start];
     }];
}

#pragma mark - Camera Crop Delegate
-(void)CameraCropViewController:(UIViewController *)controller didFinishCroppingMediaWithInfo:(NSDictionary *)userinfo
{
    [_delegate didDismissCameraController:self withUserInfo:userinfo];
    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - Alert Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {   //camera
            [_picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            _picker.showsCameraControls = NO;
            _picker.allowsEditing = NO;
            _picker.wantsFullScreenLayout = YES;
            _picker.toolbarHidden = YES;
            _picker.navigationBarHidden = YES;
            _picker.mediaTypes = @[(NSString*)kUTTypeImage];
            break;
        }
        case 1:
        {   //gallery
            [_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            _picker.mediaTypes = @[(NSString*)kUTTypeImage];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
- (void)snap
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    UIScreen* screen = [UIScreen mainScreen];
    
    if ([screen respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, screen.scale);
    }
    else
    {
        UIGraphicsBeginImageContext(window.bounds.size);
    }
    
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    _snappedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

- (void)start
{
    _snappedImage = nil;
    
    _isFirstTimeLaunch = YES;
    
    [((NSMutableDictionary*)_data)removeObjectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    [((NSMutableDictionary*)_data)removeObjectForKey:kTKPDCAMERA_DATACAMERAKEY];
    [((NSMutableDictionary*)_data)removeObjectForKey:kTKPDCAMERA_DATAPRESENTINGVIEWCONTROLLERCLASSKEY];
    [((NSMutableDictionary*)_data)removeObjectForKey:kTKPDCAMERA_DATAUSERINFOKEY];
}
@end
