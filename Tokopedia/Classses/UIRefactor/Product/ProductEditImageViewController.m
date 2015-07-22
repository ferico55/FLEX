//
//  ProductEditImageViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "camera.h"
#import "string_product.h"
#import "ProductEditImageViewController.h"
#import "TKPDPhotoPicker.h"

@interface ProductEditImageViewController () <UIAlertViewDelegate, TKPDPhotoPickerDelegate>
{
    NSMutableDictionary *_dataInput;
    UITextField *_activeTextField;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    TKPDPhotoPicker *_photoPicker;
    
    BOOL _isDefaultImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UITextField *productNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *defaultPictureSwitch;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *deleteImageButton;
@property (weak, nonatomic) IBOutlet UILabel *defaultPictLabel;
@property (weak, nonatomic) IBOutlet UIButton *setDefaultButton;

- (IBAction)tap:(id)sender;

@end

@implementation ProductEditImageViewController

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
    
    self.title = @"Edit Gambar";
    
    _dataInput = [NSMutableDictionary new];
    
    [self setDefaultData:_data];
    
    _scrollView.frame = [[UIScreen mainScreen]bounds];
    CGRect frame = _contentView.frame;
    frame.size.width = _scrollView.frame.size.width;
    _contentView.frame = frame;
    
    _scrollView.contentSize = _contentView.frame.size;
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /** keyboard notification **/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    [_scrollView addSubview:_contentView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidLayoutSubviews
{
    _scrollView.contentSize = _contentView.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _productImageView.image = _uploadedImage;
        
        BOOL isDefaultImage = [[_data objectForKey:DATA_IS_DEFAULT_IMAGE]boolValue];
        _defaultPictLabel.hidden = !isDefaultImage;
        _setDefaultButton.hidden = isDefaultImage;
        _isDefaultImage = isDefaultImage;
        
        NSString *productName = [_data objectForKey:DATA_PRODUCT_IMAGE_NAME_KEY];
        _productNameTextField.text = productName;
        
        if (_isDefaultFromWS) {
            _deleteImageButton.hidden = YES;
        }
    }
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case BUTTON_PRODUCT_DELETE_PRODUCT_IMAGE:
            {
                BOOL isDefaultImage = _isDefaultImage;
                if (!_isDefaultFromWS && _type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
                    isDefaultImage = NO;
                }
                if (isDefaultImage) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ERRORMESSAGE_INVALID_DELETE_PRODUCT_IMAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:CONFIRMATIONMESSAGE_DELETE_PRODUCT_IMAGE delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya",nil];
                    [alertView show];
                }
                break;
            }
            case BUTTON_PRODUCT_UPDATE_PRODUCT_IMAGE:
            {
                _photoPicker = [[TKPDPhotoPicker alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera
                                                      parentViewController:self
                                                     pickerTransitionStyle:UIModalTransitionStyleCrossDissolve];
                _photoPicker.delegate = self;
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButtonItem = (UIBarButtonItem*)sender;
        switch (barButtonItem.tag) {
            case BARBUTTON_PRODUCT_SAVE:
                //[_delegate ProductEditImageViewController:self withUserInfo:];
                break;
            case BARBUTTON_PRODUCT_BACK:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    }
}
- (IBAction)gesture:(id)sender {
    [_activeTextField resignFirstResponder];
}
- (IBAction)tapDefaultPict:(UIButton*)sender {
    NSInteger indexImage = [[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    [_delegate setDefaultImageAtIndex:indexImage];
    
    sender.hidden = YES;
    _defaultPictLabel.hidden = NO;
    _isDefaultImage = YES;
}

#pragma mark - Photo picker delegate

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo
{
    NSDictionary* photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIImage* image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _productImageView.image = image;

    NSData* imageData = [photo objectForKey:DATA_CAMERA_IMAGEDATA];
    [_dataInput setObject:imageData forKey:DATA_CAMERA_IMAGEDATA];

    NSInteger indexImage = [[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    [_delegate updateProductImage:image AtIndex:indexImage withUserInfo:userInfo];
}

#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            NSInteger indexImage = [[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
            BOOL isDefaultImage = _isDefaultImage;
            [_delegate deleteProductImageAtIndex:indexImage isDefaultImage:isDefaultImage];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _activeTextField = textField;
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSString *productName = textField.text;
    NSInteger indexImage = [[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    [_delegate setProductImageName:productName atIndex:indexImage];
    return YES;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        
        _scrollviewContentSize = [_scrollView contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_scrollView setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _scrollviewContentSize = [_scrollView contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                                 UIEdgeInsets inset = _scrollView.contentInset;
                             inset.top -= (_keyboardSize.height - (self.view.frame.size.height-(_keyboardPosition.y + _activeTextField.frame.origin.y + _activeTextField.frame.size.height)));
                             [_scrollView setContentInset:inset];
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _scrollView.contentInset = contentInsets;
                         _scrollView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}


@end
