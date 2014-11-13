//
//  SettingNotificationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "alert.h"
#import "profile.h"
#import "ProfileSettings.h"
#import "NotificationForm.h"

#import "Alert1ButtonView.h"

#import "SettingNotificationViewController.h"


@interface SettingNotificationViewController (){
    
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
    
    NotificationForm * _form;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
}

@property (weak, nonatomic) IBOutlet UISwitch *switchnewslatter;
@property (weak, nonatomic) IBOutlet UISwitch *switchreview;
@property (weak, nonatomic) IBOutlet UISwitch *switchproduct;
@property (weak, nonatomic) IBOutlet UISwitch *switchpm;
@property (weak, nonatomic) IBOutlet UISwitch *switchpmadmin;

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

@end

@implementation SettingNotificationViewController

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
    
    [self.navigationController.navigationItem setTitle:kTKPDPROFILESETTINGNOTIFICATION_TITLE];
    
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
    [self configureRestKit];
    [self request];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
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
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 11:
                //Done Button
                [self requestAction:_datainput];
                break;
            case 12:
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            default:
                break;
        }
    }
}

- (IBAction)switchaction:(id)sender {
    UISwitch *sw = (UISwitch*)sender;
    switch (sw.tag) {
        case 10:
        {
            //newslatter
            [_datainput setObject:@(_switchnewslatter.on) forKey:kTKPDPROFILESETTING_APIFLAGNEWSLATTERKEY];
            break;
        }
        case 11:
        {
            //review
            [_datainput setObject:@(_switchreview.on) forKey:kTKPDPROFILESETTING_APIFLAGREVIEWKEY];
            break;
        }
        case 12:
        {
            //product discuss
            [_datainput setObject:@(_switchproduct.on) forKey:kTKPDPROFILESETTING_APIFLAGTALKPRODUCTKEY];
            break;
        }
        case 13:
        {
            //message
            [_datainput setObject:@(_switchpm.on) forKey:kTKPDPROFILESETTING_APIFLAGMESSAGEKEY];
            break;
        }
        case 14:
        {
            //admin message
            [_datainput setObject:@(_switchpmadmin.on) forKey:kTKPDPROFILESETTING_APIFLAGADMINMESSAGEKEY];
            break;
        }
        default:
            break;
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[NotificationForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[NotificationFormResult class]];

    RKObjectMapping *notificationMapping = [RKObjectMapping mappingForClass:[NotificationFormNotif class]];
    [notificationMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILESETTING_APIFLAGNEWSLATTERKEY:kTKPDPROFILESETTING_APIFLAGNEWSLATTERKEY,
                                                              kTKPDPROFILESETTING_APIFLAGREVIEWKEY:kTKPDPROFILESETTING_APIFLAGREVIEWKEY,
                                                              kTKPDPROFILESETTING_APIFLAGTALKPRODUCTKEY:kTKPDPROFILESETTING_APIFLAGTALKPRODUCTKEY,
                                                              kTKPDPROFILESETTING_APIFLAGMESSAGEKEY:kTKPDPROFILESETTING_APIFLAGMESSAGEKEY,
                                                              kTKPDPROFILESETTING_APIFLAGADMINMESSAGEKEY:kTKPDPROFILESETTING_APIFLAGADMINMESSAGEKEY
                                                              }];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDPROFILESETTING_APINOTIFICATIONKEY toKeyPath:kTKPDPROFILESETTING_APINOTIFICATIONKEY withMapping:notificationMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

-(void)request
{
    if (_request.isExecuting) return;
    
    [_act startAnimating];
    _barbuttonsave.enabled = NO;
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIGETEMAILNOTIFKEY,
                            kTKPDPROFILE_APIUSERIDKEY : [auth objectForKey:kTKPD_USERIDKEY],
                            };
    _requestcount ++;
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_SETTINGAPIPATH parameters:param];
    
    /* file doesn't exist or hasn't been updated */
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailure:error];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
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
                    [self setDefaultData:_form.result.notification];
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
    [_act startAnimating];
    _act.hidden = NO;
    _barbuttonsave.enabled = NO;
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APISETEMAILNOTIFKEY,
                            kTKPDPROFILESETTING_APIFLAGNEWSLATTERKEY : [data objectForKey:kTKPDPROFILESETTING_APIFLAGNEWSLATTERKEY]?:@(_form.result.notification.flag_newsletter),
                            kTKPDPROFILESETTING_APIFLAGREVIEWKEY : [data objectForKey:kTKPDPROFILESETTING_APIFLAGREVIEWKEY]?:@(_form.result.notification.flag_review),
                            kTKPDPROFILESETTING_APIFLAGTALKPRODUCTKEY :[data objectForKey:kTKPDPROFILESETTING_APIFLAGTALKPRODUCTKEY]?:@(_form.result.notification.flag_talk_product),
                            kTKPDPROFILESETTING_APIFLAGMESSAGEKEY:[data objectForKey:kTKPDPROFILESETTING_APIFLAGMESSAGEKEY]?:@(_form.result.notification.flag_message),
                            kTKPDPROFILESETTING_APIFLAGADMINMESSAGEKEY:[data objectForKey:kTKPDPROFILESETTING_APIFLAGADMINMESSAGEKEY]?:@(_form.result.notification.flag_admin_message)
                            };
    _requestcount ++;
    
    _requestAction = [_objectmanagerAction appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:param];
    
    //[_cachecontroller clearCache];
    /* file doesn't exist or hasn't been updated */
    [_requestAction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessAction:mappingResult withOperation:operation];
        [_act stopAnimating];
        _act.hidden = YES;
        _barbuttonsave.enabled = YES;
        [self.view setUserInteractionEnabled:YES];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureAction:error];
        [_act stopAnimating];
        _act.hidden = YES;
        _barbuttonsave.enabled = YES;
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
                    NSString * message = [[setting.message_error valueForKey:@"description"] componentsJoinedByString:@"\n"];
                    v.data = @{kTKPDALERTVIEW_DATALABELKEY :message};
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
    NotificationFormNotif *notif = object;
    if (notif) {
        _switchnewslatter.on = notif.flag_newsletter;
        _switchpm.on = notif.flag_message;
        _switchproduct.on = notif.flag_talk_product;
        _switchpmadmin.on = notif.flag_admin_message;
        _switchreview.on = notif.flag_review;
    }
}

@end
