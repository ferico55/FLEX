//
//  SettingBankAccountViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "BankAccountForm.h"
#import "BankAccountGetDefaultForm.h"
#import "ProfileSettings.h"
#import "GeneralList1GestureCell.h"
#import "SettingBankDetailViewController.h"
#import "SettingBankEditViewController.h"
#import "SettingBankAccountViewController.h"

#import "MGSwipeButton.h"

#pragma mark - Setting Bank Account View Controller
@interface SettingBankAccountViewController () <UITableViewDataSource, UITableViewDelegate, SettingBankDetailViewControllerDelegate,MGSwipeTableCellDelegate>
{
    BOOL _isnodata;
    
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _ismanualsetdefault;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    NSMutableDictionary *_datainput;
    
    NSMutableArray *_list;
    
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerActionSetDefault;
    __weak RKManagedObjectRequestOperation *_requestActionSetDefault;
    
    __weak RKObjectManager *_objectmanagerActionGetDefaultForm;
    __weak RKManagedObjectRequestOperation *_requestActionGetDefaultForm;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

-(void)cancel;
-(void)configureRestKit;
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
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _list = [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _page = 1;
    _table.delegate = self;
    
    [self configureRestKitActionSetDefault];
    [self configureRestKitActionDelete];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didEditBankAccount:) name:kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY object:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self request];
        }
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if (!_isnodata) {
        
        NSString *cellid = kTKPDGENERALLIST1GESTURECELL_IDENTIFIER;
		
		cell = (GeneralList1GestureCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [GeneralList1GestureCell newcell];
			((GeneralList1GestureCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            BankAccountFormList *list = _list[indexPath.row];
            ((GeneralList1GestureCell*)cell).labelname.text = list.bank_account_name;
            ((GeneralList1GestureCell*)cell).indexpath = indexPath;
            [(GeneralList1GestureCell*)cell viewdetailresetposanimation:YES];
            ((GeneralList1GestureCell*)cell).labelvalue.hidden = YES;
            if (!_ismanualsetdefault)((GeneralList1GestureCell*)cell).labeldefault.hidden = (list.is_default_bank==1)?NO:YES;
            else {
                ((GeneralList1GestureCell*)cell).labeldefault.hidden = YES;
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY];
                if (indexPath.row == indexpath.row) {
                    ((GeneralList1GestureCell*)cell).labeldefault.hidden = NO;
                }
            }
            
        }
        
		return cell;
    } else {
        static NSString *CellIdentifier = kTKPDPROFILE_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDPROFILE_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDPROFILE_NODATACELLDESCS;
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
    BOOL isdefault;
    BankAccountFormList *list = _list[indexPath.row];
    if (_ismanualsetdefault)
        isdefault = (indexPath.row == 0)?YES:NO;
    else
    {
        isdefault = (list.is_default_bank == 1)?YES:NO;
    }

    SettingBankDetailViewController *vc = [SettingBankDetailViewController new];
    vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
                kTKPDPROFILE_DATABANKKEY : _list[indexPath.row],
                kTKPDPROFILE_DATAINDEXPATHKEY : indexPath,
                kTKPDPROFILE_DATAISDEFAULTKEY : @(isdefault)
                };

    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
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
            /** called if need to load next page **/
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [self configureRestKit];
            [self request];
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
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        //add new address
        SettingBankEditViewController *vc = [SettingBankEditViewController new];
        vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
                    kTKPDPROFILE_DATAEDITTYPEKEY : @(TYPE_ADD_EDIT_PROFILE_ADD_NEW),
                    };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Request
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[BankAccountForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[BankAccountFormResult class]];
    
    
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[BankAccountFormList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDPROFILESETTING_APIBANKIDKEY,
                                                    API_BANK_NAME_KEY,
                                                    API_BANK_ACCOUNT_NAME_KEY,
                                                    kTKPDPROFILESETTING_APIBANKACCOUNTNUMBERKEY,
                                                    kTKPDPROFILESETTING_APIBANKBRANCHKEY,
                                                    API_BANK_ACCOUNT_ID_KEY,
                                                    kTKPDPROFILESETTING_APIISDEFAULTBANKKEY
                                                    ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIURINEXTKEY:kTKPD_APIURINEXTKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY toKeyPath:kTKPD_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST  pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
    
}

-(void)request
{
    if (_request.isExecuting) return;
    
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    else{
        _table.tableFooterView = nil;
        [_act stopAnimating];
    }
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIGETUSERBANKACCOUNTKEY,
                            kTKPDPROFILE_APIPAGEKEY : @(_page),
                            kTKPDPROFILE_APILIMITKEY : @(kTKPDPROFILESETTINGBANKACCOUNT_LIMITPAGE),
//                            kTKPD_USERIDKEY : [auth objectForKey:kTKPD_USERIDKEY]
                            };
    _requestcount ++;
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_SETTINGAPIPATH parameters:[param encrypt]];
    NSTimer *timer;
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailure:error];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
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
    BankAccountForm *bankaccount = stat;
    BOOL status = [bankaccount.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
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
                }
            }
        }
        else{
            
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_act stopAnimating];
                    _table.tableFooterView = nil;
                    NSError *error = object;
                    NSString *errorDescription = error.localizedDescription;
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [errorAlert show];
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = nil;
                NSError *error = object;
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

#pragma mark - Request Action Get Default Form
-(void)cancelActionGetDefaultForm
{
    [_requestActionSetDefault cancel];
    _requestActionSetDefault = nil;
    [_objectmanagerActionSetDefault.operationQueue cancelAllOperations];
    _objectmanagerActionSetDefault = nil;
}

-(void)configureRestKitActionGetDefaultForm
{
    _objectmanagerActionGetDefaultForm = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[BankAccountGetDefaultForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[BankAccountGetDefaultFormResult class]];

    RKObjectMapping *defaultBankMapping = [RKObjectMapping mappingForClass:[BankAccountGetDefaultFormDefaultBank class]];
    [defaultBankMapping addAttributeMappingsFromDictionary:@{API_BANK_ACCOUNT_ID_KEY:API_BANK_ACCOUNT_ID_KEY,
                                                             API_BANK_NAME_KEY:API_BANK_NAME_KEY,
                                                             API_BANK_ACCOUNT_NAME_KEY:API_BANK_ACCOUNT_NAME_KEY,
                                                             API_BANK_OWNER_ID_KEY:API_BANK_OWNER_ID_KEY,
                                                             API_TOKEN_KEY:API_TOKEN_KEY
                                                             }];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_DEFAULT_BANK_KEY toKeyPath:API_DEFAULT_BANK_KEY withMapping:defaultBankMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionGetDefaultForm addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionGetDefaultForm:(id)object
{
    if (_requestActionGetDefaultForm.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:ACTION_GET_DEFAULT_BANK_FORM,
                            API_ACCOUNT_ID_KEY : @([[userinfo objectForKey:API_BANK_ACCOUNT_ID_KEY] integerValue])?:@(0),
                            kTKPD_USERIDKEY : [auth objectForKey:kTKPD_USERIDKEY]
                            };
    _requestcount ++;
    
    _requestActionGetDefaultForm = [_objectmanagerActionGetDefaultForm appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_SETTINGAPIPATH parameters:[param encrypt]];
    
    [_requestActionGetDefaultForm setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionGetDefaultForm:mappingResult withOperation:operation];
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionGetDefaultForm:error];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionGetDefaultForm];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionGetDefaultForm) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestTimeoutActionGetDefaultForm
{
    [self cancelActionGetDefaultForm];
}

-(void)requestSuccessActionGetDefaultForm:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    BankAccountGetDefaultForm *defaultBankForm = stat;
    BOOL status = [defaultBankForm.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionGetDefaultForm:object];
    }
}

-(void)requestFailureActionGetDefaultForm:(id)object
{
    [self requestProcessActionGetDefaultForm:object];
}

-(void)requestProcessActionGetDefaultForm:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            BankAccountGetDefaultForm *defaultBankForm = stat;
            BOOL status = [defaultBankForm.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(defaultBankForm.message_error)
                {
                    [self cancelActionGetDefaultForm];
                    NSArray *array = defaultBankForm.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (defaultBankForm.result.default_bank) {
                    [_datainput setObject:defaultBankForm.result.default_bank.bank_owner_id forKey:API_OWNER_ID_KEY];
                    [self configureRestKitActionSetDefault];
                    [self requestActionSetDefault:_datainput];
                }
                else
                {
                    [self cancelSetAsDefault];
                }
            }
        }
        else{
            
            [self cancelActionSetDefault];
            [self cancelSetAsDefault];
            NSError *error = object;
            NSString *errorDescription = error.localizedDescription;
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
            [errorAlert show];
        }
    }
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
    
    [_objectmanagerActionSetDefault addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionSetDefault:(id)object
{
    if (_requestActionSetDefault.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APISETDEFAULTBANKACCOUNTKEY,
                            API_ACCOUNT_ID_KEY : @([[userinfo objectForKey:API_BANK_ACCOUNT_ID_KEY] integerValue])?:@(0),
                            kTKPD_USERIDKEY : [auth objectForKey:kTKPD_USERIDKEY],
                            API_OWNER_ID_KEY : [userinfo objectForKey:API_OWNER_ID_KEY]
                            };
    _requestcount ++;
    
    _requestActionSetDefault = [_objectmanagerActionSetDefault appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:[param encrypt]];
    
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
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionSetDefault) userInfo:nil repeats:NO];
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
            id stat = [result objectForKey:@""];
            ProfileSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    [self cancelSetAsDefault];
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (setting.result.is_success == 1) {
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
                else
                {
                    [self cancelSetAsDefault];
                }
            }
        }
        else{
            
            [self cancelActionSetDefault];
            [self cancelSetAsDefault];
            NSError *error = object;
            NSString *errorDescription = error.localizedDescription;
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
            [errorAlert show];
        }
    }
}

-(void)requestTimeoutActionSetDefault
{
    [self cancelActionSetDefault];
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
    
    [_objectmanagerActionDelete addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionDelete:(id)object
{
    if (_requestActionDelete.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIDELETEBANKKEY,
                            kTKPDPROFILESETTING_APIBANKIDKEY : [userinfo objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY]?:@(0)
                            };
    _requestcount ++;
    
    _requestActionDelete = [_objectmanagerActionDelete appropriateObjectRequestOperationWithObject:self
                                                                                            method:RKRequestMethodPOST
                                                                                              path:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                        parameters:[param encrypt]];
    
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
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionDelete) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
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
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (setting.result.is_success == 1) {
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
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
    [_datainput setObject:@(list.bank_account_id) forKey:API_BANK_ACCOUNT_ID_KEY];
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
-(void)setAsDefaultAtIndexPath:(NSIndexPath*)indexPath
{
    _ismanualsetdefault = YES;
    [_table reloadData];
    BankAccountFormList *bankAccount = _list[indexPath.row];
    [_datainput setObject:@(bankAccount.bank_account_id) forKey:API_BANK_ACCOUNT_ID_KEY];
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
    [_list insertObject:[_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_table reloadData];
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
    [self configureRestKit];
    [self request];
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

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        NSIndexPath *indexPath = ((GeneralList1GestureCell*) cell).indexpath;
        //MGSwipeButton *trash = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"icon_love.png"] backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] callback:^BOOL(MGSwipeTableCell *sender) {
        //    [self deleteListAtIndexPath:indexpath];
        //    return YES;
        //}];
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self deleteListAtIndexPath:indexPath];
            return YES;
        }];
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:@"Set As\nDefault" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //edit
            [self setAsDefaultAtIndexPath:indexPath];
            return YES;
        }];
        return @[trash, flag];
    }
    
    return nil;
    
}


@end
