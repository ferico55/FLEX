//
//  MyShopAddressViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "generalcell.h"
#import "SettingLocation.h"
#import "ShopSettings.h"
#import "Paging.h"
#import "MyShopAddressViewController.h"
#import "MyShopAddressDetailViewController.h"
#import "MyShopAddressEditViewController.h"
#import "GeneralList1GestureCell.h"

#import "URLCacheController.h"

@interface MyShopAddressViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    MyShopAddressDetailViewControllerDelegate,
    UIScrollViewDelegate,
    MGSwipeTableCellDelegate
>
{
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _ismanualsetdefault;
    BOOL _ismanualdelete;
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    NSMutableDictionary *_datainput;
    
    NSMutableArray *_list;
    
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    NSOperationQueue *_operationQueue;
    
    NSTimeInterval _timeinterval;
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
-(void)requestTimeout;

-(void)cancelActionDelete;
-(void)configureRestKitActionDelete;
-(void)requestActionDelete:(id)object;
-(void)requestSuccessActionDelete:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionDelete:(id)object;
-(void)requestProcessActionDelete:(id)object;
-(void)requestTimeoutActionDelete;

- (IBAction)tap:(id)sender;

@end

@implementation MyShopAddressViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _isrefreshview = NO;
        _ismanualsetdefault = NO;
        _ismanualdelete = NO;
        self.title = kTKPDTITLE_LOCATION;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _page = 1;
    _isrefreshview = YES;
    
    if (_list.count>0)_isnodata = NO;else _isnodata = YES;
    
    //Add observer
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didEditAddress:) name:kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY object:nil];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(tap:)];
    addBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    [self configureRestKit];
    [self request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
			((MGSwipeTableCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            Address *list = _list[indexPath.row];
            ((GeneralList1GestureCell*)cell).textLabel.text = list.location_address_name;
            ((GeneralList1GestureCell*)cell).detailTextLabel.text = @"";
            ((GeneralList1GestureCell*)cell).indexpath = indexPath;
            ((GeneralList1GestureCell*)cell).type = kTKPDGENERALCELL_DATATYPEONEBUTTONKEY;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL isdefault;
    if (_ismanualsetdefault) {
        isdefault = (indexPath.row == 0)?YES:NO;
    }
    
    MyShopAddressDetailViewController *vc = [MyShopAddressDetailViewController new];
    NSDictionary *data = @{
                           kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
                           kTKPDDETAIL_DATAADDRESSKEY : _list[indexPath.row],
                           kTKPDDETAIL_DATAINDEXPATHKEY : indexPath,
                           kTKPDDETAIL_DATAISDEFAULTKEY : @(isdefault)
                           };
    vc.data = [NSMutableDictionary dictionaryWithDictionary:data];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self deleteListAtIndexPath:indexPath];
    }
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_table reloadData];
}


#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SettingLocation class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SettingLocationResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[Address class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDSHOP_APICITYNAMEKEY,
                                                 kTKPDSHOP_APIEMAILKEY,
                                                 kTKPDSHOP_APIADDRESSKEY,
                                                 kTKPDSHOP_APIPOSTALCODEKEY,
                                                 kTKPDSHOP_APICITYIDKEY,
                                                 kTKPDSHOP_APILOCATIONAREAKEY,
                                                 kTKPDSHOP_APIPHONEKEY,
                                                 kTKPDSHOP_APIDISTRICTIDKEY,
                                                 kTKPDSHOP_APIPROVINCENAMEKEY,
                                                 kTKPDSHOP_APIPROVINCEIDKEY,
                                                 kTKPDSHOP_APIDISTRICTNAMEKEY,
                                                 kTKPDSHOP_APIADDRESSIDKEY,
                                                 kTKPDSHOP_APIFAXKEY,
                                                 kTKPDSHOP_APIADDRESSNAMEKEY
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIURINEXTKEY:kTKPD_APIURINEXTKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY toKeyPath:kTKPD_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOPADDRESS_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
    
}

-(void)request
{

    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIGETSHOPLOCATIONKEY,
                            };
    
	if (_isrefreshview) {
        if (_request.isExecuting) return;

        _table.tableFooterView = _footer;
        [_act startAnimating];
        
        _requestcount ++;
        
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                        method:RKRequestMethodPOST
                                                                          path:kTKPDDETAILSHOPADDRESS_APIPATH
                                                                    parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self requestSuccess:mappingResult withOperation:operation];
            [_act stopAnimating];
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [self requestFailure:error];
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
        }];
        
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                  target:self
                                                selector:@selector(requestTimeout)
                                                userInfo:nil
                                                 repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"cache and updated in last 24 hours.");
        [self requestFailure:nil];
	}

}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    SettingLocation *address = stat;
    BOOL status = [address.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    if (_isrefreshview) {
        [self requestProcess:object];
    }
}

-(void)requestProcess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            SettingLocation *address = stat;
            BOOL status = [address.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [_list addObjectsFromArray:address.result.list];
                if (_list.count >0) {
                    _isnodata = NO;
                    _table.tableFooterView = nil;
                } else {
                    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 103);
                    NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
                    _table.tableFooterView = noResultView;
                    _table.sectionFooterHeight = 103;
                }

                [_table reloadData];
                
                NSInteger type = [[_datainput objectForKey:kTKPDDETAIL_DATATYPEKEY]integerValue];
                if (type == 1) {
                    //TODO: Behavior after edit
                    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY];
                    BOOL isdefault;
                    MyShopAddressDetailViewController *vc = [MyShopAddressDetailViewController new];
                    vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
                                kTKPDDETAIL_DATAADDRESSKEY : _list[indexpath.row],
                                kTKPDDETAIL_DATAINDEXPATHKEY : indexpath,
                                kTKPDDETAIL_DATAISDEFAULTKEY : @(isdefault)
                                };
                    vc.delegate = self;
                    [self.navigationController pushViewController:vc animated:NO];
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

-(void)requestTimeout
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOPADDRESSACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionDelete addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionDelete:(NSDictionary *)userinfo
{
    if (_requestActionDelete.isExecuting) return;

    NSTimer *timer;
    
    Address *address = [userinfo objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY];
    
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIDELETESHOPLOCATIONKEY,
                            kTKPDSHOP_APIADDRESSIDKEY : address.location_address_id?:@(0)
                            };
    _requestcount ++;
    
    _requestActionDelete = [_objectmanagerActionDelete appropriateObjectRequestOperationWithObject:self
                                                                                            method:RKRequestMethodPOST
                                                                                              path:kTKPDDETAILSHOPADDRESSACTION_APIPATH
                                                                                        parameters:[param encrypt]];
    
    [_requestActionDelete setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionDelete:mappingResult withOperation:operation];
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
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                            target:self
                                          selector:@selector(requestTimeoutActionDelete)
                                          userInfo:nil
                                           repeats:NO];
    
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
                if (setting.result.is_success) {
                    
                    NSString *message = @"Anda telah berhasil menghapus lokasi.";
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[message] delegate:self];
                    [alert show];
                    
                } else if(setting.message_error) {
                    [self cancelDeleteData];
                    
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:setting.message_error delegate:self];
                    [alert show];
                
                    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
                    [_list insertObject:[_datainput objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
                    [_table reloadData];

                }
            }
        } else {
            [self cancelActionDelete];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            [self cancelDeleteData];
        }
    }
}

-(void)requestTimeoutActionDelete
{
    [self cancelActionDelete];
}


#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([sender tag] == 10) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([sender tag] == 11) {
            //add new address
            MyShopAddressEditViewController *vc = [MyShopAddressEditViewController new];
            vc.data = @{
                        kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
                        kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY)
                        };
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
}


#pragma mark - Cell Delegate
-(void)GeneralList1GestureCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    BOOL isdefault;
    
    MyShopAddressDetailViewController *vc = [MyShopAddressDetailViewController new];
    vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
                kTKPDDETAIL_DATAADDRESSKEY : _list[indexpath.row],
                kTKPDDETAIL_DATAINDEXPATHKEY : indexpath,
                kTKPDDETAIL_DATAISDEFAULTKEY : @(isdefault)
                };
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)DidTapButton:(UIButton *)button atCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    Address *list = _list[indexpath.row];
    [_datainput setObject:list.location_address_id forKey:kTKPDSHOP_APIADDRESSIDKEY];
    switch (button.tag) {
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

#pragma mark - delegate address detail
-(void)DidTapButton:(UIButton *)button withdata:(NSDictionary *)data
{
    switch (button.tag) {
        case 11:
        {
            //delete
            NSIndexPath *indexpath = [data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            [self deleteListAtIndexPath:indexpath];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    [_list removeAllObjects];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self request];
}


-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath
{
    _ismanualdelete = YES;
    [_datainput setObject:_list[indexpath.row] forKey:kTKPDDETAIL_DATADELETEDOBJECTKEY];
    [_list removeObjectAtIndex:indexpath.row];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    [_table reloadData];
    [self configureRestKitActionDelete];
    [self requestActionDelete:_datainput];
    [_datainput setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}

-(void)cancelDeleteData
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_table reloadData];
}

#pragma mark - Notification
- (void)didEditAddress:(NSNotification*)notification
{
    NSDictionary *userinfo = notification.userInfo;
    //TODO: Behavior after edit
    [_datainput setObject:[userinfo objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDDETAIL_DATAINDEXPATHKEY];
    [self refreshView:nil];
}

@end
