//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TKPDTabInboxTalkNavigationController.h"
#import "ShopNotesPageViewController.h"
#import "MyShopNoteDetailViewController.h"
#import "GeneralList1GestureCell.h"

#import "Notes.h"
#import "GeneralAction.h"
#import "InboxTalk.h"

#import "inbox.h"
#import "string_home.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "detail.h"
#import "generalcell.h"

#import "URLCacheController.h"
#import "ShopPageHeader.h"
#import "ShopPageRequest.h"

#import "NoResultReusableView.h"

@interface ShopNotesPageViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIAlertViewDelegate,
    TKPDTabInboxTalkNavigationControllerDelegate,
    ShopPageHeaderDelegate,
    MGSwipeTableCellDelegate,
    MyShopNoteDetailDelegate,
    NoResultDelegate
>

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UIView *fakeStickytab;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *list;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *stickyTab;

@end

@implementation ShopNotesPageViewController
{
    BOOL _isNoData;
    BOOL _isrefreshview;
    BOOL _iseditmode;
    
    NSInteger _page;
    NSInteger _limit;
    NSInteger _viewposition;
    
    NSMutableDictionary *_paging;
    
    NSString *_uriNext;
    NSString *_talkNavigationFlag;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestCount;
    NSInteger _requestUnfollowCount;
    NSInteger _requestDeleteCount;
    
    NSTimer *_timer;
    UISearchBar *_searchbar;
    NSString *_keyword;
    NSString *_readstatus;
    NSString *_navthatwillrefresh;
    BOOL _isrefreshnav;
    BOOL _isNeedToInsertCache;
    BOOL _isLoadFromCache;
    
    
    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectUnfollowmanager;
    __weak RKObjectManager *_objectDeletemanager;
    
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestUnfollow;
    __weak RKManagedObjectRequestOperation *_requestDelete;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationUnfollowQueue;
    NSOperationQueue *_operationDeleteQueue;
    ShopPageRequest *_shopPageRequest;
    
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    Notes *_notes;
    Shop *_shop;
    NoResultReusableView *_noResultView;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isNoData = YES;
    }
    
    return self;
}


- (void)initNotification {

}
- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Toko ini belum mempunyai catatan"
                                  desc:@""
                              btnTitle:nil];
}

#pragma mark - Life Cycle
- (void)addBottomInsetWhen14inch {
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 155;
        _table.contentInset = inset;
    }
    else{
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 240;
        _table.contentInset = inset;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBottomInsetWhen14inch];
    _talkNavigationFlag = [_data objectForKey:@"nav"];
    _page = 1;
    
    _operationQueue = [NSOperationQueue new];

    _list = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    
    
    _table.delegate = self;
    _table.dataSource = self;
    
    _shopPageHeader = [ShopPageHeader new];
    _shopPageHeader.delegate = self;
    _shopPageHeader.data = _data;
    
    _header = _shopPageHeader.view;
    
    _shopPageRequest = [[ShopPageRequest alloc]init];
    
    UIView *btmGreenLine = (UIView *)[_header viewWithTag:22];
    [btmGreenLine setHidden:NO];
    _stickyTab = [(UIView *)_header viewWithTag:18];
    
    _table.tableFooterView = _footer;
    //_table.tableHeaderView = _header;
    [self initNoResultView];
    
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    if (_list.count > 0) {
        _isNoData = NO;
    }
    
    [_fakeStickytab.layer setShadowOffset:CGSizeMake(0, 0.5)];
    [_fakeStickytab.layer setShadowColor:[UIColor colorWithWhite:0 alpha:1].CGColor];
    [_fakeStickytab.layer setShadowRadius:1];
    [_fakeStickytab.layer setShadowOpacity:0.3];
    
    [self initNotification];
    [self configureRestKit];
    //[self loadData];
    [self requestNotes];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [TPAnalytics trackScreenName:@"Shop - Note List"];
    self.screenName = @"Shop - Note List";
    
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isNoData && _page < 1) {
            //[self loadData];
            [self requestNotes];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _header.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesList *list = _list[indexPath.row];
    MyShopNoteDetailViewController *vc = [MyShopNoteDetailViewController new];
    vc.delegate = self;
    vc.noteList = list;
    vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                kTKPDDETAIL_DATATYPEKEY: @(kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY)?:kTKPDSETTINGEDIT_DATATYPEDEFAULTVIEWKEY,
                kTKPDNOTES_APINOTEIDKEY:list.note_id?:@(0),
                kTKPDNOTES_APINOTETITLEKEY:list.note_title?:@"",
                kTKPDNOTES_APINOTESTATUSKEY:list.note_status?:@"",
                @"shop_id" : [_data objectForKey:@"shop_id"]?:@""
                };
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isNoData) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            [self configureRestKit];
            //[self loadData];
            [self requestNotes];
        } else {
            _table.tableFooterView = nil;
            [_act stopAnimating];
        }
    }
}


#pragma mark - TableView Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isNoData ? 0 : _list.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    if (!_isNoData) {
        
        NSString *cellid = kTKPDGENERALLIST1GESTURECELL_IDENTIFIER;
        
        cell = (GeneralList1GestureCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [GeneralList1GestureCell newcell];
            ((GeneralList1GestureCell*)cell).delegate = self;
        }
        
        if (_list.count > indexPath.row) {
            NotesList *list = _list[indexPath.row];
            ((GeneralList1GestureCell*)cell).textLabel.text = list.note_title;
            ((GeneralList1GestureCell*)cell).detailTextLabel.hidden = YES;
            ((GeneralList1GestureCell*)cell).indexpath = indexPath;
            ((GeneralList1GestureCell*)cell).type = kTKPDGENERALCELL_DATATYPETWOBUTTONKEY;
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

#pragma mark - Request + Mapping

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
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)loadData
{
    if (_request.isExecuting) return;
    
    _requestCount++;
    
    NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPNOTESKEY,
                            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0),
                                                        @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@"",
                            };
    
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDDETAILSHOP_APIPATH
                                                                parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        self.table.hidden = NO;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [self requestSuccess:mappingResult withOperation:operation];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _table.hidden = NO;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [self requestFailure:error];
    }];
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeout)
                                            userInfo:nil
                                             repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _notes = stats;
    BOOL status = [_notes.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    
    //    NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
    //    for (RKResponseDescriptor *descriptor in _objectManager.responseDescriptors) {
    //        [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
    //    }
    //
    //    RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
    //    NSError *mappingError = nil;
    //    BOOL isMapped = [mapper execute:&mappingError];
    //    if (isMapped && !mappingError) {
    //        RKMappingResult *mappingresult = [mapper mappingResult];
    //        NSDictionary *result = mappingresult.dictionary;
    //        id stats = [result objectForKey:@""];
    //        _talk = stats;
    //        BOOL status = [_talk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    //        if (status) {
    //            [self requestProcess:mappingresult];
    //        }
    //    }
}

-(void)requestProcess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            
            _notes = stats;
            
            BOOL status = [_notes.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                
                NSArray *list = _notes.result.list;
                _isNoData = NO;
                [_list addObjectsFromArray:list];
                
                
                [self.table reloadData];
                if (_list.count == 0) {
                    _table.tableFooterView = _noResultView;
                    _act.hidden = YES;
                }else{
                    [_noResultView removeFromSuperview];
                }
                
            }
        }else{
            
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestCount);
                    //_table.tableFooterView = _footer;
                    //[_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_act stopAnimating];
                    self.table.tableFooterView = _noResultView;
                }
            }
            else
            {
                [_act stopAnimating];
                self.table.tableFooterView = _noResultView;
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}

-(void)requestNotes{
    [_shopPageRequest requestForShopNotesPageListingWithShopId:[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0)
                                                   shop_domain:[_data objectForKey:@"shop_domain"]?:@""
                                                     onSuccess:^(Notes *notes) {
                                                         _notes = notes;
                                                         NSArray *list = _notes.result.list;
                                                         _isNoData = NO;
                                                         [_list addObjectsFromArray:list];
                                                         
                                                         [self.table reloadData];
                                                         if (_list.count == 0) {
                                                             _table.tableFooterView = _noResultView;
                                                             _act.hidden = YES;
                                                         }else{
                                                             [_noResultView removeFromSuperview];
                                                         }
                                                     }
                                                     onFailure:^(NSError *error) {
                                                         [_act stopAnimating];
                                                         self.table.tableFooterView = _noResultView;
                                                     }];
}


#pragma mark - Refresh View
-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestCount = 0;
    [_list removeAllObjects];
    _page = 1;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    //[self loadData];
    [self requestNotes];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - Shop header delegate

- (void)didLoadImage:(UIImage *)image
{
    //    _navigationImageView.image = [image applyLightEffect];
}

- (void)didReceiveShop:(Shop *)shop
{
    _shop = shop;
}

- (id)didReceiveNavigationController {
    return self;
}

#pragma mark - Note detail delegate

- (void)successEditNote:(NotesList *)noteList {
    NSInteger index = [_list indexOfObject:noteList];
    [_list replaceObjectAtIndex:index withObject:noteList];
    [self.table reloadData];
}

@end
