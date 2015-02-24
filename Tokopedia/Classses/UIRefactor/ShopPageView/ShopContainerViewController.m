//
//  ContainerViewController.m
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import "ShopContainerViewController.h"
#import "ShopTalkPageViewController.h"
#import "ShopProductPageViewController.h"
#import "ShopReviewPageViewController.h"
#import "ShopNotesPageViewController.h"


#import "URLCacheController.h"

#import "sortfiltershare.h"
#import "detail.h"
#import "string_product.h"



@interface ShopContainerViewController () <UIScrollViewDelegate> {
    BOOL _isNoData;
    BOOL _isRefreshView;
    
    NSInteger _requestCount;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    
    NSString *_cachePath;
    URLCacheController *_cacheController;
    URLCacheConnection *_cacheConnection;
    NSTimeInterval _timeInterval;
    
}

@property (strong, nonatomic) ShopProductPageViewController *shopProductViewController;
@property (strong, nonatomic) ShopTalkPageViewController *shopTalkViewController;
@property (strong, nonatomic) ShopReviewPageViewController *shopReviewViewController;
@property (strong, nonatomic) ShopNotesPageViewController *shopNotesViewController;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UILabel *productLabel;
@property (strong, nonatomic) IBOutlet UILabel *talkLabel;
@property (strong, nonatomic) IBOutlet UILabel *reviewLabel;
@property (strong, nonatomic) IBOutlet UILabel *notesLabel;

@end




@implementation ShopContainerViewController

@synthesize data = _data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNotificationCenter];
    // Do any additional setup after loading the view from its nib.
    
    _isNoData = YES;
    _isRefreshView = NO;
    _requestCount = 0;
    
    _operationQueue = [NSOperationQueue new];
    
    _cacheController = [URLCacheController new];
    _cacheController.URLCacheInterval = 86400.0;
    _cacheConnection = [URLCacheConnection new];

    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _pageController.dataSource = self;
    _pageController.delegate = self;
    
    _shopProductViewController = [ShopProductPageViewController new];
    _shopProductViewController.data = _data;
    
    _shopTalkViewController = [ShopTalkPageViewController new];
    _shopTalkViewController.data = _data;
    
    _shopReviewViewController = [ShopReviewPageViewController new];
    _shopReviewViewController.data = _data;
    
    _shopNotesViewController = [ShopNotesPageViewController new];
    _shopNotesViewController.data = _data;
    
    
    NSArray *viewControllers = [NSArray arrayWithObject:_shopProductViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:[self.pageController view]];

    NSArray *subviews = self.pageController.view.subviews;
    UIPageControl *thisControl = nil;
    for (int i=0; i<[subviews count]; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            thisControl = (UIPageControl *)[subviews objectAtIndex:i];
        }
    }
    
    thisControl.hidden = true;
    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+40);
    
    
    [self configureRestKit];
    [self request];

    [self.pageController didMoveToParentViewController:self];
    [self setScrollEnabled:NO forPageViewController:_pageController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma  - UIPageViewController Methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[ShopProductPageViewController class]]) {
        return nil;
    }
    if ([viewController isKindOfClass:[ShopTalkPageViewController class]]) {
        return _shopProductViewController;
    }
    else if ([viewController isKindOfClass:[ShopReviewPageViewController class]]) {
        return _shopTalkViewController;
    }
    else if ([viewController isKindOfClass:[ShopNotesPageViewController class]]) {
        return _shopReviewViewController;
    }
    
    return nil;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[ShopProductPageViewController class]]) {
        return _shopTalkViewController;
    }
    
    else if ([viewController isKindOfClass:[ShopTalkPageViewController class]]) {
        return _shopReviewViewController;
    }
    else if ([viewController isKindOfClass:[ShopReviewPageViewController class]]) {
        return _shopNotesViewController;
    }
    else if ([viewController isKindOfClass:[ShopNotesPageViewController class]]) {
        return nil;
    }

    return nil;
    
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}


#pragma mark - Init Notification
- (void)initNotificationCenter {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
 }

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass: [UIButton class]]) {
        UIButton *btn = (UIButton *)sender;

        switch (btn.tag) {
            case 10:
            {
                [_pageController setViewControllers:@[_shopTalkViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self postNotificationSetShopHeader];
                break;
            }
            case 11:
            {
                [_pageController setViewControllers:@[_shopReviewViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self postNotificationSetShopHeader];
                break;
            }
            case 12:
            {
               
                [_pageController setViewControllers:@[_shopNotesViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self postNotificationSetShopHeader];
                break;
            }
                
            case 13:
            {
                
                [_pageController setViewControllers:@[_shopProductViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self postNotificationSetShopHeader];
                break;
            }
            default:
                break;
        }
    }
}

- (void)postNotificationSetShopHeader {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setHeaderShopPage" object:nil userInfo:_shop];
}

-(void)setScrollEnabled:(BOOL)enabled forPageViewController:(UIPageViewController*)pageViewController{
    for(UIView* view in pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]){
            UIScrollView* scrollView=(UIScrollView*)view;
            [scrollView setScrollEnabled:enabled];
            return;
        }
    }
}

#pragma mark - Request And Mapping

-(void)cancel
{
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Shop class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailShopResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIISOPENKEY:kTKPDDETAILSHOP_APIISOPENKEY}];
    
    RKObjectMapping *closedinfoMapping = [RKObjectMapping mappingForClass:[ClosedInfo class]];
    [closedinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIUNTILKEY:kTKPDDETAILSHOP_APIUNTILKEY,
                                                            kTKPDDETAILSHOP_APIRESONKEY:kTKPDDETAILSHOP_APIRESONKEY,
                                                            kTKPDDETAILSHOP_APINOTEKEY:kTKPDDETAILSHOP_APINOTEKEY
                                                            }];
    
    RKObjectMapping *ownerMapping = [RKObjectMapping mappingForClass:[Owner class]];
    [ownerMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIOWNERIMAGEKEY:kTKPDDETAILSHOP_APIOWNERIMAGEKEY,
                                                       kTKPDDETAILSHOP_APIOWNERPHONEKEY:kTKPDDETAILSHOP_APIOWNERPHONEKEY,
                                                       kTKPDDETAILSHOP_APIOWNERIDKEY:kTKPDDETAILSHOP_APIOWNERIDKEY,
                                                       kTKPDDETAILSHOP_APIOWNEREMAILKEY:kTKPDDETAILSHOP_APIOWNEREMAILKEY,
                                                       kTKPDDETAILSHOP_APIOWNERNAMEKEY:kTKPDDETAILSHOP_APIOWNERNAMEKEY,
                                                       kTKPDDETAILSHOP_APIOWNERMESSAGERKEY:kTKPDDETAILSHOP_APIOWNERMESSAGERKEY
                                                       }];
    
    RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
    [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                          kTKPDDETAILSHOP_APICOVERKEY:kTKPDDETAILSHOP_APICOVERKEY,
                                                          kTKPDDETAILSHOP_APITOTALFAVKEY:kTKPDDETAILSHOP_APITOTALFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY,
                                                          kTKPDDETAILSHOP_APISHOPISGOLD:kTKPDDETAILSHOP_APISHOPISGOLD,
                                                          kTKPDDETAILSHOP_APISHOPURLKEY:kTKPDDETAILSHOP_APISHOPURLKEY,
                                                          }];
    
    RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY,
                                                           kTKPDSHOP_APISHOPTOTALTRANSACTIONKEY:kTKPDSHOP_APISHOPTOTALTRANSACTIONKEY,
                                                           kTKPDSHOP_APISHOPTOTALETALASEKEY:kTKPDSHOP_APISHOPTOTALETALASEKEY,
                                                           kTKPDSHOP_APISHOPTOTALPRODUCTKEY:kTKPDSHOP_APISHOPTOTALPRODUCTKEY,
                                                           kTKPDSHOP_APISHOPTOTALSOLDKEY:kTKPDSHOP_APISHOPTOTALSOLDKEY
                                                           }];
    
    RKObjectMapping *shipmentMapping = [RKObjectMapping mappingForClass:[Shipment class]];
    [shipmentMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APISHIPMENTIDKEY:kTKPDDETAILSHOP_APISHIPMENTIDKEY,
                                                          kTKPDDETAILSHOP_APISHIPMENTIMAGEKEY:kTKPDDETAILSHOP_APISHIPMENTIMAGEKEY,
                                                          kTKPDDETAILSHOP_APISHIPMENTNAMEKEY:kTKPDDETAILSHOP_APISHIPMENTNAMEKEY
                                                          }];
    
    RKObjectMapping *shipmentpackageMapping = [RKObjectMapping mappingForClass:[ShipmentPackage class]];
    [shipmentpackageMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APISHIPPINGIDKEY,
                                                            kTKPDDETAILSHOP_APIPRODUCTNAMEKEY
                                                            ]];
    
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[Payment class]];
    [paymentMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APIPAYMENTIMAGEKEY,
                                                    kTKPDDETAILSHOP_APIPAYMENTNAMEKEY]];
    
    RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[Address class]];
    [addressMapping addAttributeMappingsFromArray:@[//kTKPDDETAIL_APILOCATIONKEY,
                                                    kTKPDSHOP_APIADDRESSNAMEKEY,
                                                    kTKPDSHOP_APIADDRESSIDKEY,
                                                    kTKPDSHOP_APIPOSTALCODEKEY,
                                                    kTKPDSHOP_APIDISTRICTIDKEY,
                                                    kTKPDSHOP_APIFAXKEY,
                                                    kTKPDSHOP_APICITYIDKEY,
                                                    kTKPDSHOP_APIPHONEKEY,
                                                    kTKPDSHOP_APIEMAILKEY,
                                                    kTKPDSHOP_APIPROVINCEIDKEY
                                                    ]];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY
                                                                                  toKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY
                                                                                withMapping:closedinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIOWNERKEY
                                                                                  toKeyPath:kTKPDDETAILSHOP_APIOWNERKEY
                                                                                withMapping:ownerMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIINFOKEY
                                                                                  toKeyPath:kTKPDDETAILSHOP_APIINFOKEY
                                                                                withMapping:shopinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISTATKEY
                                                                                  toKeyPath:kTKPDDETAILSHOP_APISTATKEY
                                                                                withMapping:shopstatsMapping]];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY
                                                                                     toKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY
                                                                                   withMapping:shipmentMapping];
    [resultMapping addPropertyMapping:shipmentRel];
    
    RKRelationshipMapping *shipmentpackageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY
                                                                                            toKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY
                                                                                          withMapping:shipmentpackageMapping];
    [shipmentMapping addPropertyMapping:shipmentpackageRel];
    
    RKRelationshipMapping *paymentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIPAYMENTKEY
                                                                                    toKeyPath:kTKPDDETAILSHOP_APIPAYMENTKEY
                                                                                  withMapping:paymentMapping];
    [resultMapping addPropertyMapping:paymentRel];
    
    RKRelationshipMapping *addressRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIADDRESSKEY
                                                                                    toKeyPath:kTKPDDETAIL_APIADDRESSKEY
                                                                                  withMapping:addressMapping];
    [resultMapping addPropertyMapping:addressRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDDETAILSHOP_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
}

- (void)request
{
    _requestCount ++;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPDETAILKEY,
                            kTKPDDETAIL_APISHOPIDKEY : @([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue])};
    
    [_cacheController getFileModificationDate];
    _timeInterval = fabs([_cacheController.fileDate timeIntervalSinceNow]);
    
    if (_timeInterval > _cacheController.URLCacheInterval || _isRefreshView) {
        
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        
        _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                        method:RKRequestMethodPOST
                                                                          path:kTKPDDETAILSHOP_APIPATH
                                                                    parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            app.networkActivityIndicatorVisible = NO;
            [self requestSuccess:mappingResult withOperation:operation];
            [_timer invalidate];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            // Failure
            app.networkActivityIndicatorVisible = NO;
            [self requestFailure:error];
            [_timer invalidate];
            
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
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cacheController.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestFailure:nil];
    }
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _shop = info;
    NSString *statusstring = _shop.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        //only save cache for first page
        [_cacheConnection connection:operation.HTTPRequestOperation.request
                  didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cacheController connectionDidFinish:_cacheConnection];
        //save response data
        [operation.HTTPRequestOperation.responseData writeToFile:_cachePath atomically:YES];
        
        [self requestProcess:object];
    }
}


-(void)requestFailure:(id)object
{
    if (_timeInterval > _cacheController.URLCacheInterval || _isRefreshView) {
        [self requestProcess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachePath];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectManager.responseDescriptors) {
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
            _shop = info;
            NSString *statusstring = _shop.status;
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
            id stats = [result objectForKey:@""];
            _shop = stats;
            BOOL status = [_shop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            if (status) {
                _isNoData = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setHeaderShopPage" object:nil userInfo:_shop];
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestCount);
                    [self performSelector:@selector(configureRestKit)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}



@end
