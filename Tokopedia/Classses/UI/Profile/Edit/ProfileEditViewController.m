//
//  ProfileEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "alert.h"
#import "profile.h"
#import "GenerateHost.h"
#import "UploadProfile.h"
#import "ProfileEdit.h"
#import "ProfileEditForm.h"
#import "UploadProfileParams.h"

#import "../../Alert/AlertDatePickerView.h"
#import "../../Alert/AlertListView.h"
#import "../../Alert/Alert1ButtonView.h"
#import "../../Camera/CameraController.h"

#import "ProfileEditViewController.h"
#import "ProfileEditPhoneViewController.h"

#import "UIImage+ImageEffects.h"

@interface ProfileEditViewController ()<CameraControllerDelegate, TKPDAlertViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>
{
    NSMutableDictionary *_datainput;
    
    ProfileEdit *_profile;
    GenerateHost *_generatehost;
    UploadProfile *_images;
    ProfileEditForm *_editform;
    
    UITextField *_activetextfield;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    BOOL _isnodataprofile;
    NSInteger _requestcount;
    
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanagerUploadPhoto;
    __weak RKManagedObjectRequestOperation *_requestActionUploadPhoto;
    
    __weak RKObjectManager *_objectmanagerActionSubmit;
    __weak RKManagedObjectRequestOperation *_requestActionSubmit;
    
    __weak RKObjectManager *_objectmanagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
    
    __weak RKObjectManager *_objectmanagerProfileForm;
    __weak RKManagedObjectRequestOperation *_requestProfileForm;
    
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIView *vieweditprofile;
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

- (IBAction)tap:(id)sender;
- (IBAction)gesture:(id)sender;

@end

@implementation ProfileEditViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodataprofile = YES;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationItem setTitle:kTKPDPROFILEEDIT_TITLE];
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    [self setDefaultData:_data];
    
    /** keyboard notification **/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
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
    
    [self configureRestkitGenerateHost];
    [self requestGenerateHost];
    [self configureRestkitProfileForm];
    [self requestProfileForm];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_scrollview addSubview:_vieweditprofile];
    CGSize size = _vieweditprofile.frame.size;
    size.height += self.view.frame.origin.y;
    [_scrollview setContentSize:size];
    
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
    
    //Add sticky view
    UIView *stickyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    stickyView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    [self.view insertSubview:stickyView belowSubview:self.scrollview];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activetextfield resignFirstResponder];
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
                NSMutableArray *message = [NSMutableArray new];
                NSDictionary *userinfo = _datainput;
                if ([_datainput objectForKey:kTKPDPROFILE_APIPASSKEY]) {
                     [self requestActionSubmit:userinfo];
                }
                else
                {
                    [message addObject:@"please enter password"];
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
                c.wantsFullScreenLayout = YES;
                c.modalPresentationStyle = UIModalPresentationFullScreen;
                c.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                c.delegate = self;
                //c.data = data;
                [self.navigationController presentViewController:c animated:YES completion:nil];
                break;
            }
            case 11:
            {   //dob
                // display datepicker
                AlertDatePickerView *v = [AlertDatePickerView newview];
                v.tag = 10;
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
                AlertListView *v = [AlertListView newview];
                v.delegate = self;
                v.tag = 11;
                v.data = @{kTKPDALERTVIEW_DATALISTKEY:kTKPDPROFILE_DATAGENDERARRAYKEY};
                [v show];
                break;
            }
            case 13:
            {    //update phone number
                ProfileEditPhoneViewController *vc = [ProfileEditPhoneViewController new];
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
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
                            kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETPROFILEFORMKEY,
                            kTKPDPROFILE_APIUSERIDKEY : [auth objectForKey:kTKPDPROFILE_APIUSERIDKEY]
                            };
    
    [_act startAnimating];
    _requestProfileForm = [_objectmanagerProfileForm appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_SETTINGAPIPATH parameters:param];
    
    [_requestProfileForm setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccessProfileForm:mappingResult withOperation:operation];
        [_act stopAnimating];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailureProfileForm:error];
        [_act stopAnimating];
        [timer invalidate];
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
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    //[_act startAnimating];
                    [self performSelector:@selector(configureRestkitProfileForm) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(requestProfileForm) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    //[_act stopAnimating];
                }
            }
            else
            {
                //[_act stopAnimating];
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
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
    
    [_act startAnimating];
    _requestGenerateHost = [_objectmanagerGenerateHost appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_UPLOADIMAGEAPIPATH parameters:param];
    
    [_requestGenerateHost setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccessGenerateHost:mappingResult withOperation:operation];
        [_act stopAnimating];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailureGenerateHost:error];
        [_act stopAnimating];
        [timer invalidate];
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
                
            }
        }
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[UploadProfile class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[UploadProfileResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILE_APIUPLOADFILEPATHKEY:kTKPDPROFILE_APIUPLOADFILEPATHKEY,
                                                        kTKPDPROFILE_APIUPLOADFILETHUMBKEY:kTKPDPROFILE_APIUPLOADFILETHUMBKEY
                                                        }];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];

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
    
    NSDictionary* camera = [userInfo objectForKey:kTKPDCAMERA_DATACAMERAKEY];
    NSDictionary* photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    NSDictionary* param;
    
    param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIUPLOADPROFILEIMAGEKEY,
              kTKPDPROFILE_APIUSERIDKEY:@(602),//@(_generatehost.result.generated_host.user_id),
              kTKPDGENERATEDHOST_APISERVERIDKEY :@(2) //@(_generatehost.result.generated_host.server_id),
              };
    
    NSData* imageData;
    //UIImage *image = [UIImage imageNamed:@"icon_location.png"];
    UIImage* image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageData = UIImagePNGRepresentation(image);
    //imageData = UIImageJPEGRepresentation(image,1);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    //Set Params
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];

    //Create boundary, it can be anything
    NSString *boundary = @"------VohpleBoundary4QuqLuM1cE5lMwCy";

    //set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

    //post body
    NSMutableData *body = [NSMutableData data];

    //Populate a dictionary with all the regular values you would like to send.?action=upload_profile_image?
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:kTKPDPROFILE_APIUPLOADPROFILEIMAGEKEY forKeyPath:kTKPDPROFILE_APIACTIONKEY];
    [parameters setValue:@(602) forKeyPath:kTKPDPROFILE_APIUSERIDKEY];
    [parameters setValue:@(2) forKeyPath:kTKPDGENERATEDHOST_APISERVERIDKEY];

    //add params (all params are strings)
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSString *FileParamConstant = @"profile_img";
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: attachment; name=\"profile_img\"; filename=\"icon_location.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    

    //add image data

    //Close off the request with the boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    //setting the body of the post to the request
    [request setHTTPBody:body];

    NSString *url = @"http://www.tkpdevel-pg.renny/ws/action/upload-image.pl";

    [request setURL:[NSURL URLWithString:url]];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               
                               NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               if ([httpResponse statusCode] == 200) {
                                        NSLog(@"success");
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
                    
                }
                else
                {
                    NSLog(@"%@ : %@",NSStringFromSelector(_cmd), _images.message_error);
                }
            }
        }
        else
        {
            //[self performSelector:@selector(configureRestkitProfileForm) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            //[self performSelector:@selector(requestActionUploadPhoto:) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
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
              kTKPDPROFILE_APIBIRTHYEARKEY:[userInfo objectForKey:kTKPDPROFILE_APIBIRTHYEARKEY]?:_profile.result.data_user.birth_day,
              kTKPDPROFILE_APIGENDERKEY:[userInfo objectForKey:kTKPDPROFILE_APIGENDERKEY]?:_profile.result.data_user.gender,
              kTKPDPROFILE_APIHOBBYKEY:[userInfo objectForKey:kTKPDPROFILE_APIHOBBYKEY]?:_profile.result.data_user.hobby,
              kTKPDPROFILE_APIPASSKEY:[userInfo objectForKey:kTKPDPROFILE_APIPASSKEY]
              };
    
    UIActivityIndicatorView *act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:act];
    [self navigationItem].rightBarButtonItem = barButton;
    [act startAnimating];
    
    _requestActionSubmit = [_objectmanagerActionSubmit appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:param];
    [_requestActionSubmit setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [act stopAnimating];
         act.hidden = YES;
         [self requestSuccessSubmit:mappingResult withOperation:operation];
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [act stopAnimating];
         act.hidden = YES;
         [self requestFailureSubmit:error];
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
                if (!_editform.message_error) {
                    //TODO:: add alert
                    NSLog(@"%@",_editform.message_status);
                    Alert1ButtonView *v = [Alert1ButtonView newview];
                    v.data = @{kTKPDALERTVIEW_DATALABELKEY: _editform.message_status};
                    v.tag = 12;
                    [v show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY object:nil userInfo:nil];

                }
                else
                {
                    NSLog(@"%@ : %@",NSStringFromSelector(_cmd), _editform.message_error);
                }
            }
        }
        else
        {
            
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
            //NSLOG(@"thumb: %@", thumb);
            [thumb setImage:image];
#pragma clang diagnostic pop
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
        
        _textfieldemail.text = _profile.result.data_user.user_email;
        if (![_profile.result.data_user.hobby isEqualToString:@"none"]) _textviewhobbies.text = _profile.result.data_user.hobby;
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
    
    self.scrollview.contentInset = UIEdgeInsetsMake(0, 0, 300, 0);
    [self.scrollview setContentOffset:CGPointMake(0, 330) animated:YES];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    _activetextfield = textField;
    
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

#pragma mark - Keyboard Notification
// Called when the UIKeyboardWillShowNotification is sent
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
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             _scrollviewContentSize = [_scrollview contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if ((self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height)> _keyboardPosition.y) {
                                 UIEdgeInsets inset = _scrollview.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height + 10));
                                 [_scrollview setContentSize:_scrollviewContentSize];
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
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         _scrollview.contentInset = contentInsets;
                         _scrollview.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}


#pragma mark - Delegate Camera Controller
-(void)didDismissCameraController:(UIViewController *)controller withUserInfo:(NSDictionary *)userinfo
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
            int year = [components year];
            int month = [components month];
            int day = [components day];
            [_datainput setObject:@(year) forKey:kTKPDPROFILE_APIBIRTHYEARKEY];
            [_datainput setObject:@(month) forKey:kTKPDPROFILE_APIBIRTHMONTHKEY];
            [_datainput setObject:@(day) forKey:kTKPDPROFILE_APIBIRTHDAYKEY];
            
            NSString *stringdate = [NSString stringWithFormat:@"%d / %d / %d",day,month,year];
            [_buttondob setTitle:stringdate forState:UIControlStateNormal];
            break;
        }
        case 11:
        {
            // alert gender
            [_buttongender setTitle:kTKPDPROFILE_DATAGENDERARRAYKEY[buttonIndex] forState:UIControlStateNormal];
            [_datainput setObject:kTKPDPROFILE_DATAGENDERVALUEARRAYKEY[buttonIndex] forKey:kTKPDPROFILE_APIGENDERKEY];
            break;
        }
        default:
            break;
    }
}

@end
