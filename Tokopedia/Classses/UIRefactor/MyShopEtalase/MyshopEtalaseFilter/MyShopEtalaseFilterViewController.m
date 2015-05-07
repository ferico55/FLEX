//
//  MyShopEtalaseFilterViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Etalase.h"

#import "detail.h"
#import "MyShopEtalaseFilterCell.h"
#import "MyShopEtalaseFilterViewController.h"
#import "MyShopEtalaseEditViewController.h"

#import "URLCacheController.h"

#define ETALASE_OBJECT_SELECTED_KEY @"object_selected"
@interface MyShopEtalaseFilterViewController ()<UITableViewDataSource, UITableViewDelegate, MyShopEtalaseFilterCellDelegate, MyShopEtalaseEditViewControllerDelegate>{
    BOOL _isnodata;
    
    NSMutableArray *_etalaseList;
    NSMutableDictionary *_selecteddata;
    
    NSInteger _requestcount;
    NSTimer *_timer;
    
    Etalase *_etalase;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    EtalaseList *_selectedEtalase;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation MyShopEtalaseFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBarHidden = NO;
    
    self.title = @"Etalase";
    
    _etalaseList = [NSMutableArray new];
    _selecteddata = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _table.tableFooterView = _footer;
    
    if (self.navigationController.isBeingPresented) {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(tap:)];
        cancelBarButton.tag = 10;
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
    
    UIBarButtonItem  *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:(self)
                                                                       action:@selector(tap:)];
    rightBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    _etalase = [[Etalase alloc] init];
    NSInteger presentedEtalaseType = [[_data objectForKey:DATA_PRESENTED_ETALASE_TYPE_KEY]integerValue];
    if (presentedEtalaseType == PRESENTED_ETALASE_DEFAULT || presentedEtalaseType == PRESENTED_ETALASE_SHOP_PRODUCT){
        int etalaseArrayCount = (int)kTKPDSHOP_ETALASEARRAY.count;
        for (int i = 0;i<etalaseArrayCount;i++) {
            EtalaseList *etalase = [EtalaseList new];
            etalase.etalase_name = [kTKPDSHOP_ETALASEARRAY[i]objectForKey:kTKPDSHOP_APIETALASENAMEKEY];
            etalase.etalase_id = [kTKPDSHOP_ETALASEARRAY[i]objectForKey:kTKPDSHOP_APIETALASEIDKEY];
            [_etalaseList addObject:etalase];
        }
    } else if (presentedEtalaseType == PRESENTED_ETALASE_MANAGE_PRODUCT) {
        int etalaseArrayCount = (int)kTKPDMANAGEPRODUCT_ETALASEARRAY.count;
        for (int i = 0;i<etalaseArrayCount;i++) {
            EtalaseList *etalase = [EtalaseList new];
            etalase.etalase_name = [kTKPDMANAGEPRODUCT_ETALASEARRAY[i]objectForKey:kTKPDSHOP_APIETALASENAMEKEY];
            etalase.etalase_id = [kTKPDMANAGEPRODUCT_ETALASEARRAY[i]objectForKey:kTKPDSHOP_APIETALASEIDKEY];
            [_etalaseList addObject:etalase];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureRestKit];
    if (_isnodata) {
        [self loadData];
    }
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case 10:
            {
                //CANCEL
                if (self.presentingViewController != nil) {
                    if (self.navigationController.viewControllers.count > 1) {
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                break;
            }
            case 11:
            {
                //SUBMIT
                NSIndexPath *indexpath =[_selecteddata objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                EtalaseList *etalase = _etalaseList[indexpath.row];
                NSDictionary *userinfo = @{DATA_ETALASE_KEY:etalase,kTKPDDETAILETALASE_DATAINDEXPATHKEY:indexpath};
                
                if ([etalase.etalase_id integerValue] == DATA_ADD_NEW_ETALASE_ID) {
                    MyShopEtalaseEditViewController *newEtalaseVC = [MyShopEtalaseEditViewController new];
                    newEtalaseVC.delegate = self;
                    newEtalaseVC.data = @{DATA_ETALASE_KEY : [_data objectForKey:DATA_ETALASE_KEY]?:etalase,
                                          kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                          kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPENEWVIEWADDPRODUCTKEY),
                                          kTKPDDETAIL_DATAINDEXPATHKEY : indexpath
                                          };
                    [self.navigationController pushViewController:newEtalaseVC animated:YES];
                }
                else
                {
                    [_delegate MyShopEtalaseFilterViewController:self withUserInfo:userinfo];
                    if (self.presentingViewController != nil) {
                        if (self.navigationController.viewControllers.count > 1) {
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            [self dismissViewControllerAnimated:YES completion:NULL];
                        }
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                
                break;
            }
            default:
                break;
        }
    }
}



#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDPRODUCTETALASE_NODATAENABLE
    return _isnodata?1:_etalaseList.count;
#else
    return _isnodata?0:_etalaseList.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDMYSHOPETALASEFILTER_IDENTIFIER;
        
        cell = (MyShopEtalaseFilterCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [MyShopEtalaseFilterCell newcell];
            ((MyShopEtalaseFilterCell*)cell).delegate = self;
        }
        if (_etalaseList.count > indexPath.row) {
            EtalaseList *list =_etalaseList[indexPath.row];
<<<<<<< HEAD
            
=======

>>>>>>> ee42d20ae48e4ebfa8d7f0ebb7628bd13bbb3840
            if ([list.etalase_name isEqualToString:_selectedEtalase.etalase_name]) {
                ((MyShopEtalaseFilterCell*)cell).imageview.hidden = NO;
            }
            else
            {
                ((MyShopEtalaseFilterCell*)cell).imageview.hidden = YES;
            }
            
            ((MyShopEtalaseFilterCell*)cell).label.text = list.etalase_name;
            ((MyShopEtalaseFilterCell*)cell).indexpath = indexPath;
        }
    }
    return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        
    }
}

#pragma mark - Request + Mapping Etalase
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Etalase class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[EtalaseResult class]];
    
    // searchs list mapping
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[EtalaseList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDSHOP_APIETALASENAMEKEY,
                                                 kTKPDSHOP_APIETALASEIDKEY,
                                                 kTKPDSHOP_APIETALASETOTALPRODUCTKEY
                                                 ]];
    
    //add list relationship
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)loadData
{
    
    if (_request.isExecuting) return;
    
    _requestcount ++;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETETALASEKEY,
                            kTKPDDETAIL_APISHOPIDKEY: @([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILSHOP_APIPATH parameters:[param encrypt]];
    
    [_cachecontroller getFileModificationDate];
    _timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
    if (_timeinterval > _cachecontroller.URLCacheInterval) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self requestsuccess:mappingResult withOperation:operation];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [timer invalidate];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self requestfailure:error];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [timer invalidate];
        }];
        [_operationQueue addOperation:_request];
        
        
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestfailure:nil];
    }
}


-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stat = [result objectForKey:@""];
    _etalase = stat;
    NSString *statusstring = _etalase.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cachecontroller connectionDidFinish:_cacheconnection];
        //save response data
        [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        
        [self requestprocess:object];
    }
}

-(void)requesttimeout
{
    [self cancel];
}

-(void)requestfailure:(id)object
{
    if (_timeinterval > _cachecontroller.URLCacheInterval) {
        [self requestprocess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachepath];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            NSLog(@"result %@",[mapper mappingResult]);
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stat = [result objectForKey:@""];
            _etalase = stat;
            BOOL status = [_etalase.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stat = [result objectForKey:@""];
            _etalase = stat;
            NSString *statusstring = _etalase.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [_etalaseList addObjectsFromArray:_etalase.result.list];
                
                NSInteger presentedEtalaseType = [[_data objectForKey:DATA_PRESENTED_ETALASE_TYPE_KEY]integerValue];
                if (presentedEtalaseType == PRESENTED_ETALASE_ADD_PRODUCT) {
                    EtalaseList *etalase = [EtalaseList new];
                    etalase.etalase_name = [DATA_ADD_NEW_ETALASE_DICTIONARY objectForKey:kTKPDSHOP_APIETALASENAMEKEY];
                    etalase.etalase_id = [DATA_ADD_NEW_ETALASE_DICTIONARY objectForKey:kTKPDSHOP_APIETALASEIDKEY];
                    [_etalaseList addObject:etalase];
                }
                
                if (_etalaseList.count >0) {
                    _isnodata = NO;
                    
                    NSIndexPath *indexpath = [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                    [_selecteddata setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHKEY];
                    
                    EtalaseList *selectedEtalase = [_data objectForKey:ETALASE_OBJECT_SELECTED_KEY];
                    if (!selectedEtalase) {
                        _selectedEtalase = _etalaseList[((NSIndexPath*)[_selecteddata objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]).row];
                    }
                    else
                    {
                        _selectedEtalase = selectedEtalase;
                    }
                    
                    [_table reloadData];
                    
                }
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %ld =====",(long)_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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
                if (!([error code] == NSURLErrorCancelled)){
                    NSString *errorDescription = error.localizedDescription;
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [errorAlert show];
                }
            }
        }
    }
}

#pragma mark - Cell Delegate
-(void)MyShopEtalaseFilterCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    [_selecteddata setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHKEY];
    _selectedEtalase = _etalaseList[indexpath.row];
    [_table reloadData];
}

#pragma mark - Setting Etalase Delegate
-(void)MyShopEtalaseEditViewController:(MyShopEtalaseEditViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_delegate MyShopEtalaseFilterViewController:self withUserInfo:userInfo];
}

#pragma mark - Methods
-(void)adjustCacheController
{
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    /* prepare to use our own on-disk cache */
    //[_cachecontroller initCachePathComponent:kTKPDHOMEHOTLIST_APIRESPONSEFILE];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILETALASE_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:kTKPDDETAILSHOPETALASE_APIRESPONSEFILE];
    
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
}

@end