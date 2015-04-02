//
//  HotlistViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Hotlist.h"
#import "search.h"
#import "string_home.h"
#import "HotlistViewController.h"
#import "HotlistResultViewController.h"
#import "SearchResultViewController.h"
#import "CatalogViewController.h"

#import "URLCacheController.h"

#import "TokopediaNetworkManager.h"
#import "LoadingView.h"

#pragma mark - HotlistView

@interface HotlistViewController ()
<
    TokopediaNetworkManagerDelegate,
    LoadingViewDelegate,
    UITableViewDelegate,
    UIGestureRecognizerDelegate
>
{
    NSMutableArray *_product;
    
    NSInteger _page;
    NSInteger _limit;
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _isnodata;
    BOOL _isNeedToRemoveAllObject;
    
    UIRefreshControl *_refreshControl;

    NSTimeInterval _timeinterval;
    TokopediaNetworkManager *_networkManager;
    __weak RKObjectManager  *_objectmanager;
    
    /**cache part*/
    NSString *_cachePath;
    URLCacheConnection *_cacheConnection;
    URLCacheController *_cacheController;
    LoadingView *_loadingView;
}

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;


@end

@implementation HotlistViewController
#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isnodata = YES;
        _isNeedToRemoveAllObject = NO;
    }
    return self;
}


#pragma mark - View Lifecylce
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    _product = [NSMutableArray new];
    _page = 1;
    _limit = kTKPDHOMEHOTLIST_LIMITPAGE;
    _cacheConnection = [URLCacheConnection new];
    _cacheController = [URLCacheController new];
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    _table.tableFooterView = _footer;
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    _table.contentInset = UIEdgeInsetsMake(0, 0, 53, 0);
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    [self initCacheHotlist];
    if([self getFromCache] && _page == 1) {
        [_networkManager requestSuccess:[self getFromCache] withOperation:nil];
    } else {
        [_networkManager doRequest];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_cacheController getFileModificationDate];
    _timeinterval = fabs([_cacheController.fileDate timeIntervalSinceNow]);
    
    if(_timeinterval > _cacheController.URLCacheInterval) {
        _page = 1;
        _isNeedToRemoveAllObject = YES;
        [_networkManager doRequest];
        _table.contentOffset = CGPointMake(0, 0 - _table.contentInset.top);
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

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
            ((HotlistCell*)cell).indexpath = indexPath;
            ((HotlistCell *)cell).namelabel.text = hotlist.title;
            ((HotlistCell*)cell).pricelabel.text = hotlist.price_start;
            [((HotlistCell*)cell).act startAnimating];

            NSLog(@"\n\n\n%ld %@\n\n\n", (long)indexPath.row, hotlist.url);
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:hotlist.image_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];

            UIImageView *thumb = ((HotlistCell*)cell).productimageview;
            thumb.image = nil;
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image animated:YES];
                [thumb setContentMode:UIViewContentModeScaleAspectFill];
#pragma clang diagnosti c pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
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
            [_networkManager doRequest];
        }
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
    _page = 1;
    _isrefreshview = YES;
    _isNeedToRemoveAllObject = YES;
    
//    [_product removeAllObjects];
    [_table reloadData];
    [_networkManager doRequest];
}

#pragma mark - Tokopedia Network Manager
- (NSDictionary *)getParameter {
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY :   kTKPDHOMEHOTLISTACT,
                            kTKPDHOME_APIPAGEKEY   :   @(_page),
                            kTKPDHOME_APILIMITPAGEKEY  :   @(kTKPDHOMEHOTLIST_LIMITPAGE),
                            };
    
    return param;
}

- (NSString *)getPath {
    NSString *path = kTKPDHOMEHOTLIST_APIPATH;
    
    return path;
}

- (id)getObjectManager {
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDHOMEHOTLIST_APIPATH keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
    return _objectmanager;
}

- (NSString *)getRequestStatus:(id)result {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    Hotlist *hotlist = stat;
    
    return hotlist.status;
}

- (void)actionBeforeRequest {
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    else{
        _table.tableFooterView = nil;
        [_act stopAnimating];
    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation{
    Hotlist *hotlist = successResult;
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
    }
    
    if(_isNeedToRemoveAllObject) {
       [_product removeAllObjects];
        _isNeedToRemoveAllObject = NO;
    }
    
    [_product addObjectsFromArray: hotlist.result.list];

    if (_product.count >0) {
        _isnodata = NO;
        _urinext =  hotlist.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_urinext] integerValue];
    }
    
    if((_page - 1) == 1) {
        [self setToCache:operation];
    }

    [_table reloadData];
}

- (void)actionAfterFailRequestMaxTries {
    [_refreshControl endRefreshing];
    _table.tableFooterView = _loadingView.view;
}

#pragma mark - Caching Part 
- (void)initCacheHotlist {
    if(_page == 1) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"hotlist"];
        _cachePath = [path stringByAppendingPathComponent:kTKPDHOMEHOTLIST_APIRESPONSEFILE];
        
        _cacheController.filePath = _cachePath;
        _cacheController.URLCacheInterval = 300.0;
        [_cacheController initCacheWithDocumentPath:path];
    }
}

- (void)setToCache:(RKObjectRequestOperation*)operation {
    [_cacheConnection connection:operation.HTTPRequestOperation.request
              didReceiveResponse:operation.HTTPRequestOperation.response];
    
    [_cacheController connectionDidFinish:_cacheConnection];
    [operation.HTTPRequestOperation.responseData writeToFile:_cachePath atomically:YES];
}

- (id)getFromCache {
    [_cacheController getFileModificationDate];
    _timeinterval = fabs([_cacheController.fileDate timeIntervalSinceNow]);
    
    NSError* error;
    NSData *data = [NSData dataWithContentsOfFile:_cachePath];
    
    if(data.length) {
        id parsedData = [RKMIMETypeSerialization objectFromData:data
                                                       MIMEType:RKMIMETypeJSON
                                                          error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        _objectmanager = [self getObjectManager];
        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            
            return mappingresult;
        }
    }
    
    return nil;
}

#pragma mark - Delegate LoadingView
- (void)pressRetryButton {
    _table.tableFooterView = _footer;
    [_networkManager doRequest];
}

#pragma mark - Delegate
-(void)HotlistCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withimageview:(UIImageView *)imageview
{
    HotlistList *hotlist = _product[indexpath.row];
    
    if ([hotlist.url rangeOfString:@"/hot/"].length) {
    
        HotlistResultViewController *controller = [HotlistResultViewController new];
        controller.image = ((HotlistCell*)cell).productimageview.image;
        NSArray *query = [[[NSURL URLWithString:hotlist.url] path] componentsSeparatedByString: @"/"];
        controller.data = @{
                            kTKPDHOME_DATAQUERYKEY      : [query objectAtIndex:2]?:@"",
                            kTKPHOME_DATAHEADERIMAGEKEY : imageview,
                            kTKPD_AUTHKEY               : [_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null],
                            kTKPDHOME_APIURLKEY         : hotlist.url,
                            kTKPDHOME_APITITLEKEY       : hotlist.title,
                            };
        [self.delegate pushViewController:controller];
    
    } else if ([hotlist.url rangeOfString:@"/p/"].length) {
        
        NSURL *url = [NSURL URLWithString:hotlist.url];
        
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        
        for (int i = 2; i < url.pathComponents.count; i++) {
            if (i == 2) {
                [parameters setValue:[url.pathComponents objectAtIndex:i] forKey:kTKPDSEARCH_APIDEPARTMENT_1];
            } else if (i == 3) {
                [parameters setValue:[url.pathComponents objectAtIndex:i] forKey:kTKPDSEARCH_APIDEPARTMENT_2];
            } else if (i == 4) {
                [parameters setValue:[url.pathComponents objectAtIndex:i] forKey:kTKPDSEARCH_APIDEPARTMENT_3];
            }
        }
        
        for (NSString *parameter in [url.query componentsSeparatedByString:@"&"]) {
            NSString *key = [[parameter componentsSeparatedByString:@"="] objectAtIndex:0];
            if ([key isEqualToString:kTKPDSEARCH_APIMINPRICEKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APIMINPRICEKEY];
            } else if ([key isEqualToString:kTKPDSEARCH_APIMAXPRICEKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APIMAXPRICEKEY];
            } else if ([key isEqualToString:kTKPDSEARCH_APIOBKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APIOBKEY];
            } else if ([key isEqualToString:kTKPDSEARCH_APILOCATIONIDKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APILOCATIONIDKEY];
            } else if ([key isEqualToString:kTKPDSEARCH_APIGOLDMERCHANTKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APIGOLDMERCHANTKEY];
            }
        }
        
        SearchResultViewController *controller = [SearchResultViewController new];
        controller.data = parameters;
        [self.delegate pushViewController:controller];
        
    } else if ([hotlist.url rangeOfString:@"/catalog/"].length) {

        NSString *catalogID = [[hotlist.url componentsSeparatedByString:@"/"] objectAtIndex:4];
        CatalogViewController *controller = [CatalogViewController new];
        controller.catalogID = catalogID;
        controller.catalogName = hotlist.title;
        controller.catalogImage = hotlist.image_url;
        controller.catalogPrice = hotlist.price_start;
        [self.delegate pushViewController:controller];
    
    }
} 

@end
