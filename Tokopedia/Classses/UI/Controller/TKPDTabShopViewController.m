//
//  ShopProductViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TKPDTabShopViewController.h"

#import "string_shop.h"
#import "SearchItem.h"
#import "EtalaseList.h"

#import "search.h"
#import "sortfiltershare.h"
#import "detail.h"

#import "Shop.h"

#import "ProductEtalaseViewController.h"
#import "SortViewController.h"

#import "GeneralProductCell.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"

#import "TKPDTabNavigationController.h"
#import "CategoryMenuViewController.h"
#import "DetailProductViewController.h"
#import "ShopHeaderViewController.h"

#import "URLCacheController.h"

#import "UIImage+ImageEffects.h"

#import "GeneralAlertCell.h"

#import "ShopInfoViewController.h"
#import "ShopTalkViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"

@interface TKPDTabShopViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ShopHeaderDelegate> {
    NSMutableArray *_product;
    
    NSInteger _page;
    NSInteger _limit;
    
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
    
    CGFloat _scrollOffset;
    
    UIImageView *_navigationImageView;
    
    BOOL _navigationBarIsAnimating;
    BOOL _navigationBarShouldAnimate;

    Shop *_shop;
    BOOL _shopIsGold;
    
    ShopHeaderViewController *_headerController;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet UIView *stickyTabView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickyTabVerticalSpace;

@end

@implementation TKPDTabShopViewController

@synthesize data = _data;

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isnodata = YES;
    _requestcount = 0;
    _isrefreshview = NO;
    
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

    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPPRODUCT_APIRESPONSEFILEFORMAT, [[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
    
    if ([self.tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    
    [self configureRestKit];
    [self loadData];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_FILTERPRODUCTPOSTNOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(setDepartmentID:) name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_ETALASEPOSTNOTIFICATIONNAMEKEY object:nil];
    
    self.title = [_data objectForKey:kTKPDDETAIL_APISHOPNAMEKEY];
    
    _shopIsGold = [[_data objectForKey:kTKPDDETAIL_APISHOPISGOLD] boolValue];
    
    if (_shopIsGold) {
        _navigationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        _navigationImageView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_navigationImageView];
    }
    
    _navigationBarIsAnimating = false;
    _searchBar.delegate = self;
    
    if (_shopIsGold) {
        self.stickyTabVerticalSpace.constant = 64;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.delegate = self;

    [self configureRestKit];
    if (_isnodata && !_isrefreshview && _page<1) {
        [self loadData];
    }

    self.navigationController.navigationBar.alpha = 1;
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 1;
    [previousController.navigationItem setBackBarButtonItem:barButtonItem];

    UIImage *infoImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kTKPDIMAGE_ICONINFO ofType:@"png"]];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithImage:infoImage
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(tap:)];
    infoBarButton.tag = 2;
    self.navigationItem.rightBarButtonItem = infoBarButton;
    
    _searchBar.barTintColor = [UIColor clearColor];
    _searchBar.backgroundImage = [UIImage new];
    
    if (_shopIsGold) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    }

    _navigationBarIsAnimating = false;
    _navigationBarShouldAnimate = false;
    
    [self updateTabAppearance:_contentOffset];
    [self updateNavigationBarAppearance:_contentOffset];
    
    _navigationBarShouldAnimate = true;

    if (_contentOffset.y > self.view.frame.size.height) _contentOffset.y = _header.frame.size.height - 109;
    if (_tableView.contentInset.top == -64) _contentOffset.y = 64;

    self.tableView.contentOffset = _contentOffset;
    self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, self.view.frame.size.height, 0);
    
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:197.0/255.0 blue:34.0/255.0 alpha:1];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.tableView.delegate = nil;
}

- (void)dealloc
{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = (_product.count%2==0)?_product.count/2:_product.count/2+1;
#ifdef kTKPDSHOPPRODUCT_NODATAENABLE
    return _isnodata?1:count;
#else
    return _isnodata?0:count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDGENERALPRODUCTCELL_IDENTIFIER;
        
        cell = (GeneralProductCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [GeneralProductCell newcell];
            ((GeneralProductCell *)cell).delegate = self;
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

        static NSString *CellIdentifier = @"GeneralAlertCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [GeneralAlertCell newCell];
        }

        if (!_searchBar.resignFirstResponder) {
            cell.textLabel.text = [NSString stringWithFormat:@"No result found for '%@'", _searchBar.text];
        } else {
            cell.textLabel.text = @"No product";
        }
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
            [self configureRestKit];
            [self loadData];
            _tableView.contentInset = UIEdgeInsetsZero;
        } else {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 22, 0);
            _tableView.tableFooterView = nil;
        }
    }
}

#pragma mark - Actions

-(IBAction)tap:(id)sender{
    
    [_searchBar resignFirstResponder];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case 1:
            {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 2:
            {
                if (_shop) {
                    ShopInfoViewController *vc = [[ShopInfoViewController alloc] init];
                    vc.data = @{kTKPDDETAIL_DATAINFOSHOPSKEY : _shop,
                                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            }
            default:
                break;
        }
    }
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        switch (button.tag) {
            case 2:
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                ShopTalkViewController *shopTalkController = [storyboard instantiateViewControllerWithIdentifier:@"ShopTalkViewController"];
                shopTalkController.data = _data;
                shopTalkController.contentOffset = self.tableView.contentOffset;
                shopTalkController.shop = _shop;
                [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0], shopTalkController]];
                break;
            }                
            case 3:
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                ShopReviewViewController *shopReviewController = [storyboard instantiateViewControllerWithIdentifier:@"ShopReviewViewController"];
                shopReviewController.data = _data;
                shopReviewController.contentOffset = self.tableView.contentOffset;
                shopReviewController.shop = _shop;
                [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0], shopReviewController]];
                break;
            }
            case 4:
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                ShopNotesViewController *shopNotesController = [storyboard instantiateViewControllerWithIdentifier:@"ShopNotesViewController"];
                shopNotesController.data = _data;
                shopNotesController.contentOffset = self.tableView.contentOffset;
                shopNotesController.shop = _shop;
                [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0], shopNotesController]];
                break;
            }
            case 5:
            {
                // sort button action
                NSIndexPath *indexpath = [_detailfilter objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SortViewController *vc = [SortViewController new];
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPESHOPPRODUCTVIEWKEY),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                self.navigationController.navigationBar.alpha = 0;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 6:
            {
                // etalase button action
                NSIndexPath *indexpath = [_detailfilter objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                ProductEtalaseViewController *vc = [ProductEtalaseViewController new];
                vc.data = @{kTKPDDETAIL_APISHOPIDKEY:@([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
                vc.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                self.navigationController.navigationBar.alpha = 0;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 7:
            {
                NSString *activityItem = [NSString stringWithFormat:@"%@ - %@ | Tokopedia %@", _shop.result.info.shop_name,
                                          _shop.result.info.shop_location, _shop.result.info.shop_url];
                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityItem,]
                                                                                                 applicationActivities:nil];
                activityController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                [self presentViewController:activityController animated:YES completion:nil];
                break;
            }
            default:
                break;
        }
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
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APILISTKEY
                                                                                 toKeyPath:kTKPDSEARCH_APILISTKEY
                                                                               withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // add page relationship
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APIPAGINGKEY
                                                                                 toKeyPath:kTKPDSEARCH_APIPAGINGKEY
                                                                               withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDSHOP_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)loadData
{
    
    if (_request.isExecuting) return;
    
    self.tableView.tableFooterView = _footer;
    [_activityIndicator startAnimating];
    
    _requestcount ++;
    
    NSString *querry =[_detailfilter objectForKey:kTKPDDETAIL_DATAQUERYKEY]?:@"";
    NSInteger sort =  [[_detailfilter objectForKey:kTKPDDETAIL_APIORERBYKEY]integerValue];
    NSInteger shopID = [[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0;
    EtalaseList *etalase = [_detailfilter objectForKey:DATA_ETALASE_KEY];
    BOOL isSoldProduct = (etalase.etalase_id == 7);
    BOOL isAllEtalase = (etalase.etalase_id == 0);
    
    id etalaseid;
    
    if (isSoldProduct) {
        etalaseid = @"sold";
        if(sort == 0)sort = etalase.etalase_id;
    }
    else if (isAllEtalase)
        etalaseid = @"all";
    else{
        etalaseid = @(etalase.etalase_id);
    }
    
    NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY    :   kTKPDDETAIL_APIGETSHOPPRODUCTKEY,
                            kTKPDDETAIL_APISHOPIDKEY    :   @(shopID),
                            kTKPDDETAIL_APIPAGEKEY      :   @(_page),
                            kTKPDDETAIL_APILIMITKEY     :   @(_limit),
                            kTKPDDETAIL_APIORERBYKEY    :   @(sort),
                            kTKPDDETAIL_APIKEYWORDKEY   :   querry,
                            kTKPDDETAIL_APIETALASEIDKEY :   etalaseid?:0};
    
    [_cachecontroller getFileModificationDate];
    
    _timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
    if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1 || _isrefreshview) {
        
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST
                                                                          path:kTKPDDETAILSHOP_APIPATH
                                                                    parameters:[param encrypt]];
        
        if (!_isrefreshview) {
            self.tableView.tableFooterView = _footer;
            [_activityIndicator startAnimating];
        }
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self requestSuccess:mappingResult withOperation:operation];
            [_activityIndicator stopAnimating];
            self.tableView.tableFooterView = nil;
            [self.tableView reloadData];
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
            _isrefreshview = NO;
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [_activityIndicator stopAnimating];
            self.tableView.tableFooterView = nil;
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
            _isrefreshview = NO;
        }];
        
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                  target:self
                                                selector:@selector(requestTimeout)
                                                userInfo:nil
                                                 repeats:NO];

        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestFailure:nil];
    }
}


-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _searchitem = info;
    NSString *statusstring = _searchitem.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (_page <=1 && !_isrefreshview) {
            //only save cache for first page
            [_cacheconnection connection:operation.HTTPRequestOperation.request
                      didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            //save response data
            [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        }
        
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    if (_timeinterval > _cachecontroller.URLCacheInterval || _page>1 ||_isrefreshview) {
        [self requestProcess:object];
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
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
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
                [self requestProcess:mappingresult];
            }
        }
    }
}

-(void)requestProcess:(id)object
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
                [_product addObjectsFromArray: _searchitem.result.list];

                if (_product.count > 0) {
                    
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
                    
                    NSLog(@"next page : %zd",_page);
                    
                    _isnodata = NO;

                    if (_product.count == 0) _activityIndicator.hidden = YES;
                    
                } else {
                    _isnodata = YES;
                }
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    self.tableView.tableFooterView = _footer;
                    [_activityIndicator startAnimating];
                    [self performSelector:@selector(configureRestKit)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
            }
            else
            {
                [_activityIndicator stopAnimating];
                self.tableView.tableFooterView = nil;
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}

#pragma mark - Cell Delegate

-(void)GeneralProductCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    [_searchBar resignFirstResponder];
    NSInteger index = indexpath.section+2*(indexpath.row);
    List *list = _product[index];
    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : list.product_id,
                kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]};
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UISearchBar Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _scrollOffset = self.tableView.contentOffset.y;
    
    [_searchBar resignFirstResponder];
    [_detailfilter setObject:searchBar.text forKey:kTKPDDETAIL_DATAQUERYKEY];

    [_product removeAllObjects];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    [self configureRestKit];
    [self loadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_searchBar resignFirstResponder];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateTabAppearance:scrollView.contentOffset];
    [self updateNavigationBarAppearance:scrollView.contentOffset];
    [_headerController didScroll:scrollView];
}

- (void)updateTabAppearance:(CGPoint)contentOffset
{
    CGFloat limit;
    if (_shopIsGold) {
        limit = self.header.frame.size.height - 154;
    } else {
        limit = (self.header.frame.size.height - 89);
    }
    
    if (contentOffset.y >= limit) {
        _stickyTabView.hidden = NO;
    } else {
        _stickyTabView.hidden = YES;
    }
}

- (void)updateNavigationBarAppearance:(CGPoint)contentOffset;
{
    if (!_navigationBarIsAnimating && _shopIsGold) {
        _navigationBarIsAnimating = true;
        if (contentOffset.y > 136) {
            [self showNavigationBar];
        } else {
            [self hideNavigationBar];
        }
    }
}

- (void)showNavigationBar
{
    if (_navigationBarShouldAnimate) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            _navigationImageView.alpha = 1;
            self.title = [_data objectForKey:kTKPDDETAIL_APISHOPNAMEKEY];
        } completion:^(BOOL finished) {
            _navigationBarIsAnimating = false;
        }];
    } else {
        _navigationImageView.alpha = 1;
        self.title = [_data objectForKey:kTKPDDETAIL_APISHOPNAMEKEY];
        _navigationBarIsAnimating = false;
    }
}

- (void)hideNavigationBar
{
    if ( _navigationBarShouldAnimate) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            _navigationImageView.alpha = 0;
            self.title = @"";
        } completion:^(BOOL finished) {
            _navigationBarIsAnimating = false;
        }];
    } else {
        _navigationImageView.alpha = 0;
        self.title = @"";
        _navigationBarIsAnimating = false;
    }
}

#pragma mark - Post Notification Methods

-(void)setDepartmentID:(NSNotification*)notification
{
    [self cancel];
    NSDictionary* userinfo = notification.userInfo;
    [_detailfilter setObject:[userinfo objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY]?:@""
                      forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    [self refreshView:nil];
}

#pragma mark - Others methods

- (void)updateView:(NSNotification *)notification;
{
    [self cancel];
    NSDictionary *userinfo = notification.userInfo;
    [_detailfilter addEntriesFromDictionary:userinfo];
    [self refreshView:nil];
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    [_product removeAllObjects];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    
    [self.tableView reloadData];

    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedHeader"]) {
        _headerController = segue.destinationViewController;
        _headerController.data = _data;
        _headerController.delegate = self;
        _headerController.shop = _shop;
    }
}

#pragma mark - Shop header delegate

- (void)didLoadImage:(UIImage *)image
{
    _navigationImageView.image = [image applyLightEffect];
}

- (void)didReceiveShop:(Shop *)shop
{
    _shop = shop;
}

@end
