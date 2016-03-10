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
#import "HotlistCollectionCell.h"
#import "HotlistResultViewController.h"
#import "SearchResultViewController.h"
#import "CatalogViewController.h"
#import "TKPDTabNavigationController.h"
#import "SearchResultShopViewController.h"

#import "RetryCollectionReusableView.h"

#import "URLCacheController.h"

#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "TableViewScrollAndSwipe.h"

#import "RequestNotifyLBLM.h"
#import "NotificationManager.h"

#pragma mark - HotlistView

@interface HotlistViewController ()
<
TokopediaNetworkManagerDelegate,
LoadingViewDelegate,
UITableViewDelegate,
UIGestureRecognizerDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
NotificationDelegate,
RetryViewDelegate
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
    
    BOOL _isFailRequest;
    
    RequestNotifyLBLM *_requestLBLM;
    NotificationManager *_notifManager;
}

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic, readonly) UICollectionViewFlowLayout *flowLayout;

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
        
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}



#pragma mark - View Lifecylce
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
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
    
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
//    [self setTableInset];
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    [self initCacheHotlist];
    if([self getFromCache] && _page == 1) {
        [_networkManager requestSuccess:[self getFromCache] withOperation:nil];
    } else {
        [_networkManager doRequest];
    }
    
    UINib *cellNib = [UINib nibWithNibName:@"HotlistCollectionCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"HotlistCollectionCellIdentifier"];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
        
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_networkManager requestCancel];
}

-(void)doRequestNotify
{
    _requestLBLM = [RequestNotifyLBLM new];
    [_requestLBLM doRequestLBLM];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"Hot List Page";
    [TPAnalytics trackScreenName:@"Hot List Page"];

    [_cacheController getFileModificationDate];
    _timeinterval = fabs([_cacheController.fileDate timeIntervalSinceNow]);
    
    if(_timeinterval > _cacheController.URLCacheInterval) {
        _page = 1;
        _isNeedToRemoveAllObject = YES;
        [_networkManager doRequest];
        _collectionView.contentOffset = CGPointMake(0, 0 - _table.contentInset.top);
    }
    
    [self initNotificationManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initNotificationManager) name:@"reloadNotification" object:nil];
    
    [self doRequestNotify];
}

- (void) setTableInset {
    if([[UIScreen mainScreen]bounds].size.height >= 568) {
        _collectionView.contentInset = UIEdgeInsetsMake(5, 0, 100, 0);
    } else {
        _collectionView.contentInset = UIEdgeInsetsMake(5, 0, 200, 0);
    }
}


#pragma mark - Memory Management
- (void)dealloc
{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager.isUsingHmac = YES;
    _networkManager = nil;
}

#pragma mark - Collection View Data Source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _product.count;
    
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellid = @"HotlistCollectionCellIdentifier";
    HotlistCollectionCell *cell = (HotlistCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
    
    [cell setViewModel:((HotlistList*)_product[indexPath.row]).viewModel];
    
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 4;
    if (row == indexPath.row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            _isFailRequest = NO;
            [_networkManager doRequest];
        }
    }
    
    return cell;
}


#pragma mark - Delegate Cell
- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionFooter) {
        if(_isFailRequest) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView" forIndexPath:indexPath];
            ((RetryCollectionReusableView*)reusableView).delegate = self;
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        }
    }
    
    return reusableView;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HotlistList *hotlist = _product[indexPath.row];
    
    if ([hotlist.url rangeOfString:@"/hot/"].length) {
        HotlistCollectionCell *cell = (HotlistCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
        HotlistResultViewController *controller = [HotlistResultViewController new];
        controller.image = cell.productimageview.image;
        NSArray *query = [[[NSURL URLWithString:hotlist.url] path] componentsSeparatedByString: @"/"];
        controller.data = @{
                            kTKPDHOME_DATAQUERYKEY      : [query objectAtIndex:2]?:@"",
                            kTKPHOME_DATAHEADERIMAGEKEY : cell.productimageview,
                            kTKPDHOME_APIURLKEY         : hotlist.url,
                            kTKPDHOME_APITITLEKEY       : hotlist.title,
                            };
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if ([hotlist.url rangeOfString:@"/p/"].length) {
        
        NSURL *url = [NSURL URLWithString:hotlist.url];
        
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        NSMutableArray *departmentIdentifiers = [NSMutableArray new];
        
        for (int i = 2; i < url.pathComponents.count; i++) {
            if (i == 2) {
                [parameters setValue:[url.pathComponents objectAtIndex:i] forKey:kTKPDSEARCH_APIDEPARTMENT_1];
                [departmentIdentifiers addObject:[url.pathComponents objectAtIndex:i]];
            } else if (i == 3) {
                [parameters setValue:[url.pathComponents objectAtIndex:i] forKey:kTKPDSEARCH_APIDEPARTMENT_2];
                [departmentIdentifiers addObject:[url.pathComponents objectAtIndex:i]];
            } else if (i == 4) {
                [parameters setValue:[url.pathComponents objectAtIndex:i] forKey:kTKPDSEARCH_APIDEPARTMENT_3];
                [departmentIdentifiers addObject:[url.pathComponents objectAtIndex:i]];
            }
        }
        
        NSString *scIdentifier = nil;
        if(departmentIdentifiers.count > 0) {
            scIdentifier = [departmentIdentifiers componentsJoinedByString:@"_"];
            [parameters setValue:scIdentifier forKey:@"sc_identifier"];
        }
        
        for (NSString *parameter in [url.query componentsSeparatedByString:@"&"]) {
            NSString *key = [[parameter componentsSeparatedByString:@"="] objectAtIndex:0];
            if ([key isEqualToString:kTKPDSEARCH_APIMINPRICEKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APIPRICEMINKEY];
            } else if ([key isEqualToString:kTKPDSEARCH_APIMAXPRICEKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APIPRICEMAXKEY];
            } else if ([key isEqualToString:kTKPDSEARCH_APIOBKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APIOBKEY];
            } else if ([key isEqualToString:kTKPDSEARCH_APILOCATIONIDKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APILOCATIONIDKEY];
            } else if ([key isEqualToString:kTKPDSEARCH_APIGOLDMERCHANTKEY]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:kTKPDSEARCH_APIGOLDMERCHANTKEY];
            }
        }
        
        [parameters setValue:@"search_product" forKey:kTKPDSEARCH_DATATYPE];
        
        SearchResultViewController *controller = [SearchResultViewController new];
        controller.data = parameters;
        controller.hidesBottomBarWhenPushed = YES;
        
        NSArray *viewcontrollers = @[controller];
        
        TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
        
        [viewController setSelectedIndex:0];
        [viewController setViewControllers:viewcontrollers];
        [viewController setNavigationTitle:hotlist.title];
        
        viewController.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setsegmentcontrol" object:nil userInfo:@{@"hide_segment" : @"1"}];
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else if ([hotlist.url rangeOfString:@"/catalog/"].length) {
        
        NSString *catalogID = [[hotlist.url componentsSeparatedByString:@"/"] objectAtIndex:4];
        CatalogViewController *controller = [CatalogViewController new];
        controller.catalogID = catalogID;
        controller.catalogName = hotlist.title;
        controller.catalogImage = hotlist.image_url_600;
        controller.catalogPrice = hotlist.price_start;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat cellWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        UIDeviceOrientation *orientation = [[UIDevice currentDevice] orientation];
//        if(UIDeviceOrientationIsLandscape(orientation)) {
//            CGFloat screenWidth = screenRect.size.width/3;
//            cellWidth = screenWidth-15;
//        } else {
            CGFloat screenWidth = screenRect.size.width/2;
            cellWidth = screenWidth-15;
//        }

    } else {
        CGFloat screenWidth = screenRect.size.width;
        cellWidth = screenWidth-20;
    }
    return CGSizeMake(cellWidth, cellWidth*173/300);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(60.0f, 40.0f);
}

#pragma mark - Methods

-(void)refreshView:(UIRefreshControl*)refresh
{
    _page = 1;
    _isrefreshview = YES;
    _isNeedToRemoveAllObject = YES;
    
    [_collectionView reloadData];
    [_networkManager doRequest];
}

#pragma mark - Tokopedia Network Manager
- (NSDictionary *)getParameter:(int)tag {
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY :   kTKPDHOMEHOTLISTACT,
                            kTKPDHOME_APIPAGEKEY   :   @(_page),
                            kTKPDHOME_APILIMITPAGEKEY  :   @(kTKPDHOMEHOTLIST_LIMITPAGE),
                            };
    
    return param;
}

- (NSString *)getPath:(int)tag {
    NSString *path = kTKPDHOMEHOTLIST_APIPATH;
    
    return path;
}

- (id)getObjectManager:(int)tag {
    _objectmanager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Hotlist class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[HotlistResult class]];
    
    RKObjectMapping *hotlistMapping = [RKObjectMapping mappingForClass:[HotlistList class]];
    [hotlistMapping addAttributeMappingsFromArray:@[kTKPDHOME_APIURLKEY,kTKPDHOME_APILARGEIMGURLKEY, kTKPDHOME_APITHUMBURLKEY,kTKPDHOME_APISTARTERPRICEKEY,kTKPDHOME_APITITLEKEY]];
    
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

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    Hotlist *hotlist = stat;
    
    return hotlist.status;
}

- (void)actionBeforeRequest:(int)tag {
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    else{
        _table.tableFooterView = nil;
        [_act stopAnimating];
    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    Hotlist *hotlist = [result objectForKey:@""];
    
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
    
    _isFailRequest = NO;
    
    [_collectionView reloadData];
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    [_refreshControl endRefreshing];
    _isFailRequest = YES;
    [_collectionView reloadData];
}

#pragma mark - Caching Part
- (void)initCacheHotlist {
    if(_page == 1) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"hotlist"];
        _cachePath = [path stringByAppendingPathComponent:kTKPDHOMEHOTLIST_APIRESPONSEFILE];
        
        _cacheController.filePath = _cachePath;
        _cacheController.URLCacheInterval = 1800.0;
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
        _objectmanager = [self getObjectManager:0];
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
    _isFailRequest = NO;
    [_collectionView reloadData];
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
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
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
        [parameters setValue:@"search_product" forKey:kTKPDSEARCH_DATATYPE];
        
        SearchResultViewController *controller = [SearchResultViewController new];
        controller.data = parameters;
        controller.title = hotlist.title;
        controller.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if ([hotlist.url rangeOfString:@"/catalog/"].length) {
        
        NSString *catalogID = [[hotlist.url componentsSeparatedByString:@"/"] objectAtIndex:4];
        CatalogViewController *controller = [CatalogViewController new];
        controller.catalogID = catalogID;
        controller.catalogName = hotlist.title;
        controller.catalogImage = hotlist.image_url_600;
        controller.catalogPrice = hotlist.price_start;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}

#pragma mark - Notification Action
- (void)userDidTappedTabBar:(NSNotification*)notification {
    [_collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)didSwipeHomeTab:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger tag = [[userinfo objectForKey:@"tag"]integerValue];
    
    if(tag == 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTappedTabBar:) name:@"TKPDUserDidTappedTapBar" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TKPDUserDidTappedTapBar" object:nil];
    }
    
}

#pragma mark - Notification Manager
- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    _notifManager.delegate = self;
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}


- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
{
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - orientation changed
- (void)orientationChanged:(NSNotification *)note {
    [_collectionView reloadData];
}


@end
