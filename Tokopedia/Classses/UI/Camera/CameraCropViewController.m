//
//  CameraCropViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "CameraCropViewController.h"
#import "AlertCameraView.h"

@interface CameraCropViewController ()


@property (weak, nonatomic) IBOutlet UIView *cropAreaView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)gesture:(id)sender;

@end

@implementation CameraCropViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _cropAreaView.layer.borderColor = [UIColor blueColor].CGColor;
    _cropAreaView.layer.borderWidth = 1;
    
    if(![_data isMutable])
    {
        _data = [_data mutableCopy];
    }
    
    if(_data == nil)
    {
        _data = [NSMutableDictionary new];
    }
    
    //[_scrollViewImageSmall setDelegate:self];
    //[_scrollViewImageLarge setDelegate:self];
    
    NSDictionary* camera = [_data objectForKey:kTKPDCAMERA_DATACAMERAKEY];
    NSDictionary* photo = [_data objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    UIImage* rawPhoto = [photo objectForKey:kTKPDCAMERA_DATARAWPHOTOKEY];
    
    self.title = kTKPDCAMERACROP_ZOOMANDCROPTITLE;
    [_imageView setImage:rawPhoto];
    //[_scrollViewImageSmall setHidden:NO];
    //[_imageViewSmall setHidden:NO];
    //[_imageViewSmall setImage:rawPhoto];
    //
    //[_buttonNext setHidden:YES];
    //[_buttonNext setUserInteractionEnabled:NO];
    //[_buttonNext setEnabled:NO];
    //[_scrollViewImageLarge setHidden:YES];
    //[_imageViewLarge setHidden:YES];
    //_imageViewLarge.image = nil;
    
    //[_cropAreaView setFrame:kTKPDCAMERACROP_CROPDEFAULTRECT];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    //UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
    //    UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    //}
    //else
    //    barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    //[barbutton1 setTag:10];
    //self.navigationItem.leftBarButtonItem = barbutton1;
    
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]])
    {
        UIBarButtonItem* button = (UIBarButtonItem*)sender;
        
        switch (button.tag)
        {
            case 11:
            {   // done cropping
                CGRect cropRect;
                CGRect frame;
                
                CGPoint cropPoint;
                CGSize cropSize;
                
                UIImage* result;
                
                result = _imageView.image;
                
                frame = _cropAreaView.frame;
                
                cropSize = (CGSize){.width = frame.size.width, .height =frame.size.height};
                
                cropRect = (CGRect){.origin = cropPoint, .size = cropSize};
                
                CGAffineTransform rectTransform = [self orientationTransformedRectOfImage:result];
                
                cropRect = CGRectApplyAffineTransform(cropRect, rectTransform);
                
                CGImageRef imageRef;
                imageRef = CGImageCreateWithImageInRect(result.CGImage, frame);
                result = [UIImage imageWithCGImage:imageRef scale:result.scale orientation:result.imageOrientation];
                
                if(imageRef)CGImageRelease(imageRef);
                
                NSMutableDictionary* photo = [NSMutableDictionary dictionaryWithDictionary:[_data objectForKey:kTKPDCAMERA_DATAPHOTOKEY]];
                
                [photo setValue:result forKey:kTKPDCAMERA_DATAPHOTOKEY];
                
                [_data setValue:photo forKey:kTKPDCAMERA_DATAPHOTOKEY];
                
                //TODO::request or delegate
                [_delegate CameraCropViewController:self didFinishCroppingMediaWithInfo:[_data copy]];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            default:
            {
                break;
            }
        }
    }
}

- (IBAction)gesture:(id)sender
{
    UIPanGestureRecognizer* gesture = (UIPanGestureRecognizer*)sender;
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
- (CGAffineTransform)orientationTransformedRectOfImage:(UIImage *)img
{
    CGAffineTransform rectTransform;
    
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(kTKPDCAMERA_RAD(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(kTKPDCAMERA_RAD(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(kTKPDCAMERA_RAD(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}

- (void)translateCropAreaWithTouchLocation:(CGPoint)touchPoint andPreviousTouchPoint:(CGPoint)previousTouchPoint
{
    CGPoint center = _cropAreaView.center;
    
    CGFloat deltaCenterx;
    CGFloat deltaCentery;
    
    deltaCenterx = touchPoint.x - previousTouchPoint.x;
    deltaCentery = touchPoint.y - previousTouchPoint.y;
    
    center.x += deltaCenterx;
    center.y += deltaCentery;
    
    //if (_cropAreaView.frame.origin.x >= self.view.frame.origin.x && _cropAreaView.frame.origin.y >= self.view.frame.origin.y) {
    [_cropAreaView setCenter:center];
    //}
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:_cropAreaView]anyObject];

    if(touch)
    {
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:_cropAreaView]anyObject];
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    CGPoint previousTouchPoint = [[touches anyObject] previousLocationInView:self.view];
    
    if(touch)
    {
        [self translateCropAreaWithTouchLocation:touchPoint andPreviousTouchPoint:previousTouchPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self translateCropAreaWithTouchLocation:CGPointZero andPreviousTouchPoint:CGPointZero];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
@end
