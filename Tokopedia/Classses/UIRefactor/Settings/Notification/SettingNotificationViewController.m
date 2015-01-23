//
//  SettingNotificationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_alert.h"
#import "profile.h"
#import "ProfileSettings.h"
#import "NotificationForm.h"

#import "Alert1ButtonView.h"

#import "SettingNotificationViewController.h"
#import "SettingNotificationCell.h"

@interface SettingNotificationViewController ()<SettingNotificationCellDelegate>{
    
    BOOL _isnodata;
    
    NSArray *_listMenu;
    NSArray *_listDescription;
    NSMutableArray *_listSwitchStatus;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestCount;
    NSInteger _requestCountAction;
    
    __weak RKObjectManager *_objectManagerAction;
    __weak RKManagedObjectRequestOperation *_requestAction;
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_dataInput;
    
    NotificationForm * _form;
    
    UIBarButtonItem *_saveBarButtonItem;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
        self.title = TITLE_SETTING_NOTIFICATION;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _listSwitchStatus = [NSMutableArray new];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_saveBarButtonItem setTintColor:[UIColor blackColor]];
    _saveBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;

    
    [self configureActionRestKit];
    [self configureRestKit];
    [self request];
    
    _listMenu = ARRAY_LIST_NOTIFICATION;
    _listDescription = ARRAY_LIST_NOTIFICATION_DESCRIPTION;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _scrollView.contentSize = _viewContent.frame.size;
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
                [self requestAction:_dataInput];
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

#pragma mark - TableView Data Source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger listMenuCount = _listMenu.count;
    return listMenuCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell* cell = nil;
    NSString *cellid = kTKPDSETTINGNOTIFICATIONCELL_IDENTIFIER;
    
    cell = (SettingNotificationCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [SettingNotificationCell newcell];
        ((SettingNotificationCell*)cell).delegate = self;
    }

    ((SettingNotificationCell*)cell).indexPath = indexPath;
    ((SettingNotificationCell*)cell).notificationName.text = _listMenu[indexPath.row];
    ((SettingNotificationCell*)cell).notificationDetail.text = _listDescription[indexPath.row];
    NSInteger listSwitchStatusCount = _listSwitchStatus.count;
    ((SettingNotificationCell*)cell).settingSwitch.on = (listSwitchStatusCount>0)?[_listSwitchStatus[indexPath.row]boolValue]:NO;
    
    return cell;
}

-(void)SettingNotificationCell:(SettingNotificationCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            //newslatter
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGNEWSLATTERKEY];
            break;
        }
        case 1:
        {
            //review
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGREVIEWKEY];
            break;
        }
        case 2:
        {
            //product discuss
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGTALKPRODUCTKEY];
            break;
        }
        case 3:
        {
            //message
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGMESSAGEKEY];
            break;
        }
        case 4:
        {
            //admin message
            [_dataInput setObject:@(cell.settingSwitch.on) forKey:kTKPDPROFILESETTING_APIFLAGADMINMESSAGEKEY];
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
}

-(void)request
{
    if (_request.isExecuting) return;
    
    _saveBarButtonItem.enabled = NO;
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIGETEMAILNOTIFKEY,
                            kTKPDPROFILE_APIUSERIDKEY : [auth objectForKey:kTKPD_USERIDKEY],
                            };
    _requestCount ++;
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_SETTINGAPIPATH parameters:[param encrypt]];
    
    NSTimer *timer;
    /* file doesn't exist or hasn't been updated */
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        _saveBarButtonItem.enabled = YES;
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailure:error];
        _saveBarButtonItem.enabled = YES;
        [self.view setUserInteractionEnabled:YES];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_request];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
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
                    [self setDefaultData:_form.result.notification];
                    [_tableView reloadData];
                }
                else
                {
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:_form.message_error ,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;
                    [_saveBarButtonItem setEnabled:YES];
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

-(void)requestTimeout
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
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APISETEMAILNOTIFKEY,
                            kTKPDPROFILESETTING_APIFLAGNEWSLATTERKEY : [data objectForKey:kTKPDPROFILESETTING_APIFLAGNEWSLATTERKEY]?:@(_form.result.notification.flag_newsletter),
                            kTKPDPROFILESETTING_APIFLAGREVIEWKEY : [data objectForKey:kTKPDPROFILESETTING_APIFLAGREVIEWKEY]?:@(_form.result.notification.flag_review),
                            kTKPDPROFILESETTING_APIFLAGTALKPRODUCTKEY :[data objectForKey:kTKPDPROFILESETTING_APIFLAGTALKPRODUCTKEY]?:@(_form.result.notification.flag_talk_product),
                            kTKPDPROFILESETTING_APIFLAGMESSAGEKEY:[data objectForKey:kTKPDPROFILESETTING_APIFLAGMESSAGEKEY]?:@(_form.result.notification.flag_message),
                            kTKPDPROFILESETTING_APIFLAGADMINMESSAGEKEY:[data objectForKey:kTKPDPROFILESETTING_APIFLAGADMINMESSAGEKEY]?:@(_form.result.notification.flag_admin_message)
                            };
    _requestCountAction ++;
    
    _requestAction = [_objectManagerAction appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:[param encrypt]];
    NSTimer *timer;
    //[_cachecontroller clearCache];
    /* file doesn't exist or hasn't been updated */
    [_requestAction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessAction:mappingResult withOperation:operation];
        _saveBarButtonItem.enabled = YES;
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureAction:error];
        _saveBarButtonItem.enabled = YES;
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestAction];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutAction) userInfo:nil repeats:NO];
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
                if (setting.result.is_success == 1) {
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:setting.message_status ,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:setting.message_error ,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;
                    [_saveBarButtonItem setEnabled:YES];
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
    NotificationFormNotif *notif = object;
    if (notif) {
        [_listSwitchStatus addObject:@(notif.flag_newsletter)];
        [_listSwitchStatus addObject:@(notif.flag_review)];
        [_listSwitchStatus addObject:@(notif.flag_talk_product)];
        [_listSwitchStatus addObject:@(notif.flag_message)];
        [_listSwitchStatus addObject:@(notif.flag_admin_message)];

    }
}

@end
