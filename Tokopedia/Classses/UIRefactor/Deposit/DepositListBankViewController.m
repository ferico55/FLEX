//
//  DepositListBankViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "BankAccountForm.h"
#import "BankAccountGetDefaultForm.h"
#import "ProfileSettings.h"
#import "DepositListBankCell.h"
#import "SettingBankDetailViewController.h"
#import "SettingBankEditViewController.h"
#import "DepositListBankViewController.h"
#import "DepositFormAccountBankViewController.h"
#import "URLCacheController.h"
#import "URLCacheConnection.h"
#import "DepositForm.h"


#pragma mark - Setting Bank Account View Controller
@interface DepositListBankViewController () <UITableViewDataSource, UITableViewDelegate>
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
    NSIndexPath *_selectedIndexPath;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIButton *addAccountButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailure:(id)object;
-(void)requestTimeout:(NSTimer*)timer;


- (IBAction)tap:(id)sender;

@end

@implementation DepositListBankViewController

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

- (void)initCache {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"bank-account"];
    

    _cachepath = [path stringByAppendingPathComponent:@"mybank-account"];
    
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
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
    
    
    UIBarButtonItem *barbutton1;
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    [barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _list = [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _selectedIndexPath = [_data objectForKey:@"account_indexpath"];
    
//    [self initCache];
//    [self configureRestKit];
//    [self loadDataFromCache];
    [self requestProcess:_listBankAccount withOperation:nil];
    _page = 1;
    _table.delegate = self;
    _table.dataSource = self;
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_isrefreshview) {
//        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
//            [self loadData];
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
        
        NSString *cellid = @"DepostiListBankCellIdentifier";
        
        cell = (DepositListBankCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [DepositListBankCell newcell];

        }
        
        if (_list.count > indexPath.row) {
            BankAccountFormList *list = _list[indexPath.row];
            
            if(_selectedIndexPath.row == indexPath.row) {
                ((DepositListBankCell*)cell).isChecked.hidden = NO;
            } else {
                ((DepositListBankCell*)cell).isChecked.hidden = YES;
            }
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 4.0;
            
            NSMutableDictionary *attribute = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                             NSParagraphStyleAttributeName  : style,
                                                                                             }];
            NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ a/n %@ - %@", list.bank_account_number, list.bank_account_name, list.bank_name
                                                                                              ] attributes:attribute];
            [((DepositListBankCell*)cell).labelname setAttributedText:attributedString];
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

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    [_table reloadData];
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
//            [self configureRestKit];
//            [self loadData];
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
        UIBarButtonItem *barbtn = (UIBarButtonItem *)sender;
        switch (barbtn.tag) {
            case 10: {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
            case 11: {
                if (_list.count == 0) {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Silakan menambahkan akun bank untuk melakukan penarikan dana."] delegate:self];
                    [alert show];
                    break;
                }
                
                NSIndexPath *indexpath = _selectedIndexPath;
                DepositFormBankAccountList *list = _list[indexpath.row];
                NSString *bankName = [NSString stringWithFormat:@"%@ a/n %@ - %@", list.bank_account_number, list.bank_account_name, list.bank_name];
                
                NSDictionary *userinfo;
                userinfo = @{
                             @"indexpath" : indexpath,
                             @"bank_account_name" : bankName,
                             @"bank_account_id" : list.bank_account_id,
                             @"is_verified_account" : @(list.is_verified_account)?:0
                             };
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSelectedDepositBank" object:nil userInfo:userinfo];
                [self.navigationController popViewControllerAnimated:YES];
                break;

                break;
            }
                
            
            default:
                break;
        }

    }
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case 12 : {
                if (_listBankAccount.count >= 10) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mohon maaf, maksimal 10 rekening bank yang dapat Anda masukkan.\nSilakan hapus terlebih dahulu rekening bank yang sudah tidak digunakan." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
                DepositFormAccountBankViewController *formAddAccount = [DepositFormAccountBankViewController new];
                [self.navigationController pushViewController:formAddAccount animated:YES];
                break;
            }
            default:
                break;
        }
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
                                                 kTKPDPROFILESETTING_APIISDEFAULTBANKKEY,
                                                 kTKPDPROFILESETTING_APIISVERIFIEDBANKKEY
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIURINEXTKEY:kTKPD_APIURINEXTKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY toKeyPath:kTKPD_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
    
}

- (void)loadDataFromCache {
    [_cachecontroller getFileModificationDate];
    _timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
    
    NSError* error;
    NSData *data = [NSData dataWithContentsOfFile:_cachepath];
    
    if(data.length) {
        id parsedData = [RKMIMETypeSerialization objectFromData:data
                                                       MIMEType:RKMIMETypeJSON
                                                          error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            [self requestProcess:mappingresult withOperation:nil];
        }
    }
}

-(void)loadData
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
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIGETUSERBANKACCOUNTKEY,
                            kTKPDPROFILE_APIPAGEKEY : @(_page),
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
        [self requestProcess:object withOperation:operation];
    }
}

-(void)requestFailure:(id)object
{
//    [self requestProcess:object];
}

-(void)requestProcess:(id)object  withOperation:(RKObjectRequestOperation *)operation
{
    if (object) {
//        if ([object isKindOfClass:[RKMappingResult class]]) {
//            NSDictionary *result = ((RKMappingResult*)object).dictionary;
//            id stat = [result objectForKey:@""];
//            BankAccountForm *bankaccount = stat;
//            BOOL status = [bankaccount.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
//            if (status) {
                [_list addObjectsFromArray:object];
                
//                if(operation) {
//                    [_cacheconnection connection:operation.HTTPRequestOperation.request
//                              didReceiveResponse:operation.HTTPRequestOperation.response];
//                    [_cachecontroller connectionDidFinish:_cacheconnection];
//                    
//                    [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
//                }
                
                
                if (_list.count >0) {
                    _isnodata = NO;
//                    _urinext =  bankaccount.result.paging.uri_next;
//                    NSURL *url = [NSURL URLWithString:_urinext];
//                    NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
//                    
//                    NSMutableDictionary *queries = [NSMutableDictionary new];
//                    [queries removeAllObjects];
//                    for (NSString *keyValuePair in querry)
//                    {
//                        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//                        NSString *key = [pairComponents objectAtIndex:0];
//                        NSString *value = [pairComponents objectAtIndex:1];
//                        
//                        [queries setObject:value forKey:key];
//                    }
//                    
//                    _page = [[queries objectForKey:kTKPDPROFILE_APIPAGEKEY] integerValue];
//                }
            }
////        }
//        else{
//            
//            [self cancel];
//            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
//            if ([(NSError*)object code] == NSURLErrorCancelled) {
//                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
//                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
//                    _table.tableFooterView = _footer;
//                    [_act startAnimating];
//                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
//                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
//                }
//                else
//                {
//                    [_act stopAnimating];
//                    _table.tableFooterView = nil;
//                    NSError *error = object;
//                    NSString *errorDescription = error.localizedDescription;
//                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
//                    [errorAlert show];
//                }
//            }
//            else
//            {
//                [_act stopAnimating];
//                _table.tableFooterView = nil;
//                NSError *error = object;
//                NSString *errorDescription = error.localizedDescription;
//                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
//                [errorAlert show];
//            }
//            
//        }
    }
}

-(void)requestTimeout:(NSTimer*)timer
{
    [self cancel];
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
    [self loadData];
}


@end
