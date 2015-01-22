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
#import "StickyAlert.h"
#import "TextField.h"

@interface LoginViewController (){
    
    UITextField *_activetextfield;
    
    NSMutableDictionary *_activation;
    
    BOOL _isnodata;    
    NSInteger _requestcount;
    
    Login *_login;
    
    UIBarButtonItem *_barbuttonsignin;
        
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (strong, nonatomic) IBOutlet TextField *emailTextField;
@property (strong, nonatomic) IBOutlet TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

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
    //self = [super initWithNibName:@"LoginViewController" bundle:nibBundleOrNil];
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
    
    UIBarButtonItem* barbutton1;
    
    /** SIGN IN **/
    _barbuttonsignin = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonsignin setTag:10];
    [_barbuttonsignin setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = _barbuttonsignin;
    
    /** GO TO SIGN UP PAGE **/
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTag:11];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    [_container setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+64, _container.frame.size.width, _container.frame.size.height)];
    
    _activation = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    /** keyboard notification **/
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillBeHidden:)
//                                                 name:UIKeyboardWillHideNotification
//
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _emailTextField.isTopRoundCorner = YES;
    _passwordTextField.isBottomRoundCorner = YES;
    
    [self configureRestKitLogin];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelLogin];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - View Actipn
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    
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
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDLOGIN_APIISLOGINKEY:kTKPDLOGIN_APIISLOGINKEY,
                                                        kTKPDLOGIN_APISHOPIDKEY:kTKPDLOGIN_APISHOPIDKEY,
                                                        kTKPDLOGIN_APIUSERIDKEY:kTKPDLOGIN_APIUSERIDKEY,
                                                        kTKPDLOGIN_APIFULLNAMEKEY:kTKPDLOGIN_APIFULLNAMEKEY,
                                                        kTKPDLOGIN_APIIMAGEKEY:kTKPDLOGIN_APIIMAGEKEY,
                                                        kTKPDLOGIN_APISHOPNAMEKEY:kTKPDLOGIN_APISHOPNAMEKEY,
                                                        kTKPDLOGIN_APISHOPAVATARKEY:kTKPDLOGIN_APISHOPAVATARKEY,
                                                        kTKPDLOGIN_APISHOPISGOLDKEY:kTKPDLOGIN_APISHOPISGOLDKEY,
                                                        }];
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDLOGIN_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)requestActionLogin:(id)userinfo
{
    if (_request.isExecuting) return;
    
    NSDictionary *data = userinfo;
    
    _requestcount++;
    
    NSDictionary* param = [NSDictionary encryptDictionary : @{
                            kTKPDLOGIN_APIUSEREMAILKEY : [data objectForKey:kTKPDACTIVATION_DATAEMAILKEY]?:@(0),
                            kTKPDLOGIN_APIUSERPASSKEY : [data objectForKey:kTKPDACTIVATION_DATAPASSKEY]?:@(0)
                            }];
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    _barbuttonsignin.enabled = NO;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDLOGIN_APIPATH
                                                                parameters:[param encrypt]];
    
    NSTimer *timer;
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"clearCacheNotificationBar" object:self];
        [timer invalidate];
        //[_act stopAnimating];
        app.networkActivityIndicatorVisible = NO;
        _barbuttonsignin.enabled = YES;
        [self requestsuccessLogin:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [timer invalidate];
        //[_act stopAnimating];
        _barbuttonsignin.enabled =YES;
        app.networkActivityIndicatorVisible = NO;
        [self requestfailureLogin:error];
    }];
    [_operationQueue addOperation:_request];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeoutLogin) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccessLogin:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    _login = stats;
    BOOL status = [_login.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        _isnodata = NO;

        if (!_login.message_error) {
            [self.tabBarController setSelectedIndex:0];
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
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION object:nil userInfo:@{}];
        }
        else
        {
            NSArray *messages = _login.message_error;
//            NSString *message = [[messages valueForKey:@"description"] componentsJoinedByString:@"\n"];
            
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:messages,@"messages", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
            
//            StickyAlert *stickyalert = [[StickyAlert alloc]init];
//            [stickyalert initView:self.view];
//            [stickyalert alertError:messages];

            //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[alertView show];
        }
    }
}

-(void)requestfailureLogin:(id)object
{
    [self cancelLogin];
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
            [self performSelector:@selector(configureRestKitLogin) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            [self performSelector:@selector(requestActionLogin:) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
        else
        {
            NSArray *messages = [NSArray arrayWithObjects:@"Sign in gagal silahkan coba lagi.", nil];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:messages,@"messages", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
        }
    }
    else
    {
        NSArray *messages = [NSArray arrayWithObjects:@"Sign in gagal silahkan coba lagi.", nil];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:messages,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
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
        //if (![textField.text isEqualToString:@""]) {
            [_activation setValue:textField.text forKey:kTKPDACTIVATION_DATAEMAILKEY];
        //}
    }
    else if (textField == _passwordTextField){
        //if (![textField.text isEqualToString:@""]) {
            [_activation setValue:textField.text forKey:kTKPDACTIVATION_DATAPASSKEY];
        //}
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

@end
