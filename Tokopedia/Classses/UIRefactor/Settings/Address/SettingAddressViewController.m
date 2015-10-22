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
#import "LoadingView.h"
#import "SettingAddressViewController.h"
#import "SettingAddressDetailViewController.h"
#import "SettingAddressEditViewController.h"
#import "SettingAddressExpandedCell.h"
#import "TokopediaNetworkManager.h"

#import "MGSwipeButton.h"
#define CTagRequest 2

@interface SettingAddressViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    UIScrollViewDelegate,
    UIAlertViewDelegate,
    SettingAddressDetailViewControllerDelegate,
    MGSwipeTableCellDelegate,
    SettingAddressEditViewControllerDelegate,
    TokopediaNetworkManagerDelegate,
    LoadingViewDelegate
>
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
    NSMutableArray *_listTemp;
    NSDictionary *_auth;
        
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *tokopediaNetworkManagerRequest;
    
    __weak RKObjectManager *_objectmanagerActionSetDefault;
    __weak RKManagedObjectRequestOperation *_requestActionSetDefault;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_doneBarButtonItem;
    UIBarButtonItem *_cancelBarButtonItem;
    LoadingView *loadingView;
    NSIndexPath *_indexPath;
    
    NSString *_searchKeyword;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *searchBarView;

@property (strong, nonatomic) IBOutlet UIView *addNewAddressView;
-(void)cancel;
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
    _listTemp = [NSMutableArray new];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect frame = _searchBarView.frame;
    frame.size.width = screenWidth;
    _searchBarView.frame = frame;
    
    frame = _addNewAddressView.frame;
    frame.size.width = screenWidth;
    _addNewAddressView.frame = frame;
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PROFILE_ATC) {
        _doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                              style:UIBarButtonItemStylePlain
                                                             target:(self)
                                                             action:@selector(tap:)];
        _doneBarButtonItem.tag = TAG_SETTING_ADDRESS_BARBUTTONITEM_DONE;
        self.navigationItem.rightBarButtonItem = _doneBarButtonItem;

        [self.view addSubview:_addNewAddressView];
        _table.contentInset = UIEdgeInsetsMake(_addNewAddressView.frame.size.height, 0, 0, 0);
        //_table.tableHeaderView = _addNewAddressView;
        
        _searchBar.delegate = self;
        _searchBar.placeholder = @"Cari Alamat";
        _searchBar.userInteractionEnabled = YES;
        
    } else {
        
        UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                      target:self
                                                                                      action:@selector(tap:)];
        addBarButton.tag = 12;
        self.navigationItem.rightBarButtonItem = addBarButton;
        
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
        backBarButton.tag = 10;
        self.navigationItem.backBarButtonItem = backBarButton;
        
        //_table.tableHeaderView = _searchBarView;
        [self.view addSubview:_searchBarView];
        _table.contentInset = UIEdgeInsetsMake(_searchBarView.frame.size.height, 0, 0, 0);
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
    
    if (_list.count>0)_isnodata = NO; else _isnodata = YES;
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didEditAddress:) name:kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY object:nil];
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = auth;
    
    _selectedIndexPath = [_data objectForKey:DATA_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    _limit = kTKPDPROFILESETTINGADDRESS_LIMITPAGE;
    
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
    
//    if (!_isrefreshview) {
//        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
//            [self request];
//        }
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
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
                    
                    ((GeneralList1GestureCell*)cell).textLabel.text = list.address_name;
                    ((GeneralList1GestureCell*)cell).indexpath = indexPath;
                    
                    if (indexPath.section == 0) {
                        ((GeneralList1GestureCell*)cell).detailTextLabel.text = @"Alamat Utama";
                    }
                    else
                    {
                        ((GeneralList1GestureCell*)cell).detailTextLabel.text = @" ";
                    }

                    if (![_searchKeyword isEqualToString:@""] && _searchKeyword != nil) {
                        ((GeneralList1GestureCell*)cell).detailTextLabel.text = (list.address_status == 2)?@"Alamat Utama":@" ";
                    }
                }
            }
        } else {
            NSString *cellid = kTKPDSETTINGADDRESSEXPANDEDCELL_IDENTIFIER;
            
            cell = (SettingAddressExpandedCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [SettingAddressExpandedCell newcell];
            }
            
            if (_list.count > indexPath.section) {
                AddressFormList *list = _list[indexPath.section];
                ((SettingAddressExpandedCell*)cell).recieverNameLabel.text = list.receiver_name;
                NSString *address = [NSString stringWithFormat:@"%@\n%@\n%@\n%@, %@ %@",
                                     [NSString convertHTML:list.address_street], list.district_name, list.city_name,
                                     list.province_name, list.country_name, list.postal_code];
                
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
    } else {
        AddressFormList *list = _list[indexPath.section];
        
        NSString *string = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@ %@",
                            [NSString convertHTML:list.address_street], list.district_name, list.city_name,
                            list.province_name, list.country_name, list.postal_code];
        
        //Calculate the expected size based on the font and linebreak mode of your label
        CGSize maximumLabelSize = CGSizeMake(190,9999);
        CGSize expectedLabelSize = [string sizeWithFont:FONT_GOTHAM_BOOK_16
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:NSLineBreakByTruncatingTail];
        return 243-35+expectedLabelSize.height;

    }
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
        vc.data = @{
                    kTKPD_AUTHKEY: _auth,
                    kTKPDPROFILE_DATAADDRESSKEY : _list[indexPath.section],
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

    NSInteger section = _list.count - 1;
	if (section == indexPath.section) {
		//NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0 && ([_searchKeyword isEqualToString:@""] || _searchKeyword == nil)) {
            /** called if need to load next page **/
            NSLog(@"%@", NSStringFromSelector(_cmd));
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
    //[_table reloadData];
}

-(void)reloadTableData
{
    [_table reloadData];
}


#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    if(tokopediaNetworkManagerRequest != nil)
    {
        tokopediaNetworkManagerRequest.delegate = nil;
        [tokopediaNetworkManagerRequest requestCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if ([self getNetworkRequest:CTagRequest].getObjectRequest.isExecuting) return;
    
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    if (_page==1)_doneBarButtonItem.enabled = NO;
    [[self getNetworkRequest:CTagRequest] doRequest];
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
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        AddressForm *address = stat;
        BOOL status = [address.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            if (_page == 1) {
                [_list removeAllObjects];
                [_listTemp removeAllObjects];
            }
            
            [_list addObjectsFromArray:address.result.list];
            [_listTemp addObjectsFromArray:address.result.list];
            
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
                
                _table.tableFooterView = nil;
            } else {
                CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
                NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
                self.table.tableFooterView = noResultView;
            }
            
            NSInteger type = [[_datainput objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]integerValue];
            if (type == TYPE_ADD_EDIT_PROFILE_EDIT) {
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
            //_table.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);
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
                            kTKPDPROFILESETTING_APIADDRESSIDKEY : [userinfo objectForKey:kTKPDPROFILESETTING_APIADDRESSIDKEY]?:@0
                            };
    
    _requestActionSetDefault = [_objectmanagerActionSetDefault appropriateObjectRequestOperationWithObject:self
                                                                                                    method:RKRequestMethodPOST
                                                                                                      path:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                                parameters:[param encrypt]];
    
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
    else
    {
        [self cancelSetAsDefault];
    }
}

-(void)requestFailureActionSetDefault:(id)object
{
    [self cancelSetAsDefault];
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
                if(setting.message_error) {
                    [self cancelSetAsDefault];
                    NSArray *errorMessages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:errorMessages
                                                                                     delegate:self];
                    [alert show];
                }
                if (setting.result.is_success == 1 || setting.message_status) {
                    NSArray *successMessages = setting.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages
                                                                                     delegate:self];
                    [alert show];
                }
            }
        } else {
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

    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary *)object;
    
    NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIDELETEADDRESSKEY,
                            kTKPDPROFILESETTING_APIADDRESSIDKEY : [userinfo objectForKey:kTKPDPROFILESETTING_APIADDRESSIDKEY],
                            };
    
    _requestActionDelete = [_objectmanagerActionDelete appropriateObjectRequestOperationWithObject:self
                                                                                            method:RKRequestMethodPOST
                                                                                              path:kTKPDPROFILE_PROFILESETTINGAPIPATH
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
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
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

                if(setting.message_error) {
                    [self cancelDeleteRow];
                    NSArray *errorMessages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:errorMessages
                                                                                       delegate:self];
                    [alertView show];
                }
                
                if (setting.result.is_success == 1) {
                    NSArray *successMessages = setting.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                    StickyAlertView *alertView = [[StickyAlertView alloc] initWithSuccessMessages:successMessages
                                                                                         delegate:self];
                    [alertView show];
                } else {
                    [self cancelDeleteRow];
                }
            }
        } else {
            [self cancelActionDelete];
            [self cancelDeleteRow];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
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
                NSDictionary* userInfo = @{
                                           DATA_ADDRESS_DETAIL_KEY:address,
                                           DATA_INDEXPATH_KEY:_selectedIndexPath
                                           };
                [_delegate SettingAddressViewController:self withUserInfo:userInfo];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case TAG_SETTING_ADDRESS_BARBUTTONITEM_ADD:
            {
                //add new address
                NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
                NSInteger typeAddAddress = (type == TYPE_ADD_EDIT_PROFILE_ATC)?type:TYPE_ADD_EDIT_PROFILE_ADD_NEW;
                SettingAddressEditViewController *vc = [SettingAddressEditViewController new];
                vc.data = @{kTKPD_AUTHKEY: _auth,
                            kTKPDPROFILE_DATAEDITTYPEKEY : @(typeAddAddress)
                            };
                vc.delegate = self;

                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                
                break;
            }
            default:
                break;
        }
    } else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            //add new address
            NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
            NSInteger typeAddAddress = (type == TYPE_ADD_EDIT_PROFILE_ATC)?type:TYPE_ADD_EDIT_PROFILE_ADD_NEW;
            SettingAddressEditViewController *vc = [SettingAddressEditViewController new];
            vc.data = @{kTKPD_AUTHKEY: _auth,
                        kTKPDPROFILE_DATAEDITTYPEKEY : @(typeAddAddress)
                        };
            vc.delegate = self;
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];            
        }
    }
}

#pragma mark - delegate address detail
-(void)setDefaultAddressData:(NSDictionary *)data
{
    AddressFormList *list = [data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
    [_datainput setObject:@(list.address_id) forKey:kTKPDPROFILESETTING_APIADDRESSIDKEY];
    NSIndexPath *indexPathZero = [NSIndexPath indexPathForRow:0 inSection:0];
    _indexPath = (NSIndexPath *)[data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]?:indexPathZero;
    [self setAsDefaultAtIndexPath:_indexPath];
}

-(void)DidTapButton:(UIButton *)button withdata:(NSDictionary *)data
{
    AddressFormList *list = [data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
    [_datainput setObject:@(list.address_id) forKey:kTKPDPROFILESETTING_APIADDRESSIDKEY];
    NSIndexPath *indexPathZero = [NSIndexPath indexPathForRow:0 inSection:0];
    _indexPath = (NSIndexPath *)[data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]?:indexPathZero;
    switch (button.tag) {
        case 10:
        {
            //set as default
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ganti Alamat Utama"
                                                                message:@"Apakah Anda yakin ingin menggunakan alamat ini sebagai alamat utama Anda?"
                                                               delegate:self
                                                      cancelButtonTitle:@"Tidak"
                                                      otherButtonTitles:@"Ya", nil];
            alertView.tag = 1;
            alertView.delegate = self;
            [alertView show];
            
            break;
        }
        case 11:
        {
            //delete
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hapus Alamat"
                                                                message:@"Apakah Anda yakin ingin menghapus alamat ini?"
                                                               delegate:self
                                                      cancelButtonTitle:@"Tidak"
                                                      otherButtonTitles:@"Ya", nil];
            alertView.tag = 2;
            alertView.delegate = self;
            [alertView show];

            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
- (TokopediaNetworkManager *)getNetworkRequest:(int)tag
{
    if(tokopediaNetworkManagerRequest == nil)
    {
        tokopediaNetworkManagerRequest = [TokopediaNetworkManager new];
        tokopediaNetworkManagerRequest.delegate = self;
    }
    tokopediaNetworkManagerRequest.tagRequest = tag;
    
    return tokopediaNetworkManagerRequest;
}

-(void)setAsDefaultAtIndexPath:(NSIndexPath*)indexpath
{
    _ismanualsetdefault = YES;
    [self configureRestKitActionSetDefault];
    [self requestActionSetDefault:_datainput];
    id object = _list[indexpath.section];
    [_list removeObject:object];
    [_list insertObject:object atIndex:0];
    [_datainput setObject:indexpath forKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
    [self.table reloadData];
}
-(void)cancelSetAsDefault
{
    _ismanualsetdefault = NO;
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
    NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:0 inSection:indexpath.section];
    [_table moveSection:indexpath1.section toSection:indexpath.section];
    [_table reloadData];
}

-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath
{
    [_datainput setObject:_list[indexpath.section] forKey:kTKPDPROFILE_DATADELETEDOBJECTKEY];
    [_list removeObjectAtIndex:indexpath.section];
    [_table beginUpdates];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    [indexSet addIndex:indexpath.section];
    [_table deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
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
    
    [self request];
}

#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:@""];

    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];

    if (![searchBar.text isEqualToString:@""]) {
        [_list removeAllObjects];
        [_list addObjectsFromArray:_listTemp];
        
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchBar.text];
        NSMutableArray *listName = [NSMutableArray new];
        NSMutableArray *listReceiver = [NSMutableArray new];
        for (AddressFormList *address in _list) {
            [listName addObject: address.address_name];
            [listReceiver addObject:address.receiver_name];
        }
        
        listName = [[listName filteredArrayUsingPredicate:resultPredicate] mutableCopy];
        listReceiver = [[listReceiver filteredArrayUsingPredicate:resultPredicate] mutableCopy];
        NSMutableArray *listFiltered = [NSMutableArray new];
        for (AddressFormList *address in _list) {
            for (NSString *name in listName) {
                if ([address.address_name isEqualToString:name] && ![listFiltered containsObject:address]) {
                    [listFiltered addObject:address];
                }
            }
            for (NSString *receiver in listReceiver) {
                if ([address.receiver_name isEqualToString:receiver] && ![listFiltered containsObject:address]) {
                    [listFiltered addObject:address];
                }
            }
        }
        [_list removeAllObjects];
        [_list addObjectsFromArray:listFiltered];
    }
    else
    {
        [_list removeAllObjects];
        [_list addObjectsFromArray:_listTemp];
    }
    
    _searchKeyword = searchBar.text;
    
    [_table reloadData];
    
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
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
        
        UIColor *redColor = [UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0];
        MGSwipeButton *trash = [MGSwipeButton buttonWithTitle:@"Hapus"
                                              backgroundColor:redColor
                                                      padding:padding
                                                     callback:^BOOL(MGSwipeTableCell *sender) {
            [self deleteListAtIndexPath:indexpath];
            return YES;
        }];
        trash.titleLabel.font = [UIFont fontWithName:trash.titleLabel.font.fontName size:12];
        
        UIColor *blueColor = [UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0];
        MGSwipeButton *flag = [MGSwipeButton buttonWithTitle:@"Jadikan\nUtama"
                                             backgroundColor:blueColor
                                                     padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self setAsDefaultAtIndexPath:indexpath];
            return YES;
        }];
        flag.titleLabel.font = [UIFont fontWithName:flag.titleLabel.font.fontName size:12];
        
        return @[trash, flag];
    }
    return nil;
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [self setAsDefaultAtIndexPath:_indexPath];
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {            
            [self deleteListAtIndexPath:_indexPath];
            [self.navigationController popToViewController:self animated:YES];
        }
    }
}


#pragma mark - Method
- (LoadingView *)getLoadView:(int)tag
{
    if(loadingView == nil)
    {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    loadingView.tag = tag;
    
    return loadingView;
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    if(tag == CTagRequest)
    {
        NSString *query = [_datainput objectForKey:API_QUERY_KEY]?:@"";
        NSInteger userID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
        
        return @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APIGETUSERADDRESSKEY,
                                kTKPDPROFILE_APIPAGEKEY : @(_page),
                                kTKPDPROFILE_APILIMITKEY : @(kTKPDPROFILESETTINGADDRESS_LIMITPAGE),
                                kTKPD_USERIDKEY : @(userID),
                                API_QUERY_KEY : query
                                };
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag
{
    if(tag == CTagRequest)
        return kTKPDPROFILE_SETTINGAPIPATH;
    
    return nil;
}

- (id)getObjectManager:(int)tag
{
    if(tag == CTagRequest)
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
        return _objectmanager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    if(tag == CTagRequest)
        return ((AddressForm *) stat).status;
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if(tag == CTagRequest)
    {
        [self requestSuccess:successResult withOperation:operation];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        _doneBarButtonItem.enabled = YES;
        
    }
}


- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    if(tag == CTagRequest)
    {
    }
}

- (void)actionBeforeRequest:(int)tag
{

}

- (void)actionRequestAsync:(int)tag
{

}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    if(tag == CTagRequest)
    {
        [_refreshControl endRefreshing];
        _table.tableFooterView = [self getLoadView:CTagRequest].view;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        _doneBarButtonItem.enabled = YES;
    }
}


#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    if(loadingView.tag == CTagRequest)
    {
        _table.tableFooterView = _footer;
        [_act startAnimating];
        [self request];
    }
}

#pragma mark - Address add delegate

- (void)successAddAddress
{
    [_list removeAllObjects];

    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    [self request];
}

@end