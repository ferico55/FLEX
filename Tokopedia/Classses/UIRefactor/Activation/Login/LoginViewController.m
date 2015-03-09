//
//  LoginViewController.m
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Login.h"

#import "activation.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"

#import "TKPDSecureStorage.h"
#import "StickyAlertView.h"
#import "TextField.h"

//#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController () {
    
    UITextField *_activetextfield;
    
    NSMutableDictionary *_activation;
    
    BOOL _isnodata;
    NSInteger _requestcount;
    
    Login *_login;
    
    UIBarButtonItem *_barbuttonsignin;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_facebookObjectManager;
}

@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (strong, nonatomic) IBOutlet TextField *emailTextField;
@property (strong, nonatomic) IBOutlet TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *facebookLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (void)cancelLogin;
- (void)configureRestKitLogin;
- (void)requestActionLogin:(id)userinfo;
- (void)requestsuccessLogin:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestfailureLogin:(id)object;
- (void)requesttimeoutLogin;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHidden:(NSNotification*)aNotification;

@end

@implementation LoginViewController

@synthesize data = _data;
@synthesize emailTextField = _emailTextField;
@synthesize passwordTextField = _passwordTextField;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    /** Cecking UI device iPhone or iPad (different xib) **/
    self = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)?[super initWithNibName:kTKPDACTIVATION_LOGINNIBNAMEIPHONE bundle:nil]:[super initWithNibName:kTKPDACTIVATION_LOGINNIBNAMEIPAD bundle:nil];
    
    if (self) {
        self.title = kTKPDACTIVATION_LOGINTITTLE;
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:(self)
                                                                    action:@selector(tap:)];
    signUpButton.tag = 11;
    signUpButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = signUpButton;
    
    if (_isPresentedViewController) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(tap:)];
        cancelButton.tag = 13;
        cancelButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    [_container setFrame:CGRectMake(0,
                                    self.navigationController.navigationBar.frame.size.height+64,
                                    _container.frame.size.width,
                                    _container.frame.size.height)];
    
    _activation = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    [self configureRestKitLogin];
    
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.delegate = self;
//    loginView.readPermissions = @[@"public_profile", @"email"];
//    loginView.frame = CGRectMake(0, 0,
//                                 _facebookLoginButton.frame.size.width,
//                                 _facebookLoginButton.frame.size.height);
//    [_facebookLoginButton addSubview:loginView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _loginButton.layer.cornerRadius = 2;
    
    _emailTextField.isTopRoundCorner = YES;
    _emailTextField.isBottomRoundCorner = YES;
    
    _passwordTextField.isTopRoundCorner = YES;
    _passwordTextField.isBottomRoundCorner = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelLogin];
}

#pragma mark - View Actipn
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        
        switch (btn.tag) {
            case 10:
            {
                /** SIGN IN **/
                NSString *email = [_activation objectForKey:kTKPDACTIVATION_DATAEMAILKEY];
                NSString *pass = [_activation objectForKey:kTKPDACTIVATION_DATAPASSKEY];
                NSMutableArray *messages = [NSMutableArray new];
                BOOL valid = NO;
                NSString *message;
                if (email && pass && ![email isEqualToString:@""] && ![pass isEqualToString:@""] && [email isEmail]) {
                    valid = YES;
                }
                if (!email||[email isEqualToString:@""]) {
                    message = @"Email harus diisi.";
                    [messages addObject:message];
                    valid = NO;
                }
                if (email) {
                    if (![email isEmail]) {
                        message = @"Format email salah.";
                        [messages addObject:message];
                        valid = NO;
                    }
                }
                if (!pass || [pass isEqualToString:@""]) {
                    message = @"Password harus diisi";
                    [messages addObject:message];
                    valid = NO;
                }
                
                if (valid) {
                    NSDictionary *userinfo = @{kTKPDACTIVATION_DATAEMAILKEY : email, kTKPDACTIVATION_DATAPASSKEY : pass};
                    [_loginButton setEnabled:NO];
                    [self configureRestKitLogin];
                    [self requestActionLogin:userinfo];
                }
                else{
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:messages,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                
                NSLog(@"message : %@", messages);
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        
        switch (btn.tag) {
            case 10:
            {
                /** SIGN IN **/
                NSString *email = [_activation objectForKey:kTKPDACTIVATION_DATAEMAILKEY];
                NSString *pass = [_activation objectForKey:kTKPDACTIVATION_DATAPASSKEY];
                NSMutableArray *messages = [NSMutableArray new];
                BOOL valid = NO;
                NSString *message;
                if (email && pass && ![email isEqualToString:@""] && ![pass isEqualToString:@""] && [email isEmail]) {
                    valid = YES;
                }
                if (!email||[email isEqualToString:@""]) {
                    message = @"Email harus diisi.";
                    [messages addObject:message];
                    valid = NO;
                }
                if (email) {
                    if (![email isEmail]) {
                        message = @"Format email salah.";
                        [messages addObject:message];
                        valid = NO;
                    }
                }
                if (!pass || [pass isEqualToString:@""]) {
                    message = @"Password harus diisi";
                    [messages addObject:message];
                    valid = NO;
                }
                
                if (valid) {
                    NSDictionary *userinfo = @{kTKPDACTIVATION_DATAEMAILKEY : email, kTKPDACTIVATION_DATAPASSKEY : pass};

                    [self configureRestKitLogin];
                    [self requestActionLogin:userinfo];
                }
                else{
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:messages,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                
                NSLog(@"message : %@", messages);
                break;
            }
            case 11:
            {
                /** GO TO SIGN UP PAGE **/
                RegisterViewController *vc = [RegisterViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 13:
            {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            default:
                break;
        }
    }
    
}
#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - property
-(void)setData:(NSDictionary *)data
{
    data = _data;
}

#pragma mark - Request and Mapping
-(void)cancelLogin
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKitLogin
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Login class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LoginResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDLOGIN_APIISLOGINKEY    : kTKPDLOGIN_APIISLOGINKEY,
                                                        kTKPDLOGIN_APISHOPIDKEY     : kTKPDLOGIN_APISHOPIDKEY,
                                                        kTKPDLOGIN_APIUSERIDKEY     : kTKPDLOGIN_APIUSERIDKEY,
                                                        kTKPDLOGIN_APIFULLNAMEKEY   : kTKPDLOGIN_APIFULLNAMEKEY,
                                                        kTKPDLOGIN_APIIMAGEKEY      : kTKPDLOGIN_APIIMAGEKEY,
                                                        kTKPDLOGIN_APISHOPNAMEKEY   : kTKPDLOGIN_APISHOPNAMEKEY,
                                                        kTKPDLOGIN_APISHOPAVATARKEY : kTKPDLOGIN_APISHOPAVATARKEY,
                                                        kTKPDLOGIN_APISHOPISGOLDKEY : kTKPDLOGIN_APISHOPISGOLDKEY,
                                                        kTKPDLOGIN_API_STATUS_KEY               : kTKPDLOGIN_API_STATUS_KEY,
                                                        kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY   : kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY,
                                                        kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY   : kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY,
                                                        }];
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDLOGIN_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)configureRestKitFacebookLogin
{
    // initialize RestKit
    _facebookObjectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Login class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LoginResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDLOGIN_APIISLOGINKEY    : kTKPDLOGIN_APIISLOGINKEY,
                                                        kTKPDLOGIN_APISHOPIDKEY     : kTKPDLOGIN_APISHOPIDKEY,
                                                        kTKPDLOGIN_APIUSERIDKEY     : kTKPDLOGIN_APIUSERIDKEY,
                                                        kTKPDLOGIN_APIFULLNAMEKEY   : kTKPDLOGIN_APIFULLNAMEKEY,
                                                        kTKPDLOGIN_APIIMAGEKEY      : kTKPDLOGIN_APIIMAGEKEY,
                                                        kTKPDLOGIN_APISHOPNAMEKEY   : kTKPDLOGIN_APISHOPNAMEKEY,
                                                        kTKPDLOGIN_APISHOPAVATARKEY : kTKPDLOGIN_APISHOPAVATARKEY,
                                                        kTKPDLOGIN_APISHOPISGOLDKEY : kTKPDLOGIN_APISHOPISGOLDKEY,
                                                        kTKPDLOGIN_API_STATUS_KEY               : kTKPDLOGIN_API_STATUS_KEY,
                                                        kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY   : kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY,
                                                        kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY   : kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY,
                                                        }];
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDLOGIN_FACEBOOK_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_facebookObjectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)requestActionLogin:(NSDictionary *)data
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
    NSDictionary* param = @{
                            kTKPDLOGIN_APIUSEREMAILKEY : [data objectForKey:kTKPDACTIVATION_DATAEMAILKEY]?:@(0),
                            kTKPDLOGIN_APIUSERPASSKEY : [data objectForKey:kTKPDACTIVATION_DATAPASSKEY]?:@(0)
                            };
    
    _loginButton.enabled = NO;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDLOGIN_APIPATH
                                                                parameters:[param encrypt]];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(requesttimeoutLogin)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer
                                 forMode:NSRunLoopCommonModes];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [timer invalidate];
        _loginButton.enabled = YES;
        [self requestsuccessLogin:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [timer invalidate];
        _loginButton.enabled = YES;
        [self requestfailureLogin:error];
    }];
    
    [_operationQueue addOperation:_request];
}

//- (void)requestLoginFacebookUser:(id<FBGraphUser>)user
//{
//    if (_request.isExecuting) return;
//    
//    _requestcount++;
//    
//    NSDictionary *param = @{
//                            kTKPDREGISTER_APIACTIONKEY      : kTKPDREGISTER_APIDOLOGINKEY,
//                            kTKPDLOGIN_API_APP_TYPE_KEY     : @"1",
//                            kTKPDLOGIN_API_EMAIL_KEY        : [user objectForKey:@"email"]?:@"",
//                            kTKPDLOGIN_API_NAME_KEY         : [user objectForKey:@"name"]?:@"",
//                            kTKPDLOGIN_API_ID_KEY           : [user objectForKey:@"id"]?:@"",
//                            kTKPDLOGIN_API_BIRTHDAY_KEY     : [user objectForKey:@"birthday"]?:@"",
//                            kTKPDLOGIN_API_GENDER_KEY       : [user objectForKey:@"gender"]?:@"",
//                            @"enc_dec"                      : @"off"
//                            };
//    
//    _barbuttonsignin.enabled = NO;
//    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
//                                                                    method:RKRequestMethodGET
//                                                                      path:kTKPDLOGIN_FACEBOOK_APIPATH
//                                                                parameters:param];
//    
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
//                                                      target:self
//                                                    selector:@selector(requesttimeoutLogin)
//                                                    userInfo:nil
//                                                     repeats:NO];
//    
//    [[NSRunLoop currentRunLoop] addTimer:timer
//                                 forMode:NSRunLoopCommonModes];
//    
//    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        [timer invalidate];
//        _barbuttonsignin.enabled = YES;
//        [self requestsuccessLogin:mappingResult withOperation:operation];
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        [timer invalidate];
//        _barbuttonsignin.enabled = YES;
//        [self requestfailureLogin:error];
//    }];
//    
//    [_operationQueue addOperation:_request];
//}

-(void)requestsuccessLogin:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    _login = stats;
    BOOL status = [_login.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        
        _isnodata = NO;
        
        if (!_login.message_error) {
            //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //[defaults saveCustomObject:_login.result key:kTKPD_AUTHKEY];
            //[defaults setObject:operation.HTTPRequestOperation.responseData forKey:kTKPD_AUTHKEY];
            //[defaults synchronize];
            //TODO:: api key
            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            
            [secureStorage setKeychainWithValue:@(_login.result.is_login) withKey:kTKPD_ISLOGINKEY];
            
            [secureStorage setKeychainWithValue:@(_login.result.user_id) withKey:kTKPD_USERIDKEY];
            [secureStorage setKeychainWithValue:_login.result.full_name withKey:kTKPD_FULLNAMEKEY];
            [secureStorage setKeychainWithValue:_login.result.user_image withKey:kTKPD_USERIMAGEKEY];
            
            [secureStorage setKeychainWithValue:@(_login.result.shop_id) withKey:kTKPD_SHOPIDKEY];
            [secureStorage setKeychainWithValue:_login.result.shop_name withKey:kTKPD_SHOPNAMEKEY];
            [secureStorage setKeychainWithValue:_login.result.shop_avatar withKey:kTKPD_SHOPIMAGEKEY];
            [secureStorage setKeychainWithValue:_login.result.shop_avatar withKey:kTKPD_SHOPIMAGEKEY];
            [secureStorage setKeychainWithValue:@(_login.result.shop_is_gold) withKey:kTKPD_SHOPISGOLD];
            
            if (_isPresentedViewController) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                [self.delegate redirectViewController:_redirectViewController];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                                    object:nil
                                                                  userInfo:nil];
                
            } else {
                [self.tabBarController setSelectedIndex:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION
                                                                    object:nil
                                                                  userInfo:nil];
            }
        }
        else
        {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:_login.message_error
                                                                           delegate:self];
            [alert show];
        }
    }
    else
    {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                       delegate:self];
        [alert show];
    }
}

-(void)requestfailureLogin:(id)object
{
    [self cancelLogin];
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
            [self performSelector:@selector(configureRestKitLogin) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            [self performSelector:@selector(requestActionLogin:) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
        else
        {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                           delegate:self];
            [alert show];
        }
    } else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                       delegate:self];
        [alert show];
    }
}

-(void)requesttimeoutLogin
{
    [self cancelLogin];
}

#pragma mark - Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activetextfield = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _emailTextField) {
        [_activation setValue:textField.text forKey:kTKPDACTIVATION_DATAEMAILKEY];
    } else if (textField == _passwordTextField){
        [_activation setValue:textField.text forKey:kTKPDACTIVATION_DATAPASSKEY];
    }
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([_emailTextField isFirstResponder]){
        
        [_passwordTextField becomeFirstResponder];
    }
    else if ([_passwordTextField isFirstResponder]){
        
        [_passwordTextField resignFirstResponder];
    }
    return YES;
}

// Called when the UIKeyboardWillShowNotification is sent
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _container.contentInset = contentInsets;
    _container.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _activetextfield.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _activetextfield.frame.origin.y-kbSize.height);
        [_container setContentOffset:scrollPoint animated:YES];
    }
}
// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _container.contentInset = contentInsets;
    _container.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Facebook login delegate
//
//// Call method when user information has been fetched
//- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
//    [self configureRestKitFacebookLogin];
//    [self requestLoginFacebookUser:user];
//}
//
//// Handle possible errors that can occur during login
//- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
//    NSString *alertMessage, *alertTitle;
//    if ([FBErrorUtility shouldNotifyUserForError:error]) {
//        
//        alertTitle = @"Facebook error";
//        alertMessage = [FBErrorUtility userMessageForError:error];
//        
//    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
//        
//        alertTitle = @"Session Error";
//        alertMessage = @"Your current session is no longer valid. Please log in again.";
//        
//    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
//        
//        NSLog(@"user cancelled login");
//        
//    } else {
//        
//        alertTitle  = @"Something went wrong";
//        alertMessage = @"Please try again later.";
//        NSLog(@"Unexpected error:%@", error);
//        
//    }
//    
//    if (alertMessage) {
//        [[[UIAlertView alloc] initWithTitle:alertTitle
//                                    message:alertMessage
//                                   delegate:nil
//                          cancelButtonTitle:@"OK"
//                          otherButtonTitles:nil] show];
//    }
//}

@end