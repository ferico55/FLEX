//
//  SettingPasswordViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "alert.h"
#import "profile.h"
#import "ProfileSettings.h"

#import "SettingPasswordViewController.h"

#import "Alert1ButtonView.h"

#pragma mark - Setting Password View Controller
@interface SettingPasswordViewController ()<UITextFieldDelegate>
{
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_requestAction;
    NSOperationQueue *_operationQueue;
    
    UITextField *_activetextfield;
    NSMutableDictionary *_datainput;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
}

@property (weak, nonatomic) IBOutlet UITextField *textfieldOldPass;
@property (weak, nonatomic) IBOutlet UITextField *textfieldNewPass;
@property (weak, nonatomic) IBOutlet UITextField *textfieldConfirmPass;

-(void)cancelAction;
-(void)configureActionRestKit;
-(void)requestAction:(id)userinfo;
-(void)requestSuccessAction:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureAction:(id)object;
-(void)requestProcessAction:(id)object;
-(void)requestTimeoutAction;

- (IBAction)tap:(id)sender;
- (IBAction)gesture:(id)sender;

@end

@implementation SettingPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationItem setTitle:kTKPDPROFILESETTINGPASSWORD_TITLE];
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonsave setTintColor:[UIColor whiteColor]];
    _barbuttonsave.tag = 11;
    _act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barbuttonact = [[UIBarButtonItem alloc] initWithCustomView:_act];
    self.navigationItem.rightBarButtonItems = @[_barbuttonsave,barbuttonact];
    [_act setHidesWhenStopped:YES];
    
    [self configureActionRestKit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 12;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelAction];
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

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 11:
            {
                //submit button
                NSMutableArray *message = [NSMutableArray new];
                NSDictionary *userinfo = _datainput;
                NSString *pass = [_datainput objectForKey:kTKPDPROFILESETTING_APIPASSKEY];
                NSString *newpass = [_datainput objectForKey:kTKPDPROFILESETTING_APINEWPASSKEY];
                NSString *confirmpass = [_datainput objectForKey:kTKPDPROFILESETTING_APIPASSCONFIRMKEY];
                if (pass && newpass && confirmpass) {
                    [self requestAction:userinfo];
                }
                else
                {
                    if (!pass) {
                        [message addObject:@"Kata Sandi Lama harus diisi."];
                    }
                    if (!newpass) {
                        [message addObject:@"Kata Sandi Baru harus diisi."];
                    }
                    if (!confirmpass) {
                        [message addObject:@"Konfirmasi Kata Sandi Baru harus diisi."];
                    }
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:message ,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                    self.navigationItem.rightBarButtonItem = _barbuttonsave;
                    [_barbuttonsave setEnabled:YES];
                }
                break;
            }
            case 12:
            {
                [self.navigationController popViewControllerAnimated:YES];
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
-(void)cancelAction
{
    [_requestAction cancel];
    _requestAction = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureActionRestKit
{
    // initialize AFNetworking HTTPClient + restkit
    //TraktAPIClient *client = [TraktAPIClient sharedClient];
    _objectmanager = [RKObjectManager sharedClient];
    
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILE_APIISSUCCESSKEY:kTKPDPROFILE_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
    
    
}

- (void)requestAction:(id)userinfo
{
    if (_requestAction.isExecuting) return;
    
    NSDictionary *data = userinfo;
    
    [self.view setUserInteractionEnabled:NO];
    [_act startAnimating];
    _barbuttonsave.enabled = NO;
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APISETPASSWORDKEY,
                            kTKPDPROFILESETTING_APIPASSKEY : [data objectForKey:kTKPDPROFILESETTING_APIPASSKEY],
                            kTKPDPROFILESETTING_APINEWPASSKEY : [data objectForKey:kTKPDPROFILESETTING_APINEWPASSKEY],
                            kTKPDPROFILESETTING_APIPASSCONFIRMKEY :[data objectForKey:kTKPDPROFILESETTING_APINEWPASSKEY]
                            };
    _requestcount ++;
    
    _requestAction = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:param];
    
    //[_cachecontroller clearCache];
    /* file doesn't exist or hasn't been updated */
    [_requestAction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessAction:mappingResult withOperation:operation];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
        [self.view setUserInteractionEnabled:YES];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureAction:error];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
        [self.view setUserInteractionEnabled:YES];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_requestAction];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessAction:(id)object withOperation:(RKObjectRequestOperation *)operation{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ProfileSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessAction:object];
    }
}


-(void)requestTimeoutAction
{
    [self cancelAction];
}


-(void)requestFailureAction:(id)object
{
    [self requestProcessAction:object];
}

-(void)requestProcessAction:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ProfileSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (!setting.message_error) {
                    if (setting.result.is_success) {
                        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@[@"Anda telah berhasil mengubah password.",] ,@"messages", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        
                    }
                }
                else
                {
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:setting.message_error ,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                    self.navigationItem.rightBarButtonItem = _barbuttonsave;
                    [_barbuttonsave setEnabled:YES];
                }
            }
        }
        else{
            
            [self cancelAction];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    //[_act startAnimating];
                    //TODO: Reload handler
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

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activetextfield = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([_textfieldOldPass isFirstResponder]){
        
        [_textfieldNewPass becomeFirstResponder];
    }
    else if ([_textfieldNewPass isFirstResponder]){
        
        [_textfieldConfirmPass becomeFirstResponder];
    }
    else if([_textfieldConfirmPass isFirstResponder])
    {
        [_textfieldConfirmPass resignFirstResponder];
    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _textfieldOldPass) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIPASSKEY];
    }
    if (textField == _textfieldNewPass) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APINEWPASSKEY];
    }
    if (textField == _textfieldConfirmPass) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIPASSCONFIRMKEY];
    }
    return YES;
}

@end
