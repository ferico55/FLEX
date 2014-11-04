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
#import "StickyAlert.h"

@interface LoginViewController (){
    
    UITextField *_activetextfield;
    
    NSMutableDictionary *_activation;
    
    BOOL _isnodata;    
    NSInteger _requestcount;
    NSTimer *_timer;
    
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    
    Login *_login;
        
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UITextField *textfieldemail;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpass;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

-(void)keyboardWillShow:(NSNotification *)notification;

@end

@implementation LoginViewController

@synthesize data = _data;
@synthesize textfieldemail = _textfieldemail;
@synthesize textfieldpass = _textfieldpass;

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
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-light-pt"]];
    
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage *img;
    
    /** SIGN IN **/
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    }
    else
//        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];

    [barbutton1 setTag:10];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = barbutton1;

    /** GO TO SIGN UP PAGE **/
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    }
    else
//        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
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
                NSString *message;
                if (email && pass && ![email isEqualToString:@""] && ![pass isEqualToString:@""]) {
                    if ([email isEmail]) {
                        NSDictionary *userinfo = @{kTKPDACTIVATION_DATAEMAILKEY : email, kTKPDACTIVATION_DATAPASSKEY : pass};
                        [self LoadDataActionLogin:userinfo];
                    }
                    else {
                        message = @"Invalid Email Format";
                        [messages addObject:message];
                        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Invalid Email Format" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        //[alertView show];
                    }
                }
                else{
                    if (!email||[email isEqualToString:@""]) {
                        message = @"Email must be filled";
                        [messages addObject:message];
                        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Email must be filled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        //[alertView show];
                    }
                    else{
                        if (![email isEmail]) {
                            message = @"Invalid Email Format";
                            [messages addObject:message];
                        }
                    }
                    if (!pass || [pass isEqualToString:@""]) {
                        message = @"Password must be filled";
                        [messages addObject:message];
                        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Password must be filled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        //[alertView show];
                    }
                }
                
                StickyAlert *stickyalert = [[StickyAlert alloc]init];
                [stickyalert initView:self.view];
                [stickyalert alertError:messages];
                
//                [self.navigationController dismissViewControllerAnimated:YES completion:nil];

                
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
                                                       kTKPDLOGIN_APIFULLNAMEKEY:kTKPDLOGIN_APIFULLNAMEKEY
                                                        }];
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];

    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDLOGIN_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)LoadDataActionLogin:(id)userinfo
{
    if (_request.isExecuting) return;
    
    NSDictionary *data = userinfo;
    
    _requestcount++;
    
    [_act startAnimating];
    
	NSDictionary* param = @{
                            kTKPDLOGIN_APIUSEREMAILKEY : [data objectForKey:kTKPDACTIVATION_DATAEMAILKEY]?:@(0),
                            kTKPDLOGIN_APIUSERPASSKEY : [data objectForKey:kTKPDACTIVATION_DATAPASSKEY]?:@(0)
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDLOGIN_APIPATH parameters:param];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [self requestsuccessLogin:mappingResult];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [self requestfailureLogin:error];
    }];
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeoutLogin) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccessLogin:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    _login = stats;
    BOOL status = [_login.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        _isnodata = NO;

        if (!_login.message_error) {
            [self.tabBarController setSelectedIndex:0];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults saveCustomObject:_login.result key:kTKPD_AUTHKEY];
            //[[NSUserDefaults standardUserDefaults]setObject:_login.result forKey:kTKPD_AUTHKEY];
            [defaults synchronize];
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:kTKPD_ISLOGINNOTIFICATIONNAMEKEY object:nil userInfo:@{}];
        }
        else
        {
            NSArray *messages = _login.message_error;
            NSString *message = [[messages valueForKey:@"description"] componentsJoinedByString:@"\n"];
            
            StickyAlert *stickyalert = [[StickyAlert alloc]init];
            [stickyalert initView:self.view];
            [stickyalert alertError:messages];

//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
        }
    }
}

-(void)requesttimeoutLogin
{
    [self cancelLogin];
}

-(void)requestfailureLogin:(id)object
{
    [self cancelLogin];
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
            //_table.tableFooterView = _footer;
            [_act startAnimating];
            //[self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            //[self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
        else
        {
            [_act stopAnimating];
            //_table.tableFooterView = nil;
        }
    }
    else
    {
        [_act stopAnimating];
        //_table.tableFooterView = nil;
    }
}


#pragma mark - Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activetextfield = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _textfieldemail) {
        //if (![textField.text isEqualToString:@""]) {
            [_activation setValue:textField.text forKey:kTKPDACTIVATION_DATAEMAILKEY];
        //}
    }
    else if (textField == _textfieldpass){
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
    if([_textfieldemail isFirstResponder]){
        
        [_textfieldpass becomeFirstResponder];
    }
    else if ([_textfieldpass isFirstResponder]){
        
        [_textfieldpass resignFirstResponder];
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
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _container.contentInset = contentInsets;
    _container.scrollIndicatorInsets = contentInsets;
}

@end
