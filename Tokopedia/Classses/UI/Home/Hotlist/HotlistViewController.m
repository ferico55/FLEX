//
//  HotlistViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Hotlist.h"

#import "home.h"
#import "HotlistViewController.h"
#import "HotListCell.h"
#import "TraktAPIClient.h"
#import "HotlistResultViewController.h"

#pragma mark - HotlistView

@interface HotlistViewController ()

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;

@property (nonatomic, strong) NSMutableArray *product;

@end

@implementation HotlistViewController
{
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;
}

#pragma mark - View Lifecylce
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    /** create new **/
    _product = [NSMutableArray new];
    
    /** set first page become 1 **/
    _page = 1;
    
    /** set max data per page request **/
    _limit = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    /** set inset table for different size**/
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 150;
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
    
    _isnodata = NO; //TODO: Remove this
    
    
    //if (_product.count > 0) {
    //    _isnodata = NO;
    //}
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    [self configureRestKit];
}

#pragma mark - Methods
-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    [_product removeAllObjects];
    _page = 1;
    
    [_table reloadData];
    /** request data **/
    [self loadData];
    //[self request:YES withrefreshControl:refresh];
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
		
		cell = (HotlistCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [HotlistCell newcell];
			((HotlistCell*)cell).delegate = self;
		}
		
		if (_product.count > indexPath.row) {
            
            HotlistList *hotlist = _product[indexPath.row];
            ((HotlistCell*)cell).pricelabel.text = hotlist.price_start;
            
            [((HotlistCell*)cell).act startAnimating];
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:hotlist.image_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.3];
            //request.URL = url;
            
            UIImageView *thumb = ((HotlistCell*)cell).productimageview;
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            [_act startAnimating];
            
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
                
                [_act stopAnimating];
#pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [_act stopAnimating];
            }];
            
		}
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
	if (row == indexPath.row+1) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
		
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            /** called if need to load next page **/
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [self loadData];
        }
	}
}

#pragma mark - Request + Mapping
- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient + restkit
    TraktAPIClient *client = [TraktAPIClient sharedClient];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
#define kTKPDHOME_APISTATUSKEY @"status"
#define kTKPDHOME_APISERVERPROCESSTIMEKEY @"server_process_time"
#define kTKPDHOME_APIRESULTKEY @"result"
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Hotlist class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPDHOME_APISTATUSKEY,kTKPDHOME_APISERVERPROCESSTIMEKEY,kTKPDHOME_APIRESULTKEY]];
    
    RKObjectMapping *hotlistMapping = [RKObjectMapping mappingForClass:[HotlistList class]];
    [hotlistMapping addAttributeMappingsFromArray:@[kTKPDHOME_APIURLKEY,kTKPDHOME_APITHUMBURLKEY,kTKPDHOME_APISTARTERPRICEKEY,kTKPDHOME_APITITLEKEY]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDHOME_APIURINEXTKEY:kTKPDHOME_APIURINEXTKEY}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLIST_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    RKResponseDescriptor *responseDescriptorHotlist = [RKResponseDescriptor responseDescriptorWithMapping:hotlistMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLIST_APIPATH keyPath:kTKPDHOMEHOTLIST_APILISTKEYPATH statusCodes:kTkpdIndexSetStatusCodeOK];
    
    RKResponseDescriptor *responseDescriptorPaging = [RKResponseDescriptor responseDescriptorWithMapping:pagingMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLIST_APIPATH keyPath:kTKPDHOMEHOTLIST_APIPAGINGKEYPATH statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
    [objectManager addResponseDescriptor:responseDescriptorHotlist];
    [objectManager addResponseDescriptor:responseDescriptorPaging];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:responseDescriptorHotlist.mapping forKey:(responseDescriptorHotlist.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptorPaging.mapping forKey:(responseDescriptorPaging.keyPath ?: [NSNull null])];
    
    [self loadData];
}

- (void)loadData
{
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:nil
                                   selector:@selector(requestfailure:)
                                   userInfo:nil
                                    repeats:NO];
    
	NSDictionary* param = @{@"auth":@(1),
                            kTKPDHOME_APIACTIONKEY:kTKPDHOMEHOTLISTACT,
                            kTKPDHOME_APIPAGEKEY : @(_page),
                            kTKPDHOME_APILIMITPAGEKEY : @(kTKPDHOMEHOTLIST_LIMITPAGE)
                            };
    
    [[RKObjectManager sharedManager] getObjectsAtPath:kTKPDHOMEHOTLIST_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self requestsuccess:mappingResult];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        [_refreshControl endRefreshing];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_refreshControl endRefreshing];
    }];
}

-(void)requestsuccess:(id)object
{
    
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    Hotlist *hotlist = stat;
    BOOL status = [hotlist.status isEqualToString:@"OK"];
    
    if (status) {
        
        
        [_product addObjectsFromArray: [result objectForKey:kTKPDHOME_APIPATHMAPPINGLISTKEY]];
        //[_paging removeAllObjects];
        id page =[result objectForKey:kTKPDHOME_APIPATHMAPPINGPAGINGKEY];
        //[_paging addObject:[result objectForKey:@"result.paging"]];
        
        if (_product.count >0) {
            
            Paging *paging = page;
            _urinext =  paging.uri_next;
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
            NSLog(@"next page : %d",_page);
        }
        /** uri split **/
        //NSLog(@"scheme: %@", [url scheme]);
        //NSLog(@"host: %@", [url host]);
        //NSLog(@"port: %@", [url port]);
        //NSLog(@"path: %@", [url path]);
        //NSLog(@"path components: %@", [url pathComponents]);
        //NSLog(@"parameterString: %@", [url parameterString]);
        //NSLog(@"query: %@", [url query]);
        //NSLog(@"fragment: %@", [url fragment]);
        
    #ifdef _DEBUG
        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDHOMEHOTLIST_APIRESPONSEFILE];
        [response writeToFile:path atomically:YES];
    #endif
    }
}

-(void)requesttimeout
{
    _table.tableFooterView = _footer;
    [_act startAnimating];
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
}

-(void)requestfailure:(id)object
{
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.3];
    }
}

#pragma mark - Delegate
-(void)HotlistCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    HotlistResultViewController *vc = [HotlistResultViewController new];
    vc.image = ((HotlistCell*)cell).productimageview.image;
    HotlistList *hotlist = _product[indexpath.row];
    NSURL *url = [NSURL URLWithString:hotlist.url];
    NSArray* querry = [[url path] componentsSeparatedByString: @"/"];
    
    vc.data = @{kTKPDHOME_DATAQUERYKEY: querry[2]};
    [self.navigationController pushViewController:vc animated:YES];
}

@end
