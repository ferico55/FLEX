//
//  SettingPrivacyViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "alert.h"
#import "profile.h"
#import "PrivacyForm.h"
#import "ProfileSettings.h"
#import "Alert1ButtonView.h"
#import "SettingPrivacyViewController.h"

@interface SettingPrivacyViewController ()
{
    
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    __weak RKObjectManager *_objectmanagerAction;
    __weak RKManagedObjectRequestOperation *_requestAction;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    UITextField *_activetextfield;
    NSMutableDictionary *_datainput;
    
    PrivacyForm * _form;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
}
@property (weak, nonatomic) IBOutlet UISwitch *switchbirthdate;
@property (weak, nonatomic) IBOutlet UISwitch *switchemail;
@property (weak, nonatomic) IBOutlet UISwitch *switchmesseger;
@property (weak, nonatomic) IBOutlet UISwitch *switchhp;
@property (weak, nonatomic) IBOutlet UISwitch *switchaddress;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailure:(id)object;
-(void)requestProcess:(id)object;
-(void)requestTimeout;

-(void)cancelAction;
-(void)configureActionRestKit;
-(void)requestAction:(id)userinfo;
-(void)requestSuccessAction:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureAction:(id)object;
-(void)requestProcessAction:(id)object;
-(void)requestTimeoutAction;

- (IBAction)tap:(id)sender;

@end

@implementation SettingPrivacyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationItem setTitle:kTKPDPROFILESETTINGPRIVACY_TITLE];
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonsave setTintColor:[UIColor whiteColor]];
    _barbuttonsave.tag = 11;
    _act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barbuttonact = [[UIBarButtonItem alloc] initWithCustomView:_act];
    self.navigationItem.rightBarButtonItems = @[_barbuttonsave,barbuttonact];
    [_act setHidesWhenStopped:YES];
    
    [self configureRestKit];
    [self request];
    [self configureActionRestKit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_white.png"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    backBarButtonItem.tag = 12;
    backBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tapswitch:(id)sender {
    UISwitch *sw = (UISwitch*)sender;
    if (sw == _switchbirthdate) {
        [_datainput setObject:@(sw.on) forKey:kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY];
    }
    if (sw == _switchaddress) {
        [_datainput setObject:@(sw.on) forKey:kTKPDPROFILESETTING_APIFLAGADDRESSKEY];
    }
    if (sw == _switchemail) {
        [_datainput setObject:@(sw.on) forKey:kTKPDPROFILESETTING_APIFLAGEMAILKEY];
    }
    if (sw == _switchhp) {
        [_datainput setObject:@(sw.on) forKey:kTKPDPROFILESETTING_APIFLAGHPKEY];
    }
    if (sw == _switchmesseger) {
        [_datainput setObject:@(sw.on) forKey:kTKPDPROFILESETTING_APIFLAGMESSEGERKEY];
    }
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        if (btn.tag == 12) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self requestAction:_datainput];            
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        
    }
}


#pragma mark - Request + Mapping
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

-(void)configureRestKit
{
    _objectmanager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[PrivacyForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PrivacyFormResult class]];
    
    RKObjectMapping *notificationMapping = [RKObjectMapping mappingForClass:[PrivacyFormPrivacy class]];
    [notificationMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILESETTING_APIFLAGMESSEGERKEY:kTKPDPROFILESETTING_APIFLAGMESSEGERKEY,
                                                              kTKPDPROFILESETTING_APIFLAGHPKEY:kTKPDPROFILESETTING_APIFLAGHPKEY,
                                                              kTKPDPROFILESETTING_APIFLAGEMAILKEY:kTKPDPROFILESETTING_APIFLAGEMAILKEY,
                                                              kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY:kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY,
                                                              kTKPDPROFILESETTING_APIFLAGADDRESSKEY:kTKPDPROFILESETTING_APIFLAGADDRESSKEY
                                                              }];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDPROFILESETTING_APIPRIVACYKEY toKeyPath:kTKPDPROFILESETTING_APIPRIVACYKEY withMapping:notificationMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

-(void)request
{
    if (_request.isExecuting) return;
    
    //[_act startAnimating];
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIGETPRIVACYKEY,
                            kTKPDPROFILE_APIUSERIDKEY : [auth objectForKey:kTKPD_USERIDKEY],
                            };
    _requestcount ++;
    
    _barbuttonsave.enabled = NO;
    [_act startAnimating];
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_SETTINGAPIPATH parameters:param];
    
    /* file doesn't exist or hasn't been updated */
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        _barbuttonsave.enabled = YES;
        [_act stopAnimating];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailure:error];
        _barbuttonsave.enabled = YES;
        [_act stopAnimating];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    _form = stat;
    BOOL status = [_form.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    [self requestProcess:object];
}

-(void)requestProcess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            _form = stat;
            BOOL status = [_form.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (!_form.message_error) {
                    [self setDefaultData:_form.result.privacy];
                }
                else
                {
                    Alert1ButtonView *v = [Alert1ButtonView new];
                    v.tag = 11;
                    v.data = @{kTKPDALERTVIEW_DATALABELKEY :_form.message_error};
                    v.delegate = self;
                    [v show];
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

-(void)requestTimeout
{
    [self cancel];
}

#pragma mark Request Action
-(void)cancelAction
{
    [_requestAction cancel];
    _requestAction = nil;
    [_objectmanagerAction.operationQueue cancelAllOperations];
    _objectmanagerAction = nil;
}

- (void)configureActionRestKit
{
    // initialize AFNetworking HTTPClient + restkit
    //TraktAPIClient *client = [TraktAPIClient sharedClient];
    _objectmanagerAction = [RKObjectManager sharedClient];
    
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILE_APIISSUCCESSKEY:kTKPDPROFILE_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerAction addResponseDescriptor:responseDescriptor];
}

- (void)requestAction:(id)userinfo
{
    if (_requestAction.isExecuting) return;
    
    NSDictionary *data = userinfo;
    
    _barbuttonsave.enabled = NO;
    [_act startAnimating];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APISETPRIVACYKEY,
                            kTKPDPROFILESETTING_APIFLAGMESSEGERKEY : [data objectForKey:kTKPDPROFILESETTING_APIFLAGMESSEGERKEY]?:@(_form.result.privacy.flag_messenger),
                            kTKPDPROFILESETTING_APIFLAGHPKEY : [data objectForKey:kTKPDPROFILESETTING_APIFLAGHPKEY]?:@(_form.result.privacy.flag_hp),
                            kTKPDPROFILESETTING_APIFLAGEMAILKEY :[data objectForKey:kTKPDPROFILESETTING_APIFLAGEMAILKEY]?:@(_form.result.privacy.flag_email),
                            kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY:[data objectForKey:kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY]?:@(_form.result.privacy.flag_birthdate),
                            kTKPDPROFILESETTING_APIFLAGADDRESSKEY:[data objectForKey:kTKPDPROFILESETTING_APIFLAGADDRESSKEY]?:@(_form.result.privacy.flag_address)
                            };
    _requestcount ++;
    
    _requestAction = [_objectmanagerAction appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:param];
    
    //[_cachecontroller clearCache];
    /* file doesn't exist or hasn't been updated */
    [_requestAction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessAction:mappingResult withOperation:operation];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureAction:error];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_requestAction];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessAction:(id)object withOperation:(RKObjectRequestOperation*)operation
{
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
                        Alert1ButtonView *v = [Alert1ButtonView new];
                        v.tag = 10;
                        if (setting.message_status)
                            v.data = @{kTKPDALERTVIEW_DATALABELKEY : setting.message_status};
                        else
                            v.data = @{kTKPDALERTVIEW_DATALABELKEY : @"Success"};
                        v.delegate = self;
                        [v show];
                    }
                }
                else
                {
                    Alert1ButtonView *v = [Alert1ButtonView new];
                    v.tag = 11;
                    v.data = @{kTKPDALERTVIEW_DATALABELKEY :setting.message_error};
                    v.delegate = self;
                    [v show];
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


#pragma mark - Methods
-(void)setDefaultData:(id)object
{
    PrivacyFormPrivacy *privacy = object;
    if (privacy) {
        _switchbirthdate.on = privacy.flag_birthdate;
        _switchaddress.on = privacy.flag_address;
        _switchemail.on = privacy.flag_email;
        _switchmesseger.on = privacy.flag_messenger;
        _switchhp.on = privacy.flag_hp;
    }
}

@end
