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
#import "CameraController.h"
#import "RequestUploadImage.h"
#import "RequestGenerateHost.h"

#import "SettingUserProfileViewController.h"
#import "SettingUserPhoneViewController.h"
#import "TokopediaNetworkManager.h"

#import "UIImage+ImageEffects.h"
#define CTagProfile 2

#pragma mark - Profile Edit View Controller
@interface SettingUserProfileViewController ()
<
    CameraControllerDelegate,
    TKPDAlertViewDelegate,
    RequestUploadImageDelegate,
    GenerateHostDelegate,
    UITextFieldDelegate,
    UIScrollViewDelegate,
    UITextViewDelegate,
    TokopediaNetworkManagerDelegate
>
{
    NSMutableDictionary *_datainput;
    
    ProfileEdit *_profile;
    GenerateHost *_generatehost;
    UploadImage *_images;
    ProfileEditForm *_editform;
    
    UITextField *_activetextfield;
    UITextView *_activeTextView;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    BOOL _isnodataprofile;
    NSInteger _requestcount;
    
    BOOL _isaddressexpanded;
    
    __weak RKObjectManager *_objectmanagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
    
    __weak RKObjectManager *_objectmanagerUploadPhoto;
    __weak RKManagedObjectRequestOperation *_requestActionUploadPhoto;
    
    __weak RKObjectManager *_objectmanagerActionSubmit;
    __weak RKManagedObjectRequestOperation *_requestActionSubmit;
    
    __weak RKObjectManager *_objectmanagerProfileForm;
    TokopediaNetworkManager *tokopediaNetworkManagerProfileForm;
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_barbuttonsave;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *labelfullname;
@property (weak, nonatomic) IBOutlet UIButton *buttondob;
@property (weak, nonatomic) IBOutlet UIButton *buttongender;
@property (weak, nonatomic) IBOutlet UITextView *textviewhobbies;
@property (weak, nonatomic) IBOutlet UITextField *textfieldemail;
@property (weak, nonatomic) IBOutlet UITextField *textfieldmesseger;
@property (weak, nonatomic) IBOutlet UITextField *textfieldphone;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpassword;
@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIButton *editProfilePictButton;

- (IBAction)tap:(id)sender;
- (IBAction)gesture:(id)sender;

@end

@implementation SettingUserProfileViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodataprofile = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationItem setTitle:kTKPDPROFILEEDIT_TITLE];
    
    self.title = kTKPDPROFILEEDIT_TITLE;
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    //[self setDefaultData:_data];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:kTKPDPROFILESAVE
                                                      style:UIBarButtonItemStyleDone
                                                     target:(self)
                                                     action:@selector(tap:)];
    _barbuttonsave.tag = 11;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
    
    [self requestProfileForm];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollview addSubview:_contentView];
    self.scrollview.contentSize = CGSizeMake(self.view.frame.size.width,
                                             _contentView.frame.size.height);
    self.scrollview.contentOffset = CGPointZero;

    CGRect frame = _contentView.frame;
    frame.origin = CGPointZero;
    _contentView.frame = frame;
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if(tokopediaNetworkManagerProfileForm != nil)
    {
        tokopediaNetworkManagerProfileForm.delegate = nil;
        [tokopediaNetworkManagerProfileForm requestCancel];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activetextfield resignFirstResponder];
    [_activeTextView resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                // back button
                break;
            }
            case 11:
            {
                //submit button
                [self configureRestkitSubmit];
                NSMutableArray *messages = [NSMutableArray new];
                NSDictionary *userinfo = _datainput;
                NSString *password = [_datainput objectForKey:kTKPDPROFILE_APIPASSKEY];
                if (password && ![password isEqualToString:@""]) {
                     [self requestActionSubmit:userinfo];
                } else {
                    [messages addObject:ERRORMESSAGE_NULL_PASSWORD];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
                    [alert show];
                }
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {   //edit thumbnail
                CameraController* c = [CameraController new];
                c.delegate = self;
                [c snap];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:c];
                nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self.navigationController presentViewController:nav
                                                        animated:NO
                                                      completion:nil];
                break;
            }
            case 11:
            {   //dob
                // display datepicker
                AlertDatePickerView *v = [AlertDatePickerView newview];
                v.tag = 10;
                v.isSetMinimumDate = YES;
                v.delegate = self;
                if (!_isnodataprofile) {
                    NSString *dob = [NSString stringWithFormat:kTKPDPROFILEEDIT_DATEOFBIRTHFORMAT,_profile.result.data_user.birth_day,_profile.result.data_user.birth_month, _profile.result.data_user.birth_year];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd / MM / yyyy"];
                    NSDate *date = [dateFormat dateFromString:dob];
                    v.currentdate = date;
                }
                [v show];
                break;
            }
            case 12:
            {    //gender
                AlertPickerView *alertView = [AlertPickerView newview];
                alertView.tag = 11;
                alertView.delegate = self;
                alertView.pickerData = ARRAY_GENDER;
                [alertView show];
                break;
            }
            case 13:
            {    //update phone number
                SettingUserPhoneViewController *vc = [SettingUserPhoneViewController new];
                vc.data = @{kTKPDPROFILEEDIT_DATAPHONENUMBERKEY:_profile.result.data_user.user_phone};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
    [_activeTextView resignFirstResponder];
}

#pragma mark - Request + Mapping
#pragma mark Request Get Profile Form

-(void)cancelProfileForm
{
//    [_requestProfileForm cancel];
//    _requestProfileForm = nil;
    
    [_objectmanagerProfileForm.operationQueue cancelAllOperations];
    _objectmanagerProfileForm = nil;
}

- (void)requestProfileForm
{
    if([self getNetWorkManager:CTagProfile].getObjectRequest.isExecuting) return;
    _barbuttonsave.enabled = NO;
    [_act startAnimating];
    
    
    [[self getNetWorkManager:CTagProfile] doRequest];
}


-(void)requestsuccessProfileForm:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _profile = info;
    NSString *statusstring = _profile.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestprocessProfileForm:object];
    }
}

-(void)requestfailureProfileForm:(id)object
{
    [self requestprocessProfileForm:object];
}

-(void)requestprocessProfileForm:(id)object
{
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id info = [result objectForKey:@""];
        _profile = info;
        NSString *statusstring = _profile.status;
        BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            [self setDefaultData:_profile];
            _isnodataprofile = NO;
        }
    }
}

-(void)requesttimeoutProfileForm
{
    [self cancelProfileForm];
}

#pragma mark Request Generate Host
-(void)successGenerateHost:(GenerateHost *)generateHost
{
    _generatehost = generateHost;
}

#pragma mark Request Action Upload Photo
-(void)actionUploadImage:(id)object
{
    _thumb.alpha = 0.5;
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    uploadImage.imageObject = object;
    uploadImage.delegate = self;
    uploadImage.generateHost = _generatehost;
    uploadImage.action = kTKPDPROFILE_APIUPLOADPROFILEIMAGEKEY;
    uploadImage.fieldName = API_UPLOAD_PROFILE_IMAGE_DATA_NAME;
    [uploadImage configureRestkitUploadPhoto];
    [uploadImage requestActionUploadPhoto];
}

-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    _thumb.alpha = 1;
    NSDictionary *userinfo = @{kTKPDPROFILE_APIUPLOADFILETHUMBKEY :_images.result.file_th,
                               kTKPDPROFILE_APIUPLOADFILEPATHKEY:_images.result.file_path
                               };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
}

-(void)failedUploadObject:(id)object
{
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_profile.result.data_user.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    UIImageView *thumb = _thumb;
    thumb = [UIImageView circleimageview:thumb];
    
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    _thumb.alpha = 1;
}

#pragma mark Request Action Submit
-(void)configureRestkitSubmit
{
    _objectmanagerActionSubmit =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileEditForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileEditFormResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILE_APIISSUCCESSKEY:kTKPDPROFILE_APIISSUCCESSKEY
                                                        }];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionSubmit addResponseDescriptor:responseDescriptor];
}


- (void)cancelActionSubmit
{
	[_requestActionSubmit cancel];
	_requestActionSubmit = nil;
	
    [_objectmanagerActionSubmit.operationQueue cancelAllOperations];
    _objectmanagerActionSubmit = nil;
}

- (void)requestActionSubmit:(id)object
{
    if (_requestActionSubmit.isExecuting) return;
    
	NSDictionary* userInfo = object;
    
    NSTimer *timer;
    
    NSDictionary* param;
    
    param = @{kTKPDPROFILE_APIACTIONKEY :kTKPDPROFILE_APIEDITPROFILEKEY,
              kTKPDPROFILE_APIFULLNAMEKEY:[userInfo objectForKey:kTKPDPROFILE_APIFULLNAMEKEY]?:_profile.result.data_user.full_name,
              kTKPDPROFILE_APIBIRTHDAYKEY:[userInfo objectForKey:kTKPDPROFILE_APIBIRTHDAYKEY]?:_profile.result.data_user.birth_day,
              kTKPDPROFILE_APIBIRTHMONTHKEY:[userInfo objectForKey:kTKPDPROFILE_APIBIRTHMONTHKEY]?:_profile.result.data_user.birth_month,
              kTKPDPROFILE_APIBIRTHYEARKEY:[userInfo objectForKey:kTKPDPROFILE_APIBIRTHYEARKEY]?:_profile.result.data_user.birth_year,
              kTKPDPROFILE_APIGENDERKEY:[userInfo objectForKey:kTKPDPROFILE_APIGENDERKEY]?:_profile.result.data_user.gender,
              kTKPDPROFILE_APIHOBBYKEY:[userInfo objectForKey:kTKPDPROFILE_APIHOBBYKEY]?:_profile.result.data_user.hobby,
              kTKPDPROFILE_APIPASSKEY:[userInfo objectForKey:kTKPDPROFILE_APIPASSKEY]
              };
    
    _barbuttonsave.enabled = NO;
    _requestActionSubmit = [_objectmanagerActionSubmit appropriateObjectRequestOperationWithObject:self
                                                                                            method:RKRequestMethodPOST
                                                                                              path:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                        parameters:[param encrypt]];
    
    [_requestActionSubmit setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [self requestSuccessSubmit:mappingResult withOperation:operation];
        _barbuttonsave.enabled = YES;
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [self requestFailureSubmit:error];
         _barbuttonsave.enabled = YES;
     }];

    [_operationQueue addOperation:_requestActionSubmit];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                             target:self
                                           selector:@selector(requesttimeoutProfileForm)
                                           userInfo:nil
                                            repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)requestSuccessSubmit:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _editform = info;
    NSString *statusstring = _editform.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessSubmit:object];
    }
}

- (void)requestFailureSubmit:(id)object
{
    [self requestProcessSubmit:object];
}

- (void)requestProcessSubmit:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _editform = info;
            NSString *statusstring = _editform.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(_editform.message_error) {
                    NSArray *errorMessages = _editform.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                }
                if ([_editform.result.is_success boolValue]) {
                    NSArray *successMessages = _editform.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                    [alert show];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY
                                                                        object:nil
                                                                      userInfo:nil];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
        {
            NSError *error = object;
            NSString *errorDescription = error.localizedDescription;
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"ERROR" message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
        }
    }
}
-(void)requesttimeoutSubmit
{
    [self cancelActionSubmit];
}

#pragma mark - Methods
- (TokopediaNetworkManager *)getNetWorkManager:(int)tag
{
    if(tag == CTagProfile)
    {
        if(tokopediaNetworkManagerProfileForm == nil)
        {
            tokopediaNetworkManagerProfileForm = [TokopediaNetworkManager new];
            tokopediaNetworkManagerProfileForm.tagRequest = CTagProfile;
            tokopediaNetworkManagerProfileForm.delegate = self;
        }
        
        return tokopediaNetworkManagerProfileForm;
    }
    
    return nil;
}

- (void)setDefaultData:(id)object
{
    if (object) {
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_profile.result.data_user.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        //request.URL = url;
        
        UIImageView *thumb = _thumb;
        thumb = [UIImageView circleimageview:thumb];
        
        thumb.image = nil;
        //thumb.hidden = YES;	//@prepareforreuse then @reset
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image];
#pragma clang diagnostic pop
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
        
        _textfieldemail.text = _profile.result.data_user.user_email;
        NSString *hobby =_profile.result.data_user.hobby;
        _textviewhobbies.text = ([hobby isEqualToString:@"0"])?@"":hobby;
        _textfieldmesseger.text = _profile.result.data_user.user_messenger;
        _textfieldphone.text = _profile.result.data_user.user_phone;
        
        _labelfullname.text = _profile.result.data_user.full_name?:@"";
        
        NSString *dob = [NSString stringWithFormat:kTKPDPROFILEEDIT_DATEOFBIRTHFORMAT,
                         _profile.result.data_user.birth_day?:@"",
                         _profile.result.data_user.birth_month,
                         _profile.result.data_user.birth_year];
        [_buttondob setTitle:dob?:@"" forState:UIControlStateNormal];
        NSString *gender = ([_profile.result.data_user.gender isEqualToString:@"1"])?@"Pria":@"Wanita";
        [_buttongender setTitle:gender forState:UIControlStateNormal];
    }
}

#pragma mark - Scroll View delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_activetextfield resignFirstResponder];
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activetextfield = textField;
    _activeTextView = nil;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _textfieldemail) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILE_APIUSEREMAILKEY];
    }
    if ((UITextView *)textField == _textviewhobbies) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILE_APIHOBBYKEY];
    }
    if (textField == _textfieldphone) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILE_APIUSERPHONEKEY];
    }
    if (textField == _textfieldpassword) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILE_APIPASSKEY];
    }
    if (textField == _textfieldmesseger) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILE_APIUSERMESSENGERKEY];
    }

    return YES;
}

#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    _activeTextView = textView;
    _activetextfield = nil;
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _textviewhobbies) {
        [_datainput setObject:textView.text forKey:kTKPDPROFILE_APIHOBBYKEY];
    }
    return YES;
}

#pragma mark - Scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_activetextfield resignFirstResponder];
    [_activeTextView resignFirstResponder];
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    self.scrollview.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height+25, 0);
}

- (void)keyboardWillHide:(NSNotification *)info {
    self.scrollview.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Delegate Camera Controller

-(void)didDismissCameraController:(CameraController *)controller withUserInfo:(NSDictionary *)userinfo
{
    NSDictionary *object = @{DATA_SELECTED_PHOTO_KEY : userinfo,
                             DATA_SELECTED_IMAGE_VIEW_KEY : _thumb};
    [self actionUploadImage:object];
}

#pragma mark - Delegate Alert View

-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 10:
        {
            // alert date picker date of birth
            NSDictionary *data = alertView.data;
            NSDate *date = [data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
            NSInteger year = [components year];
            NSInteger month = [components month];
            NSInteger day = [components day];
            [_datainput setObject:@(year) forKey:kTKPDPROFILE_APIBIRTHYEARKEY];
            [_datainput setObject:@(month) forKey:kTKPDPROFILE_APIBIRTHMONTHKEY];
            [_datainput setObject:@(day) forKey:kTKPDPROFILE_APIBIRTHDAYKEY];
            
            NSString *stringdate = [NSString stringWithFormat:@"%zd / %zd / %zd", day, month, year];
            [_buttondob setTitle:stringdate forState:UIControlStateNormal];
            break;
        }
        case 11:
        {
            // alert gender
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *gender = [ARRAY_GENDER[index] objectForKey:DATA_NAME_KEY];
            NSInteger genderID = [[ARRAY_GENDER[index] objectForKey:DATA_VALUE_KEY]integerValue];
            [_buttongender setTitle:gender forState:UIControlStateNormal];
            [_datainput setObject:@(genderID) forKey:kTKPDPROFILE_APIGENDERKEY];
            break;
        }
        default:
            break;
    }
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    if(tag == CTagProfile)
        return @{kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETPROFILEKEY};
    
    return nil;
}

- (NSString*)getPath:(int)tag
{
    if(tag == CTagProfile)
        return kTKPDPROFILE_SETTINGAPIPATH;
    
    return nil;
}

- (id)getObjectManager:(int)tag
{
    if(tag == CTagProfile)
    {
        _objectmanagerProfileForm =  [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileEdit class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileEditResult class]];
        
        RKObjectMapping *datauserMapping = [RKObjectMapping mappingForClass:[DataUser class]];
        [datauserMapping addAttributeMappingsFromDictionary:@{
                                                              kTKPDPROFILE_APIHOBBYKEY:kTKPDPROFILE_APIHOBBYKEY,
                                                              kTKPDPROFILE_APIBIRTHDAYKEY:kTKPDPROFILE_APIBIRTHDAYKEY,
                                                              kTKPDPROFILE_APIFULLNAMEKEY:kTKPDPROFILE_APIFULLNAMEKEY,
                                                              kTKPDPROFILE_APIBIRTHMONTHKEY:kTKPDPROFILE_APIBIRTHMONTHKEY,
                                                              kTKPDPROFILE_APIBIRTHMONTHKEY:kTKPDPROFILE_APIBIRTHMONTHKEY,
                                                              kTKPDPROFILE_APIBIRTHYEARKEY:kTKPDPROFILE_APIBIRTHYEARKEY,
                                                              kTKPDPROFILE_APIGENDERKEY:kTKPDPROFILE_APIGENDERKEY,
                                                              kTKPDPROFILE_APIUSERIMAGEKEY:kTKPDPROFILE_APIUSERIMAGEKEY,
                                                              kTKPDPROFILE_APIUSEREMAILKEY:kTKPDPROFILE_APIUSEREMAILKEY,
                                                              kTKPDPROFILE_APIUSERMESSENGERKEY:kTKPDPROFILE_APIUSERMESSENGERKEY,
                                                              kTKPDPROFILE_APIUSERPHONEKEY:kTKPDPROFILE_APIUSERPHONEKEY
                                                              }];
        // Relationship Mapping
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                      toKeyPath:kTKPD_APIRESULTKEY
                                                                                    withMapping:resultMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDPROFILE_APIDATAUSERKEY
                                                                                      toKeyPath:kTKPDPROFILE_APIDATAUSERKEY
                                                                                    withMapping:datauserMapping]];
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanagerProfileForm addResponseDescriptor:responseDescriptor];

        return _objectmanagerProfileForm;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagProfile)
        return ((ProfileEdit *) stat).status;
    
    return nil;
}


- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if(tag == CTagProfile)
    {
        [self requestsuccessProfileForm:successResult withOperation:operation];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    if(tag == CTagProfile)
    {
    
    }
}

- (void)actionBeforeRequest:(int)tag
{}

- (void)actionRequestAsync:(int)tag
{}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    if(tag == CTagProfile)
    {
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
    }
}
@end
