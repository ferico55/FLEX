//
//  SettingNoteViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "generalcell.h"
#import "Notes.h"
#import "ShopSettings.h"
#import "URLCacheController.h"
#import "SettingNoteViewController.h"
#import "SettingNoteDetailViewController.h"
#import "GeneralList1GestureCell.h"

#import "MGSwipeButton.h"

#pragma mark - Setting Note View Controller
@interface SettingNoteViewController () <UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>
{
    NSMutableDictionary *_datainput;
    NSMutableArray *_list;
    NSInteger _requestcount;
    BOOL _isnodata;
    
    BOOL _isrefreshview;
    
    Notes *_notes;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    NSOperationQueue *_operationQueue;
    
    UIRefreshControl *_refreshControl;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIButton *buttonadd;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

- (IBAction)tap:(id)sender;

@end

@implementation SettingNoteViewController
#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        self.title = kTKPDTITLE_NOTE;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _datainput = [NSMutableDictionary new];
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _cachecontroller = [URLCacheController new];
    _cacheconnection = [URLCacheConnection new];
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    //cache
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPNOTES_APIRESPONSEFILEFORMAT,[[auth objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
    
    //Add observer
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didEditNote:) name:kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata) {
            [self request];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
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
            NotesList *list = _list[indexPath.row];
            ((GeneralList1GestureCell*)cell).labelname.text = list.note_title;
            ((GeneralList1GestureCell*)cell).labeldefault.hidden = YES;
            ((GeneralList1GestureCell*)cell).labelvalue.hidden = YES;
            ((GeneralList1GestureCell*)cell).indexpath = indexPath;
            ((GeneralList1GestureCell*)cell).type = kTKPDGENERALCELL_DATATYPETWOBUTTONKEY;
            [((GeneralList1GestureCell*)cell).buttondefault setTitle:@"Ubah\nCatatan" forState:UIControlStateNormal];
            
        }
        
		return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotesList *list = _list[indexPath.row];
    SettingNoteDetailViewController *vc = [SettingNoteDetailViewController new];
    vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                kTKPDDETAIL_DATATYPEKEY: @(kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY),
                kTKPDNOTES_APINOTEIDKEY:list.note_id,
                kTKPDNOTES_APINOTETITLEKEY:list.note_title
                };
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

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

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        //add new notes
        SettingNoteDetailViewController *vc = [SettingNoteDetailViewController new];
        vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@"",
                    kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY)
                    };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request and Mapping
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Notes class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[NotesResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[NotesList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDNOTES_APINOTEIDKEY,
                                                 kTKPDNOTES_APINOTESTATUSKEY,
                                                 kTKPDNOTES_APINOTETITLEKEY
                                                 ]];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOPNOTE_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPNOTEKEY,
                            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0),
                            };
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval || _isrefreshview) {
        if (!_isrefreshview) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        }
        NSTimer *timer;
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPNOTE_APIPATH parameters:param];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [timer invalidate];
            _table.hidden = NO;
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [_act stopAnimating];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [timer invalidate];
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [_act stopAnimating];
            [self requestfailure:error];
        }];
        [_operationQueue addOperation:_request];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestfailure:nil];
    }
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _notes = stats;
    BOOL status = [_notes.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status && _notes.result) {
        if (_notes.result.list > 0) {
            [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            //save response data
            [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        }
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    if (_timeinterval > _cachecontroller.URLCacheInterval || _isrefreshview) {
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
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stats = [result objectForKey:@""];
            _notes = stats;
            BOOL status = [_notes.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            
            id stats = [result objectForKey:@""];
            
            _notes = stats;
            BOOL status = [_notes.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _notes.result.list;
                [_list addObjectsFromArray:list];
                _isnodata = NO;
                
                [_table reloadData];
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    //[self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    //[self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    //[_act stopAnimating];
                    //_table.tableFooterView = nil;
                }
            }
            else
            {
                //[_act stopAnimating];
                //_table.tableFooterView = nil;
            }
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOPNOTEACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionDelete addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionDelete:(id)object
{
    if (_requestActionDelete.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIDELETENOTESDETAILKEY,
                            kTKPDNOTES_APINOTEIDKEY : [userinfo objectForKey:kTKPDNOTES_APINOTEIDKEY]?:0
                            };
    _requestcount ++;
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    _requestActionDelete = [_objectmanagerActionDelete appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPNOTEACTION_APIPATH parameters:param]; //kTKPDPROFILE_PROFILESETTINGAPIPATH
    
    [_requestActionDelete setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionDelete:mappingResult withOperation:operation];
        [_act stopAnimating];
        _isrefreshview = NO;
        [timer invalidate];
        app.networkActivityIndicatorVisible = NO;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionDelete:error];
        _isrefreshview = NO;
        [timer invalidate];
        app.networkActivityIndicatorVisible = NO;
    }];
    
    [_operationQueue addOperation:_requestActionDelete];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionDelete) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionDelete:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
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
            ShopSettings *setting = stat;
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
            }
        }
        else{
            [self cancelActionDelete];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            [self cancelDeleteRow];
        }
    }
}

-(void)requestTimeoutActionDelete
{
    [self cancelActionDelete];
}


#pragma mark - Cell Delegate
//-(void)GeneralList1GestureCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
//{
//    NotesList *list = _list[indexpath.row];
//    SettingNoteDetailViewController *vc = [SettingNoteDetailViewController new];
//    vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
//                kTKPDDETAIL_DATATYPEKEY: @(kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY),
//                kTKPDNOTES_APINOTEIDKEY:list.note_id};
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//-(void)DidTapButton:(UIButton *)button atCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
//{
//    NotesList *list = _list[indexpath.row];
//    [_datainput setObject:list.note_id forKey:kTKPDNOTES_APINOTEIDKEY];
//    switch (button.tag) {
//        case 10:
//        {
//            //edit
//            SettingNoteDetailViewController *vc = [SettingNoteDetailViewController new];
//            vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@"",
//                        kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY),
//                        kTKPDNOTES_APINOTEIDKEY : list.note_id
//                        };
//            [self.navigationController pushViewController:vc animated:YES];
//            break;
//        }
//        case 11:
//        {
//            //delete
//            [self deleteListAtIndexPath:indexpath];
//            break;
//        }
//        default:
//            break;
//    }
//}


#pragma mark - Methods

-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath
{
    [_datainput setObject:_list[indexpath.row] forKey:kTKPDDETAIL_DATADELETEDOBJECTKEY];
    [_list removeObjectAtIndex:indexpath.row];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    [self configureRestKitActionDelete];
    [self requestActionDelete:_datainput];
    [_datainput setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_table reloadData];
}


-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestcount = 0;
    [_list removeAllObjects];
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self request];
}

#pragma mark - Notification
- (void)didEditNote:(NSNotification*)notification
{
    NSDictionary *userinfo = notification.userInfo;
    //TODO: Behavior after edit
    [_datainput setObject:[userinfo objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDDETAIL_DATAINDEXPATHKEY];
    //[_datainput setObject:[userinfo objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]?:@(0) forKey:kTKPDPROFILE_DATAEDITTYPEKEY];
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
        NSIndexPath *indexpath = ((GeneralList1GestureCell*) cell).indexpath;
        NotesList *list = _list[indexpath.row];
        [_datainput setObject:list.note_id forKey:kTKPDNOTES_APINOTEIDKEY];
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self deleteListAtIndexPath:indexpath];
            return YES;
        }];
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:@"Ubah\nCatatan" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //edit
            SettingNoteDetailViewController *vc = [SettingNoteDetailViewController new];
            vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@"",
                        kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY),
                        kTKPDNOTES_APINOTEIDKEY : list.note_id
                        };
            [self.navigationController pushViewController:vc animated:YES];
            return YES;
        }];
        return @[trash, flag];
    }
    
    return nil;
    
}

@end
