//
//  SettingUserProfileViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "string_alert.h"
#import "profile.h"
#import "GenerateHost.h"
#import "UploadImage.h"
#import "ProfileEdit.h"
#import "ProfileEditForm.h"

#import "AlertDatePickerView.h"
#import "AlertListView.h"
#import "AlertPickerView.h"
#import "RequestUploadImage.h"

#import "SettingUserProfileViewController.h"
#import "SettingUserPhoneViewController.h"
#import "TKPDPhotoPicker.h"

#import "UIImage+ImageEffects.h"
#import "UIView+HVDLayout.h"

#import "Tokopedia-Swift.h"

#pragma mark - Profile Edit View Controller

typedef NS_ENUM(NSInteger, PickerView) {
    PickerViewDate,
    PickerViewGender,
};

@interface SettingUserProfileViewController ()
<
    UITextFieldDelegate,
    UITextViewDelegate,
    UIScrollViewDelegate,
    TKPDAlertViewDelegate,
    TKPDPhotoPickerDelegate
>

// Data
@property (strong, nonatomic) DataUser *userData;

// Container
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

// Profile image outlets
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *changeProfileImageButton;

// Labels
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberStatusLabel;

// Verification phone number view
@property (weak, nonatomic) IBOutlet UIView *verificationPhoneView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verificationPhoneViewHeight;

// Textfields
@property (weak, nonatomic) IBOutlet UITextField *hobbyTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *messengerTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) UITextField *activeTextField;

// Photo picker
@property (strong, nonatomic) TKPDPhotoPicker *photoPicker;
@property (strong, nonatomic) IBOutlet UIButton *verifyButton;

@end

@implementation SettingUserProfileViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Biodata Diri";
    [self requestGetData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [AnalyticsManager trackScreenName:@"Setting User Profile Page"];
    [self initView];
    [_verifyButton setUserInteractionEnabled:YES];
    [_verifyButton setHidden:NO];
    
    [self showSaveButton];
    _scrollView.contentSize = CGSizeMake(_contentView.frame.size.width, _contentView.frame.size.height + 200);

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self setPhoneVerificationStatus];
    [self requestGetData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)initView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    CGRect viewFrame = self.view.frame;
    viewFrame.size.width = screenRect.size.width;
    self.view.frame = viewFrame;
    
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.width = screenRect.size.width;
    self.contentView.frame = contentFrame;
    
    [self.scrollView addSubview:_contentView];
    [self.scrollView setContentSize:_contentView.frame.size];
    
    if(IS_IPAD) {
        [self.scrollView HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(20, 70, 0, 70)];
    }

}

- (void)showSaveButton {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(didTapSaveButton:)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)showLoadingBar {
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingView startAnimating];
    UIBarButtonItem *loadingButton = [[UIBarButtonItem alloc] initWithCustomView:loadingView];
    self.navigationItem.rightBarButtonItem = loadingButton;
}

#pragma mark - Request Method

- (void)requestGetData {
    
    [SettingUserProfileRequest fetchUserProfileForm:^(DataUser * data) {
        
        [self showUserData:data];
        [self showSaveButton];
        
    } onFailure:^{
        
        [self showSaveButton];
        
    }];
}

- (void)requestSubmitData {
    
    [self showLoadingBar];
    
    _userData.user_password = _passwordTextField.text?:@"";
    
    [SettingUserProfileRequest fetchEditUserProfile:_userData onSuccess:^{
        
        [self notifySuccessEditProfile];
        [self removePassword];
        [self showSaveButton];
        
    } onFailure:^{
        [self showSaveButton];
    }];
}

-(void)removePassword{
    // Reset password field
    self.passwordTextField.text = @"";
}

- (void)notifySuccessEditProfile{
    
    // Notify other controller that edit profile is success
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY
                                                        object:nil
                                                      userInfo:nil];
    
    // Notify delegate controller that edit profile is success
    if ([_delegate respondsToSelector:@selector(successEditUserProfile)]) {
        [_delegate successEditUserProfile];
    }
}

- (void)showUserData:(DataUser *)userData {
    _userData = userData;
    
    // Set value to outlet
    self.fullNameLabel.text = userData.full_name;
    self.birthdateLabel.text = [NSString stringWithFormat:@"%@/%@/%@", userData.birth_day, userData.birth_month, userData.birth_year];
    self.sexLabel.text = [userData.gender isEqualToString:@"1"]?@"Pria":@"Wanita";
    self.hobbyTextField.text = userData.hobby;
    self.emailTextField.text = userData.user_email;
    self.messengerTextField.text = userData.user_messenger?:@"-";
    self.phoneNumberLabel.text = userData.user_phone;
    
    // Set user profile picture
    [self setUserProfilePicture];
    [self setPhoneVerificationStatus];
}

-(void)setPhoneVerificationStatus{
    // Show verification view if user phone number not verified
    UserAuthentificationManager *auth = [[UserAuthentificationManager alloc]init];
    
    if([auth isUserPhoneVerified]){
        [self populateViewIfVerifiedStatusIs:YES];
    } else {
        [OTPRequest checkPhoneVerifiedStatusOnSuccess:^(NSString * _Nonnull result) {
            [self populateViewIfVerifiedStatusIs:[result boolValue]];
        } onFailure:^{
            [self populateViewIfVerifiedStatusIs:NO];
        }];
    }
}

-(void)populateViewIfVerifiedStatusIs:(BOOL)verifiedStatus{
    if(verifiedStatus){
        self.phoneNumberStatusLabel.hidden = NO;
        self.phoneNumberStatusLabel.text = @"Terverifikasi";
        self.phoneNumberStatusLabel.textColor = [UIColor colorWithRed:0.061 green:0.648 blue:0.275 alpha:1];
        self.verificationPhoneView.hidden = YES;
        self.verificationPhoneViewHeight.constant = 20;
    }else{
        self.phoneNumberStatusLabel.hidden = NO;
        self.phoneNumberStatusLabel.text = @"Belum Terverifikasi";
        self.phoneNumberStatusLabel.textColor = [UIColor colorWithRed:0.882 green:0.296 blue:0.209 alpha:1];
        self.verificationPhoneView.hidden = NO;
        self.verificationPhoneViewHeight.constant = 100;
    }
}

- (void)setUserProfilePicture {
    // Set user profile image
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_userData.user_image]];
    [self.profileImageView setImageWithURLRequest:request
                                 placeholderImage:_profileImageView.image
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              self.profileImageView.image = image;
                                          } failure:nil];
}

#pragma mark - Scroll delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.view endEditing:YES];
}

#pragma mark - Keyboard notification

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + 30, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Textfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;

    // Set textfield value
    if (textField == _hobbyTextField) {
        self.userData.hobby = _hobbyTextField.text;
    } else if (textField == _messengerTextField) {
        self.userData.user_messenger = _messengerTextField.text;
    }
}

#pragma mark - Tap Gesture

- (IBAction)didTapBirthdateLabel:(UITapGestureRecognizer *)sender {
    AlertDatePickerView *datePicker = [AlertDatePickerView newview];
    datePicker.tag = PickerViewDate;
    datePicker.isSetMinimumDate = YES;
    datePicker.delegate = self;
    datePicker.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPEREGISTERKEY)};
    if (_userData) {
        NSString *dob = [NSString stringWithFormat:@"%@/%@/%@", _userData.birth_day, _userData.birth_month, _userData.birth_year];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        datePicker.currentdate = [dateFormat dateFromString:dob];
    }
    [datePicker show];
}

- (IBAction)didTapGenderLabel:(id)sender {
    AlertPickerView *pickerView = [AlertPickerView newview];
    pickerView.tag = PickerViewGender;
    pickerView.delegate = self;
    pickerView.pickerData = ARRAY_GENDER;
    [pickerView show];
}

#pragma mark - Picker delegate

-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == PickerViewDate) {
        // alert date picker date of birth
        NSDate *date = [alertView.data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
        NSCalendarUnit calendarUnit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:calendarUnit fromDate:date];
        
        self.userData.birth_day = [NSString stringWithFormat:@"%zd", [components day]];
        self.userData.birth_month = [NSString stringWithFormat:@"%zd", [components month]];
        self.userData.birth_year = [NSString stringWithFormat:@"%zd", [components year]];
        
        NSString *birthdate = [NSString stringWithFormat:@"%@/%@/%@",
                               _userData.birth_day,
                               _userData.birth_month,
                               _userData.birth_year];
        self.birthdateLabel.text = birthdate;
        
    } else if (alertView.tag == PickerViewGender) {
        // alert gender
        NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];

        NSString *genderLabel = [ARRAY_GENDER[index] objectForKey:DATA_NAME_KEY];
        self.sexLabel.text = genderLabel;

        NSString *genderValue = [[ARRAY_GENDER[index] objectForKey:DATA_VALUE_KEY] stringValue];
        self.userData.gender = genderValue;
    }
}

#pragma mark - Action Button

- (IBAction)didTapChangeProfilePicture:(UIButton *)sender {
    self.photoPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
    [self.photoPicker setDelegate:self];
}

- (IBAction)didTapVerificationPhoneButton:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    PhoneVerificationViewController *vc = [[PhoneVerificationViewController alloc]
                                           initWithPhoneNumber:_userData.user_phone
                                           isFirstTimeVisit:NO didVerifiedPhoneNumber:^{
                                               [weakSelf requestGetData];
                                           }];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didTapSaveButton:(UIBarButtonItem *)saveButton {
    [self requestSubmitData];
}

#pragma mark - Photo picker delegate

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:userInfo forKey:DATA_SELECTED_PHOTO_KEY];
    
    NSDictionary *photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIImage *image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];

    self.profileImageView.image = image;
    self.profileImageView.alpha = 0.5;
    [self showLoadingBar];
    
    [SettingUserProfileRequest fetchUploadProfilePicture:image onSuccess:^(NSString * imageURLString) {
        
        self.profileImageView.alpha = 1;
        [self.profileImageView setImage:image];
        [self showSaveButton];
        [self notifySuccessEditProfileImageWithURLString:imageURLString];
        [self.profileImageView setImage:image];
        
    } onFailure:^{
        // Show user profile image
        [self setUserProfilePicture];
        [self showSaveButton];
    }];
}

-(void)notifySuccessEditProfileImageWithURLString:(NSString*)imageURLString{
    // Notify other controller that upload image is success
    NSDictionary *userInfo = @{
                               kTKPDPROFILE_APIPROFILEPHOTOKEY : _profileImageView.image,
                               @"file_th": imageURLString?:@""
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY
                                                        object:nil
                                                      userInfo:userInfo];
}

@end
