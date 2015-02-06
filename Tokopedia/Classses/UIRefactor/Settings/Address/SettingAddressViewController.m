//
//  SettingAddressViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_settings.h"
#import "profile.h"
#import "AddressForm.h"
#import "ProfileSettings.h"
#import "GeneralList1GestureCell.h"
#import "GeneralCheckmarkCell.h"
#import "SettingAddressViewController.h"
#import "SettingAddressDetailViewController.h"
#import "SettingAddressEditViewController.h"
#import "SettingAddressExpandedCell.h"

#import "MGSwipeButton.h"

@interface SettingAddressViewController ()<UITableViewDataSource, UITableViewDelegate, SettingAddressDetailViewControllerDelegate, UIScrollViewDelegate,MGSwipeTableCellDelegate, UISearchBarDelegate, SettingAddressEditViewControllerDelegate>
{
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _ismanualsetdefault;
    BOOL _isnodata;
    
    NSIndexPath *_selectedIndexPath;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    
    NSMutableDictionary *_datainput;
    NSDictionary *_auth;
    
    NSMutableArray *_list;
    
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerActionSetDefault;
    __weak RKManagedObjectRequestOperation *_requestActionSetDefault;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_doneBarButtonItem;
    UIBarButtonItem *_cancelBarButtonItem;
    
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *searchBarView;

@property (strong, nonatomic) IBOutlet UIView *addNewAddressView;
-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailure:(id)object;
-(void)requestProcess:(id)object;
-(void)requestTimeout;

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

@implementation SettingAddressViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _isrefreshview = NO;
        _ismanualsetdefault = NO;
        self.title = TITLE_LIST_ADDRESS;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
    
    if (type == TYPE_ADD_EDIT_PROFILE_ATC) {
        _cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [_cancelBarButtonItem setTintColor:[UIColor whiteColor]];
        [_cancelBarButtonItem setTag:TAG_SETTING_ADDRESS_BARBUTTONITEM_BACK];
        self.navigationItem.leftBarButtonItem = _cancelBarButtonItem;
        
        _doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [_doneBarButtonItem setTintColor:[UIColor blackColor]];
        [_doneBarButtonItem setTag:TAG_SETTING_ADDRESS_BARBUTTONITEM_DONE];
        self.navigationItem.rightBarButtonItem = _doneBarButtonItem;
        
        UIView *additionalView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 88)];
        [additionalView addSubview:_searchBarView];
        CGRect frame = _addNewAddressView.frame;
        frame.origin.y +=_searchBarView.frame.size.height;
        [_addNewAddressView setFrame:frame];
        [additionalView addSubview:_addNewAddressView];
        _table.tableHeaderView = additionalView;
        //UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 44.0)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"Cari Alamat";
        _searchBar.userInteractionEnabled=YES;
        //searchBar.searchBarStyle = UISearchBarStyleMinimal;
        //
        //UIView *searchBarContainer = [[UIView alloc] initWithFrame:searchBar.frame];
        //[searchBarContainer addSubview:searchBar];
        //
        //self.navigationItem.titleView = searchBarContainer;

    }
    else
    {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
        UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        barButtonItem.tag = 10;
        [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        UIView *additionalView = [[UIView alloc]initWithFrame:_addNewAddressView.frame];
        [additionalView addSubview:_addNewAddressView];
        _table.tableHeaderView = additionalView;
    }

    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    _list = [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    [_datainput addEntriesFromDictionary:_data];
    _operationQueue = [NSOperationQueue new];
    
    _page = 1;
    
    if (_list.count>0)_isnodata = NO;else _isnodata = YES;
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didEditAddress:) name:kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY object:nil];
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = auth;
    
    _selectedIndexPath = [_data objectForKey:DATA_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    _limit = kTKPDPROFILESETTINGADDRESS_LIMITPAGE;
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
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isnodata?0:_list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        if (indexPath.row == 0) {
            NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
            
            if (type == TYPE_ADD_EDIT_PROFILE_ATC) {
                static NSString *CellIdentifier = GENERAL_CHECKMARK_CELL_IDENTIFIER;
                
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [GeneralCheckmarkCell newcell];
                }
                AddressFormList *list = _list[indexPath.section];
                ((GeneralCheckmarkCell*)cell).cellLabel.text = list.address_name;
                
                if (_list.count > indexPath.row) {
                    AddressFormList *addressSelected = [_datainput objectForKey:DATA_ADDRESS_DETAIL_KEY];
                    NSIndexPath *indexpath = _selectedIndexPath;
                    if (addressSelected.address_id != list.address_id) {
                        ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = YES;
                    }
                    else
                        ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = NO;
                }
            }
            else
            {
                NSString *cellid = kTKPDGENERALLIST1GESTURECELL_IDENTIFIER;
                
                cell = (GeneralList1GestureCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
                if (cell == nil) {
                    cell = [GeneralList1GestureCell newcell];
                    ((GeneralList1GestureCell*)cell).delegate = self;
                }
                
                if (_list.count > indexPath.section) {
                    AddressFormList *list = _list[indexPath.section];
                    ((GeneralList1GestureCell*)cell).labelname.text = list.address_name;
                    ((GeneralList1GestureCell*)cell).indexpath = indexPath;
                    [(GeneralList1GestureCell*)cell viewdetailresetposanimation:YES];
                    ((GeneralList1GestureCell*)cell).labelvalue.hidden = YES;
                    if (!_ismanualsetdefault)((GeneralList1GestureCell*)cell).labeldefault.hidden = (list.address_status==2)?NO:YES;
                    else {
                        if (indexPath.section==0)((GeneralList1GestureCell*)cell).labeldefault.hidden = NO;
                        else ((GeneralList1GestureCell*)cell).labeldefault.hidden = YES;
                    }
                    
                }
            }
        }
        else
        {
            NSString *cellid = kTKPDSETTINGADDRESSEXPANDEDCELL_IDENTIFIER;
            
            cell = (SettingAddressExpandedCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [SettingAddressExpandedCell newcell];
            }
            
            if (_list.count > indexPath.section) {
                AddressFormList *list = _list[indexPath.section];
                ((SettingAddressExpandedCell*)cell).recieverNameLabel.text = list.receiver_name;
                NSString *address = [NSString stringWithFormat:@"%@\n%@\n%@\n%@, %@ %zd",list.address_street, list.district_name, list.city_name,list.province_name, list.country_name, list.postal_code];
                UIFont *font = [UIFont fontWithName:@"GothamBook" size:14];
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 6.0;
                
                NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                             NSFontAttributeName: font,
                                             NSParagraphStyleAttributeName: style,
                                             };
                
                NSAttributedString *addressAttributedText = [[NSAttributedString alloc] initWithString:address
                                                                                                attributes:attributes];
                
                ((SettingAddressExpandedCell*)cell).addressLabel.attributedText = addressAttributedText;
                ((SettingAddressExpandedCell*)cell).phoneLabel.text = list.receiver_phone;
            }
        }

    } else {
        static NSString *CellIdentifier = kTKPDPROFILE_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = kTKPDPROFILE_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDPROFILE_NODATACELLDESCS;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 44;
    }
    else
        return 190;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isdefault;
    NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PROFILE_ATC) {
         AddressFormList *address = _list[indexPath.section];
        [_datainput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
        [_table reloadData];
    }
    else
    {
        AddressFormList *list = _list[indexPath.section]; //
        if (_ismanualsetdefault) {
            isdefault = (indexPath.section == 0)?YES:NO; //
        }
        else
        {
            isdefault = (list.address_status == 2)?YES:NO;
        }
        
        SettingAddressDetailViewController *vc = [SettingAddressDetailViewController new];
        vc.data = @{kTKPD_AUTHKEY: _auth,
                    kTKPDPROFILE_DATAADDRESSKEY : _list[indexPath.section], //
                    kTKPDPROFILE_DATAINDEXPATHKEY : indexPath,
                    kTKPDPROFILE_DATAISDEFAULTKEY : @(isdefault)
                    };
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
	if (row == indexPath.row) {
		//NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            /** called if need to load next page **/
            NSLog(@"%@", NSStringFromSelector(_cmd));
            [self configureRestKit];
            [self request];
        }
	}
}

-(void)tableView:(UITableView *)tableView moveSection:(NSUInteger)sourceSection toIndexPath:(NSUInteger)destinationSection
{
    id dataObject = [_list objectAtIndex:sourceSection];
    [_list removeObjectAtIndex:sourceSection];
    [_list insertObject:dataObject atIndex:destinationSection];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id dataObject = [_list objectAtIndex:sourceIndexPath.section]; //
    [_list removeObjectAtIndex:sourceIndexPath.section]; //
    [_list insertObject:dataObject atIndex:destinationIndexPath.section]; //
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_table reloadData];
}


#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[AddressForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[AddressFormResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[AddressFormList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDPROFILESETTING_APICOUNTRYNAMEKEY,
                                                 kTKPDPROFILESETTING_APIRECEIVERNAMEKEY,
                                                 kTKPDPROFILESETTING_APIADDRESSNAMEKEY,
                                                 kTKPDPROFILESETTING_APIADDRESSIDKEY,
                                                 kTKPDPROFILESETTING_APIRECEIVERPHONEKEY,
                                                 kTKPDPROFILESETTING_APIPROVINCENAMEKEY,
                                                 kTKPDPROFILESETTING_APIPOSTALCODEKEY,
                                                 kTKPDPROFILESETTING_APIADDRESSSTATUSKEY,
                                                 kTKPDPROFILESETTING_APIADDRESSSTREETKEY,
                                                 kTKPDPROFILESETTING_APIDISTRICNAMEKEY,
                                                 kTKPDPROFILESETTING_APICITYNAMEKEY,
                                                 kTKPDPROFILESETTING_APICITYIDKEY,
                                                 kTKPDPROFILESETTING_APIPROVINCEIDKEY,
                                                 kTKPDPROFILESETTING_APIDISTRICTIDKEY
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIURINEXTKEY:kTKPD_APIURINEXTKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY toKeyPath:kTKPD_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
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
    
    if (_page==1)_doneBarButtonItem.enabled = NO;
    
    NSString *query = [_datainput objectForKey:API_QUERY_KEY]?:@"";
    NSInteger userID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIGETUSERADDRESSKEY,
                            kTKPDPROFILE_APIPAGEKEY : @(_page),
                            kTKPDPROFILE_APILIMITKEY : @(kTKPDPROFILESETTINGADDRESS_LIMITPAGE),
                            kTKPD_USERIDKEY : @(userID),
                            API_QUERY_KEY : query
                            };
    _requestcount ++;
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_SETTINGAPIPATH parameters:[param encrypt]];
    NSTimer *timer;
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        //_table.tableHeaderView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        _doneBarButtonItem.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailure:error];
        //[_act stopAnimating];
        //_table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        _doneBarButtonItem.enabled = YES;
    }];
    
    [_operationQueue addOperation:_request];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    AddressForm *address = stat;
    BOOL status = [address.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
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
            AddressForm *address = stat;
            BOOL status = [address.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (_page == 1) {
                    [_list removeAllObjects];
                }
                
                [_list addObjectsFromArray:address.result.list];
                if (_list.count >0) {
                    _isnodata = NO;
                    _urinext =  address.result.paging.uri_next;
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
                    NSLog(@"%zd",_page);
                }
                NSInteger type = [[_datainput objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]integerValue];
                if (type == 1) {
                    //TODO: Behavior after edit
                    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY];
                    BOOL isdefault;
                    
                    AddressFormList *list = _list[indexpath.row];
                    isdefault = (list.address_status == 2)?YES:NO;
                    SettingAddressDetailViewController *vc = [SettingAddressDetailViewController new];
                    vc.data = @{kTKPD_AUTHKEY: _auth,
                                kTKPDPROFILE_DATAADDRESSKEY : _list[indexpath.row],
                                kTKPDPROFILE_DATAINDEXPATHKEY : indexpath,
                                kTKPDPROFILE_DATAISDEFAULTKEY : @(isdefault)
                                };
                    vc.delegate = self;
                    [self.navigationController pushViewController:vc animated:NO];
                }
                [_table reloadData];

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

#pragma mark Request Action Set Default
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionSetDefault addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionSetDefault:(id)object
{
    if (_requestActionSetDefault.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APISETDEFAULTADDRESSKEY,
                            kTKPDPROFILESETTING_APIADDRESSIDKEY : [userinfo objectForKey:kTKPDPROFILESETTING_APIADDRESSIDKEY]?:0
                            };
    
    _requestActionSetDefault = [_objectmanagerActionSetDefault appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:[param encrypt]];
    
    [_requestActionSetDefault setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionSetDefault:mappingResult withOperation:operation];
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
                if (setting.result.is_success == 1 || setting.message_status) {
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
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
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIDELETEADDRESSKEY,
                            kTKPDPROFILESETTING_APIADDRESSIDKEY : [userinfo objectForKey:kTKPDPROFILESETTING_APIADDRESSIDKEY],
                            @"dec_enc":@"off"
                            };
    
    _requestActionDelete = [_objectmanagerActionDelete appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:param]; //kTKPDPROFILE_PROFILESETTINGAPIPATH
    
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
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionDelete) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionDelete:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    AddressForm *address = stat;
    BOOL status = [address.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
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
            [self cancelDeleteRow];
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
        UIBarButtonItem *barButtonItem = (UIBarButtonItem*)sender;
        switch (barButtonItem.tag) {
            case TAG_SETTING_ADDRESS_BARBUTTONITEM_BACK:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case TAG_SETTING_ADDRESS_BARBUTTONITEM_DONE:
            {
                AddressFormList *address = [_datainput objectForKey:DATA_ADDRESS_DETAIL_KEY];
                NSDictionary* userInfo = @{DATA_ADDRESS_DETAIL_KEY:address,
                                           DATA_INDEXPATH_KEY:_selectedIndexPath
                                           };
                [_delegate SettingAddressViewController:self withUserInfo:userInfo];
                [self.navigationController popViewControllerAnimated:YES];
            }
            default:
                break;
        }
    }
    else {
        //add new address
        NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
        NSInteger typeAddAddress = (type == TYPE_ADD_EDIT_PROFILE_ATC)?type:TYPE_ADD_EDIT_PROFILE_ADD_NEW;
        SettingAddressEditViewController *vc = [SettingAddressEditViewController new];
        vc.data = @{kTKPD_AUTHKEY: _auth,
                    kTKPDPROFILE_DATAEDITTYPEKEY : @(typeAddAddress)
                    };
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];        
    }
}

#pragma mark - delegate address detail
-(void)DidTapButton:(UIButton *)button withdata:(NSDictionary *)data
{
    AddressFormList *list = [data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
    [_datainput setObject:@(list.address_id) forKey:kTKPDPROFILESETTING_APIADDRESSIDKEY];
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
-(void)setAsDefaultAtIndexPath:(NSIndexPath*)indexpath
{
    _ismanualsetdefault = YES;
    [self configureRestKitActionSetDefault];
    [self requestActionSetDefault:_datainput];
    [_datainput setObject:indexpath forKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
    NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:indexpath.row inSection:0];
    [self tableView:_table moveSection:indexpath.section toIndexPath:indexpath1.section];
    //[_table moveSection:indexpath.section toSection:indexpath1.section];
    //[self tableView:_table moveRowAtIndexPath:indexpath toIndexPath:indexpath1];
    [_table reloadData];
}
-(void)cancelSetAsDefault
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
    NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:0 inSection:indexpath.section];
    [_table moveSection:indexpath1.section toSection:indexpath.section];
    //[self tableView:_table moveRowAtIndexPath:indexpath1 toIndexPath:indexpath];
    _ismanualsetdefault = NO;
    [_table reloadData];
}

-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath
{
    [_datainput setObject:_list[indexpath.section] forKey:kTKPDPROFILE_DATADELETEDOBJECTKEY]; //
    [_list removeObjectAtIndex:indexpath.section]; //
    [_table beginUpdates];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    [indexSet addIndex:indexpath.section];
    [_table deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    //[_table deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    [self configureRestKitActionDelete];
    [self requestActionDelete:_datainput];
    [_datainput setObject:indexpath forKey:kTKPDPROFILE_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY] atIndex:indexpath.section]; //
    [_table reloadData];
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];

    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    
    [self configureRestKit];
    [self request];
}

#pragma mark - UISearchBar Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //_table.tableHeaderView = _footer;
    //[_act startAnimating];
    [searchBar resignFirstResponder];
    //[self.navigationItem setRightBarButtonItem:_doneBarButtonItem];
    //[self.navigationItem setLeftBarButtonItem:_cancelBarButtonItem];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:@""];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [_datainput setObject:searchBar.text forKey:API_QUERY_KEY];
    [self refreshView:nil];
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    //[self.navigationItem setRightBarButtonItem:nil];
    //[self.navigationItem setLeftBarButtonItem:nil];
    return YES;
}


#pragma mark - Notification
- (void)didEditAddress:(NSNotification*)notification
{
    NSDictionary *userinfo = notification.userInfo;
    //TODO: Behavior after edit
    [_datainput setObject:[userinfo objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDPROFILE_DATAINDEXPATHKEY];
    [_datainput setObject:[userinfo objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]?:@(0) forKey:kTKPDPROFILE_DATAEDITTYPEKEY];
    [self refreshView:nil];
}

#pragma mark - Add / Edit Address Delegate
-(void)SettingAddressEditViewController:(SettingAddressEditViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_delegate SettingAddressViewController:self withUserInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
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
        AddressFormList *list = _list[indexpath.section];
        [_datainput setObject:@(list.address_id) forKey:kTKPDPROFILESETTING_APIADDRESSIDKEY];
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self deleteListAtIndexPath:indexpath];
            return YES;
        }];
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:@"Set As\nDefault" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self setAsDefaultAtIndexPath:indexpath];
            return YES;
        }];
        return @[trash, flag];
    }
    
    return nil;
    
}


@end
