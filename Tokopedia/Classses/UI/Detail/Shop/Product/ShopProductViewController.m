//
//  ShopProductViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SearchItem.h"
#import "EtalaseList.h"

#import "search.h"
#import "sortfiltershare.h"
#import "detail.h"

#import "ProductEtalaseViewController.h"
#import "SortViewController.h"

#import "GeneralProductCell.h"
#import "ShopProductViewController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"

#import "TKPDTabNavigationController.h"
#import "CategoryMenuViewController.h"
#import "DetailProductViewController.h"

#import "URLCacheController.h"

@interface ShopProductViewController () <UITableViewDataSource,UITableViewDelegate, GeneralProductCellDelegate, UISearchBarDelegate>
{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    NSMutableArray *_buttons;
    NSMutableDictionary *_detailfilter;
    NSMutableArray *_departmenttree;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
    BOOL _isrefreshview;
    
    UIRefreshControl *_refreshControl;
    
    UIBarButtonItem *_barbuttoncategory;
    
    NSInteger _requestcount;
    NSTimer *_timer;
    
    SearchItem *_searchitem;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIScrollView *hashtagsscrollview;
@property (strong, nonatomic) IBOutlet UIView *descriptionview;
@property (weak, nonatomic) IBOutlet UIScrollView *imagescrollview;
@property (weak, nonatomic) IBOutlet UILabel *descriptionlabel;
@property (weak, nonatomic) IBOutlet UIView *filterview;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrol;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipegestureleft;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipegestureright;

@property (nonatomic, strong) NSMutableArray *product;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

@end

@implementation ShopProductViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _requestcount = 0;
        _isrefreshview = NO;
    }
    return self;
}

#pragma mark - Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // set title navigation
    NSString * title = [_data objectForKey:kTKPDDETAIL_DATASHOPTITLEKEY];
    self.navigationItem.title = title;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // create initialitation
    _paging = [NSMutableDictionary new];
    _product = [NSMutableArray new];
    _detailfilter = [NSMutableDictionary new];
    _departmenttree = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    // set max data per page request
    _limit = kTKPDSHOPPRODUCT_LIMITPAGE;
    
    _page = 1;
    
    UIEdgeInsets inset = _table.contentInset;
    inset.bottom += 100;
    _table.contentInset = inset;

    _table.tableHeaderView = _header;
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // adjust refresh control
    //_refreshControl = [[UIRefreshControl alloc] init];
    //_refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    //[_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    //[_table addSubview:_refreshControl];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_FILTERPRODUCTPOSTNOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(setDepartmentID:) name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_ETALASEPOSTNOTIFICATIONNAMEKEY object:nil];
    
//    UIImageView *imageview = [_data objectForKey:kTKPDETAIL_DATAHEADERIMAGEKEY];
//    if (imageview) {
//        _imageview.image = imageview.image;
//        _header.hidden = NO;
//        _pagecontrol.hidden = YES;
//        _swipegestureleft.enabled = NO;
//        _swipegestureright.enabled = NO;
//    }
    
    [_descriptionview setFrame:CGRectMake(350, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
    [_pagecontrol bringSubviewToFront:_descriptionview];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPPRODUCT_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
    
    _table.scrollEnabled = NO;
    
    if ([_table respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    
    [self configureRestKit];
    [self loadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureRestKit];
    if (_isnodata && !_isrefreshview && _page<1) {
        [self loadData];
    }
    
    self.table.scrollEnabled = NO;
    self.table.contentOffset = CGPointMake(0, 0);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = (_product.count%2==0)?_product.count/2:_product.count/2+1;
#ifdef kTKPDSHOPPRODUCT_NODATAENABLE
    return _isnodata?1:count;
#else
    return _isnodata?0:count;
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        [self reset:(GeneralProductCell*)cell];
        
        NSString *cellid = kTKPDGENERALPRODUCTCELL_IDENTIFIER;
		
		cell = (GeneralProductCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [GeneralProductCell newcell];
			((GeneralProductCell*)cell).delegate = self;
		}
		
        if (_product.count > indexPath.row) {
            /** Flexible view count **/
            NSUInteger indexsegment = indexPath.row * 2;
            NSUInteger indexmax = indexsegment + 2;
            NSUInteger indexlimit = MIN(indexmax, _product.count);
            
            NSAssert(!(indexlimit > _product.count), @"producs out of bounds");
            
            NSUInteger i;
            
            for (i = 0; (indexsegment + i) < indexlimit; i++) {
                List *list = [_product objectAtIndex:indexsegment + i];
                ((UIView*)((GeneralProductCell*)cell).viewcell[i]).hidden = NO;
                (((GeneralProductCell*)cell).indexpath) = indexPath;
                
                ((UILabel*)((GeneralProductCell*)cell).labelprice[i]).text = list.catalog_price?:list.product_price;
                ((UILabel*)((GeneralProductCell*)cell).labeldescription[i]).text = list.catalog_name?:list.product_name;
                ((UILabel*)((GeneralProductCell*)cell).labelalbum[i]).text = list.shop_name?:@"";
                
                NSString *urlstring = list.catalog_image?:list.product_image;
                
                NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                
                UIImageView *thumb = (UIImageView*)((GeneralProductCell*)cell).thumb[i];
                thumb.image = nil;
                [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                    [thumb setImage:image];
#pragma clang diagnostic pop
                } failure:nil];
            }
        }
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
		
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            /** called if need to load next page **/
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [self configureRestKit];
            [self loadData];
        }
	}
}

#pragma mark - Action View
-(IBAction)tap:(id)sender{
    [_searchbaractive resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        switch (button.tag) {
            case 10:
            {
                //BACK
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            default:
                break;
        }
    }
}
- (IBAction)gesture:(id)sender {
    [_searchbaractive resignFirstResponder];
    if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)sender;
        switch (swipe.state) {
            case UIGestureRecognizerStateEnded: {
                if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
                    [self descriptionviewhideanimation:YES];
                    _pagecontrol.currentPage=0;
                }
               if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
                   [self descriptionviewshowanimation:YES];
                   _pagecontrol.currentPage=1;
                }
                break;
            }
            default:
                break;
        }
    }
}

-(void)descriptionviewshowanimation:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [_descriptionview setFrame:CGRectMake(_imageview.frame.origin.x, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
                             [self.view addSubview:_descriptionview];
                         }
                         completion:^(BOOL finished){
                         }];
    }
}
-(void)descriptionviewhideanimation:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [_descriptionview setFrame:CGRectMake(350, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
                             [self.view addSubview:_descriptionview];
                         }
                         completion:^(BOOL finished){
                         }];
    }
}


#pragma mark - Request + Mapping Shop
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
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIHASCATALOGKEY:kTKPDSEARCH_APIHASCATALOGKEY}];
    
    // searchs list mapping
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[List class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDSEARCH_APIPRODUCTIMAGEKEY,
                                                 kTKPDSEARCH_APIPRODUCTPRICEKEY,
                                                 kTKPDSEARCH_APIPRODUCTNAMEKEY,
                                                 kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY,
                                                 kTKPDSEARCH_APICATALOGIMAGEKEY,
                                                 kTKPDSEARCH_APICATALOGNAMEKEY,
                                                 kTKPDSEARCH_APICATALOGPRICEKEY,
                                                 kTKPDSEARCH_APIPRODUCTIDKEY,
                                                 kTKPDSEARCH_APICATALOGIDKEY]];
    
    // paging mapping
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIURINEXTKEY:kTKPDSEARCH_APIURINEXTKEY}];
    
    RKObjectMapping *departmentMapping = [RKObjectMapping mappingForClass:[DepartmentTree class]];
    [departmentMapping addAttributeMappingsFromArray:@[kTKPDSEARCH_APIHREFKEY, kTKPDSEARCH_APITREEKEY, kTKPDSEARCH_APIDIDKEY, kTKPDSEARCH_APITITLEKEY,kTKPDSEARCH_APICHILDTREEKEY]];
    
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDSHOP_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)loadData
{
    
    if (_request.isExecuting) return;
    
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    _requestcount ++;
    
    NSString *querry =[_detailfilter objectForKey:kTKPDDETAIL_DATAQUERYKEY]?:@"";
    NSIndexPath *indexpathetalase = [_detailfilter objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY];
    NSInteger index = indexpathetalase.row;
    
    NSInteger sort =  [[_detailfilter objectForKey:kTKPDDETAIL_APIORERBYKEY]integerValue];
    id etalaseid;
    if (index==0) {
        // ketika pada etalase memilih produk terjual
        etalaseid = @"sold";
        if(sort == 0)sort = 7;
    }
    else if (index == 1)
    {
        // ketika pada etalase memilih semua etalase
        etalaseid = @"all";
    }
    else{
        // default
        EtalaseList *etalase = [_detailfilter objectForKey:kTKPDDETAIL_DATAETALASEKEY];
        etalaseid = @(etalase.etalase_id);
    }
    
	NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPPRODUCTKEY,
                            kTKPDDETAIL_APISHOPIDKEY: @([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                            kTKPDDETAIL_APIPAGEKEY : @(_page),
                            kTKPDDETAIL_APILIMITKEY : @(_limit),
                            kTKPDDETAIL_APIORERBYKEY : @(sort?:0),
                            kTKPDDETAIL_APIKEYWORDKEY : querry?:@"",
                            kTKPDDETAIL_APIETALASEIDKEY :etalaseid?:0
                            };
    
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
	if (_timeinterval > _cachecontroller.URLCacheInterval || _page>1 || _isrefreshview) {
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOP_APIPATH parameters:param];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self requestsuccess:mappingResult withOperation:operation];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [_table reloadData];
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [self requestfailure:error];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[alertView show];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
        }];
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    else {
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
    id info = [result objectForKey:@""];
    _searchitem = info;
    NSString *statusstring = _searchitem.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
       if (_page <=1 && !_isrefreshview) {
            //only save cache for first page
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
    if (_timeinterval > _cachecontroller.URLCacheInterval || _page>1 ||_isrefreshview) {
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
            id info = [result objectForKey:@""];
            _searchitem = info;
            NSString *statusstring = _searchitem.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            
            id info = [result objectForKey:@""];
            _searchitem = info;
            NSString *statusstring = _searchitem.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                
                if (_page == 1) {
                    [_product removeAllObjects];
                }
                _filterview.hidden = NO;
                [_product addObjectsFromArray: _searchitem.result.list];
                _pagecontrol.hidden = NO;
                _swipegestureleft.enabled = YES;
                _swipegestureright.enabled = YES;
                
                if (_product.count >0) {
                    
                    _descriptionview.hidden = NO;
                    _header.hidden = NO;
                    _filterview.hidden = NO;
                    
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
                    
                    _page = [[queries objectForKey:kTKPDDETAIL_APIPAGEKEY] integerValue];
                    
                    NSLog(@"next page : %d",_page);
                    
                    _isnodata = NO;
                    
                    _filterview.hidden = NO;
                    _barbuttoncategory.enabled = YES;
                    
                }
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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

#pragma mark - Cell Delegate
-(void)GeneralProductCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    [_searchbaractive resignFirstResponder];
    NSInteger index = indexpath.section+2*(indexpath.row);
    List *list = _product[index];
    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : list.product_id,
                kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]};
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Methods
-(void)reset:(UITableViewCell*)cell
{
    [((GeneralProductCell*)cell).thumb makeObjectsPerformSelector:@selector(setImage:) withObject:nil];
    [((GeneralProductCell*)cell).labelprice makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).labelalbum makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).labeldescription makeObjectsPerformSelector:@selector(setText:) withObject:nil];
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    [_product removeAllObjects];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_searchbaractive resignFirstResponder];
    _table.scrollEnabled = YES;
}

#pragma mark - UISearchBar Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollToTop" object:nil];
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchbaractive = searchBar;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchbaractive resignFirstResponder];
    [_detailfilter setObject:searchBar.text forKey:kTKPDDETAIL_DATAQUERYKEY];
    [self refreshView:nil];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchbaractive resignFirstResponder];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    if (scrollView.contentOffset.y <= -64) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"enableParentScroll" object:nil];
//        _table.scrollEnabled = NO;
//    } else {
//        _table.scrollEnabled = YES;
//    }
//    NSLog(@"\n\n%f\n\n", scrollView.contentOffset.y);
}

#pragma mark - Post Notification Methods

-(void)setDepartmentID:(NSNotification*)notification
{
    [self cancel];
    NSDictionary* userinfo = notification.userInfo;
    [_detailfilter setObject:[userinfo objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY]?:@"" forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    [self refreshView:nil];
}

- (void)updateView:(NSNotification *)notification;
{
    [self cancel];
    NSDictionary *userinfo = notification.userInfo;
    [_detailfilter addEntriesFromDictionary:userinfo];
    [self refreshView:nil];
}

@end
