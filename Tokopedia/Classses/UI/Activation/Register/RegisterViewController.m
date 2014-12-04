//
//  RegisterViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Register.h"
#import "alert.h"
#import "activation.h"
#import "RegisterViewController.h"

#import "AlertDatePickerView.h"
#import "Alert1ButtonView.h"

#import "TextField.h"

#pragma mark - Register View Controller
@interface RegisterViewController () <UITextFieldDelegate,UIScrollViewDelegate,UIAlertViewDelegate, TKPDAlertViewDelegate>
{
    UITextField *_activetextfield;
    NSMutableDictionary *_datainput;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    Register *_register;
    
    BOOL _isnodata;
    NSInteger _requestcount;
    NSTimer *_timer;

    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet TextField *texfieldfullname;
@property (weak, nonatomic) IBOutlet TextField *textfieldphonenumber;
@property (weak, nonatomic) IBOutlet TextField *textfieldemail;
@property (weak, nonatomic) IBOutlet TextField *textfielddob;
@property (weak, nonatomic) IBOutlet TextField *textfieldpassword;
@property (weak, nonatomic) IBOutlet TextField *textfieldconfirmpass;
@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIButton *buttonagreement;

- (IBAction)tap:(id)sender;
- (IBAction)tapsegment:(id)sender;
- (IBAction)gesture:(id)sender;

- (void)cancel;
- (void)configureRestKit;
- (void)LoadDataAction:(id)userinfo;
- (void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestfailure:(id)object;
- (void)requesttimeout;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification*)aNotification;

@end

@implementation RegisterViewController

#pragma mark - Initialitation
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.texfieldfullname.isTopRoundCorner = YES;
    self.textfielddob.isBottomRoundCorner = YES;    
    self.textfieldpassword.isTopRoundCorner = YES;
    self.textfieldconfirmpass.isBottomRoundCorner = YES;
    
    _datainput = [NSMutableDictionary new];
    _operationQueue =[NSOperationQueue new];
    
    NSBundle* bundle = [NSBundle mainBundle];
    UIBarButtonItem *barbutton1;
    UIImage *img;
    
    /** BACK **/
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
    //    UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    //}
    //else
    //    barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    //
    //[barbutton1 setTag:10];
    //self.navigationItem.leftBarButtonItem = barbutton1;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /** SIGN UP **/
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    
    [barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    // keyboard notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    //set default data
    [_datainput setObject:@(0) forKey:kTKPDREGISTER_APIGENDERKEY];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                //done button action
                
                NSMutableArray *messages = [NSMutableArray new];
                
                NSString *fullname = [_datainput objectForKey:kTKPDREGISTER_APIFULLNAMEKEY];
                NSString *phone = [_datainput objectForKey:kTKPDREGISTER_APIPHONEKEY];
                NSString *email = [_datainput objectForKey:kTKPDREGISTER_APIEMAILKEY];
                NSString *gender = [_datainput objectForKey:kTKPDREGISTER_APIGENDERKEY];
                NSString *birthday = [_datainput objectForKey:kTKPDREGISTER_APIBIRTHDAYKEY];
                NSString *birthmonth = [_datainput objectForKey:kTKPDREGISTER_APIBIRTHMONTHKEY];
                NSString *birthyear = [_datainput objectForKey:kTKPDREGISTER_APIBITHYEARKEY];
                NSString *pass = [_datainput objectForKey:kTKPDREGISTER_APIPASSKEY];
                NSString *confirmpass = [_datainput objectForKey:kTKPDREGISTER_APICONFIRMPASSKEY];
                BOOL isagree = [[_datainput objectForKey:kTKPDACTIVATION_DATAISAGREEKEY]boolValue];
                
                NSInteger phoneCharCount= [[phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length];
                NSInteger passCharCount= [[phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length];
                
                if (fullname && ![fullname isEqualToString:@""] &&
                    phone &&
                    email && [email isEmail] &&
                    gender &&
                    birthday && birthmonth && birthyear &&
                    pass && ![pass isEqualToString:@""] &&
                    confirmpass && ![confirmpass isEqualToString:@""]&&
                    [pass isEqualToString:confirmpass] && phoneCharCount>=6 && passCharCount >=6 &&
                    isagree) {
                        [self configureRestKit];
                        [self LoadDataAction:_datainput];
                    }
                else
                {
                    if (!fullname || [fullname isEqualToString:@""]) {
                        [messages addObject:@"Fullname must be filled"];
                    }
                    if (!phone) {
                        [messages addObject:@"Mobile Number must be filled."];
                    }
                    else{
                        if (phoneCharCount<6) {
                            [messages addObject:@"phone minimum 6 character"];
                        }
                    }
                    if (!email || [email isEqualToString:@""]) {
                        [messages addObject:@"Email must be filled"];
                    }
                    else
                    {
                        if (![email isEmail]) {
                            [messages addObject:@"Invalid email format"];
                        }
                    }
                    if (!gender) {
                        [messages addObject:@"Gender must be filled"];
                    }
                    if (!birthday || !birthmonth || !birthyear) {
                        [messages addObject:@"Date of birth must be filled"];
                    }
                    if (!pass || [pass isEqualToString:@""]) {
                        [messages addObject:@"Password must be filled"];
                    }
                    else
                    {
                        if (passCharCount < 6) {
                            [messages addObject:@"password minimum 6 character"];
                        }
                    }
                    if (!confirmpass || [confirmpass isEqualToString:@""]) {
                        [messages addObject:@"Confirm password must be filled"];
                    }
                    else
                    {
                        if (![pass isEqualToString:confirmpass]) {
                            [messages addObject:@"Password and confirm password not macth"];
                        }
                    }
                    if (!isagree) {
                        [messages addObject:@"You have to agree the Terms & Conditions of Tokopedia."];
                    }
                }
                
                NSLog(@"%@",messages);
                
                NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:messages,@"messages", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                
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
            {
                // go to login
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                // go to terms of service
                break;
            }
            case 12:{
                // button agreement
                if (!btn.selected)
                    btn.selected = YES;
                else btn.selected = NO;
                if (_buttonagreement.selected) {
                    [_datainput setObject:@(YES) forKey:kTKPDACTIVATION_DATAISAGREEKEY];
                }
                else{
                    [_datainput setObject:@(NO) forKey:kTKPDACTIVATION_DATAISAGREEKEY];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)tapsegment:(UISegmentedControl*)sender {
    [_activetextfield resignFirstResponder];
    [_datainput setObject:@(sender.selectedSegmentIndex) forKey:kTKPDREGISTER_APIGENDERKEY];
}

- (IBAction)gesture:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [_activetextfield resignFirstResponder];
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request + Mapping
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Register class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[RegisterResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDREGISTER_APIISACTIVEKEY:kTKPDREGISTER_APIISACTIVEKEY,
                                                        kTKPDREGISTER_APIUIKEY:kTKPDREGISTER_APIUIKEY
                                                        }];
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDREGISTER_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

-(void)LoadDataAction:(id)userinfo
{
    if (_request.isExecuting)return;
    
    _requestcount ++;
    
    [_act startAnimating];
    
    NSDictionary *data = userinfo;
    
	NSDictionary* param = @{kTKPDREGISTER_APIACTIONKEY :kTKPDREGISTER_APIDOREGISTERKEY,
                            kTKPDREGISTER_APIFULLNAMEKEY:[data objectForKey:kTKPDREGISTER_APIFULLNAMEKEY],
                            kTKPDREGISTER_APIEMAILKEY:[data objectForKey:kTKPDREGISTER_APIEMAILKEY],
                            kTKPDREGISTER_APIPHONEKEY:[data objectForKey:kTKPDREGISTER_APIPHONEKEY],
                            kTKPDREGISTER_APIGENDERKEY:[data objectForKey:kTKPDREGISTER_APIGENDERKEY],
                            kTKPDREGISTER_APIBIRTHDAYKEY:[data objectForKey:kTKPDREGISTER_APIBIRTHDAYKEY],
                            kTKPDREGISTER_APIBIRTHMONTHKEY:[data objectForKey:kTKPDREGISTER_APIBIRTHMONTHKEY],
                            kTKPDREGISTER_APIBITHYEARKEY:[data objectForKey:kTKPDREGISTER_APIBITHYEARKEY],
                            kTKPDREGISTER_APIPASSKEY:[data objectForKey:kTKPDREGISTER_APIPASSKEY],
                            kTKPDREGISTER_APICONFIRMPASSKEY:[data objectForKey:kTKPDREGISTER_APICONFIRMPASSKEY]
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDREGISTER_APIPATH parameters:param];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        [self requestfailure:error];
    }];
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSArray *messages = _register.message_error;
    
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    _register = stats;
    BOOL status = [_register.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        _isnodata = NO;
        
        if (!_register.message_error) {
            //TODO:: action when success ->alert->login page
            Alert1ButtonView *v = [Alert1ButtonView newview];
            v.tag = 11;
            v.delegate = self;
            [v show];
        }
        else
        {
            //TODO:: add alert
            NSArray *messages = _register.message_error;
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:messages,@"messages", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
        }
    }
}

-(void)requestfailure:(id)object
{
    [self cancel];
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

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == _textfielddob) {
        // display datepicker
        AlertDatePickerView *v = [AlertDatePickerView newview];
        v.tag = 10;
        v.delegate = self;
        [v show];
        return NO;
    }
    else{
        _activetextfield = textField;
        [textField resignFirstResponder];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    if(textField == _texfieldfullname){
        [_textfieldphonenumber becomeFirstResponder];
        _activetextfield = _textfieldphonenumber;
    }
    else if (textField == _textfieldphonenumber){
        [_textfieldemail becomeFirstResponder];
        _activetextfield = _textfieldemail;
    }
    else if (textField ==_textfieldemail){
        [_textfieldemail resignFirstResponder];
    }
    else if (textField ==_textfieldpassword){
        [_textfieldconfirmpass becomeFirstResponder];
        _activetextfield = _textfieldconfirmpass;
    }
    else if (textField ==_textfieldconfirmpass){
        [_textfieldconfirmpass resignFirstResponder];
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _texfieldfullname) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIFULLNAMEKEY];
    }
    if (textField == _textfieldemail) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIEMAILKEY];
    }
    if (textField == _textfieldphonenumber) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIPHONEKEY];
    }
    if (textField == _textfieldpassword) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIPASSKEY];
    }
    if (textField == _textfieldconfirmpass) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APICONFIRMPASSKEY];
    }
    return YES;
}

#pragma mark - Keyboard Notification
// Called when the UIKeyboardWillShowNotification is sent
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        _scrollviewContentSize = [_container contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_container setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             _scrollviewContentSize = [_container contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if ((self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height)> _keyboardPosition.y) {
                                 UIEdgeInsets inset = _container.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height + 10));
                                 [_container setContentSize:_scrollviewContentSize];
                                 [_container setContentInset:inset];
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
                         _container.contentInset = contentInsets;
                         _container.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Alert View Delegate
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
            [_datainput setObject:@(year) forKey:kTKPDREGISTER_APIBITHYEARKEY];
            [_datainput setObject:@(month) forKey:kTKPDREGISTER_APIBIRTHMONTHKEY];
            [_datainput setObject:@(day) forKey:kTKPDREGISTER_APIBIRTHDAYKEY];
            
            _textfielddob.text = [NSString stringWithFormat:@"%d / %d / %d",day,month,year];
            break;
        }
        case 11:
        {
            // alert success login
            [self.navigationController popViewControllerAnimated:YES];
        }
        default:
            break;
    }
}

-(void)alertViewCancel:(TKPDAlertView *)alertView
{
    switch (alertView.tag) {
        case 11:
        {
            //alert success
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

@end
