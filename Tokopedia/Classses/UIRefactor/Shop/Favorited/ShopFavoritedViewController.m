//
//  ShopFavoritedViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Favorited.h"

#import "detail.h"
#import "ShopFavoritedViewController.h"
#import "ShopFavoritedCell.h"

#import "ProfileFavoriteShopViewController.h"
#import "ProfileContactViewController.h"

#import "URLCacheController.h"
#import "UserContainerViewController.h"
#import "NavigateViewController.h"

@interface ShopFavoritedViewController ()<UITableViewDataSource, UITableViewDelegate, ShopFavoritedCellDelegate>
{
    NSInteger _page;
    
    NSMutableDictionary *_param;
    NSMutableArray *_list;
    NSInteger _requestcount;
    NSTimer *_timer;
    BOOL _isnodata;
    
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    
    Favorited *_favorited;
    
    RKObjectManager *_objectmanager;
    RKManagedObjectRequestOperation *_request;
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
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

@end

@implementation ShopFavoritedViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        self.title = KTKPDTITLE_FAV_THIS_SHOP;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _cachecontroller = [URLCacheController new];
    _cacheconnection = [URLCacheConnection new];
    
    _page = 1;
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPFAVORITED_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue]]];
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
            [self request];
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
        
        NSString *cellid = kTKPDSHOPFAVORITEDCELL_IDENTIFIER;
		
		cell = (ShopFavoritedCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [ShopFavoritedCell newcell];
			((ShopFavoritedCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            ListFavorited *list = _list[indexPath.row];
            ((ShopFavoritedCell*)cell).label.text = list.user_name;
            ((ShopFavoritedCell*)cell).indexpath = indexPath;
            NSString *urlstring = list.user_image;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = (UIImageView*)((ShopFavoritedCell*)cell).thumb;
            thumb = [UIImageView circleimageview:thumb];
            thumb.image = nil;
            
            UIActivityIndicatorView *act = (UIActivityIndicatorView*)((ShopFavoritedCell*)cell).act;
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

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_favorited.result.total_page > _page) {
            _page++;
            [self configureRestKit];
            [self request];
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Favorited class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[FavoritedResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APITOTALPAGEKEY:kTKPDDETAIL_APITOTALPAGEKEY,
                                                        kTKPDDETAIL_APIPAGEKEY:kTKPDDETAIL_APIPAGEKEY
                                                        }];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ListFavorited class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDFAVORITED_APIUSERIDKEY,
                                                 kTKPDFAVORITED_APIUSERIMAGEKEY,
                                                 kTKPDFAVORITED_APIUSERNAMEKEY
                                                 ]];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPFAVORITEDKEY,
                            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0),
                            kTKPDDETAIL_APIPAGEKEY : @(_page)
                            };
    
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval || _page>1 || _isrefreshview) {
        if (!_isrefreshview) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        }
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILSHOP_APIPATH parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
            _table.hidden = NO;
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            _table.tableFooterView = nil;
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
    }else{
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
    _favorited = stats;
    BOOL status = [_favorited.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
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
            _favorited = stats;
            BOOL status = [_favorited.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            
            _favorited = stats;
            BOOL status = [_favorited.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _favorited.result.list;
                [_list addObjectsFromArray:list];
                _isnodata = NO;
                
                [_table reloadData];
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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
    _table.tableFooterView = nil;
    
    /** request data **/
    [self configureRestKit];
    [self request];
}

#pragma mark - Cell Delegate
-(void)ShopFavoritedCellDelegate:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    //go to profile
    NSArray *favs = _list;
    ListFavorited *fav = favs[indexpath.row];
    NSInteger userid = fav.user_id;
    
    NavigateViewController *navigateController = [NavigateViewController new];
    [navigateController navigateToProfileFromViewController:self withUserID:[NSString stringWithFormat:@"%ld", (long)userid]];
    
}


#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
                [self.navigationController popViewControllerAnimated:YES];
                break;
        default:
            break;
        }
    }
}

@end
