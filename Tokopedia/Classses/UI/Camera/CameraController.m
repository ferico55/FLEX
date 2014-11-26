//
//  CameraController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "CameraController.h"

#import "CameraAlbumListViewController.h"
#import "CameraCropViewController.h"
#import "AlertCameraView.h"

#import "NSDictionaryCategory.h"

@interface CameraController () <TKPDAlertViewDelegate, CameraCropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL _isFirstTimeLaunch;
    
    UIImage* _snappedImage;
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
    //cropimage from camera collection view
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(CameraCrop:) name:kTKPD_CROPIMAGEPOSTNOTIFICATIONNAMEKEY object:nil];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if(!_snappedImage)
//    {
//        [self snap];
//        
//        [_imageView setImage:_snappedImage];
//    }
//    else
//    {
//        [_imageView setImage:_snappedImage];
//    }
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
//            [_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//            _picker.mediaTypes = @[(NSString*)kUTTypeImage];
//            if(_picker != nil)
//            {
//                [self presentViewController:_picker animated:YES completion:nil];
//            }
            //TODO:: add alert choose type camera
            AlertCameraView *v = [AlertCameraView newview];
            v.delegate = self;
            v.tag = 10;
            [v show];
           
        }else
        {
            CameraAlbumListViewController *vc = [CameraAlbumListViewController new];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
            //[_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            //_picker.mediaTypes = @[(NSString*)kUTTypeImage];
            //if(_picker != nil)
            //{
            //    [self presentViewController:_picker animated:YES completion:nil];
            //}

        }
        
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    
    //UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;
    
    UIImage* rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    [_data setValue:@{
                      kTKPDCAMERA_DATARAWPHOTOKEY:rawImage,
                      kTKPDCAMERA_DATAMEDIATYPEKEY:mediaType,
                      kTKPDCAMERA_DATAPHOTOKEY:rawImage //TODO::remove it - cropped image
                      } forKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    [_delegate didDismissCameraController:self withUserInfo:_data];
    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    //CameraCropViewController *c = [CameraCropViewController new];
    //[c setDelegate:self];
    //[c setData:[_data copy]];
    //[c setPicker:picker];
    //
    //[picker pushViewController:c animated:YES];
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

-(void)CameraCrop:(NSNotification*)notification
{
    NSDictionary* userinfo = notification.userInfo;
    [_delegate didDismissCameraController:self withUserInfo:userinfo];
}

#pragma mark - Alert Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {   //camera
            [_picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [_picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
            _picker.showsCameraControls = YES;
            _picker.allowsEditing = NO;
            _picker.toolbarHidden = YES;
            _picker.navigationBarHidden = NO;
            _picker.mediaTypes = @[(NSString*)kUTTypeImage];
            
            if(_picker != nil)
            {
                [self presentViewController:_picker animated:YES completion:nil];
            }
            break;
        }
        case 1:
        {   //gallery
             
            CameraAlbumListViewController *vc = [CameraAlbumListViewController new];
            [self.navigationController pushViewController:vc animated:YES];
            //[self presentViewController:vc animated:YES completion:nil];
            //[_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            //_picker.mediaTypes = @[(NSString*)kUTTypeImage];
            break;
        }
        default:
            break;
    }
}
-(void)alertViewCancel:(TKPDAlertView *)alertView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        if (btn.tag == 10) {
            //back
            [self dismissViewControllerAnimated:YES completion:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
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
