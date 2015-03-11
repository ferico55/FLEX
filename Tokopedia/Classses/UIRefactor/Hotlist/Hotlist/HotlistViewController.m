//
//  HotlistViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Hotlist.h"
#import "HotlistViewController.h"
#import "HotlistResultViewController.h"
#import "SearchResultViewController.h"

#import "string_home.h"

#import "TokopediaNetworkManager.h"

#pragma mark - HotlistView

@interface HotlistViewController () <TokopediaNetworkManagerDelegate>
{
    NSMutableArray *_product;
    
    NSInteger _page;
    NSInteger _limit;
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;

    NSTimeInterval _timeinterval;
    TokopediaNetworkManager *_networkManager;
    __weak RKObjectManager  *_objectmanager;

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
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    _table.tableFooterView = _footer;
    
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
    [_networkManager doRequest];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
            ((HotlistCell*)cell).pricelabel.text = hotlist.price_start;
            ((HotlistCell*)cell).namelabel.text = hotlist.title;
            [((HotlistCell*)cell).act startAnimating];
            
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

#pragma mark - Delegate
-(void)HotlistCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withimageview:(UIImageView *)imageview
{
    HotlistList *hotlist = _product[indexpath.row];
    if ([hotlist.url rangeOfString:@"/hot/"].length ||
        [hotlist.url rangeOfString:@"/p/"].length) {
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
    
    [_product removeAllObjects];
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

- (void)actionAfterRequest:(id)successResult {
    Hotlist *hotlist = successResult;
    [_product addObjectsFromArray: hotlist.result.list];
    [_refreshControl endRefreshing];
    
    if (_product.count >0) {
        _isnodata = NO;
        _urinext =  hotlist.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_urinext] integerValue];
    }
    
    [_table reloadData];
}



@end
