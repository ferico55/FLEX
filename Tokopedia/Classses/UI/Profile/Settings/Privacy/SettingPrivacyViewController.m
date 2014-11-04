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
#import "SettingPrivacyListViewController.h"

@interface SettingPrivacyViewController ()<SettingPrivacyListViewControllerDelegate>
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
}
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIButton *buttonbirthdate;
@property (weak, nonatomic) IBOutlet UIButton *buttonemail;
@property (weak, nonatomic) IBOutlet UIButton *buttonmesseger;
@property (weak, nonatomic) IBOutlet UIButton *buttonhp;
@property (weak, nonatomic) IBOutlet UIButton *buttonaddress;

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
    
    UIBarButtonItem *barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor blackColor]];
    barbutton1.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    [self configureRestKit];
    [self request];
    [self configureActionRestKit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [self requestAction:_datainput];
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        SettingPrivacyListViewController* vc = [SettingPrivacyListViewController new];
        vc.delegate = self;
        switch (btn.tag) {
            case 10:
            {
                // birthdate
                vc.data = @{kTKPDPROFILESETTING_DATAPRIVACYKEY:[_datainput objectForKey:kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY]?:@(_form.result.privacy.flag_birthdate),
                            kTKPDPROFILESETTING_DATAPRIVACYTYPEKEY:@(btn.tag-10),
                            kTKPDPROFILESETTING_DATAPRIVACYTITILEKEY:kTKPDPROFILESETTING_DATAPRIVACYTITILEARRAYKEY[btn.tag-10]};
                break;
            }
            case 11:
            {
                //email
                vc.data = @{kTKPDPROFILESETTING_DATAPRIVACYKEY:[_datainput objectForKey:kTKPDPROFILESETTING_APIFLAGEMAILKEY]?:@(_form.result.privacy.flag_email),
                            kTKPDPROFILESETTING_DATAPRIVACYTYPEKEY:@(btn.tag-10),
                            kTKPDPROFILESETTING_DATAPRIVACYTITILEKEY:kTKPDPROFILESETTING_DATAPRIVACYTITILEARRAYKEY[btn.tag-10]};
                break;
            }
            case 12:
            {
                //ym
                vc.data = @{kTKPDPROFILESETTING_DATAPRIVACYKEY:[_datainput objectForKey:kTKPDPROFILESETTING_APIFLAGMESSEGERKEY]?:@(_form.result.privacy.flag_messenger),
                            kTKPDPROFILESETTING_DATAPRIVACYTYPEKEY:@(btn.tag-10),
                            kTKPDPROFILESETTING_DATAPRIVACYTITILEKEY:kTKPDPROFILESETTING_DATAPRIVACYTITILEARRAYKEY[btn.tag-10]};
                break;
            }
            case 13:
            {
                //hp
                vc.data = @{kTKPDPROFILESETTING_DATAPRIVACYKEY:[_datainput objectForKey:kTKPDPROFILESETTING_APIFLAGHPKEY]?:@(_form.result.privacy.flag_hp),
                            kTKPDPROFILESETTING_DATAPRIVACYTYPEKEY:@(btn.tag-10),
                            kTKPDPROFILESETTING_DATAPRIVACYTITILEKEY:kTKPDPROFILESETTING_DATAPRIVACYTITILEARRAYKEY[btn.tag-10]};
                break;
            }
            case 14:
            {
                //address
                vc.data = @{kTKPDPROFILESETTING_DATAPRIVACYKEY:[_datainput objectForKey:kTKPDPROFILESETTING_APIFLAGADDRESSKEY]?:@(_form.result.privacy.flag_address),
                          kTKPDPROFILESETTING_DATAPRIVACYTYPEKEY:@(btn.tag-10),
                          kTKPDPROFILESETTING_DATAPRIVACYTITILEKEY:kTKPDPROFILESETTING_DATAPRIVACYTITILEARRAYKEY[btn.tag-10]};
                break;
            }
            default:
                break;
        }
        [self.navigationController pushViewController:vc animated:YES];
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
    
    [self.view setUserInteractionEnabled:NO];
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_SETTINGAPIPATH parameters:param];
    
    /* file doesn't exist or hasn't been updated */
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        [self.view setUserInteractionEnabled:YES];
        //[_act stopAnimating];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailure:error];
        //[_act stopAnimating];
        [self.view setUserInteractionEnabled:YES];
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
    
    [self.view setUserInteractionEnabled:NO];
    //[_act startAnimating];
    
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
        //[_act stopAnimating];
        [self.view setUserInteractionEnabled:YES];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureAction:error];
        //[_act stopAnimating];
        [self.view setUserInteractionEnabled:YES];
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
        if (privacy.flag_hp) {
            [_buttonhp setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[1] forState:UIControlStateNormal];
        }else
        {
            [_buttonhp setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[0] forState:UIControlStateNormal];
        }
        if (privacy.flag_email) {
            [_buttonemail setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[1] forState:UIControlStateNormal];
        }else
        {
            [_buttonemail setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[0] forState:UIControlStateNormal];
        }
        if (privacy.flag_birthdate) {
            [_buttonbirthdate setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[1] forState:UIControlStateNormal];
        }else
        {
            [_buttonbirthdate setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[0] forState:UIControlStateNormal];
        }
        if (privacy.flag_messenger) {
            [_buttonmesseger setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[1] forState:UIControlStateNormal];
        }else
        {
            [_buttonmesseger setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[0] forState:UIControlStateNormal];
        }
        if (privacy.flag_address) {
            [_buttonaddress setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[1] forState:UIControlStateNormal];
        }else
        {
            [_buttonaddress setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[0] forState:UIControlStateNormal];
        }
    }
}

-(void)SettingPrivacyListType:(NSInteger)type withIndex:(NSInteger)index
{
    [((UIButton*)_buttons[type]) setTitle:kTKPDPROFILE_DATAPRIVACYARRAYKEY[index] forState:UIControlStateNormal];
    switch (type) {
        case 0:
        {
            // birthdate
            [_datainput setObject:@(index) forKey:kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY];
            break;
        }
        case 1:
        {
            //email
            [_datainput setObject:@(index) forKey:kTKPDPROFILESETTING_APIFLAGEMAILKEY];
            break;
        }
        case 2:
        {
            //ym
            [_datainput setObject:@(index) forKey:kTKPDPROFILESETTING_APIFLAGMESSEGERKEY];
            break;
        }
        case 3:
        {
            //hp
            [_datainput setObject:@(index) forKey:kTKPDPROFILESETTING_APIFLAGHPKEY];
            break;
        }
        case 4:
        {
            //address
            [_datainput setObject:@(index) forKey:kTKPDPROFILESETTING_APIFLAGADDRESSKEY];
            break;
        }

        default:
            break;
    }
    
}

@end
