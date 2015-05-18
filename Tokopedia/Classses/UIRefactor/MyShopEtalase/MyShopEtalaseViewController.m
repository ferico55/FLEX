//
//  MyShopEtalaseViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Etalase.h"
#import "ShopSettings.h"
#import "detail.h"
#import "generalcell.h"
#import "MyShopEtalaseViewController.h"
#import "MyShopEtalaseDetailViewController.h"
#import "MyShopEtalaseEditViewController.h"
#import "GeneralList1GestureCell.h"

#import "URLCacheController.h"

@interface MyShopEtalaseViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    MyShopEtalaseDetailViewControllerDelegate,
    MGSwipeTableCellDelegate
>
{
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _ismanualsetdefault;
    BOOL _isnodata;
    
    NSOperationQueue *_operationQueue;
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    
    NSMutableDictionary *_datainput;
    
    NSMutableArray *_list;
    Etalase *_etalase;
    
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    NSTimeInterval _timeinterval;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

@end

@implementation MyShopEtalaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        self.title = kTKPDTITLE_ETALASE;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _list= [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _isrefreshview = YES;
    
    _page = 1;
    _limit = kTKPDSHOPETALASE_LIMITPAGE;
    
    /// adjust refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
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
    
    //Add observer
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didEditEtalase:) name:kTKPD_ADDETALASEPOSTNOTIFICATIONNAMEKEY object:nil];
    
    [self configureRestKit];
    [self request];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Shop - Etalase List";
    [self configureRestKit];
    if (_isnodata && _page<=1) {
        [self request];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.screenName  =@"";
    [self cancel];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10: {
                //back
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11: {
                //add
                MyShopEtalaseEditViewController *vc = [MyShopEtalaseEditViewController new];
                vc.data = @{
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                            kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY)
                            };

                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];

                break;
            }
            default:
                break;
        }
    }
}


#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (!_isnodata) {
        GeneralList1GestureCell* cell = nil;
        NSString *cellid = kTKPDGENERALLIST1GESTURECELL_IDENTIFIER;
		
		cell = (GeneralList1GestureCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [GeneralList1GestureCell newcell];
			((GeneralList1GestureCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            EtalaseList *list = _list[indexPath.row];

            if (list.etalase_name.length > 20) {
                NSRange stringRange = {0, MIN([list.etalase_name length], 20)};
                stringRange = [list.etalase_name rangeOfComposedCharacterSequencesForRange:stringRange];
                NSString *shortString = [list.etalase_name substringWithRange:stringRange];
                cell.textLabel.text = [NSString stringWithFormat:@"%@...", shortString];
            } else {
                cell.textLabel.text = list.etalase_name;
            }
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Produk",list.etalase_total_product];
            cell.indexpath = indexPath;
            cell.type = kTKPDGENERALCELL_DATATYPEONEBUTTONKEY;
        }
		return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
        return cell;
    }
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MyShopEtalaseDetailViewController *vc = [MyShopEtalaseDetailViewController new];
    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY],DATA_ETALASE_KEY : _list[indexPath.row], kTKPDDETAIL_DATAINDEXPATHKEY:indexPath};
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
        EtalaseList *list = _list[indexPath.row];
        if ([list.etalase_total_product isEqualToString:@"0"]) {
            [self deleteListAtIndexPath:indexPath];
        } else {
            NSArray *errorMessages = @[@"Anda tidak dapat menghapus etalase.\nSilahkan pindahkan produk ke etalase lain terlebih dahulu."];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
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
                                                 kTKPDSHOP_APIETALASENUMPRODUCTKEY,
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

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount ++;
    
	NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETETALASEKEY,
                            kTKPDDETAIL_APISHOPIDKEY: @([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                            kTKPDDETAIL_APILIMITKEY : @(_limit)
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDDETAILSHOP_APIPATH
                                                                parameters:[param encrypt]];
    
	if (_isrefreshview) {
        
        _table.tableFooterView = _footer;
        [_act startAnimating];

        NSTimer *timer;
        //[_cachecontroller clearCache];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self requestsuccess:mappingResult withOperation:operation];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [_table reloadData];
            [timer invalidate];
            [_refreshControl endRefreshing];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [self requestfailure:error];
            //[alertView show];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [timer invalidate];
            [_refreshControl endRefreshing];
        }];
        
        [_operationQueue addOperation:_request];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                 target:self
                                               selector:@selector(requesttimeout)
                                               userInfo:nil
                                                repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
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
        [self requestprocess:object];
    }
}

-(void)requesttimeout
{
    [self cancel];
}

-(void)requestfailure:(id)object
{
    if (_isrefreshview) {
        [self requestprocess:object];
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
                
                if (_page == 1) {
                    [_list removeAllObjects];
                }
                
                [_list addObjectsFromArray:_etalase.result.list];

                if (_list.count >0) {
                    _isnodata = NO;
                    [_table reloadData];
                }
                
                _urinext =  _etalase.result.paging.uri_next;
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

                _page = [[queries objectForKey:kTKPDDETAIL_APIPAGEKEY] integerValue];
                NSLog(@"%zd",_page);
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
                    //TODO::Reload Handler
                    //[self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    //[self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOPETALASEACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionDelete addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionDelete:(id)object
{
    if (_requestActionDelete.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIDELETEETALASEKEY,
                            kTKPDSHOP_APIETALASEIDKEY : [userinfo objectForKey:kTKPDSHOP_APIETALASEIDKEY]
                            };
    _requestcount ++;
    
    _requestActionDelete = [_objectmanagerActionDelete appropriateObjectRequestOperationWithObject:self
                                                                                            method:RKRequestMethodPOST
                                                                                              path:kTKPDDETAILSHOPETALASEACTION_APIPATH
                                                                                        parameters:[param encrypt]];
    
    [_requestActionDelete setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionDelete:mappingResult withOperation:operation];
        [_act stopAnimating];
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
                if (setting.result.is_success == 1) {
                    NSArray *messages = @[@"Anda telah berhasil menghapus etalase."];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:messages
                                                                                     delegate:self];
                    [alert show];
                }
                if(setting.message_error) {
                    [self cancelDeleteData];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:setting.message_error
                                                                                   delegate:self];
                    [alert show];
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


#pragma mark - Cell Delegate
-(void)GeneralList1GestureCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    MyShopEtalaseDetailViewController *vc = [MyShopEtalaseDetailViewController new];
    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY],DATA_ETALASE_KEY : _list[indexpath.row], kTKPDDETAIL_DATAINDEXPATHKEY:indexpath};
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)DidTapButton:(UIButton *)button atCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
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

#pragma mark - Etalase Detail Delegate
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
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    [self configureRestKit];
    [self request];
}

-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath
{
    EtalaseList *list = _list[indexpath.row];
    [_datainput setObject:list.etalase_id?:@"" forKey:kTKPDSHOP_APIETALASEIDKEY];
    [_datainput setObject:_list[indexpath.row] forKey:kTKPDDETAIL_DATADELETEDOBJECTKEY];
    [_list removeObjectAtIndex:indexpath.row];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    [_table reloadData];
    [_datainput setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [self configureRestKitActionDelete];
    [self requestActionDelete:_datainput];
}
-(void)cancelDeleteData
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_table reloadData];
}

#pragma mark - Notification
- (void)didEditEtalase:(NSNotification*)notification
{
    NSDictionary *userinfo = notification.userInfo;
    //TODO: Behavior after edit
    [_datainput setObject:[userinfo objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDDETAIL_DATAINDEXPATHKEY];
    [self refreshView:nil];
}
@end
