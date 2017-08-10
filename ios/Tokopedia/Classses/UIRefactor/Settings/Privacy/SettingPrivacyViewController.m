//
//  SettingPrivacyViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_alert.h"
#import "profile.h"
#import "PrivacyForm.h"
#import "ProfileSettings.h"
#import "SettingPrivacyViewController.h"
#import "SettingPrivacyCell.h"

@interface SettingPrivacyViewController ()<UITableViewDataSource,UITableViewDelegate,SettingPrivacyCellDelegate>
{
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestCount;
    NSInteger _requestActionCount;
    
    NSArray *_listPrivacy;
    NSMutableArray *_listSwitchStatus;
    
    RKObjectManager *_objectManagerAction;
    RKManagedObjectRequestOperation *_requestAction;
    RKObjectManager *_objectManager;
    RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_dataInput;
    
    PrivacyForm * _form;
    
    UIBarButtonItem *_saveBarButtonItem;
}

@property (weak, nonatomic) IBOutlet UISwitch *switchbirthdate;
@property (weak, nonatomic) IBOutlet UISwitch *switchemail;
@property (weak, nonatomic) IBOutlet UISwitch *switchmesseger;
@property (weak, nonatomic) IBOutlet UISwitch *switchhp;
@property (weak, nonatomic) IBOutlet UISwitch *switchaddress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailure:(id)object;
-(void)requestProcess:(id)object;
-(void)requestTimeout:(NSTimer*)timer;

-(void)cancelAction;
-(void)configureActionRestKit;
-(void)requestAction:(id)userinfo;
-(void)requestSuccessAction:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureAction:(id)object;
-(void)requestProcessAction:(id)object;
-(void)requestTimeoutAction:(NSTimer*)timer;

- (IBAction)tap:(id)sender;

@end

@implementation SettingPrivacyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = TITLE_SETTING_PRIVACY;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataInput = [NSMutableDictionary new];
    _listSwitchStatus = [NSMutableArray new];
    
    _operationQueue = [NSOperationQueue new];
    
    [self.navigationController.navigationItem setTitle:kTKPDPROFILESETTINGPRIVACY_TITLE];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kTKPDPROFILESAVE style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_saveBarButtonItem setTintColor:[UIColor blackColor]];
    _saveBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;

    _listPrivacy = ARRAY_LIST_PRIVACY;
    
    [self configureRestKit];
    [self request];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        if (btn.tag == 10) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self configureActionRestKit];
            [self requestAction:_dataInput];
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        
    }
}

#pragma mark - TableView Data Source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger listMenuCount = _listPrivacy.count;
    return listMenuCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell* cell = nil;
    NSString *cellid = kTKPDSETTINGPRIVACYCELL_IDENTIFIER;
    
    cell = (SettingPrivacyCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [SettingPrivacyCell newcell];
        ((SettingPrivacyCell*)cell).delegate = self;
    }
    
    ((SettingPrivacyCell*)cell).indexPath = indexPath;
    ((SettingPrivacyCell*)cell).textCellLabel.text = _listPrivacy[indexPath.row];
    NSInteger listSwitchStatusCount = _listSwitchStatus.count;
    ((SettingPrivacyCell*)cell).settingSwitch.on = (listSwitchStatusCount>0)?[_listSwitchStatus[indexPath.row]boolValue]:NO;
    
    return cell;
}

-(void)SettingPrivacyCell:(SettingPrivacyCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            //tanggal lahir
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY];
            break;
        }
        case 1:
        {
            //email
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGEMAILKEY];
            break;
        }
        case 2:
        {
            //YM
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGMESSEGERKEY];
            break;
        }
        case 3:
        {
            //message
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGHPKEY];
            break;
        }
        case 4:
        {
            //admin message
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGADDRESSKEY];
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
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

-(void)configureRestKit
{
    _objectManager = [RKObjectManager sharedClient];
    
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
    
    [_objectManager addResponseDescriptor:responseDescriptor];
}

-(void)request
{
    if (_request.isExecuting) return;
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIGETPRIVACYKEY,
                            kTKPDPROFILE_APIUSERIDKEY : [auth objectForKey:kTKPD_USERIDKEY],
                            };
    _requestCount ++;
    
    _saveBarButtonItem.enabled = NO;
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_SETTINGAPIPATH parameters:[param encrypt]];
    
    NSTimer *timer;
    __weak typeof(self) weakSelf = self;
    __weak UIBarButtonItem *weakBarButtonItem = _saveBarButtonItem;
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [weakSelf requestSuccess:mappingResult withOperation:operation];
        weakBarButtonItem.enabled = YES;
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [weakSelf requestFailure:error];
        weakBarButtonItem.enabled = YES;
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_request];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
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
                    [_tableView reloadData];
                }
                else
                {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:_form.message_error delegate:self];
                    [alert show];
                }
            }
        }
        else{
            
            [self cancelAction];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
            
        }
    }
}

-(void)requestTimeout:(NSTimer*)timer
{
    [self cancel];
}

#pragma mark Request Action
-(void)cancelAction
{
    [_requestAction cancel];
    _requestAction = nil;
    [_objectManagerAction.operationQueue cancelAllOperations];
    _objectManagerAction = nil;
}

- (void)configureActionRestKit
{
    // initialize AFNetworking HTTPClient + restkit
    //TraktAPIClient *client = [TraktAPIClient sharedClient];
    _objectManagerAction = [RKObjectManager sharedClient];
    
    
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerAction addResponseDescriptor:responseDescriptor];
}

- (void)requestAction:(id)userinfo
{
    if (_requestAction.isExecuting) return;
    
    NSDictionary *data = userinfo;
    

    _saveBarButtonItem.enabled = NO;
    
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APISETPRIVACYKEY,
                            kTKPDPROFILESETTING_APIFLAGMESSEGERKEY : [data objectForKey:kTKPDPROFILESETTING_APIFLAGMESSEGERKEY]?:@(_form.result.privacy.flag_messenger),
                            kTKPDPROFILESETTING_APIFLAGHPKEY : [data objectForKey:kTKPDPROFILESETTING_APIFLAGHPKEY]?:@(_form.result.privacy.flag_hp),
                            kTKPDPROFILESETTING_APIFLAGEMAILKEY :[data objectForKey:kTKPDPROFILESETTING_APIFLAGEMAILKEY]?:@(_form.result.privacy.flag_email),
                            kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY:[data objectForKey:kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY]?:@(_form.result.privacy.flag_birthdate),
                            kTKPDPROFILESETTING_APIFLAGADDRESSKEY:[data objectForKey:kTKPDPROFILESETTING_APIFLAGADDRESSKEY]?:@(_form.result.privacy.flag_address)
                            };
    _requestCount ++;
    
    _requestAction = [_objectManagerAction appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:[param encrypt]];
    NSTimer *timer;
    __weak typeof(self) weakSelf = self;
    __weak UIBarButtonItem *weakBarButtonItem = _saveBarButtonItem;
    [_requestAction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [weakSelf requestSuccessAction:mappingResult withOperation:operation];
        weakBarButtonItem.enabled = YES;
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [weakSelf requestFailureAction:error];
        weakBarButtonItem.enabled = YES;
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestAction];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutAction:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
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


-(void)requestTimeoutAction:(NSTimer*)timer
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
                if ([setting.data.is_success boolValue]) {
                    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:setting.message_status delegate:self];
                    [stickyAlertView show];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:setting.message_error delegate:self];
                    [alert show];
                }
            }
        }
        else{
            
            [self cancelAction];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
            
        }
    }
}


#pragma mark - Methods
-(void)setDefaultData:(id)object
{
    PrivacyFormPrivacy *privacy = object;
    if (privacy) {
        [_listSwitchStatus addObject: @(privacy.flag_birthdate)];
        [_listSwitchStatus addObject: @(privacy.flag_email)];
        [_listSwitchStatus addObject: @(privacy.flag_messenger)];
        [_listSwitchStatus addObject: @(privacy.flag_hp)];
        [_listSwitchStatus addObject: @(privacy.flag_address)];
    }
}

- (void)showSubviews
{
    for (id subview in self.view.subviews) {
        if (![subview isKindOfClass:[UIActivityIndicatorView class]]) {
            [subview setHidden:NO];
        }
    }
}

@end
