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
#import "UploadImageParams.h"

#import "AlertDatePickerView.h"
#import "AlertListView.h"
#import "AlertPickerView.h"
#import "RequestUploadImage.h"
#import "RequestGenerateHost.h"

#import "SettingUserProfileViewController.h"
#import "SettingUserPhoneViewController.h"
#import "TokopediaNetworkManager.h"

#import "TKPDPhotoPicker.h"

#import "UIImage+ImageEffects.h"
#import "UIView+HVDLayout.h"

#import "PhoneVerifViewController.h"

#pragma mark - Profile Edit View Controller

typedef NS_ENUM(NSInteger, RequestType) {
    RequestTypeGetData,
    RequestTypeSubmitData,
    RequestTypeUploadImage,
};

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
    RequestUploadImageDelegate,
    GenerateHostDelegate,
    TokopediaNetworkManagerDelegate,
    TKPDPhotoPickerDelegate
>

// Data
@property (strong, nonatomic) GeneratedHost *generatedHostData;
@property (strong, nonatomic) UploadImage *uploadImageData;
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
    TokopediaNetworkManager *network = [TokopediaNetworkManager new];
    network.tagRequest = RequestTypeGetData;
    network.delegate = self;
    [network doRequest];
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
}

- (void)requestSubmitData {
    TokopediaNetworkManager *network = [TokopediaNetworkManager new];
    network.tagRequest = RequestTypeSubmitData;
    network.delegate = self;
    [network doRequest];
}

- (void)requestUploadPhoto {
    TokopediaNetworkManager *network = [TokopediaNetworkManager new];
    network.tagRequest = RequestTypeUploadImage;
    network.delegate = self;
    [network doRequest];
}

#pragma mark - Network delegate

- (NSString *)getPath:(int)tag {
    NSString *path = @"";
    if (tag == RequestTypeGetData) {
        path = kTKPDPROFILE_SETTINGAPIPATH;
    } else if (tag == RequestTypeSubmitData) {
        path = kTKPDPROFILE_PROFILESETTINGAPIPATH;
    } else if (tag == RequestTypeUploadImage) {
        path = kTKPDPROFILE_PROFILESETTINGAPIPATH;
    }
    return path;
}

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameter = @{};
    if (tag == RequestTypeGetData) {
        parameter = @{
            kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETPROFILEKEY
        };
    } else if (tag == RequestTypeSubmitData) {
        NSString *userPassword = self.passwordTextField.text?:@"";
        parameter = @{
            kTKPDPROFILE_APIACTIONKEY      : kTKPDPROFILE_APIEDITPROFILEKEY,
            kTKPDPROFILE_APIFULLNAMEKEY    : _userData.full_name,
            kTKPDPROFILE_APIBIRTHDAYKEY    : _userData.birth_day,
            kTKPDPROFILE_APIBIRTHMONTHKEY  : _userData.birth_month,
            kTKPDPROFILE_APIBIRTHYEARKEY   : _userData.birth_year,
            kTKPDPROFILE_APIGENDERKEY      : _userData.gender,
            kTKPDPROFILE_APIHOBBYKEY       : _userData.hobby,
            kTKPDPROFILE_APIMESSENGERKEY   : _userData.user_messenger,
            kTKPDPROFILE_APIPASSKEY        : userPassword,
            kTKPDPROFILE_APIMSISDNKEY      : _userData.user_phone
        };
    } else if (tag == RequestTypeUploadImage) {
        parameter = @{
            kTKPDPROFILE_APIACTIONKEY           : kTKPDPROFILE_APIUPLOADPROFILEPICTUREKEY,
            kTKPDPROFILE_APIFILEUPLOADEDKEY     : _uploadImageData.result.pic_obj,
            @"server_id"                        : _generatedHostData.server_id
        };
    }
    return parameter;
}

- (id)getObjectManager:(int)tag {
    RKObjectManager *objectManager;
    if (tag == RequestTypeGetData) {
        objectManager = [self getDataObjectManager];
    } else if (tag == RequestTypeSubmitData) {
        objectManager = [self submitDataObjectManager];
    } else if (tag == RequestTypeUploadImage) {
        objectManager = [self uploadImageObjectManager];
    }
    return objectManager;
}

- (RKObjectManager *)getDataObjectManager {
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileEdit class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileEditResult class]];
    
    RKObjectMapping *datauserMapping = [RKObjectMapping mappingForClass:[DataUser class]];
    [datauserMapping addAttributeMappingsFromArray:@[kTKPDPROFILE_APIHOBBYKEY,
                                                     kTKPDPROFILE_APIBIRTHDAYKEY,
                                                     kTKPDPROFILE_APIFULLNAMEKEY,
                                                     kTKPDPROFILE_APIBIRTHMONTHKEY,
                                                     kTKPDPROFILE_APIBIRTHYEARKEY,
                                                     kTKPDPROFILE_APIGENDERKEY,
                                                     kTKPDPROFILE_APIUSERIMAGEKEY,
                                                     kTKPDPROFILE_APIUSEREMAILKEY,
                                                     kTKPDPROFILE_APIUSERMESSENGERKEY,
                                                     kTKPDPROFILE_APIUSERPHONEKEY]];

    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDPROFILE_APIDATAUSERKEY
                                                                                  toKeyPath:kTKPDPROFILE_APIDATAUSERKEY
                                                                                withMapping:datauserMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_SETTINGAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

- (RKObjectManager *)submitDataObjectManager {
    RKObjectManager *objectManager =  [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileEditForm class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY
                                                   ]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileEditFormResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPDPROFILE_APIISSUCCESSKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];

    return objectManager;
}

- (RKObjectManager *)uploadImageObjectManager {
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileEditForm class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY
                                                   ]];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileEditFormResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPDPROFILE_APIISSUCCESSKEY]];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    return [[mappingResult.dictionary objectForKey:@""] status];
}

- (void)actionBeforeRequest:(int)tag {
    if (tag == RequestTypeSubmitData) {
        [self showLoadingBar];
    } else if (tag == RequestTypeUploadImage) {
        [self showLoadingBar];
    }
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult
             withOperation:(RKObjectRequestOperation *)operation
                   withTag:(int)tag {

    // Replace loading with save button
    [self showSaveButton];

    if (tag == RequestTypeGetData) {
        
        ProfileEdit *response = [mappingResult.dictionary objectForKey:@""];
        self.userData = response.result.data_user;
        [self showUserData:_userData];
        
    } else if (tag == RequestTypeSubmitData) {
        
        ProfileEditForm *response = [mappingResult.dictionary objectForKey:@""];
        BOOL isSuccess = [response.result.is_success boolValue];
        if (isSuccess) {
            // Shows success message save data
            NSArray *successMessages = response.message_status?:@[kTKPDMESSAGE_SUCCESSEDITPROFILEMESSAGEKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
            [alert show];
            
            // Notify other controller that edit profile is success
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY
                                                                object:nil
                                                              userInfo:nil];

            // Notify delegate controller that edit profile is success
            if ([_delegate respondsToSelector:@selector(successEditUserProfile)]) {
                [_delegate successEditUserProfile];
            }
            
            // Reset password field
            self.passwordTextField.text = @"";
            
        } else {
            NSArray *errorMessages = response.message_error?:@[kTKPDMESSAGE_ERROREDITPROFILEMESSAGEKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
        
    } else if (tag == RequestTypeUploadImage) {
        
        ProfileEditForm *response = [mappingResult.dictionary objectForKey:@""];
        BOOL isSuccess = [response.result.is_success boolValue];
        BOOL hasErrorMessages = response.message_error?YES:NO;
        if (isSuccess) {
            // Notify other controller that upload image is success
            NSDictionary *userInfo = @{
                kTKPDPROFILE_APIPROFILEPHOTOKEY : _profileImageView.image,
                @"file_th": _uploadImageData.result.file_th
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY
                                                                object:nil
                                                              userInfo:userInfo];
        } else if (hasErrorMessages) {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:response.message_error delegate:self];
            [alert show];
        }
    }
}

- (void)showUserData:(DataUser *)userData {
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
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    if([[auth objectForKey:@"msisdn_is_verified"] boolValue]){
        self.phoneNumberStatusLabel.hidden = NO;
        self.phoneNumberStatusLabel.text = @"Terverifikasi";
        self.phoneNumberStatusLabel.textColor = [UIColor colorWithRed:0.061 green:0.648 blue:0.275 alpha:1];
        self.verificationPhoneView.hidden = YES;
        self.verificationPhoneViewHeight.constant = 20;
    } else{
        self.phoneNumberStatusLabel.hidden = NO;
        self.phoneNumberStatusLabel.text = @"Belum Terverifikasi";
        self.phoneNumberStatusLabel.textColor = [UIColor colorWithRed:0.882 green:0.296 blue:0.209 alpha:1];
        self.verificationPhoneView.hidden = NO;
        self.verificationPhoneViewHeight.constant = 100;
    }
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    [self showSaveButton];
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
        NSCalendarUnit calendarUnit = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:calendarUnit fromDate:date];
        
        self.userData.birth_day = [NSString stringWithFormat:@"%d", [components day]];
        self.userData.birth_month = [NSString stringWithFormat:@"%d", [components month]];
        self.userData.birth_year = [NSString stringWithFormat:@"%d", [components year]];
        
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
    PhoneVerifViewController *controller = [PhoneVerifViewController new];
    controller.title = @"Verifikasi No. HP";
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didTapSaveButton:(UIBarButtonItem *)saveButton {
    [self requestSubmitData];
}

#pragma mark - Photo picker delegate

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:userInfo forKey:DATA_SELECTED_PHOTO_KEY];
    [object setObject:self.profileImageView forKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    
    NSDictionary *photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIImage *image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];

    self.profileImageView.image = image;
    
    [self uploadImageData:object];
}

#pragma mark - Upload profile image

- (void)uploadImageData:(NSDictionary *)data {
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    [uploadImage requestActionUploadObject:data
                             generatedHost:_generatedHostData
                                    action:kTKPDPROFILE_APIUPLOADPROFILEIMAGEKEY
                                    newAdd:1
                                 productID:@""
                                 paymentID:@""
                                 fieldName:API_UPLOAD_PROFILE_IMAGE_DATA_NAME
                                   success:^(id imageObject, UploadImage *uploadImageData) {
                                       self.uploadImageData = uploadImageData;
                                       [self requestUploadPhoto];
                                   } failure:^(id imageObject, NSError *error) {
                                       // Show error messages
                                       StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[[error localizedDescription]] delegate:self];
                                       [alert show];
                                       
                                       // Show user profile image
                                       [self setUserProfilePicture];
                                   }];
}

- (void)failedUploadErrorMessage:(NSArray *)errorMessage {
    
}

#pragma mark - Request Generate Host

-(void)successGenerateHost:(GenerateHost *)generateHost
{
    _generatedHostData = generateHost.result.generated_host;
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}

@end
