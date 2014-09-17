//
//  SearchResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "search.h"
#import "SearchRedirect.h"
#import "List.h"
#import "Paging.h"

#import "DetailProductViewController.h"
#import "SearchResultCell.h"
#import "SearchResultViewController.h"
#import "SearchFilterLocationViewController.h"
#import "DetailShopViewController.h"
#import "HotlistResultViewController.h"
#import "TKPDTabNavigationController.h"

@interface SearchResultViewController () <SearchResultCellDelegate, TKPDTabNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) NSMutableArray *product;
@property (weak, nonatomic) IBOutlet UIView *catalogproductview;
@property (weak, nonatomic) IBOutlet UIView *shopview;

@end

@implementation SearchResultViewController
{
    NSInteger _page;
    NSInteger _limit;
    
    NSMutableArray *_urlarray;
    NSMutableDictionary *_params;
    
    NSString *_urinext;
    NSString *_uriredirect;
    
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    //_refreshControl = [[UIRefreshControl alloc] init];
    //_refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    //[_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    //[_table addSubview:_refreshControl];
    
    [self configureRestKit];

}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDepartmentID:) name:@"setDepartmentID" object:nil];
}


// We have been obscured -- cancel any pending requests
- (void)viewWillDisappear:(BOOL)animated {
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


#pragma mark - Methods
-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [_product removeAllObjects];
    _page = 1;
    
    [_table reloadData];
    /** request data **/
    //[self loadData];
    //[self request:YES withrefreshControl:refresh];
}



#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
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
        NSString *cellid = kTKPDSEARCHRESULTCELL_IDENTIFIER;
		
		cell = (SearchResultCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [SearchResultCell newcell];
			((SearchResultCell*)cell).delegate = self;
		}
        
        /** Flexible view count **/
		NSUInteger indexsegment = indexPath.row * 2;
		NSUInteger indexmax = indexsegment + 2;
		NSUInteger indexlimit = MIN(indexmax, _product.count);
		
		NSAssert(!(indexlimit > _product.count), @"producs out of bounds");
		
		NSUInteger i;
		
		for (i = 0; (indexsegment + i) < indexlimit; i++) {
            List *list = [_product objectAtIndex:indexsegment + i];
            ((UIView*)((SearchResultCell*)cell).viewcell[i]).hidden = NO;
            (((SearchResultCell*)cell).indexpath) = indexPath;
            
            if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY]) {
                ((UILabel*)((SearchResultCell*)cell).labelprice[i]).text = list.product_price?:@"";
                ((UILabel*)((SearchResultCell*)cell).labeldescription[i]).text = list.product_name?:@"";
                ((UILabel*)((SearchResultCell*)cell).labelalbum[i]).text = list.shop_name?:@"";
                
                NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.3];
                
                UIImageView *thumb = (UIImageView*)((SearchResultCell*)cell).thumb[i];
                thumb.image = nil;
                
                UIActivityIndicatorView *act = (UIActivityIndicatorView*)((SearchResultCell*)cell).act[i];
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
            else if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
                ((UILabel*)((SearchResultCell*)cell).labelprice[i]).text = list.catalog_price?:@"";
                ((UILabel*)((SearchResultCell*)cell).labeldescription[i]).text = list.catalog_name?:@"";
                ((UILabel*)((SearchResultCell*)cell).labelalbum[i]).text = list.product_name?:@"";
                NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.catalog_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.3];
                //request.URL = url;
                
                UIImageView *thumb = (UIImageView*)((SearchResultCell*)cell).thumb[i];
                thumb.image = nil;
                //thumb.hidden = YES;	//@prepareforreuse then @reset
                
                UIActivityIndicatorView *act = (UIActivityIndicatorView*)((SearchResultCell*)cell).act[i];
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
            else if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHSHOPKEY]) {
                ((UILabel*)((SearchResultCell*)cell).labelprice[i]).text = list.product_price?:@"";
                ((UILabel*)((SearchResultCell*)cell).labeldescription[i]).text = list.shop_name?:@"";
                //((UILabel*)((SearchResultCell*)cell).labelalbum[i]).text = searchitem.product_name?:@"";
                
                NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.shop_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.3];
                //request.URL = url;
                
                UIImageView *thumb = (UIImageView*)((SearchResultCell*)cell).thumb[i];
                thumb.image = nil;
                //thumb.hidden = YES;	//@prepareforreuse then @reset
                
                UIActivityIndicatorView *act = (UIActivityIndicatorView*)((SearchResultCell*)cell).act[i];
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
        }
        
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
- (void)configureRestKit
{
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
/** RestKit With Core Data
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error = nil;
    [managedObjectStore createPersistentStoreCoordinator];
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    //NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"dataSearch.sqlite"];
    //NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    //if (! persistentStore) {
    // RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    //}
    [managedObjectStore createManagedObjectContexts];
    
    RKObjectManager *objectManager =  [RKObjectManager sharedManager];
    objectManager.managedObjectStore = managedObjectStore;
    
    [RKObjectManager setSharedManager:objectManager];
    
    RKEntityMapping *searchMapping = [RKEntityMapping mappingForEntityForName:@"List" inManagedObjectStore:managedObjectStore];

    //searchs list mappng
    //RKObjectMapping *searchMapping = [RKObjectMapping mappingForClass:[List class]];
    [searchMapping addAttributeMappingsFromArray:@[kTKPDSEARCH_APIPRODUCTPRICEKEY,kTKPDSEARCH_APIPRODUCTNAMEKEY]];
    searchMapping.identificationAttributes = @[kTKPDSEARCH_APIPRODUCTNAMEKEY];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
                                                responseDescriptorWithMapping:searchMapping
                                                pathPattern:nil
                                                keyPath:@"result.list"
                                                statusCodes:kTkpdIndexSetStatusCodeOK];
    
    
    
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    [self loadData];
**/

    // initialize RestKit
    RKObjectManager *objectManager =  [RKObjectManager sharedManager];
    
    // setup object mappings
    /** searchs list mappng **/
    RKObjectMapping *searchMapping = [RKObjectMapping mappingForClass:[List class]];
    [searchMapping addAttributeMappingsFromArray:@[kTKPDSEARCH_APIPRODUCTIMAGEKEY,kTKPDSEARCH_APIPRODUCTPRICEKEY,kTKPDSEARCH_APIPRODUCTNAMEKEY,kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY, kTKPDSEARCH_APICATALOGIMAGEKEY,kTKPDSEARCH_APICATALOGNAMEKEY,kTKPDSEARCH_APICATALOGPRICEKEY]];
    
    /** paging mappng **/
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIURINEXTKEY:kTKPDSEARCH_APIURINEXTKEY}];
    
    /** redirect mappng & hascatalog **/
    RKObjectMapping *redirectMapping = [RKObjectMapping mappingForClass:[SearchRedirect class]];
    [redirectMapping addAttributeMappingsFromDictionary: @{kTKPDSEARCH_APIREDIRECTURLKEY:kTKPDSEARCH_APIREDIRECTURLKEY, kTKPDSEARCH_APIDEPARTEMENTIDKEY:kTKPDSEARCH_APIDEPARTEMENTIDKEY,kTKPDSEARCH_APIHASCATALOGKEY:kTKPDSEARCH_APIHASCATALOGKEY}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorSearch = [RKResponseDescriptor responseDescriptorWithMapping:searchMapping method:RKRequestMethodGET pathPattern:kTKPDSEARCH_APIPATH keyPath:kTKPDSEARCH_APIPATHMAPPINGLISTKEY statusCodes:kTkpdIndexSetStatusCodeOK];
    
    RKResponseDescriptor *responseDescriptorPaging = [RKResponseDescriptor responseDescriptorWithMapping:pagingMapping method:RKRequestMethodGET pathPattern:kTKPDSEARCH_APIPATH keyPath:kTKPDSEARCH_APIPATHMAPPINGPAGINGKEY statusCodes:kTkpdIndexSetStatusCodeOK];
    
    RKResponseDescriptor *responseDescriptorRedirect = [RKResponseDescriptor responseDescriptorWithMapping:redirectMapping method:RKRequestMethodGET pathPattern:kTKPDSEARCH_APIPATH keyPath:kTKPDSEARCH_APIPATHMAPPINGREDIRECTKEY statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [objectManager addResponseDescriptor:responseDescriptorSearch];
    [objectManager addResponseDescriptor:responseDescriptorPaging];
    [objectManager addResponseDescriptor:responseDescriptorRedirect];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:responseDescriptorSearch.mapping forKey:(responseDescriptorSearch.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptorPaging.mapping forKey:(responseDescriptorPaging.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptorRedirect.mapping forKey:(responseDescriptorRedirect.keyPath ?: [NSNull null])];
    
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
    
    NSString *querry =[_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *type = [_params objectForKey:kTKPDSEARCH_DATATYPE];
    NSString *deptid =[_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    NSDictionary* param;
    
    if (deptid == nil ) {
        param = @{
                //@"auth":@(1),
                kTKPDSEARCH_APIQUERYKEY : querry?:@"",
                kTKPDSEARCH_APIACTIONTYPEKEY : type?:@"",
                kTKPDSEARCH_APIPAGEKEY : @(_page),
                kTKPDSEARCH_APILIMITKEY : @(kTKPDSEARCH_LIMITPAGE),
                };
    }
    else{
       param = @{
                //@"auth":@(1),
                kTKPDSEARCH_APIDEPARTEMENTIDKEY : deptid?:@"",
                kTKPDSEARCH_APIACTIONTYPEKEY : type?:@"",
                kTKPDSEARCH_APIPAGEKEY : @(_page),
                kTKPDSEARCH_APILIMITKEY : @(kTKPDSEARCH_LIMITPAGE),
                };
    }

    
    // Some asynchronous work to do
    //dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"============================== GET %@ =====================", [_data objectForKey:kTKPDSEARCH_DATATYPE]);
        [[RKObjectManager sharedManager] getObjectsAtPath:kTKPDSEARCH_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            [self requestsuccess:mappingResult];
            [_table reloadData];
            [_refreshControl endRefreshing];
            //[_act stopAnimating];
            //_table.tableFooterView = nil;
            NSLog(@"============================== DONE GET %@ =====================", [_data objectForKey:kTKPDSEARCH_DATATYPE]);
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [self requestfailure:error];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[alertView show];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [_refreshControl endRefreshing];
            
            NSLog(@"============================== DONE GET %@ =====================", [_data objectForKey:kTKPDSEARCH_DATATYPE]);
        }];
    //});

}


-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id redirect_catalog = [result objectForKey:kTKPDSEARCH_APIPATHMAPPINGREDIRECTKEY];
    SearchRedirect *searchcatalog = redirect_catalog;
    NSString *uriredirect = searchcatalog.redirect_url;
    NSString *hascatalog = searchcatalog.has_catalog;
    
    if (uriredirect == nil) {
        //setting is this product has catalog or not
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY]) {
            if ([hascatalog isEqualToString:@"1"] && hascatalog) {
                NSDictionary *userInfo = @{@"count":@(3)};
                [[NSNotificationCenter defaultCenter] postNotificationName: @"setsegmentcontrol" object:nil userInfo:userInfo];
            }
            else if ([hascatalog isEqualToString:@"0"] && hascatalog){
                NSDictionary *userInfo = @{@"count":@(2)};
                [[NSNotificationCenter defaultCenter] postNotificationName: @"setsegmentcontrol" object:nil userInfo:userInfo];
            }
        }
        
        [_product addObjectsFromArray: [result objectForKey:kTKPDSEARCH_APIPATHMAPPINGLISTKEY]];
        if (_product.count == 0) {
            [_act stopAnimating];
            _table.tableFooterView = nil;
        }
        //[_paging removeAllObjects];
        id page =[result objectForKey:kTKPDSEARCH_APIPATHMAPPINGPAGINGKEY];
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
        if ([querry[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTHOTKEY]) {
            HotlistResultViewController *vc = [HotlistResultViewController new];
            vc.data = @{kTKPDSEARCH_DATAISSEARCHHOTLISTKEY : @(YES), kTKPDSEARCHHOTLIST_APIQUERYKEY : querry[2]};
            [self.navigationController pushViewController:vc animated:NO];
        }
        // redirect uri to search category
        if ([querry[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTCATEGORY]) {
            NSString *deptid = searchcatalog.department_id;
            [_params setObject:deptid forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
            [self loadData];
        }
    }
    _catalogproductview.hidden = NO;
    _shopview.hidden = YES;
    
    
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

#pragma mark - cell delegate
-(void)SearchResultCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    DetailProductViewController *vc = [DetailProductViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TKPDTabNavigationController Tap Button Notification
-(IBAction)tap:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10:
        {
            // Action Location Button
            SearchFilterLocationViewController *vc = [SearchFilterLocationViewController new];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            
            break;
        }
        case 11:
        {
            // Action Filter Button
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
-(void)setDepartmentID:(NSNotification*)notification
{
    NSDictionary* userinfo = notification.userInfo;
    
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    [_params setObject:[userinfo objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY]?:@"" forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    [_product removeAllObjects];
    _page = 1;
    [_table reloadData];
    [self loadData];
}

@end
