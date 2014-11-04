//
//  ProfileFavoriteShopViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoriteShop.h"
#import "detail.h"

#import "profile.h"
#import "ProfileFavoriteShopViewController.h"
#import "ProfileFavoriteShopCell.h"

#import "TKPDTabShopNavigationController.h"
#import "ShopProductViewController.h"
#import "ShopNotesViewController.h"
#import "ShopReviewViewController.h"
#import "ShopTalkViewController.h"

#import "URLCacheController.h"

#pragma mark - Profile Favorite Shop View Controller
@interface ProfileFavoriteShopViewController ()<UITableViewDataSource, UITableViewDelegate, ProfileFavoriteShopCellDelegate>
{
    NSInteger _page;
    NSString *_urinext;
    
    NSMutableDictionary *_param;
    NSMutableArray *_list;
    NSInteger _requestcount;
    NSTimer *_timer;
    BOOL _isnodata;
    
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    
    FavoriteShop *_favoriteshop;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

@end

@implementation ProfileFavoriteShopViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _list = [NSMutableArray new];
    
    _page = 1;
    
    _table.tableFooterView = _footer;
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDPROFILE_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDPFAVORITESHOP_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDPROFILE_APIUSERIDKEY] integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata) {
            [self loadData];
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
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDPROFILEFAVORITESHOPCELL_IDENTIFIER;
		
		cell = (ProfileFavoriteShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [ProfileFavoriteShopCell newcell];
			((ProfileFavoriteShopCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            ListFavoriteShop *list = _list[indexPath.row];
            ((ProfileFavoriteShopCell*)cell).label.text = list.shop_name;
            ((ProfileFavoriteShopCell*)cell).indexpath = indexPath;
            NSString *urlstring = list.shop_image;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = (UIImageView*)((ProfileFavoriteShopCell*)cell).thumb;
            thumb = [UIImageView circleimageview:thumb];
            
            thumb.image = nil;
            
            UIActivityIndicatorView *act = (UIActivityIndicatorView*)((ProfileFavoriteShopCell*)cell).act;
            [act startAnimating];
            
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
                
                [act stopAnimating];
#pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [act stopAnimating];
            }];
        }
        
		return cell;
    } else {
        static NSString *CellIdentifier = kTKPDPROFILE_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDPROFILE_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDPROFILE_NODATACELLDESCS;
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


#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request and Mapping
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoriteShop class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[FavoriteShopResult class]];

    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ListFavoriteShop class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDPROFILE_APISHOPTOTALETALASEKEY,
                                                 kTKPDPROFILE_APISHOPIMAGEKEY,
                                                 kTKPDPROFILE_APISHOPLOCATIONKEY,
                                                 kTKPDPROFILE_APISHOPIDKEY,
                                                 kTKPDPROFILE_APISHOPTOTALSOLDKEY,
                                                 kTKPDPROFILE_APISHOPTOTALPRODUCTKEY,
                                                 kTKPDPROFILE_APISHOPNAMEKEY
                                                 ]];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_PEOPLEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)loadData
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
	NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETFAVORITESHOPKEY,
                            kTKPDPROFILE_APIUSERIDKEY : [_data objectForKey:kTKPDPROFILE_APIUSERIDKEY]?:@(0),
                            kTKPDPROFILE_APIPAGEKEY : @(_page)
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILPRODUCT_APIPATH parameters:param];
	[_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval || _page>1 || _isrefreshview) {
        if (!_isrefreshview) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        }
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PEOPLEAPIPATH parameters:param];
    
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
            _table.hidden = NO;
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [self requestfailure:error];
        }];
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestfailure:nil];
	}
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _favoriteshop = stats;
    BOOL status = [_favoriteshop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (_page<=1) {
            [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            //save response data
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
            _favoriteshop = stats;
            BOOL status = [_favoriteshop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            
            _favoriteshop = stats;
            BOOL status = [_favoriteshop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _favoriteshop.result.list;
                [_list addObjectsFromArray:list];
                _isnodata = NO;
                
                _urinext =  _favoriteshop.result.paging.uri_next;
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
                NSLog(@"next page : %d",_page);
                
                [_table reloadData];
            }
        }else{
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

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - Methods

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _page = 1;
    _requestcount = 0;
    [_list removeAllObjects];
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Cell Delegate
-(void)ProfileFavoriteShopCellDelegate:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    ListFavoriteShop *list = _favoriteshop.result.list[indexpath.row];
    
    //shop id yg difavoritkan profile ini dan yang me-triger profile ini
    NSInteger shopidbefore = [[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue];
    // shop id yg difavoritkan profile ini dan yg sedang dipilih
    NSInteger shopid = [list.shop_id integerValue];
    if (shopidbefore == shopid) {
        NSArray *viewcontrollers = self.navigationController.viewControllers;
        NSInteger index = viewcontrollers.count - 4;
        [self.navigationController popToViewController:viewcontrollers[index] animated:YES];
    }
    else
    {
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
        tapnavcon.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:0};
        [tapnavcon setViewControllers:viewcontrollers animated:YES];
        [tapnavcon setSelectedIndex:0];
        
        [self.navigationController pushViewController:tapnavcon animated:YES];
    }

}

@end
