//
//  CameraController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "CameraController.h"
#import "NSDictionaryCategory.h"

@interface CameraController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    BOOL _isFirstTimeLaunch;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImagePickerController *picker;

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
            UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                    @"Camera",
                                    @"Library",
                                    nil];
            popup.tag = 1;
            [popup showInView:[UIApplication sharedApplication].keyWindow];
        }else
        {
            [self presentPickerSourceTypePhotoLibrary];

        }
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    //[[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImage* rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSURL *imagePath = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    //UIImage *image = [UIImage imageNamed:@"icon_location.png"];
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, chosenImage.scale);
    [chosenImage drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    chosenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *imageName;
    NSData* imageData;
    if (imagePath) {
        imageName = [imagePath lastPathComponent];
        
        NSString *extensionOFImage =[imageName substringFromIndex:[imageName rangeOfString:@"."].location+1 ];
        if ([extensionOFImage isEqualToString:@"jpg"])
            imageData =  UIImagePNGRepresentation(chosenImage);
        else
            imageData = UIImageJPEGRepresentation(chosenImage, 1.0);
    }
    else{
        imageData =  UIImagePNGRepresentation(chosenImage);
    }

    
    [_data setValue:@{
                      kTKPDCAMERA_DATARAWPHOTOKEY:rawImage,
                      kTKPDCAMERA_DATAMEDIATYPEKEY:mediaType,
                      kTKPDCAMERA_DATAPHOTOKEY:chosenImage,
                      DATA_CAMERA_IMAGENAME:imageName?:@"image.png",
                      DATA_CAMERA_IMAGEDATA:imageData
                      } forKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    [_delegate didDismissCameraController:self withUserInfo:_data];
    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^
     {
         [self start];
     }];
}

#pragma mark - Alert Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {   //camera
            [self presentPickerSourceTypeCamera];
            break;
        }
        case 1:
        {   //Library
            [self presentPickerSourceTypePhotoLibrary];
            break;
        }
        default:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

#pragma mark - Methods
- (void) presentPickerSourceTypePhotoLibrary
{
    [_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    _picker.title = @"Select Photo";
    _picker.allowsEditing = YES;
    _picker.mediaTypes = @[(NSString*)kUTTypeImage];
    _picker.navigationBarHidden = NO;
    _picker.wantsFullScreenLayout = NO;
    _picker.navigationBar.tintColor = [UIColor blackColor];
    if(_picker != nil)
    {
        [self presentViewController:_picker animated:YES completion:nil];
    }
}

-(void)presentPickerSourceTypeCamera
{
    [_picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [_picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
    _picker.showsCameraControls = YES;
    _picker.allowsEditing = YES;
    _picker.toolbarHidden = YES;
    _picker.navigationBarHidden = NO;
    _picker.mediaTypes = @[(NSString*)kUTTypeImage];
    
    if(_picker != nil)
    {
        [self presentViewController:_picker animated:YES completion:nil];
    }
}

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
    [((NSMutableDictionary*)_data)removeObjectForKey:kTKPDCAMERA_DATAUSERINFOKEY];
}

@end
