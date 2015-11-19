//
//  SearchResultShopViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "search.h"
#import "detail.h"
#import "sortfiltershare.h"

#import "SearchItem.h"

#import "TKPDTabNavigationController.h"

#import "DetailProductViewController.h"
#import "SearchResultShopCell.h"
#import "SearchResultViewController.h"
#import "SortViewController.h"
#import "FilterViewController.h"
#import "HotlistResultViewController.h"

#import "SearchResultShopViewController.h"

#import "NSDictionaryCategory.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NoResultView.h"

#import "URLCacheController.h"
#import "ShopContainerViewController.h"

@interface SearchResultShopViewController ()<UITableViewDelegate, UITableViewDataSource, SearchResultShopCellDelegate,SortViewControllerDelegate,FilterViewControllerDelegate, TokopediaNetworkManagerDelegate, LoadingViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) NSMutableArray *product;
@property (weak, nonatomic) IBOutlet UIView *shopview;

-(void)cancel;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

@end

@implementation SearchResultShopViewController
{
    NSInteger _page;
    NSInteger _limit;
    
    NSMutableArray *_urlarray;
    NSMutableDictionary *_params;
    
    NSString *_urinext;
    NSString *_uriredirect;
    
    BOOL _isnodata;
    BOOL _isrefreshview;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    
    SearchItem *_searchitem;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSOperationQueue *_operationQueue;
    
    
    LoadingView *loadingView;
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _requestcount = 0;
        _isnodata = YES;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /** create new **/
    _product = [NSMutableArray new];
    _urlarray = [NSMutableArray new];
    _params = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    /** set first page become 1 **/
    _page = 1;
    
    /** set max data per page request **/
    _limit = kTKPDSEARCH_LIMITPAGE;
    
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    /** set table footer view (loading act) **/
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    if (_data) {
        [_params addEntriesFromDictionary:_data];
    }
    
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    _shopview.hidden = YES;
    
    //cache
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDSEARCH_CACHEFILEPATH];
    NSString *querry =[_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *deptid =[_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDSEARCHSHOP_APIRESPONSEFILEFORMAT, querry?:deptid]];

    _cachecontroller.filePath = _cachepath;
//    _cachecontroller.URLCacheInterval = 86400.0;
    _cachecontroller.URLCacheInterval = 0;
    [_cachecontroller initCacheWithDocumentPath:path];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCategory:)
                                                 name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY
                                               object:nil];    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_isrefreshview) {
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self loadData];
        }
    }
    
    [TPAnalytics trackScreenName:@"Shop Search Result"];
    self.screenName = @"Shop Search Result";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setTabShopActive" object:@""];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}



#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section]-1;
    
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
		
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext !=0 ) {
            /** called if need to load next page **/
            [self loadData];
        }
        else{
            [_act stopAnimating];
            _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
	}
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = _product.count;
#ifdef kTKPDSEARCHRESULT_NODATAENABLE
    return _isnodata?1:count;
#else
    return _isnodata?0:count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDSEARCHRESULTSHOPCELL_IDENTIFIER;
		
		cell = (SearchResultShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [SearchResultShopCell newcell];
			((SearchResultShopCell*)cell).delegate = self;
		}
        
        if (_product.count>indexPath.row) {
            
            ((SearchResultShopCell*)cell).indexpath = indexPath;
            
            List *list = [_product objectAtIndex:indexPath.row];

            ((SearchResultShopCell*)cell).shopname.text = list.shop_name?:@"";
            //((UILabel*)((SearchResultCell*)cell).labelalbum[i]).text = searchitem.product_name?:@"";
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.shop_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            
            if([list.shop_gold_status isEqualToString:@"1"]){
                ((SearchResultShopCell*)cell).goldBadgeView.hidden = NO;
            }else{
                ((SearchResultShopCell*)cell).goldBadgeView.hidden = YES;
            }
            
            if([list.shop_is_fave_shop isEqualToString:@"1"]) {
                [((SearchResultShopCell*)cell).favbutton setImage:[UIImage imageNamed:@"icon_love_active.png"] forState:UIControlStateNormal];
            } else {
                [((SearchResultShopCell*)cell).favbutton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
            }
            
            UIImageView *thumb = (UIImageView*)((SearchResultShopCell*)cell).thumb;
            thumb = [UIImageView circleimageview:thumb];
            thumb.image = [UIImage imageNamed:@"icon_default_shop.jpg"];
            
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            UIActivityIndicatorView *act = ((SearchResultShopCell*)cell).act;
            [act startAnimating];
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image];
                [act stopAnimating];
    #pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [act stopAnimating];
            }];
        }
        else [self reset:cell];
    } else {
        static NSString *CellIdentifier = kTKPDSEARCH_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDSEARCH_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDSEARCH_NODATACELLDESCS;
    }
	return cell;
}




#pragma mark - Request + Mapping
-(void)cancel
{
//    [_request cancel];
//    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)loadData
{
    if ([self getNetworkManager].getObjectRequest.isExecuting) return;
	[_cachecontroller getFileModificationDate];
	
    _timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
//	if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1 || _isrefreshview) {
        if (!_isrefreshview) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        }
        
        [[self getNetworkManager] doRequest];
//    }else {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
//        NSLog(@"cache and updated in last 24 hours.");
//        [self requestfailure:nil];
//	}
}


-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _searchitem = stats;
    BOOL status = [_searchitem.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (_page<=1 && !_isrefreshview) {
            [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            //save response data to plist
            [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        }
        
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    if (_timeinterval > _cachecontroller.URLCacheInterval || _page>1 || _isrefreshview) {
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
            _searchitem = stats;
            BOOL status = [_searchitem.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
}

-(void)requestprocess:(id)object
{
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        
        _searchitem = [result objectForKey: @""];

        NSString *statusstring = _searchitem.status;
        BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            NSString *uriredirect = _searchitem.result.redirect_url;
            
            if (uriredirect == nil) {
                if (_page == 1) {
                    [_product removeAllObjects];
                }
                
                [_product addObjectsFromArray:_searchitem.result.list];
                
                if (_product.count == 0) {
                    [_act stopAnimating];
                    _table.tableFooterView = [NoResultView new].view;
                }
                
                if (_product.count >0) {
                    _table.tableFooterView = nil;
                    _urinext =  _searchitem.result.paging.uri_next;
                    
                    NSInteger tempInt = [[tokopediaNetworkManager splitUriToPage:_urinext] integerValue];
                    if(tempInt == _page)
                        _urinext = nil;
                    _page = tempInt;
                    
                    NSLog(@"next page : %zd",_page);
                    _isnodata = NO;
                    
                    [_table reloadData];
                }
            }
            else{
                _uriredirect =  uriredirect;
                NSURL *url = [NSURL URLWithString:_uriredirect];
                NSArray* querry = [[url path] componentsSeparatedByString: @"/"];
                
                // Redirect URI to hotlist
                if ([querry[1] isEqualToString:@"hot"]) {
                    HotlistResultViewController *vc = [HotlistResultViewController new];
                    vc.data = @{kTKPDSEARCH_DATAISSEARCHHOTLISTKEY : @(YES), kTKPDSEARCHHOTLIST_APIQUERYKEY : querry[2]};
                    [self.navigationController pushViewController:vc animated:NO];
                }
                // redirect uri to search category
                if ([querry[1] isEqualToString:@"p"]) {
                    NSString *deptid = _searchitem.result.department_id;
                    [_params setObject:deptid forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
                    [self loadData];
                }
            }
            
            _shopview.hidden = NO;
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - cell delegate

-(void)SearchResultShopCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    List *list = _product[indexpath.row];
    
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    NSIndexPath *indexPath = [_params objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    container.data = @{kTKPDDETAIL_APISHOPIDKEY : list.shop_id,
                       kTKPDDETAIL_APISHOPNAMEKEY : list.shop_name,
                       kTKPDDETAIL_APISHOPISGOLD : list.shop_gold_status,
                       kTKPDFILTERSORT_DATAINDEXPATHKEY : indexPath?:@0,
                       kTKPD_AUTHKEY:[_data objectForKey : kTKPD_AUTHKEY]?:@{}
                       };
    [self.navigationController pushViewController:container animated:YES];
}

#pragma mark - TKPDTabNavigationController Tap Button Notification
-(IBAction)tap:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10:
        {
            // Action Sort Button
            NSIndexPath *indexpath = [_params objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            SortViewController *vc = [SortViewController new];
            vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPESHOPVIEWKEY),
                        kTKPDFILTER_DATAINDEXPATHKEY: indexpath?:@0};
            vc.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            
            break;
        }
        case 11:
        {
            // Action Filter Button
            FilterViewController *vc = [FilterViewController new];
            vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPESHOPVIEWKEY),
                        kTKPDFILTER_DATAFILTERKEY: _params};
            vc.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
- (TokopediaNetworkManager *)getNetworkManager
{
    if(tokopediaNetworkManager == nil)
    {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    
    return tokopediaNetworkManager;
}

- (LoadingView *)getLoadView
{
    if(loadingView == nil)
    {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

-(void)reset:(UITableViewCell*)cell
{
    ((SearchResultShopCell*)cell).thumb = nil;
    ((SearchResultShopCell*)cell).shopname = nil;
    ((SearchResultShopCell*)cell).favbutton = nil;
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    _page = 1;
    _isrefreshview = YES;
    _requestcount = 0;
    
    [_table reloadData];
    [self loadData];
}

#pragma mark - Sort Delegate
-(void)SortViewController:(SortViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
    [_act startAnimating];
    _table.tableFooterView = _footer;
}

#pragma mark - Filter Delegate
-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
    [_act startAnimating];
    _table.tableFooterView = _footer;
}

#pragma mark - Category notification

- (void)changeCategory:(NSNotification *)notification
{
    [_product removeAllObjects];
    [_params setObject:[notification.userInfo objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY] forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    [self refreshView:nil];
    _table.tableFooterView = _footer;
    [_act startAnimating];
}



#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    [self loadData];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    NSString *querry = [_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *type = kTKPDSEARCH_DATASEARCHSHOPKEY;
    NSString *deptid = [_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    
    NSDictionary* param;
    if (deptid == nil ) {
        param = @{kTKPDSEARCH_APIQUERYKEY       :   querry?:@"",
                  kTKPDSEARCH_APIACTIONTYPEKEY  :   type?:@"",
                  kTKPDSEARCH_APIPAGEKEY        :   @(_page),
                  kTKPDSEARCH_APILIMITKEY       :   @(kTKPDSEARCH_LIMITPAGE),
                  kTKPDSEARCH_APIORDERBYKEY     :   [_params objectForKey:kTKPDSEARCH_APIORDERBYKEY]?:@"",
                  kTKPDSEARCH_APILOCATIONKEY    :   [_params objectForKey:kTKPDSEARCH_APILOCATIONKEY]?:@"",
                  kTKPDSEARCH_APISHOPTYPEKEY    :   [_params objectForKey:kTKPDSEARCH_APISHOPTYPEKEY]?:@"",
                  kTKPDSEARCH_APIPRICEMINKEY    :   [_params objectForKey:kTKPDSEARCH_APIPRICEMINKEY]?:@"",
                  kTKPDSEARCH_APIPRICEMAXKEY    :   [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@""
                  };
    } else {
        param = @{kTKPDSEARCH_APIDEPARTEMENTIDKEY   :   deptid?:@"",
                  kTKPDSEARCH_APIACTIONTYPEKEY      :   type?:@"",
                  kTKPDSEARCH_APIPAGEKEY            :   @(_page),
                  kTKPDSEARCH_APILIMITKEY           :   @(kTKPDSEARCH_LIMITPAGE),
                  kTKPDSEARCH_APIORDERBYKEY         :   [_params objectForKey:kTKPDSEARCH_APIORDERBYKEY]?:@"",
                  kTKPDSEARCH_APILOCATIONKEY        :   [_params objectForKey:kTKPDSEARCH_APILOCATIONKEY]?:@"",
                  kTKPDSEARCH_APISHOPTYPEKEY        :   [_params objectForKey:kTKPDSEARCH_APISHOPTYPEKEY]?:@"",
                  kTKPDSEARCH_APIPRICEMINKEY        :   [_params objectForKey:kTKPDSEARCH_APIPRICEMINKEY]?:@"",
                  kTKPDSEARCH_APIPRICEMAXKEY        :   [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@""
                  };
    }
    
    return param;
}

- (NSString*)getPath:(int)tag
{
    return kTKPDSEARCH_APIPATH;
}

- (id)getObjectManager:(int)tag
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SearchItem class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SearchResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIHASCATALOGKEY:kTKPDSEARCH_APIHASCATALOGKEY,
                                                        kTKPDSEARCH_APISEARCH_URLKEY:kTKPDSEARCH_APISEARCH_URLKEY,
                                                        kTKPDSEARCH_APIREDIRECTURLKEY:kTKPDSEARCH_APIREDIRECTURLKEY,
                                                        kTKPDSEARCH_APIDEPARTMENTIDKEY:kTKPDSEARCH_APIDEPARTMENTIDKEY
                                                        }];
    
    // setup object mappings
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[List class]];
    [listMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APISHOPIDKEY:kTKPDSEARCH_APISHOPIDKEY,
                                                      kTKPDSEARCH_APISHOPIMAGEKEY:kTKPDSEARCH_APISHOPIMAGEKEY,
                                                      kTKPDSEARCH_APISHOPLOCATIONKEY:kTKPDSEARCH_APISHOPLOCATIONKEY,
                                                      kTKPDSEARCH_APISHOPTOTALTRANSACTIONKEY:kTKPDSEARCH_APISHOPTOTALTRANSACTIONKEY,
                                                      kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY:kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY,
                                                      kTKPDSEARCH_APISHOPTOTALFAVKEY:kTKPDSEARCH_APISHOPTOTALFAVKEY,
                                                      kTKPDSEARCH_APISHOPGOLDSHOP:kTKPDSEARCH_APISHOPGOLDSTATUS ,
                                                      kTKPDSEARCH_APISHOPISFAV:kTKPDSEARCH_APISHOPISFAV
                                                      }];
    
    /** paging mapping **/
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIURINEXTKEY:kTKPDSEARCH_APIURINEXTKEY}];
    
    //add list relationship
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APILISTKEY toKeyPath:kTKPDSEARCH_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // add page relationship
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APIPAGINGKEY toKeyPath:kTKPDSEARCH_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDSEARCH_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptor];
    return _objectmanager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    return ((SearchItem *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    [self requestsuccess:successResult withOperation:operation];
    [_table reloadData];
    _isrefreshview = NO;
    [_refreshControl endRefreshing];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{}

- (void)actionBeforeRequest:(int)tag
{}

- (void)actionRequestAsync:(int)tag
{}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    _isrefreshview = NO;
    [_refreshControl endRefreshing];
    _table.tableFooterView = [self getLoadView].view;
}

@end