//
//  HotlistViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Hotlist.h"
#import "ExpiringCache.h"
#import "home.h"
#import "HotlistViewController.h"
#import "HotlistResultViewController.h"

#pragma mark - HotlistView

@interface HotlistViewController ()
{
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
}

@property (nonatomic, strong) ExpiringCache *accountsCache;

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;

@property (nonatomic, strong) NSMutableArray *product;

@end

@implementation HotlistViewController
#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isnodata = YES;
    }
    return self;
}


#pragma mark - View Lifecylce
- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    _operationQueue = [NSOperationQueue new];
    
    /** create new **/
    _product = [NSMutableArray new];
    
    /** set first page become 1 **/
    _page = 1;
    
    /** set max data per page request **/
    _limit = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    /** set inset table for different size**/
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 115;
        _table.contentInset = inset;
    }
    else{
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 200;
        _table.contentInset = inset;
    }
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    /** set table footer view (loading act) **/
    _table.tableFooterView = _footer;
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    if (!self.accountsCache) {
        self.accountsCache = [[ExpiringCache alloc] init];
        self.accountsCache.expiryTimeInterval = 360; // 2 hours
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            // get an object
            NSObject *cachedObj = [self.accountsCache objectForKey:@"hotlist"];
            if (!cachedObj) {
                [self loadData];
            }
        }
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
}


#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDPRODUCTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : _product.count;
#else
    return _isnodata ? 0 : _product.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDHOTLISTCELL_IDENTIFIER;
        UIFont * font = kTKPDHOME_FONTHOTLIST;
		
		cell = (HotlistCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [HotlistCell newcell];
			((HotlistCell*)cell).delegate = self;
		}
		
		if (_product.count > indexPath.row) {
            
            HotlistList *hotlist = _product[indexPath.row];
            ((HotlistCell*)cell).indexpath = indexPath;
            ((HotlistCell*)cell).pricelabel.text = hotlist.price_start;
            ((HotlistCell*)cell).namelabel.text = hotlist.title;
            
            //((HotlistCell*)cell).pricelabel.font = font;
            
            [((HotlistCell*)cell).act startAnimating];
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:hotlist.image_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            
            UIImageView *thumb = ((HotlistCell*)cell).productimageview;
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            [((HotlistCell*)cell).act startAnimating];
            
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
                
                [((HotlistCell*)cell).act stopAnimating];
#pragma clang diagnosti c pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [((HotlistCell*)cell).act stopAnimating];
            }];
            
		}else [self reset:((HotlistCell*)cell)];
	} else {
		static NSString *CellIdentifier = kTKPDHOME_STANDARDTABLEVIEWCELLIDENTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		cell.textLabel.text = kTKPDHOME_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDHOME_NODATACELLDESCS;
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
		
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            /** called if need to load next page **/
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [self configureRestKit];
            [self loadData];
        }
	}
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
    // initialize AFNetworking HTTPClient + restkit
    //TraktAPIClient *client = [TraktAPIClient sharedClient];
    _objectmanager = [RKObjectManager sharedClient];
    
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Hotlist class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[HotlistResult class]];
    
    RKObjectMapping *hotlistMapping = [RKObjectMapping mappingForClass:[HotlistList class]];
    [hotlistMapping addAttributeMappingsFromArray:@[kTKPDHOME_APIURLKEY,kTKPDHOME_APITHUMBURLKEY,kTKPDHOME_APISTARTERPRICEKEY,kTKPDHOME_APITITLEKEY]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDHOME_APIURINEXTKEY:kTKPDHOME_APIURINEXTKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:hotlistMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];

    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLIST_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
    
    
}

- (void)loadData
{
    if (_request.isExecuting) return;
    
    // create a new one, this one is expired or we've never gotten it
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:kTKPDHOMEHOTLISTACT,
                            kTKPDHOME_APIPAGEKEY : @(_page),
                            kTKPDHOME_APILIMITPAGEKEY : @(kTKPDHOMEHOTLIST_LIMITPAGE)
                            };
    _requestcount ++;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDHOMEHOTLIST_APIPATH parameters:param];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult withOperation:operation];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        //[_act stopAnimating];
        //_table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    Hotlist *hotlist = stat;
    BOOL status = [hotlist.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [_product addObjectsFromArray: hotlist.result.list];
        
        [self requestproses:object];

        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDHOMEHOTLIST_APIRESPONSEFILE];
        NSError *error;
        BOOL success = [result writeToFile:path atomically:YES];
        if (!success) {
            NSLog(@"writeToFile failed with error %@", error);
        }
        
    }
}


-(void)requesttimeout
{
    [self cancel];
}
  

-(void)requestfailure:(id)object
{

    NSDictionary* result;
	
	NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDHOMEHOTLIST_APIRESPONSEFILE];
	result = [NSDictionary dictionaryWithContentsOfFile:path];
    
}

-(void)requestproses:(id)object{
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        Hotlist *hotlist = stat;
        BOOL status = [hotlist.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            [_product addObjectsFromArray: hotlist.result.list];
            
            if (_product.count >0) {
                _isnodata = NO;
                _urinext =  hotlist.result.paging.uri_next;
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
                
                _page = [[queries objectForKey:kTKPDHOME_APIPAGEKEY] integerValue];
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

#pragma mark - Delegate
-(void)HotlistCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withimageview:(UIImageView *)imageview
{
    HotlistResultViewController *vc = [HotlistResultViewController new];
    vc.image = ((HotlistCell*)cell).productimageview.image;
    HotlistList *hotlist = _product[indexpath.row];
    NSURL *url = [NSURL URLWithString:hotlist.url];
    NSArray* querry = [[url path] componentsSeparatedByString: @"/"];
    
    if ([querry[1] isEqualToString:kTKPDHOME_DATAURLREDIRECTHOTKEY]) {
        vc.data = @{kTKPDHOME_DATAQUERYKEY: querry[2]?:@"", kTKPHOME_DATAHEADERIMAGEKEY: imageview};
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    // redirect uri to search category
    else if ([querry[1] isEqualToString:kTKPDHOME_DATAURLREDIRECTCATEGORY]) {
        //TODO:: GO TO SEARCH
        //SearchResultViewController *vc = [SearchResultViewController new];
        //NSString *searchtext = hashtags.department_id;
        //vc.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
        //SearchResultViewController *vc1 = [SearchResultViewController new];
        //vc1.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
        //SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
        //vc2.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
        //NSArray *viewcontrollers = @[vc,vc1,vc2];
        //
        //TKPDTabNavigationController *c = [TKPDTabNavigationController new];
        //
        //[c setSelectedIndex:0];
        //[c setViewControllers:viewcontrollers];
        //UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
        //[nav.navigationBar setTranslucent:NO];
        //[self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else{
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - Methods
-(void)reset:(UITableViewCell*)cell
{
    ((HotlistCell*)cell).productimageview = nil;
    ((HotlistCell*)cell).pricelabel = nil;
    ((HotlistCell*)cell).namelabel = nil;
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestcount = 0;
    [_product removeAllObjects];
    _page = 1;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

@end
