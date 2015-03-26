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

#import "SettingUserProfileViewController.h"
#import "SettingUserPhoneViewController.h"

#import "UIImage+ImageEffects.h"

#pragma mark - Profile Edit View Controller
@interface SettingUserProfileViewController ()<CameraControllerDelegate, TKPDAlertViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate>
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
    __weak RKManagedObjectRequestOperation *_requestProfileForm;
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_barbuttonsave;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIView *contentView;
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
    
    [self setDefaultData:_data];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonsave setTintColor:[UIColor blackColor]];
	[_barbuttonsave setTag:11];
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
    
    [self configureRestkitGenerateHost];
    [self requestGenerateHost];
    [self configureRestkitProfileForm];
    [self requestProfileForm];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

-(void)viewDidLayoutSubviews
{
    _scrollview.contentSize = _contentView.frame.size;
    
}
#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
                }
                else
                {
                    [messages addObject:ERRORMESSAGE_NULL_PASSWORD];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:messages,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
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
                [c snap];
                c.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
                nav.wantsFullScreenLayout = YES;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
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
-(void)configureRestkitProfileForm
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
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDPROFILE_APIDATAUSERKEY toKeyPath:kTKPDPROFILE_APIDATAUSERKEY withMapping:datauserMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerProfileForm addResponseDescriptor:responseDescriptor];
}

-(void)cancelProfileForm
{
    [_requestProfileForm cancel];
    _requestProfileForm = nil;
    
    [_objectmanagerProfileForm.operationQueue cancelAllOperations];
    _objectmanagerProfileForm = nil;
}

- (void)requestProfileForm
{
    if(_requestProfileForm.isExecuting) return;
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    
    _requestcount ++;
    
    NSTimer *timer;
    
	NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETPROFILEKEY
                            };
    _barbuttonsave.enabled = NO;
    [_act startAnimating];
    _requestProfileForm = [_objectmanagerProfileForm appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_SETTINGAPIPATH parameters:[param encrypt]];
    
    [_requestProfileForm setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccessProfileForm:mappingResult withOperation:operation];
        [_act stopAnimating];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailureProfileForm:error];
        [_act stopAnimating];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestProfileForm];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeoutProfileForm) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
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
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _profile = info;
            NSString *statusstring = _profile.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self setDefaultData:_profile];
                _isnodataprofile = NO;
            }
        }else{
            [self cancelProfileForm];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    //[_act startAnimating];
                    [self performSelector:@selector(configureRestkitProfileForm) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(requestProfileForm) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    NSError *error = object;
                    NSString *errorDescription = error.localizedDescription;
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [errorAlert show];
                }
            }
            else
            {
                NSError *error = object;
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }

    }
}

-(void)requesttimeoutProfileForm
{
    [self cancelProfileForm];
}

#pragma mark Request Generate Host
-(void)configureRestkitGenerateHost
{
    _objectmanagerGenerateHost =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GenerateHost class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GenerateHostResult class]];
    
    RKObjectMapping *generatedhostMapping = [RKObjectMapping mappingForClass:[GeneratedHost class]];
    [generatedhostMapping addAttributeMappingsFromDictionary:@{
                                                               kTKPDGENERATEDHOST_APISERVERIDKEY:kTKPDGENERATEDHOST_APISERVERIDKEY,
                                                               kTKPDGENERATEDHOST_APIUPLOADHOSTKEY:kTKPDGENERATEDHOST_APIUPLOADHOSTKEY,
                                                               kTKPDGENERATEDHOST_APIUSERIDKEY:kTKPDGENERATEDHOST_APIUSERIDKEY
                                                               }];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY toKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY withMapping:generatedhostMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerGenerateHost addResponseDescriptor:responseDescriptor];
}

-(void)cancelGenerateHost
{
    [_requestGenerateHost cancel];
    _requestGenerateHost = nil;
    
    [_objectmanagerGenerateHost.operationQueue cancelAllOperations];
    _objectmanagerGenerateHost = nil;
}

- (void)requestGenerateHost
{
    if(_requestGenerateHost.isExecuting) return;
    
    _requestcount ++;
    
    NSTimer *timer;
    
	NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIUPLOADGENERATEHOSTKEY
                            };
    
    _editProfilePictButton.enabled = NO;
    _requestGenerateHost = [_objectmanagerGenerateHost appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_UPLOADIMAGEAPIPATH parameters:[param encrypt]];
    
    [_requestGenerateHost setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccessGenerateHost:mappingResult withOperation:operation];
        [timer invalidate];
        _editProfilePictButton.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailureGenerateHost:error];
        [timer invalidate];
        _editProfilePictButton.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestGenerateHost];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeoutGenerateHost) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


-(void)requestsuccessGenerateHost:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _generatehost = info;
    NSString *statusstring = _generatehost.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestprocessGenerateHost:object];
    }
}

-(void)requestfailureGenerateHost:(id)object
{
    [self requestprocessGenerateHost:object];
}

-(void)requestprocessGenerateHost:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _generatehost = info;
            NSString *statusstring = _generatehost.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if ([_generatehost.result.generated_host.server_id integerValue] == 0)
                {
                    [self configureRestkitGenerateHost];
                    [self requestGenerateHost];
                }
            }
        }
    }
    else
    {
        NSError *error = object;
        NSString *errorDescription = error.localizedDescription;
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
        [errorAlert show];
    }
}

-(void)requesttimeoutGenerateHost
{
    [self cancelGenerateHost];
}

#pragma mark Request Action Upload Photo
-(void)configureRestkitUploadPhoto
{
    _objectmanagerUploadPhoto =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[UploadImage class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[UploadImageResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILE_APIUPLOADFILEPATHKEY:kTKPDPROFILE_APIUPLOADFILEPATHKEY,
                                                        kTKPDPROFILE_APIUPLOADFILETHUMBKEY:kTKPDPROFILE_APIUPLOADFILETHUMBKEY
                                                        }];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];

    [_objectmanagerUploadPhoto addResponseDescriptor:responseDescriptor];
    
    // Request Mapping
    //[_objectmanagerUploadPhoto.router.routeSet addRoute:[RKRoute
    //                                                     routeWithClass:[UploadProfileParams class]
    //                                                     pathPattern:kTKPDPROFILE_UPLOADIMAGEAPIPATH
    //                                                     method:RKRequestMethodPOST]] ;
    //RKObjectMapping *userRequestMapping = [RKObjectMapping requestMapping];
    //[userRequestMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIACTIONKEY,
    //                                                         kTKPDPROFILE_APIUSERIDKEY : kTKPDPROFILE_APIUSERIDKEY,
    //                                                         kTKPDGENERATEDHOST_APISERVERIDKEY : kTKPDGENERATEDHOST_APISERVERIDKEY}];
    //
    //RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:userRequestMapping
    //                                                                               objectClass:[UploadProfileParams class]
    //                                                                               rootKeyPath:nil
    //                                                                                    method:RKRequestMethodAny];
    //[_objectmanagerUploadPhoto addRequestDescriptor:requestDescriptor];
    
    [_objectmanagerUploadPhoto setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [_objectmanagerUploadPhoto setRequestSerializationMIMEType:RKMIMETypeJSON];
}


- (void)cancelActionUploadPhoto
{
	[_requestActionUploadPhoto cancel];
	_requestActionUploadPhoto = nil;
	
    [_objectmanagerUploadPhoto.operationQueue cancelAllOperations];
    _objectmanagerUploadPhoto = nil;
}

- (void)requestActionUploadPhoto:(id)object
{
    
    if (_requestActionUploadPhoto.isExecuting) return;
    
	NSDictionary* userInfo = object;
    
    NSDictionary* photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    NSData* imageData = [photo objectForKey:DATA_CAMERA_IMAGEDATA];
    NSString* imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIUPLOADPROFILEIMAGEKEY,
              kTKPDPROFILE_APIUSERIDKEY:@(_generatehost.result.generated_host.user_id),
              kTKPDGENERATEDHOST_APISERVERIDKEY :_generatehost.result.generated_host.server_id,
              };
    _thumb.alpha = 0.5f;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestUploadImageData:imageData
                                                                      withName:API_UPLOAD_PROFILE_IMAGE_DATA_NAME
                                                                   andFileName:imageName
                                                         withRequestParameters:param
                                    ];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               
                               NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               if ([httpResponse statusCode] == 200) {
                                   id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
                                   if (parsedData == nil && error) {
                                       NSLog(@"parser error");
                                   }
                                   
                                   NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
                                   for (RKResponseDescriptor *descriptor in _objectmanagerUploadPhoto.responseDescriptors) {
                                       [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
                                   }
                                   
                                   RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
                                   NSError *mappingError = nil;
                                   BOOL isMapped = [mapper execute:&mappingError];
                                   if (isMapped && !mappingError) {
                                       NSLog(@"result %@",[mapper mappingResult]);
                                       RKMappingResult *mappingresult = [mapper mappingResult];
                                       NSDictionary *result = mappingresult.dictionary;
                                       id stat = [result objectForKey:@""];
                                       _images = stat;
                                       BOOL status = [_images.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                       
                                       if (status) {
                                           _thumb.alpha = 1.0f;
                                           [self requestProcessUploadPhoto:mappingresult];
                                       }
                                   }

                               }
                               NSLog(@"%@",responsestring);
                           }];
    
    
    /*
    // option1

    //NSMutableURLRequest *request = [NSMutableURLRequest new];
    //request = [_objectmanagerUploadPhoto.HTTPClient multipartFormRequestWithMethod:@"POST" path:kTKPDPROFILE_UPLOADIMAGEAPIPATH parameters:param constructingBodyWithBlock: ^(id <AFMultipartFormData> formData)
    //                                {
    //                                    [formData appendPartWithFileData:imageData name:kTKPDPROFILE_APIPROFILEPHOTOKEY fileName:@"image.png" mimeType:@"image/png"];
    //                                }];
    // option2
    UploadProfileParams *obj = [UploadProfileParams new];
    obj.action = @"upload_profile_image";
        NSMutableURLRequest *request =
        [_objectmanagerUploadPhoto multipartFormRequestWithObject:nil method:RKRequestMethodPOST
                                                             path:kTKPDPROFILE_UPLOADIMAGEAPIPATH parameters:param
                                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
         {
             [formData appendPartWithFileData:imageData
                                         name:kTKPDPROFILE_APIPROFILEPHOTOKEY
                                     fileName:@"image.png"
                                     mimeType:@"image/png"];
             NSLog(@"%@",formData);
             
         }];
        _objectmanagerUploadPhoto.requestSerializationMIMEType = RKMIMETypeFormURLEncoded;
    
        //option3
        //NSMutableURLRequest *request = [_objectmanagerUploadPhoto multipartFormRequestWithObject:params
        //                                                                                        method:RKRequestMethodPOST
        //                                                                                          path:kTKPDPROFILE_UPLOADIMAGEAPIPATH
        //                                                                                    parameters:param
        //                                                                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // [formData appendPartWithFileData:imageData
        //                             name:kTKPDPROFILE_APIPROFILEPHOTOKEY
        //                         fileName:@"image.png"
        //                         mimeType:@"image/png"];
        //                                                                     }];
    
        RKObjectRequestOperation *operation = [_objectmanagerUploadPhoto objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self requestSuccessUploadPhoto:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self requestFailureUploadPhoto:error];
        }];

        [_operationQueue addOperation:operation];
     */
}

- (void)requestSuccessUploadPhoto:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _images = info;
    NSString *statusstring = _images.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessUploadPhoto:object];
    }
}

- (void)requestFailureUploadPhoto:(id)object
{
    [self requestProcessUploadPhoto:object];
}

- (void)requestProcessUploadPhoto:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _images = info;
            NSString *statusstring = _images.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (!_images.message_error) {
                    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_images.result.file_th] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                    //request.URL = url;
                    
                    UIImageView *thumb = _thumb;
                    thumb = [UIImageView circleimageview:thumb];
                    
                    thumb.image = nil;
                    //thumb.hidden = YES;	//@prepareforreuse then @reset
                    
                    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                        //NSLOG(@"thumb: %@", thumb);
                        [thumb setImage:image];
#pragma clang diagnostic pop
                        
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    }];
                    
                    NSDictionary *userinfo = @{kTKPDPROFILE_APIUPLOADFILETHUMBKEY :_images.result.file_th,
                                               kTKPDPROFILE_APIUPLOADFILEPATHKEY:_images.result.file_path
                                               };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                }
                else
                {
                    NSLog(@"%@ : %@",NSStringFromSelector(_cmd), _images.message_error);
                }
            }
        }
        else
        {
            NSError *error = object;
            NSString *errorDescription = error.localizedDescription;
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
            [errorAlert show];
        }
    }
}
-(void)requesttimeoutUploadPhoto
{
    //[self cancelActionUploadPhoto];
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
    
    
    param = @{kTKPDPROFILE_APIACTIONKEY :kTKPDPROFILE_APISETUSERPROFILEKEY,
              kTKPDPROFILE_APIFULLNAMEKEY:[userInfo objectForKey:kTKPDPROFILE_APIFULLNAMEKEY]?:_profile.result.data_user.full_name,
              kTKPDPROFILE_APIBIRTHDAYKEY:[userInfo objectForKey:kTKPDPROFILE_APIBIRTHDAYKEY]?:_profile.result.data_user.birth_day,
              kTKPDPROFILE_APIBIRTHMONTHKEY:[userInfo objectForKey:kTKPDPROFILE_APIBIRTHMONTHKEY]?:_profile.result.data_user.birth_month,
              kTKPDPROFILE_APIBIRTHYEARKEY:[userInfo objectForKey:kTKPDPROFILE_APIBIRTHYEARKEY]?:_profile.result.data_user.birth_year,
              kTKPDPROFILE_APIGENDERKEY:[userInfo objectForKey:kTKPDPROFILE_APIGENDERKEY]?:_profile.result.data_user.gender,
              kTKPDPROFILE_APIHOBBYKEY:[userInfo objectForKey:kTKPDPROFILE_APIHOBBYKEY]?:_profile.result.data_user.hobby,
              kTKPDPROFILE_APIPASSKEY:[userInfo objectForKey:kTKPDPROFILE_APIPASSKEY]
              };
    
    _barbuttonsave.enabled = NO;
    _requestActionSubmit = [_objectmanagerActionSubmit appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:[param encrypt]];
    [_requestActionSubmit setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [self requestSuccessSubmit:mappingResult withOperation:operation];
        _barbuttonsave.enabled = YES;
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [self requestFailureSubmit:error];
         _barbuttonsave.enabled = YES;
     }];

    [_operationQueue addOperation:_requestActionSubmit];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeoutProfileForm) userInfo:nil repeats:NO];
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
                if(_editform.message_error)
                {
                    NSArray *array = _editform.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (_editform.result.is_success == 1) {
                    NSArray *array = _editform.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY object:nil userInfo:nil];
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
        
        NSString *dob = [NSString stringWithFormat:kTKPDPROFILEEDIT_DATEOFBIRTHFORMAT,_profile.result.data_user.birth_day,_profile.result.data_user.birth_month, _profile.result.data_user.birth_year];
        [_buttondob setTitle:dob forState:UIControlStateNormal];
        NSString *gender = ([_profile.result.data_user.gender isEqualToString:@"1"])?@"Male":@"Female";
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

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        
        _scrollviewContentSize = [_scrollview contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_scrollview setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _scrollviewContentSize = [_scrollview contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             //TODO::
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if (_activetextfield!=nil && ((self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height)> _keyboardPosition.y)) {
                                 UIEdgeInsets inset = _scrollview.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height + 10));
                                 [_scrollview setContentInset:inset];
                             }
                             if (_activeTextView!=nil && ((self.view.frame.origin.y + _activeTextView.frame.origin.y+_activeTextView.frame.size.height)> _keyboardPosition.y)) {
                                 UIEdgeInsets inset = _scrollview.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activeTextView.frame.origin.y+_activeTextView.frame.size.height + 10));
                                 [_scrollview setContentInset:inset];
                             }
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
                         _scrollview.contentInset = contentInsets;
                         _scrollview.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}


#pragma mark - Delegate Camera Controller
-(void)didDismissCameraController:(CameraController *)controller withUserInfo:(NSDictionary *)userinfo
{
    [self configureRestkitUploadPhoto];
    [self requestActionUploadPhoto:userinfo];
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
            
            NSString *stringdate = [NSString stringWithFormat:@"%zd / %zd / %zd",day,month,year];
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

@end
