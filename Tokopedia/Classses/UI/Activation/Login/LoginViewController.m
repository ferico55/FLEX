//
//  LoginViewController.m
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "activation.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"

@interface LoginViewController (){
    
    UITextField *_activetextfield;
    
    NSMutableDictionary *_activation;
    
    BOOL _isnodata;
   // __weak AFHTTPRequestOperation *_requestaction;
}

@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UITextField *textfieldemail;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpass;
@property (weak, nonatomic) IBOutlet UIButton *buttonsubmit;

-(void)keyboardWillShow:(NSNotification *)notification;

//-(void)cancelaction;
//-(void)requestaction:(id)object;
//-(void)requestactionsuccess:(id)object;
//-(void)requestactionfailure:(id)object;
//-(void)requestactionprocess;

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
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-light-pt"]];
    
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage *img;
    
    /** SIGN IN **/
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];

    [barbutton1 setTag:10];
    self.navigationItem.rightBarButtonItem = barbutton1;

    /** GO TO SIGN UP PAGE **/
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    
    [barbutton1 setTag:11];
    self.navigationItem.leftBarButtonItem = barbutton1;

    
    [_container setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+64, _container.frame.size.width, _container.frame.size.height)];
    
    _activation = [NSMutableDictionary new];
    
    
    /** keyboard notification **/
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillBeHidden:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}

#pragma mark - View Gesture
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        
        switch (btn.tag) {
            case 10:
            {
                /** SIGN IN **/
                NSString *email = [_activation objectForKey:kTKPDACTIVATION_EMAILDATA];
                NSString *pass = [_activation objectForKey:kTKPDACTIVATION_PASSDATA];
                if (![email isEmail]) {
                    
                }
                else if (email && pass && [email isEmail]) {
                    NSDictionary *userinfo = @{kTKPDACTIVATION_EMAILDATA : email, kTKPDACTIVATION_PASSDATA : pass};
                    //[self requestaction:userinfo];
                }
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

//#pragma mark - Request
//#pragma mark - - Request Action Submit
//
//-(void)cancelaction{
//    [_requestaction cancel];
//    _requestaction = nil;
//}
//
//-(void)requestaction:(id)object
//{
//    //NSDictionary* tkpd = [_data dictionaryForKey:TKPD_AUTHKEY];
//    NSDictionary *userinfo = object;
//    NSString *email = [userinfo objectForKey:kTKPDACTIVATION_EMAILDATA];
//    NSString *pass = [userinfo objectForKey:kTKPDACTIVATION_PASSDATA];
//    
//	NSDictionary* param = @{kTKPDACTIVATION_APIEMAILDATA :email?:@""
//                            ,kTKPDACTIVATION_APIPASSDATA :pass?:@""};
//	   
//    /** Use This For Post Param**/
//    //[Client setParameterEncoding:AFJSONParameterEncoding];
//    //_requestaction = (AFJSONRequestOperation*)[client postPath:kTKPDLOGIN_APIPATH parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    
//    TraktAPIClient *client = [TraktAPIClient sharedClient];
//    
//    [client GET:kTKPDLOGIN_APIPATH  parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        _requestaction = nil;
//        [self requestactionsuccess:responseObject];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        _requestaction = nil;
//        [self requestactionfailure:error];
//        
//    }];
//}
//
//-(void)requestactionsuccess:(id)object
//{
//    NSDictionary *response = (NSDictionary*)object;
//    [_activation addEntriesFromDictionary:response];
//    NSString *status = [response objectForKey:kTKPDACTIVATION_APISTATUSDATA];
//    if (status) {
//        
//#ifdef _DEBUG
//        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDACTIVATIONLOGIN_APIRSPONSEFILE];
//        [response writeToFile:path atomically:YES];
//#endif
//    }else{
//        [self requestactionfailure:object];
//    }
//    
//    [self requestactionprocess];
//}
//
//-(void)requestactionfailure:(id)object
//{
//#ifdef _DEBUG
//    
//	NSDictionary* response;
//	
//	NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDACTIVATIONLOGIN_APIRSPONSEFILE];
//	response = [NSDictionary dictionaryWithContentsOfFile:path];
//#endif
//    
//    [self requestactionprocess];
//    
//}
//
//-(void)requestactionprocess
//{
//    
//}


#pragma mark - Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activetextfield = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _textfieldemail) {
        [_activation setValue:textField.text forKey:kTKPDACTIVATION_EMAILDATA];
    }
    else if (textField == _textfieldpass){
        [_activation setValue:textField.text forKey:kTKPDACTIVATION_PASSDATA];
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
