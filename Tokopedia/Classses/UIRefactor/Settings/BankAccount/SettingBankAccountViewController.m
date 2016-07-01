//
//  SettingBankAccountViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "BankAccountGetDefaultForm.h"
#import "ProfileSettings.h"
#import "GeneralList1GestureCell.h"
#import "GeneralCheckmarkCell.h"
#import "LoadingView.h"
#import "SettingBankDetailViewController.h"
#import "SettingBankEditViewController.h"
#import "SettingBankAccountViewController.h"
#import "BankAccountRequest.h"

#import "MGSwipeButton.h"
#define CTagRequest 2

#pragma mark - Setting Bank Account View Controller
@interface SettingBankAccountViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    SettingBankDetailViewControllerDelegate,
    MGSwipeTableCellDelegate,
    LoadingViewDelegate
>
{
    BOOL _isnodata;
    
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _ismanualsetdefault;
    
    LoadingView *loadingView;
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    NSMutableDictionary *_datainput;
    
    NSMutableArray *_list;
    
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *tokopediaNetworkManagerRequest;
    TokopediaNetworkManager *_networkManager;
    
    __weak RKObjectManager *_objectmanagerActionSetDefault;
    __weak RKManagedObjectRequestOperation *_requestActionSetDefault;
    
    __weak RKObjectManager *_objectmanagerActionGetDefaultForm;
    __weak RKManagedObjectRequestOperation *_requestActionGetDefaultForm;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    NSOperationQueue *_operationQueue;
    
    BankAccountRequest *_request;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *addNewRekeningView;

-(void)cancel;
-(void)request;
-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailure:(id)object;
-(void)requestProcess:(id)object;
-(void)requestTimeout:(NSTimer*)timer;

-(void)cancelActionGetDefaultForm;
-(void)configureRestKitActionGetDefaultForm;
-(void)requestActionGetDefaultForm:(id)object;
-(void)requestSuccessActionGetDefaultForm:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionGetDefaultForm:(id)object;
-(void)requestProcessActionGetDefaultForm:(id)object;
-(void)requestTimeoutActionGetDefaultForm;

-(void)cancelActionSetDefault;
-(void)configureRestKitActionSetDefault;
-(void)requestActionSetDefault:(id)object;
-(void)requestSuccessActionSetDefault:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionSetDefault:(id)object;
-(void)requestProcessActionSetDefault:(id)object;
-(void)requestTimeoutActionSetDefault;

-(void)cancelActionDelete;
-(void)configureRestKitActionDelete;
-(void)requestActionDelete:(id)object;
-(void)requestSuccessActionDelete:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionDelete:(id)object;
-(void)requestProcessActionDelete:(id)object;
-(void)requestTimeoutActionDelete;

- (IBAction)tap:(id)sender;

@end

@implementation SettingBankAccountViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _isrefreshview = NO;
        _ismanualsetdefault = NO;
        self.title =TITLE_LIST_BANK;
    }
    return self;
}

#pragma mark - View LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(tap:)];
    addBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    _list = [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _page = 1;
    _table.delegate = self;
    
    [self configureRestKitActionSetDefault];
    [self configureRestKitActionDelete];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didEditBankAccount:) name:kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY object:nil];
    
    if (_delegate == nil) {
        _table.tableHeaderView = _addNewRekeningView;
    }
    
    NSArray *lists = [_data objectForKey:DATA_LIST_BANK_ACOUNT_KEY];
    if (lists.count>0) {
        _isnodata = NO;
        [_list addObjectsFromArray:lists];
    }
    
    _request = [BankAccountRequest new];
    
    if (!_isrefreshview) {
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self getBankAccount];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_delegate !=nil) {
        [_delegate selectedObject:_selectedObject];
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(tokopediaNetworkManagerRequest != nil)
    {
        tokopediaNetworkManagerRequest.delegate = nil;
        [tokopediaNetworkManagerRequest requestCancel];
    }
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    if (_list.count > indexPath.row) {
        if (_delegate ==nil) {
            NSString *cellid = kTKPDGENERALLIST1GESTURECELL_IDENTIFIER;
            
            cell = (GeneralList1GestureCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [GeneralList1GestureCell newcell];
                ((GeneralList1GestureCell*)cell).delegate = self;
            }
            
            BankAccountFormList *list = _list[indexPath.row];
            ((GeneralList1GestureCell*)cell).textLabel.text = list.bank_account_name;
            ((GeneralList1GestureCell*)cell).detailTextLabel.text = list.bank_name;
            //            ((GeneralList1GestureCell*)cell).imageView.image = list.ban
            ((GeneralList1GestureCell*)cell).indexpath = indexPath;
            
            if (indexPath.row == 0) {
                ((GeneralList1GestureCell*)cell).detailTextLabel.text = [NSString stringWithFormat:@"%@ (Utama)", list.bank_name];
                ((GeneralList1GestureCell*)cell).detailTextLabel.textColor = [UIColor redColor];
            } else {
                ((GeneralList1GestureCell*)cell).detailTextLabel.textColor = [UIColor grayColor];
            }
            
        }
        else
        {
            NSString *cellid = GENERAL_CHECKMARK_CELL_IDENTIFIER;
            
            cell = (GeneralCheckmarkCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [GeneralCheckmarkCell newcell];
            }
            
            BankAccountFormList *list = _list[indexPath.row];
            ((GeneralCheckmarkCell*)cell).cellLabel.text = list.bank_account_name;
            ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = !([_selectedObject isEqual:list]);
        }
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_delegate ==nil) {
        BOOL isdefault;
        BankAccountFormList *list = _list[indexPath.row];
        if (_ismanualsetdefault)
            isdefault = (indexPath.row == 0)?YES:NO;
        else
        {
            isdefault = (list.is_default_bank == 1)?YES:NO;
        }
        
        SettingBankDetailViewController *vc = [SettingBankDetailViewController new];
        vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                    kTKPDPROFILE_DATABANKKEY : _list[indexPath.row]?:[BankAccountFormList new],
                    kTKPDPROFILE_DATAINDEXPATHKEY : indexPath,
                    kTKPDPROFILE_DATAISDEFAULTKEY : @(isdefault)
                    };
        
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        _selectedObject = _list[indexPath.row];
        [_table reloadData];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            [self getBankAccount];
        }
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id dataObject = [_list objectAtIndex:sourceIndexPath.row];
    [_list removeObjectAtIndex:sourceIndexPath.row];
    [_list insertObject:dataObject atIndex:destinationIndexPath.row];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 10) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (button.tag == 11) {
            SettingBankEditViewController *vc = [SettingBankEditViewController new];
            vc.data = [NSMutableDictionary dictionaryWithDictionary:@{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                                                      kTKPDPROFILE_DATAEDITTYPEKEY : @(TYPE_ADD_EDIT_PROFILE_ADD_NEW),
                                                                      }];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
}

#pragma mark - Request
-(void)cancel
{
    //    [_request cancel];
    //    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

-(void)request
{
    if ([self getNetworkManager:CTagRequest].getObjectRequest.isExecuting) return;
    
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    else{
        _table.tableFooterView = nil;
        [_act stopAnimating];
    }
    
    [[self getNetworkManager:CTagRequest] doRequest];
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    BankAccountForm *bankaccount = stat;
    BOOL status = [bankaccount.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    
}

-(void)requestProcess:(id)object
{
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        BankAccountForm *bankaccount = stat;
        BOOL status = [bankaccount.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            [_list addObjectsFromArray:bankaccount.result.list];
            if (_list.count >0) {
                _isnodata = NO;
                _urinext =  bankaccount.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:_urinext];
                NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
                
                NSMutableDictionary *queries = [NSMutableDictionary new];
                [queries removeAllObjects];
                for (NSString *keyValuePair in querry)
                {
                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                    NSString *key = [pairComponents objectAtIndex:0];
                    NSString *value = [pairComponents objectAtIndex:1];
                    
                    [queries setObject:value forKey:key];
                }
                
                _page = [[queries objectForKey:kTKPDPROFILE_APIPAGEKEY] integerValue];
                
                _table.tableFooterView = nil;
                
            } else {
                CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
                NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
                self.table.tableFooterView = noResultView;
            }
        }
    }
}

-(void)requestTimeout:(NSTimer*)timer
{
    [self cancel];
}


#pragma mark - Request Set Default
-(void)cancelActionSetDefault
{
    [_requestActionSetDefault cancel];
    _requestActionSetDefault = nil;
    [_objectmanagerActionSetDefault.operationQueue cancelAllOperations];
    _objectmanagerActionSetDefault = nil;
}

-(void)configureRestKitActionSetDefault
{
    _objectmanagerActionSetDefault = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileSettings class]];
    [statusMapping addAttributeMappingsFromArray:@[
                                                   kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY,
                                                   ]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileSettingsResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPDPROFILE_APIISSUCCESSKEY,]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionSetDefault addResponseDescriptor:responseDescriptor];
    
}
-(void)requestActionSetDefault:(id)object
{
    if (_requestActionSetDefault.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIEDITDEFAULTBANKACCOUNTKEY,
                            API_ACCOUNT_ID_KEY  : [userinfo objectForKey:API_BANK_ACCOUNT_ID_KEY]?:@"0",
                            API_OWNER_ID_KEY    : [userinfo objectForKey:API_BANK_OWNER_ID_KEY]?:@"0",
                            };
    
    _requestActionSetDefault = [_objectmanagerActionSetDefault appropriateObjectRequestOperationWithObject:self
                                                                                                    method:RKRequestMethodPOST
                                                                                                      path:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                                parameters:[param encrypt]];
    
    [_requestActionSetDefault setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionSetDefault:mappingResult withOperation:operation];
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionSetDefault:error];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionSetDefault];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                            target:self
                                          selector:@selector(requestTimeoutActionSetDefault)
                                          userInfo:nil
                                           repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionSetDefault:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ProfileSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionSetDefault:object];
    }
}

-(void)requestFailureActionSetDefault:(id)object
{
    [self requestProcessActionSetDefault:object];
}

-(void)requestProcessActionSetDefault:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            ProfileSettings *setting = [result objectForKey:@""];
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    NSArray *errorMessages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                }
                if (setting.result.is_success == 1) {
                    NSArray *successMessages = setting.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                    [alert show];
                    _ismanualsetdefault = NO;
                }
            }
        } else {
            [self cancelActionSetDefault];
            [self cancelSetAsDefault];
            NSError *error = object;
            NSString *errorDescription = error.localizedDescription;
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE
                                                                message:errorDescription
                                                               delegate:self
                                                      cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE
                                                      otherButtonTitles:nil];
            [errorAlert show];
        }
    }
}

-(void)requestTimeoutActionSetDefault
{
    [self cancelActionSetDefault];
}

#pragma mark - Restkit get default form

-(void)configureRestKitActionGetDefaultForm {
    _objectmanagerActionGetDefaultForm = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[BankAccountGetDefaultForm class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[BankAccountGetDefaultFormResult class]];
    
    RKObjectMapping *defaultBankMapping = [RKObjectMapping mappingForClass:[BankAccountGetDefaultFormDefaultBank class]];
    [defaultBankMapping addAttributeMappingsFromArray:@[
                                                        API_BANK_ACCOUNT_ID_KEY,
                                                        API_BANK_NAME_KEY,
                                                        API_BANK_ACCOUNT_NAME_KEY,
                                                        API_BANK_OWNER_ID_KEY,
                                                        API_TOKEN_KEY
                                                        ]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_DEFAULT_BANK_KEY
                                                                                  toKeyPath:API_DEFAULT_BANK_KEY
                                                                                withMapping:defaultBankMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_PEOPLEAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionGetDefaultForm addResponseDescriptor:responseDescriptor];
}

-(void)requestActionGetDefaultForm:(id)object {
    if (_requestActionGetDefaultForm.isExecuting) {
        return;
    }
    
    NSString *bankAccountID = [_datainput objectForKey:API_BANK_ACCOUNT_ID_KEY];
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    
    NSDictionary *parameters = @{
                                 kTKPDPROFILE_APIACTIONKEY  : ACTION_GET_DEFAULT_BANK_ACCOUNT_KEY,
                                 kTKPDPROFILE_APIUSERIDKEY : auth.getUserId,
                                 kTKPDPROFILESETTING_APIACCOUNTIDKEY : bankAccountID?:@"",
                                 };
    
    _requestActionGetDefaultForm = [_objectmanagerActionGetDefaultForm appropriateObjectRequestOperationWithObject:self
                                                                                                            method:RKRequestMethodPOST
                                                                                                              path:kTKPDPROFILE_PEOPLEAPIPATH
                                                                                                        parameters:[parameters encrypt]];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(requestTimeoutActionGetDefaultForm)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    [_requestActionGetDefaultForm setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionGetDefaultForm:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionGetDefaultForm:error];
    }];
    
    [_operationQueue addOperation:_requestActionGetDefaultForm];
}

-(void)requestSuccessActionGetDefaultForm:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    BankAccountGetDefaultForm *setting = [result objectForKey:@""];
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self requestProcessActionGetDefaultForm:object];
    }
}

-(void)requestFailureActionGetDefaultForm:(id)object {
    [self requestProcessActionGetDefaultForm:object];
}

-(void)requestProcessActionGetDefaultForm:(id)object {
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            BankAccountGetDefaultForm *defaultForm = [result objectForKey:@""];
            BOOL status = [defaultForm.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            if (status) {
                [_datainput setObject:defaultForm.result.default_bank.bank_owner_id forKey:API_BANK_OWNER_ID_KEY];
                [self configureRestKitActionSetDefault];
                [self requestActionSetDefault:_datainput];
            }
        } else {
            [self cancelActionGetDefaultForm];
        }
    }
}

-(void)cancelActionGetDefaultForm {
    [_requestActionGetDefaultForm cancel];
    _requestActionGetDefaultForm = nil;
    
    [_objectmanagerActionGetDefaultForm.operationQueue cancelAllOperations];
    _objectmanagerActionGetDefaultForm = nil;
}

-(void)requestTimeoutActionGetDefaultForm {
    [self cancelActionGetDefaultForm];
}

#pragma mark Request Action Delete

-(void)cancelActionDelete
{
    [_requestActionDelete cancel];
    _requestActionDelete = nil;
    [_objectmanagerActionDelete.operationQueue cancelAllOperations];
    _objectmanagerActionDelete = nil;
}

-(void)configureRestKitActionDelete
{
    _objectmanagerActionDelete = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileSettings class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY]];
    
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
    
    [_objectmanagerActionDelete addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionDelete:(id)object
{
    if (_requestActionDelete.isExecuting) return;
    
    BankAccountFormList *bankAccount = [_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY];
    
    NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIDELETEBANKKEY,
                            kTKPDPROFILESETTING_APIACCOUNTIDKEY : bankAccount.bank_account_id?:@(0)
                            };
    _requestcount ++;
    
    _requestActionDelete = [_objectmanagerActionDelete appropriateObjectRequestOperationWithObject:self
                                                                                            method:RKRequestMethodPOST
                                                                                              path:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                        parameters:[param encrypt]];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(requestTimeoutActionDelete)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    [_requestActionDelete setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionDelete:mappingResult withOperation:operation];
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionDelete:error];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionDelete];
}

-(void)requestSuccessActionDelete:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ProfileSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionDelete:object];
    }
}

-(void)requestFailureActionDelete:(id)object
{
    [self requestProcessActionDelete:object];
}

-(void)requestProcessActionDelete:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ProfileSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    [self cancelDeleteRow];
                    
                    NSArray *errorMessages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                }
                if (setting.result.is_success == 1) {
                    NSArray *successMessages = setting.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages
                                                                                     delegate:self];
                    [alert show];
                }
                else
                {
                    [self cancelDeleteRow];
                }
            }
        }
        else{
            
            [self cancelActionDelete];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    //TODO:: Reload handler
                }
                else
                {
                    [_act stopAnimating];
                    _table.tableFooterView = nil;
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = nil;
            }
            
        }
    }
}

-(void)requestTimeoutActionDelete
{
    [self cancelActionDelete];
}

#pragma mark - delegate bank account detail
-(void)DidTapButton:(UIButton *)button withdata:(NSDictionary *)data
{
    BankAccountFormList *list = [data objectForKey:kTKPDPROFILE_DATABANKKEY];
    [_datainput setObject:list.bank_account_id forKey:API_BANK_ACCOUNT_ID_KEY];
    NSIndexPath *indexpath = [data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    switch (button.tag) {
        case 10:
        {
            //set as default
            //NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:0 inSection:indexpath.section];
            [self setAsDefaultAtIndexPath:indexpath];
            break;
        }
        case 11:
        {
            //delete
            [self deleteListAtIndexPath:indexpath];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
- (LoadingView *)getLoadView:(int)tag
{
    if (loadingView == nil) {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag
{
    if(tag == CTagRequest)
    {
        if(tokopediaNetworkManagerRequest == nil)
        {
            tokopediaNetworkManagerRequest = [TokopediaNetworkManager new];
            tokopediaNetworkManagerRequest.delegate = self;
            tokopediaNetworkManagerRequest.tagRequest = CTagRequest;
        }
        
        return tokopediaNetworkManagerRequest;
    }
    
    return nil;
}

-(void)setAsDefaultAtIndexPath:(NSIndexPath*)indexPath
{
    _ismanualsetdefault = YES;
    
    BankAccountFormList *bankAccount = _list[indexPath.row];
    [_datainput setObject:bankAccount.bank_account_id forKey:API_BANK_ACCOUNT_ID_KEY];
    
    [self configureRestKitActionGetDefaultForm];
    [self requestActionGetDefaultForm:_datainput];
    
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
    [self tableView:_table moveRowAtIndexPath:indexPath toIndexPath:indexPath1];
    
    [_datainput setObject:indexPath forKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
    
    [_table reloadData];
}

-(void)cancelSetAsDefault
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
    NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:0 inSection:indexpath.section];
    [self tableView:_table moveRowAtIndexPath:indexpath1 toIndexPath:indexpath];
}

-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath
{
    [_datainput setObject:_list[indexpath.row] forKey:kTKPDPROFILE_DATADELETEDOBJECTKEY];
    [_list removeObjectAtIndex:indexpath.row];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    [self configureRestKitActionDelete];
    [self requestActionDelete:_datainput];
    [_datainput setObject:indexpath forKey:kTKPDPROFILE_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDELETEKEY];
    BankAccountFormList *deletedData = [_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY];
    if (![_list containsObject:deletedData]) {
        [_list insertObject:[_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
        [_table reloadData];
    }
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    [_list removeAllObjects];
    _page = 1;
    _requestcount = 0;
    //_isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self getBankAccount];
}

#pragma mark - Requests

- (void)getBankAccount {
    __weak typeof(self) weakSelf = self;
    [_request requestGetBankAccountOnSuccess:^(BankAccountFormResult *result) {
        [weakSelf loadBankAccountData:result];
        
        [_act stopAnimating];
        _table.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
    }
    onFailure:^(NSError *error) {
        [_act stopAnimating];
        _table.tableFooterView = [self getLoadView:CTagRequest].view;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        _table.tableFooterView = loadingView.view;
    }];
}

- (void)loadBankAccountData:(BankAccountFormResult *)account {
    [_list addObjectsFromArray:account.list];
    
    if (_list.count > 0) {
        _isnodata = NO;
        _urinext =  account.paging.uri_next;
        NSURL *url = [NSURL URLWithString:_urinext];
        NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
        
        NSMutableDictionary *queries = [NSMutableDictionary new];
        [queries removeAllObjects];
        for (NSString *keyValuePair in querry)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            
            [queries setObject:value forKey:key];
        }
        
        _page = [[queries objectForKey:kTKPDPROFILE_APIPAGEKEY] integerValue];
        
        _table.tableFooterView = nil;
        
    } else {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
        NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
        self.table.tableFooterView = noResultView;
    }
}

- (void)requestSetDefaultBankAccountAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    
    BankAccountFormList *bankAccount = _list[indexPath.row];
    [_datainput setObject:bankAccount.bank_account_id forKey:API_BANK_ACCOUNT_ID_KEY];
    
    [_request requestSetDefaultBankAccountWithAccountID:[_datainput objectForKey:API_BANK_ACCOUNT_ID_KEY]
                                              onSuccess:^(ProfileSettings *result) {
                                                  [weakSelf displayMessages:result];
                                                  _isrefreshview = NO;
                                                  [_refreshControl endRefreshing];
                                                  
                                                  NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                                                  [self tableView:_table moveRowAtIndexPath:indexPath toIndexPath:indexPath1];
                                                  
                                                  [_datainput setObject:indexPath forKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
                                                  
                                                  [_table reloadData];
                                              }
                                              onFailure:^(NSError *error) {
                                                  
                                                  
                                              }];
}

- (void)displayMessages:(ProfileSettings *)settings {
    if ([settings.status isEqualToString:@"OK"]) {
        if(settings.message_error) {
            NSArray *errorMessages = settings.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
        
        if (settings.data.is_success == 1) {
            NSArray *successMessages = settings.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
            [alert show];
            _ismanualsetdefault = NO;
        }
    }
}

#pragma mark - Notification
- (void)didEditBankAccount:(NSNotification*)notification
{
    [self refreshView:nil];
}

#pragma mark - Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        NSIndexPath *indexPath = ((GeneralList1GestureCell*) cell).indexpath;
        
        __weak typeof(self) weakSelf = self;
        
        UIColor *redColor = [UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0];
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Hapus"
                                               backgroundColor:redColor
                                                       padding:padding
                                                      callback:^BOOL(MGSwipeTableCell *sender) {
                                                          [weakSelf deleteListAtIndexPath:indexPath];
                                                          return YES;
                                                      }];
        trash.titleLabel.font = [UIFont fontWithName:trash.titleLabel.font.fontName size:12];
        
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:@"Jadikan\nUtama"
                                              backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0]
                                                      padding:padding
                                                     callback:^BOOL(MGSwipeTableCell *sender) {
                                                         //edit
                                                         [weakSelf requestSetDefaultBankAccountAtIndexPath:indexPath];
                                                         return YES;
                                                     }];
        flag.titleLabel.font = [UIFont fontWithName:flag.titleLabel.font.fontName size:12];
        
        return @[trash, flag];
    }
    
    return nil;
    
}

#pragma mark - Loading View Delegate
- (void)pressRetryButton {
    _table.tableFooterView = _footer;
    [_act startAnimating];
    [self getBankAccount];
}
@end
