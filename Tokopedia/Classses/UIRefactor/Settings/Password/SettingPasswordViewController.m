//
//  SettingPasswordViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_alert.h"
#import "profile.h"
#import "ProfileSettings.h"

#import "SettingPasswordViewController.h"
#import "TokopediaNetworkManager.h"
#import "UserAuthentificationManager.h"

#pragma mark - Setting Password View Controller
@interface SettingPasswordViewController () <UITextFieldDelegate, TokopediaNetworkManagerDelegate>
{
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSOperationQueue *_operationQueue;
    NSDictionary *tempData;
    
    UITextField *_activetextfield;
    NSMutableDictionary *_datainput;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
}

@property (weak, nonatomic) IBOutlet UITextField *textfieldOldPass;
@property (weak, nonatomic) IBOutlet UITextField *textfieldNewPass;
@property (weak, nonatomic) IBOutlet UITextField *textfieldConfirmPass;

-(void)cancelAction;
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
    self.title = kTKPDPROFILESETTINGPASSWORD_TITLE;
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                      style:UIBarButtonItemStyleDone
                                                     target:(self)
                                                     action:@selector(tap:)];
    _barbuttonsave.tag = 11;

    _act = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_act setHidesWhenStopped:YES];
    
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
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
                NSMutableArray *errorMessages = [NSMutableArray new];
                NSDictionary *userinfo = _datainput;
                NSString *pass = [_datainput objectForKey:kTKPDPROFILESETTING_APIPASSKEY];
                NSString *newpass = [_datainput objectForKey:kTKPDPROFILESETTING_APINEWPASSKEY];
                NSString *confirmpass = [_datainput objectForKey:kTKPDPROFILESETTING_APIPASSCONFIRMKEY];
                if (pass && newpass && confirmpass) {
                    [self requestAction:userinfo];
                }
                else
                {
                    if (!pass || [pass isEqualToString:@""]) {
                        [errorMessages addObject:@"Kata Sandi Lama harus diisi."];
                    }
                    if (!newpass || [newpass isEqualToString:@""]) {
                        [errorMessages addObject:@"Kata Sandi Baru harus diisi."];
                    }
                    if (!confirmpass || [confirmpass isEqualToString:@""]) {
                        [errorMessages addObject:@"Konfirmasi Kata Sandi Baru harus diisi."];
                    }
                    
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                    
                    _barbuttonsave.enabled = YES;
                    self.navigationItem.rightBarButtonItem = _barbuttonsave;
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
//    [_requestAction cancel];
//    _requestAction = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}


- (void)requestAction:(id)userinfo
{
    if ([self getNetworkManager].getObjectRequest.isExecuting) return;
    

    tempData = userinfo;
    
    [_act startAnimating];
    _barbuttonsave.enabled = NO;
    
    UIBarButtonItem *barButtonLoading = [[UIBarButtonItem alloc] initWithCustomView:_act];
    self.navigationItem.rightBarButtonItem = barButtonLoading;
    
    [tokopediaNetworkManager doRequest];
}

-(void)requestSuccessAction:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation{
    ProfileSettings *setting = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self requestProcessAction:mappingResult];
    }
}


-(void)requestTimeoutAction
{
    [self cancelAction];
}

-(void)requestFailureAction:(id)object
{
    [self cancelAction];
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
        } else {
            [_act stopAnimating];
            self.navigationItem.rightBarButtonItem = _barbuttonsave;
        }
    } else {
        [_act stopAnimating];
        self.navigationItem.rightBarButtonItem = _barbuttonsave;
    }
}

-(void)requestProcessAction:(RKMappingResult *)mappingResult
{
    _barbuttonsave.enabled = YES;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;

    if (mappingResult) {
        ProfileSettings *setting = [mappingResult.dictionary objectForKey:@""];
        BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        if (status) {
            if (setting.message_status) {
                if (setting.result.is_success == 1) {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:setting.message_status
                                                                                     delegate:self];
                    [alert show];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Ubah kata sandi gagal."]
                                                                                   delegate:self];
                    [alert show];
                }
            } else if (setting.message_error) {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:setting.message_error
                                                                               delegate:self];
                [alert show];
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
    } else if (textField == _textfieldNewPass) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APINEWPASSKEY];
    } else if (textField == _textfieldConfirmPass) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIPASSCONFIRMKEY];
    }
    return YES;
}


#pragma mark - Method
- (TokopediaNetworkManager *)getNetworkManager
{
    if(tokopediaNetworkManager == nil)
    {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    
    return tokopediaNetworkManager;
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    NSDictionary *data = [tempData mutableCopy];
    tempData = nil;
    return @{
             kTKPDPROFILE_APIACTIONKEY               : kTKPDPROFILE_APIEDITPASSWORDKEY,
             kTKPDPROFILESETTING_APIPASSKEY          : [data objectForKey:kTKPDPROFILESETTING_APIPASSKEY],
             kTKPDPROFILESETTING_APINEWPASSKEY       : [data objectForKey:kTKPDPROFILESETTING_APINEWPASSKEY],
             kTKPDPROFILESETTING_APIPASSCONFIRMKEY   : [data objectForKey:kTKPDPROFILESETTING_APINEWPASSKEY],
             };
}

- (NSString*)getPath:(int)tag
{
    return kTKPDPROFILE_PROFILESETTINGAPIPATH;
}

- (id)getObjectManager:(int)tag
{
    _objectmanager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileSettings class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY,
                                                   ]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileSettingsResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPDPROFILE_APIISSUCCESSKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
    
    return _objectmanager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    return ((ProfileSettings *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    [self requestSuccessAction:successResult withOperation:operation];
    [_act stopAnimating];
    _barbuttonsave.enabled = YES;
    [self.view setUserInteractionEnabled:YES];
    [_timer invalidate];
    _timer = nil;
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    /** failure **/
    [self requestFailureAction:errorResult];
    [_act stopAnimating];
    _barbuttonsave.enabled = YES;
    [self.view setUserInteractionEnabled:YES];
    [_timer invalidate];
    _timer = nil;
}

- (void)actionBeforeRequest:(int)tag
{
}

- (void)actionRequestAsync:(int)tag
{
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
}
@end
