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
#import "TKPDTabShopNavigationController.h"

#import "DetailProductViewController.h"
#import "SearchResultShopCell.h"
#import "SearchResultViewController.h"
#import "SortViewController.h"
#import "FilterViewController.h"
#import "DetailShopViewController.h"
#import "HotlistResultViewController.h"

#import "SearchResultShopViewController.h"

#import "ShopProductViewController.h"
#import "ShopTalkViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"

@interface SearchResultShopViewController ()<UITableViewDelegate, UITableViewDataSource, SearchResultShopCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) NSMutableArray *product;
@property (weak, nonatomic) IBOutlet UIView *shopview;

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
    NSTimer *_timer;
    
    SearchItem *_searchitem;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
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
    
    /** set first page become 1 **/
    _page = 1;
    
    /** set max data per page request **/
    _limit = kTKPDSEARCH_LIMITPAGE;
    
    /** set inset table for different size**/
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        //inset.bottom += 200;
        _table.contentInset = inset;
    }
    else{
        UIEdgeInsets inset = _table.contentInset;
        //inset.bottom += 280;
        _table.contentInset = inset;
    }
    
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
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateViewShop:) name:@"setfilterShop" object:nil];
    [nc addObserver:self selector:@selector(setDepartmentID:) name:@"setDepartmentID" object:nil];

    _shopview.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self loadData];
        }
    }
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
            _table.tableFooterView = nil;
        }
	}
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = (_product.count%2==0)?_product.count/2:_product.count/2+1;
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
            
            UIImageView *thumb = (UIImageView*)((SearchResultShopCell*)cell).thumb;
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            UIActivityIndicatorView *act = ((SearchResultShopCell*)cell).act;
            [act startAnimating];
            NSLog(@"============================== START GET %@ IMAGE =====================", [_data objectForKey:kTKPDSEARCH_DATATYPE]);
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
                
                [act stopAnimating];
                NSLog(@"============================== DONE GET %@ IMAGE =====================", [_data objectForKey:kTKPDSEARCH_DATATYPE]);
    #pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [act stopAnimating];
                NSLog(@"============================== DONE GET %@ IMAGE =====================", [_data objectForKey:kTKPDSEARCH_DATATYPE]);
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SearchItem class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SearchResult class]];
    
    // setup object mappings
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[List class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDSEARCH_APISHOPIDKEY,
                                                 kTKPDSEARCH_APISHOPIMAGEKEY,
                                                 kTKPDSEARCH_APISHOPLOCATIONKEY,
                                                 kTKPDSEARCH_APISHOPTOTALTRANSACTIONKEY,
                                                 kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY,
                                                 kTKPDSEARCH_APISHOPTOTALFAVKEY
                                                 ]];
    
    /** paging mapping **/
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIURINEXTKEY:kTKPDSEARCH_APIURINEXTKEY}];
    
    /** redirect mapping & hascatalog **/
    RKObjectMapping *redirectMapping = [RKObjectMapping mappingForClass:[SearchRedirect class]];
    [redirectMapping addAttributeMappingsFromDictionary: @{kTKPDSEARCH_APIREDIRECTURLKEY:kTKPDSEARCH_APIREDIRECTURLKEY,
                                                           kTKPDSEARCH_APIDEPARTEMENTIDKEY:kTKPDSEARCH_APIDEPARTEMENTIDKEY,
                                                           kTKPDSEARCH_APIHASCATALOGKEY:kTKPDSEARCH_APIHASCATALOGKEY}];
    
    //add list relationship
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APILISTKEY toKeyPath:kTKPDSEARCH_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // add page relationship
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APIPAGINGKEY toKeyPath:kTKPDSEARCH_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];

    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDSEARCH_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptor];
}


- (void)loadData
{
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    _requestcount ++;

    NSString *querry =[_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *type = kTKPDSEARCH_DATASEARCHSHOPKEY;
    NSString *deptid =[_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    NSDictionary* param;
    
    if (deptid == nil ) {
        param = @{
                  kTKPDSEARCH_APIQUERYKEY : querry?:@"",
                  kTKPDSEARCH_APIACTIONTYPEKEY : type?:@"",
                  kTKPDSEARCH_APIPAGEKEY : @(_page),
                  kTKPDSEARCH_APILIMITKEY : @(kTKPDSEARCH_LIMITPAGE),
                  kTKPDSEARCH_APIORDERBYKEY : [_params objectForKey:kTKPDSEARCH_APIORDERBYKEY]?:@"",
                  kTKPDSEARCH_APILOCATIONKEY : [_params objectForKey:kTKPDSEARCH_APILOCATIONKEY]?:@"",
                  kTKPDSEARCH_APISHOPTYPEKEY : [_params objectForKey:kTKPDSEARCH_APISHOPTYPEKEY]?:@"",
                  kTKPDSEARCH_APIPRICEMINKEY : [_params objectForKey:kTKPDSEARCH_APIPRICEMINKEY]?:@"",
                  kTKPDSEARCH_APIPRICEMAXKEY : [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@""
                  };
    }
    else{
        param = @{
                  kTKPDSEARCH_APIDEPARTEMENTIDKEY : deptid?:@"",
                  kTKPDSEARCH_APIACTIONTYPEKEY : type?:@"",
                  kTKPDSEARCH_APIPAGEKEY : @(_page),
                  kTKPDSEARCH_APILIMITKEY : @(kTKPDSEARCH_LIMITPAGE),
                  kTKPDSEARCH_APIORDERBYKEY : [_params objectForKey:kTKPDSEARCH_APIORDERBYKEY]?:@"",
                  kTKPDSEARCH_APILOCATIONKEY : [_params objectForKey:kTKPDSEARCH_APILOCATIONKEY]?:@"",
                  kTKPDSEARCH_APISHOPTYPEKEY : [_params objectForKey:kTKPDSEARCH_APISHOPTYPEKEY]?:@"",
                  kTKPDSEARCH_APIPRICEMINKEY : [_params objectForKey:kTKPDSEARCH_APIPRICEMINKEY]?:@"",
                  kTKPDSEARCH_APIPRICEMAXKEY : [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@""
                  };
    }
    
    _requestcount ++;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDSEARCH_APIPATH parameters:param];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult];
        [_table reloadData];
        _isrefreshview = NO;
        //[_act stopAnimating];
        //_table.tableFooterView = nil;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        NSLog(@"============================== DONE GET %@ =====================", [_data objectForKey:kTKPDSEARCH_DATATYPE]);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alertView show];
        //[_act stopAnimating];
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        NSLog(@"============================== DONE GET %@ =====================", [_data objectForKey:kTKPDSEARCH_DATATYPE]);
    }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:_request];

    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}


-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    _searchitem = [result objectForKey: @""];
    
    NSString *statusstring = _searchitem.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        NSString *uriredirect = _searchitem.result.redirect_url.redirect_url;
        
        if (uriredirect == nil) {
            
            //TODO::
            [_product addObjectsFromArray:_searchitem.result.list];
            
            if (_product.count == 0) {
                [_act stopAnimating];
                _table.tableFooterView = nil;
            }
            
            if (_product.count >0) {
                
                _urinext =  _searchitem.result.paging.uri_next;
                
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
                
                _page = [[queries objectForKey:kTKPDSEARCH_APIPAGEKEY] integerValue];
                
                NSLog(@"next page : %d",_page);
                _isnodata = NO;
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
                NSString *deptid = _searchitem.result.redirect_url.department_id;
                [_params setObject:deptid forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
                [self loadData];
            }
        }
        
        _shopview.hidden = NO;
    }
}

-(void)requesttimeout
{
    [self cancel];
}

-(void)requestfailure:(id)object
{
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

#pragma mark - cell delegate
-(void)SearchResultShopCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    List *list = _product[indexpath.row];
    NSMutableArray *viewcontrollers = [NSMutableArray new];
    /** create new view controller **/
    ShopProductViewController *v = [ShopProductViewController new];
    v.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:@(0)};
    [viewcontrollers addObject:v];
    ShopTalkViewController *v1 = [ShopTalkViewController new];
    v1.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:@(0)};
    [viewcontrollers addObject:v1];
    ShopReviewViewController *v2 = [ShopReviewViewController new];
    v2.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:@(0)};
    [viewcontrollers addObject:v2];
    ShopNotesViewController *v3 = [ShopNotesViewController new];
    v3.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:@(0)};
    [viewcontrollers addObject:v3];
    /** Adjust View Controller **/
    TKPDTabShopNavigationController *tapnavcon = [TKPDTabShopNavigationController new];
    NSIndexPath *indexpathparam = [_params objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    tapnavcon.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id,
                       kTKPDFILTERSORT_DATAINDEXPATHKEY: indexpathparam?:0};
    [tapnavcon setViewControllers:viewcontrollers animated:YES];
    [tapnavcon setSelectedIndex:0];

    [self.navigationController pushViewController:tapnavcon animated:YES];
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
                        kTKPDFILTER_DATAINDEXPATHKEY: indexpath?:0};
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
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
-(void)reset:(UITableViewCell*)cell
{
    ((SearchResultShopCell*)cell).thumb = nil;
    ((SearchResultShopCell*)cell).shopname = nil;
    ((SearchResultShopCell*)cell).favbutton = nil;
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    [_product removeAllObjects];
    _page = 1;
    _isrefreshview = YES;
    _requestcount = 0;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}


#pragma mark - Post Notification Methods

-(void)setDepartmentID:(NSNotification*)notification
{
    NSDictionary* userinfo = notification.userInfo;
    [_params setObject:[userinfo objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY]?:@"" forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    [self refreshView:nil];
}

- (void)updateViewShop:(NSNotification *)notification;
{
    NSDictionary *userinfo = notification.userInfo;
    [_params addEntriesFromDictionary:userinfo];
    [self refreshView:nil];
}

@end