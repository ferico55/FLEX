//
//  ProductEtalaseViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Etalase.h"

#import "detail.h"
#import "ProductEtalaseCell.h"
#import "ProductEtalaseViewController.h"

#import "URLCacheController.h"

@interface ProductEtalaseViewController ()<UITableViewDataSource, UITableViewDelegate, ProductEtalaseCellDelegate>{
    BOOL _isnodata;
    
    NSMutableArray *_datas;
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
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation ProductEtalaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _datas = [NSMutableArray new];
    _selecteddata = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _table.tableFooterView = _footer;
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
    //    UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    //}
    //else
    //    barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    //[barbutton1 setTag:10];
    //self.navigationItem.leftBarButtonItem = barbutton1;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //TODO:: Change image
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONMORECATEGORY ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        //UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [barbutton1 setTintColor:[UIColor blackColor]];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    // set table view datasource and delegate
    _table.delegate = self;
    _table.dataSource = self;
    
    [self.navigationController.navigationBar setTranslucent:NO];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _etalase = [[Etalase alloc] init];

    [_datas addObjectsFromArray:kTKPDSHOP_ETALASEARRAY];
    
    NSIndexPath *indexpath = [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_selecteddata setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHKEY];
    
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
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                //SUBMIT
                NSIndexPath *indexpath =[_selecteddata objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                NSDictionary *orderdict = _datas[indexpath.row];
                NSDictionary *userinfo = @{kTKPDDETAIL_DATAETALASEKEY:orderdict,kTKPDDETAILETALASE_DATAINDEXPATHKEY:indexpath};
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ETALASEPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    return _isnodata?1:_datas.count;
#else
    return _isnodata?0:_datas.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDPRODUCTETALASECELL_IDENTIFIER;
		
        cell = (ProductEtalaseCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [ProductEtalaseCell newcell];
            ((ProductEtalaseCell*)cell).delegate = self;
        }
        
        if (indexPath.row>1) {
            if (_datas.count > indexPath.row) {
                if (indexPath.row != ((NSIndexPath*)[_selecteddata objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]).row) {
                    ((ProductEtalaseCell*)cell).imageview.hidden = YES;
                }
                else
                    ((ProductEtalaseCell*)cell).imageview.hidden = NO;
                EtalaseList *list =_datas[indexPath.row];
                ((ProductEtalaseCell*)cell).label.text = list.etalase_name;
                ((ProductEtalaseCell*)cell).indexpath = indexPath;
            }
        }else{
            if (_datas.count > indexPath.row) {
                if (indexPath.row != ((NSIndexPath*)[_selecteddata objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]).row) {
                    ((ProductEtalaseCell*)cell).imageview.hidden = YES;
                }
                else
                    ((ProductEtalaseCell*)cell).imageview.hidden = NO;
                NSDictionary *data =_datas[indexPath.row];
                ((ProductEtalaseCell*)cell).label.text = [data objectForKey:kTKPDSHOP_APIETALASENAMEKEY];
                ((ProductEtalaseCell*)cell).indexpath = indexPath;
            }
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOPETALASE_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)loadData
{
    
    if (_request.isExecuting) return;
    
    _requestcount ++;
    
	NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETETALASEKEY,
                            kTKPDDETAIL_APISHOPIDKEY: @([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0)
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPETALASE_APIPATH parameters:param];
    
	[_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
	if (_timeinterval > _cachecontroller.URLCacheInterval) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
        
        //[_cachecontroller clearCache];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self requestsuccess:mappingResult withOperation:operation];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [_table reloadData];
            [_timer invalidate];
            _timer = nil;
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [self requestfailure:error];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[alertView show];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [_timer invalidate];
            _timer = nil;
        }];
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
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
                [_datas addObjectsFromArray:_etalase.result.list];
                if (_datas.count >0) {
                    _isnodata = NO;
                    [_table reloadData];
                }
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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

#pragma mark - Cell Delegate
-(void)ProductEtalaseCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    [_selecteddata setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHKEY];
    [_table reloadData];
}


@end
