//
//  DetailCatalogViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "sortfiltershare.h"

#import "Catalog.h"

#import "DetailCatalogViewController.h"
#import "CatalogSellerViewController.h"
#import "DetailCatalogSpecView.h"

#import "URLCacheController.h"

@interface DetailCatalogViewController ()
{
    NSMutableDictionary *_params;
    
    BOOL _isnodata;
    BOOL _isrefreshseller;
    NSTimer *_timer;
    NSInteger _requestcount;
    
    NSMutableArray *_headerimages;
    
    NSInteger _pageheaderimages;
    DetailCatalogSpecView *_specview;
    
    Catalog *_catalog;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

@property (weak, nonatomic) IBOutlet UIView *headerview;
@property (weak, nonatomic) IBOutlet UIScrollView *continerscrollview;
@property (weak, nonatomic) IBOutlet UIScrollView *headerimagescrollview;
@property (weak, nonatomic) IBOutlet UIButton *imagebackbutton;
@property (weak, nonatomic) IBOutlet UIButton *imagenextbutton;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrol;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UIButton *sellbutton;
@property (weak, nonatomic) IBOutlet UIButton *descriptionbutton;
@property (weak, nonatomic) IBOutlet UIButton *specificationbutton;
@property (weak, nonatomic) IBOutlet UIView *containerview;

@property (strong, nonatomic) IBOutlet UIView *descriptionview;
@property (strong, nonatomic) IBOutlet UILabel *descriptionlabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (weak, nonatomic) IBOutlet UIButton *buybutton;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

- (IBAction)tap:(id)sender;

@end

#pragma mark - Detail Catalog View Controller
@implementation DetailCatalogViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _isrefreshseller = NO;
        _requestcount = 0;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _headerimages = [NSMutableArray new];
    _params = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _specview = [DetailCatalogSpecView newview];
    

    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILCATALOG_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILCATALOG_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APICATALOGIDKEY] integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureRestKit];
    if (_isnodata) {
        [self request];
    }
    if (_isrefreshseller || _isnodata) {
        _continerscrollview.hidden = YES;
    }
    else
    {
        _continerscrollview.hidden = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self showDescription:YES];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    _imagenextbutton.hidden = (_pageheaderimages == _headerimages.count -1)?YES:NO;
    _imagebackbutton.hidden = (_pageheaderimages == 0)?YES:NO;

    if ([sender isKindOfClass:[UISegmentedControl class]])
    {
        UISegmentedControl *detailCatalogSegmentedControl = (UISegmentedControl*) sender;
        switch (detailCatalogSegmentedControl.selectedSegmentIndex) {
            case 0:
            {
                [self showDescription:YES];
                break;
            }
            case 1:
            {
                [self showDescription:NO];
                break;
            }
            default:
                break;
        }
    }
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 12:
            {
                // action sell button
                break;
            }
            case 15:
            {
                // action buy button - go to seller list
                CatalogSellerViewController *vc = [CatalogSellerViewController new];
                vc.data = @{kTKPDDETAIL_DATASHOPSKEY: (_catalog.result.catalog_shops)?:@"",
                            kTKPDDETAIL_DATALOCATIONARRAYKEY: _catalog.result.catalog_location?:@"",
                            kTKPDFILTER_DATAINDEXPATHKEY: [_params objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0],
                            kTKPDFILTER_DATAFILTERKEY:_params
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 16:
            {
                NSString *activityItem = [NSString stringWithFormat:@"Jual %@ | Tokopedia %@",
                                          _catalog.result.catalog_info.catalog_name,
                                          _catalog.result.catalog_info.catalog_uri?:@"www.tokopedia.com"];
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

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _headerimagescrollview.frame.size.width;
    _pageheaderimages = floor((_headerimagescrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pagecontrol.currentPage = _pageheaderimages;
    _imagenextbutton.hidden = (_pageheaderimages == _headerimages.count -1)?YES:NO;
    _imagebackbutton.hidden = (_pageheaderimages == 0)?YES:NO;
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
    RKObjectMapping *catalogMapping = [RKObjectMapping mappingForClass:[Catalog class]];
    [catalogMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                         kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailCatalogResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILCATALOG_APICATALOGIMAGEKEY:kTKPDDETAILCATALOG_APICATALOGIMAGEKEY}];
    
    RKObjectMapping *infoMapping = [RKObjectMapping mappingForClass:[CatalogInfo class]];
    [infoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILCATALOG_APICATALOGDESCKEY:kTKPDDETAILCATALOG_APICATALOGDESCKEY,
                                                      kTKPDDETAILCATALOG_APICATALOGKEYKEY:kTKPDDETAILCATALOG_APICATALOGKEYKEY,
                                                      kTKPDDETAILCATALOG_APICATALOGDEPARTMENTIDKEY:kTKPDDETAILCATALOG_APICATALOGDEPARTMENTIDKEY,
                                                      kTKPDDETAILCATALOG_APICATALOGIDKEY:kTKPDDETAILCATALOG_APICATALOGIDKEY,
                                                      kTKPDDETAILCATALOG_APICATALOGNAMEKEY:kTKPDDETAILCATALOG_APICATALOGNAMEKEY,
                                                      kTKPDDETAILCATALOG_APICATALOGURIKEY:kTKPDDETAILCATALOG_APICATALOGURIKEY
                                                      }];
    
    RKObjectMapping *priceMapping = [RKObjectMapping mappingForClass:[CatalogPrice class]];
    [priceMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILCATALOG_APIPRICEMINKEY:kTKPDDETAILCATALOG_APIPRICEMINKEY,kTKPDDETAILCATALOG_APIPRICEMAXKEY:kTKPDDETAILCATALOG_APIPRICEMAXKEY}];
    
    RKObjectMapping *specsMapping = [RKObjectMapping mappingForClass:[CatalogSpecs class]];
    [specsMapping addAttributeMappingsFromArray:@[kTKPDDETAILCATALOG_APISPECHEADERKEY]];
    
    RKObjectMapping *specchildsMapping = [RKObjectMapping mappingForClass:[SpecChilds class]];
    [specchildsMapping addAttributeMappingsFromArray:@[kTKPDDETAILCATALOG_APISPECVALKEY, kTKPDDETAILCATALOG_APISPECKEYKEY]];

    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[CatalogLocation class]];
    [locationMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILCATALOG_APILOCATIONNAMEKEY:kTKPDDETAILCATALOG_APILOCATIONNAMEKEY,
                                                          kTKPDDETAILCATALOG_APILOCATIONIDKEY:kTKPDDETAILCATALOG_APILOCATIONIDKEY,
                                                          kTKPDDETAILCATALOG_APITOTALSHOPKEY:kTKPDDETAILCATALOG_APITOTALSHOPKEY}];
    
    RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[CatalogImages class]];
    [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILCATALOG_APIIMAGEPRIMARYKEY,
                                                   kTKPDDETAILCATALOG_APIIMAGESRCKEY]];

    RKObjectMapping *reviewMapping = [RKObjectMapping mappingForClass:[CatalogReview class]];
    [reviewMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILCATALOG_APIREVIEWIMAGEKEY:kTKPDDETAILCATALOG_APIREVIEWIMAGEKEY,
                                                           kTKPDDETAILCATALOG_APIREVIEWRATINGKEY:kTKPDDETAILCATALOG_APIREVIEWRATINGKEY,
                                                           kTKPDDETAILCATALOG_APIREVIEWURLKEY:kTKPDDETAILCATALOG_APIREVIEWURLKEY,
                                                           kTKPDDETAILCATALOG_APIREVIEWFROMURLKEY:kTKPDDETAILCATALOG_APIREVIEWFROMURLKEY,
                                                           kTKPDDETAILCATALOG_APIREVIEWFROMKEY:kTKPDDETAILCATALOG_APIREVIEWFROMKEY,
                                                           kTKPDDETAILCATALOG_APICATALOGIDKEY:kTKPDDETAILCATALOG_APICATALOGIDKEY,
                                                           kTKPDDETAILCATALOG_APIREVIEWDESCKEY:kTKPDDETAILCATALOG_APIREVIEWDESCKEY
                                                           }];
    
    RKObjectMapping *marketpriceMapping = [RKObjectMapping mappingForClass:[CatalogMarketPlace class]];
    [marketpriceMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILCATALOG_APIMAXPRICEKEY:kTKPDDETAILCATALOG_APIMAXPRICEKEY,
                                                          kTKPDDETAILCATALOG_APITIMEKEY:kTKPDDETAILCATALOG_APITIMEKEY,
                                                          kTKPDDETAILCATALOG_APINAMEKEY:kTKPDDETAILCATALOG_APINAMEKEY,
                                                          kTKPDDETAILCATALOG_APIMINPRICEKEY:kTKPDDETAILCATALOG_APIMINPRICEKEY
                                                          }];
    
    RKObjectMapping *shopsMapping = [RKObjectMapping mappingForClass:[CatalogShops class]];
    [shopsMapping addAttributeMappingsFromArray:@[
                                                    kTKPDDETAILCATALOG_APISHOPRATEACCURACYKEY,
                                                    kTKPDDETAILCATALOG_APISHOPIMAGEKEY,
                                                    kTKPDDETAIL_APISHOPIDKEY,
                                                    kTKPDDETAILCATALOG_APISHOPLOCATIONKEY,
                                                    kTKPDDETAILCATALOG_APISHOPRATESPEEDKEY,
                                                    kTKPDDETAILCATALOG_APIISGOLDSHOPKEY,
                                                    kTKPDDETAILCATALOG_APISHOPNAMEKEY,
                                                    kTKPDDETAILCATALOG_APISHOPTOTALADDRESSKEY,
                                                    kTKPDDETAILCATALOG_APISHOPTOTALPRODUCTKEY,
                                                    kTKPDDETAILCATALOG_APISHOPRATESERVICEKEY
                                                    ]];
    
    RKObjectMapping *productlistMapping = [RKObjectMapping mappingForClass:[ProductList class]];
    [productlistMapping addAttributeMappingsFromArray:@[kTKPDDETAILCATALOG_APIPRODUCTPRICEKEY,
                                                        kTKPDDETAILCATALOG_APIPRODUCTIDKEY,
                                                        kTKPDDETAILCATALOG_APIPRODUCTCONDITIONKEY,
                                                        kTKPDDETAILCATALOG_APIPRODUCTNAMEKEY]];

    // Relationship Mapping
    [catalogMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
    
    [infoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGPRICEKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGPRICEKEY withMapping:priceMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGINFOKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGINFOKEY withMapping:infoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGREVIEWKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGREVIEWKEY withMapping:reviewMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGMARKETPRICEKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGMARKETPRICEKEY withMapping:marketpriceMapping]];
    
    RKRelationshipMapping *imagesRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APICATALOGIMAGEPATHKEY toKeyPath:kTKPDDETAIL_APICATALOGIMAGEPATHKEY withMapping:imagesMapping];
    [infoMapping addPropertyMapping:imagesRel];
    
    RKRelationshipMapping *locationRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APILOCATIONKEY toKeyPath:kTKPDDETAILCATALOG_APILOCATIONKEY withMapping:locationMapping];
    [resultMapping addPropertyMapping:locationRel];
    RKRelationshipMapping *shopsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGSHOPSKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGSHOPSKEY withMapping:shopsMapping];
    [resultMapping addPropertyMapping:shopsRel];
    
    RKRelationshipMapping *productlistRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPRODUCTLISTPATHKEY toKeyPath:kTKPDDETAILCATALOG_APIPRODUCTLISTKEY withMapping:productlistMapping];
    [shopsMapping addPropertyMapping:productlistRel];
    
    RKRelationshipMapping *specsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APICATALOGSPECSPATHKEY toKeyPath:kTKPDDETAIL_APICATALOGSPECSPATHKEY withMapping:specsMapping];
    [resultMapping addPropertyMapping:specsRel];
    
    RKRelationshipMapping *specchildsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APICATALOGSPECCHILDSPATHKEY toKeyPath:kTKPDDETAIL_APICATALOGSPECCHILDSPATHKEY withMapping:specchildsMapping];
    [specsMapping addPropertyMapping:specchildsRel];
    
    // set response description
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:catalogMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKDPDETAILCATALOG_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];

    [_objectmanager addResponseDescriptor:responseDescriptor];
    
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
    [_act startAnimating];
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETCATALOGDETAILKEY,
                            kTKPDDETAIL_APICATALOGIDKEY : [_data objectForKey:kTKPDDETAIL_APICATALOGIDKEY]?:@(0),
                            kTKPDDETAIL_APILOCATIONKEY : [_params objectForKey:kTKPDDETAIL_APILOCATIONKEY]?:@(0),
                            kTKPDDETAIL_APIORERBYKEY : [_params objectForKey:kTKPDDETAIL_APIORERBYKEY]?:@(0),
                            kTKPDDETAIL_APICONDITIONKEY : [_params objectForKey:kTKPDDETAIL_APICONDITIONKEY]?:@(0)
                            };
    
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval) {
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKDPDETAILCATALOG_APIPATH parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
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
    _catalog = stats;
    BOOL status = [_catalog.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cachecontroller connectionDidFinish:_cacheconnection];
        //save response data to plist
        [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    if (_timeinterval > _cachecontroller.URLCacheInterval) {
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
            _catalog = stats;
            BOOL status = [_catalog.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            
            _catalog = stats;
            BOOL status = [_catalog.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self setHeaderviewData];
                [self setSpecsViewData];
                [self showDescription:YES];
                _isnodata = NO;
                
                if(_isrefreshseller)
                {
                    // go to seller list
                    _isrefreshseller = NO;
                    _continerscrollview.hidden = YES;
                    CatalogSellerViewController *vc = [CatalogSellerViewController new];
                    NSIndexPath *indexpath = [_params objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                    vc.data = @{kTKPDDETAIL_DATASHOPSKEY: (_catalog.result.catalog_shops),
                                kTKPDDETAIL_DATALOCATIONARRAYKEY: _catalog.result.catalog_location,
                                kTKPDFILTERSORT_DATAINDEXPATHKEY: indexpath};
                    [self.navigationController pushViewController:vc animated:NO];
                }
                else{
                    _continerscrollview.hidden = NO;
                }
            }
        }
        else{
            //[self cancel];

            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    //_table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_act stopAnimating];
                    NSError *error = object;
                    NSString *errorDescription = error.localizedDescription;
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [errorAlert show];
                }
            }
            else
            {
                NSError *error = object;
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
            //else
            //{
            //    [_act stopAnimating];
            //    if(_isrefreshseller)
            //    {
            //        // go to seller list
            //        _isrefreshseller = NO;
            //        CatalogSellerViewController *vc = [CatalogSellerViewController new];
            //        vc.data = @{kTKPDDETAIL_DATALOCATIONARRAYKEY: _catalog.result.catalog_location,
            //                    kTKPDFILTER_DATAINDEXPATHKEY: [_params objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0],
            //                    kTKPDFILTER_DATAFILTERKEY:_params};
            //        [self.navigationController pushViewController:vc animated:NO];
            //    }
            //}
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - Methods
-(void)showDescription:(BOOL)isShow
{
    if (isShow) {
        [_specview removeFromSuperview];
        CGRect frame = _containerview.frame;
        frame.size = _descriptionlabel.frame.size;
        frame.size.height +=64;
        [_containerview setFrame:frame];
        [_containerview addSubview:_descriptionlabel];
        frame.size.height += _headerview.frame.size.height;
        frame.size.width = self.view.frame.size.width;
        [_continerscrollview setContentSize:frame.size];
    }
    else
    {
        [_specview.tabel layoutIfNeeded];
        CGRect frame = _containerview.frame;
        frame.size=_specview.tabel.contentSize;
        [_descriptionlabel removeFromSuperview];
        [_containerview setFrame:frame];
        [_containerview addSubview:_specview];
        frame.size.height += _headerview.frame.size.height;
        frame.size.width = self.view.frame.size.width;
        [_continerscrollview setContentSize:frame.size];
    }
}

-(void)setHeaderviewData{
    
    _namelabel.text = _catalog.result.catalog_info.catalog_name;
    _pricelabel.text = [NSString stringWithFormat:@"%@ - %@", _catalog.result.catalog_info.catalog_price.price_min, _catalog.result.catalog_info.catalog_price.price_max];
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:[NSString convertHTML:_catalog.result.catalog_info.catalog_description]
                                                                                    attributes:attributes];
    
    _descriptionTextView.attributedText = productNameAttributedText;
    _descriptionlabel.attributedText = productNameAttributedText;
    
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize = [_catalog.result.catalog_info.catalog_description sizeWithFont:_descriptionlabel.font constrainedToSize:maximumLabelSize lineBreakMode:_descriptionlabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = _descriptionlabel.frame;
    newFrame.size.height = expectedLabelSize.height+20;
    _descriptionlabel.frame = newFrame;
    
    NSArray *images = _catalog.result.catalog_info.catalog_images;
    
    for(int i = 0; i< images.count; i++)
    {
        CGFloat y = i * self.view.frame.size.width;
        
        CatalogImages *image = images[i];
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:image.image_src] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        //request.URL = url;
        
        UIImageView *thumb = [[UIImageView alloc]initWithFrame:CGRectMake(y, 0, _headerimagescrollview.frame.size.width, _headerimagescrollview.frame.size.height)];
        
        thumb.image = nil;
        //thumb.hidden = YES;	//@prepareforreuse then @reset
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image];
            
#pragma clang diagnostic pop
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
        
        [_headerimagescrollview addSubview:thumb];
        [_headerimages addObject:thumb];
    }
    
    _headerimagescrollview.pagingEnabled = YES;
    
    _pagecontrol.hidden = _headerimages.count <= 1?YES:NO;
    _pagecontrol.numberOfPages = images.count;
    
    _imagenextbutton.hidden = _headerimages.count <= 1?YES:NO;
    _imagebackbutton.hidden = _headerimages.count <= 1?YES:NO;
    
    _imagenextbutton.hidden = (_pageheaderimages == _headerimages.count -1)?YES:NO;
    _imagebackbutton.hidden = (_pageheaderimages == 0)?YES:NO;
    
    _headerimagescrollview.contentSize = CGSizeMake(_headerimages.count*320,0);
}

-(void)setSpecsViewData{

    _specview.data = @{kTKPDDETAILCATALOG_APICATALOGSPECSKEY: _catalog.result.catalog_specs};
    [_specview.tabel layoutIfNeeded];
    CGSize tableViewSize=_specview.tabel.contentSize;
    CGRect frame = _specview.frame;
    frame.size.height = tableViewSize.height;
    [_specview.tabel setFrame:frame];
    [_specview setFrame:frame];
    
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestcount = 0;
    
    /** request data **/
    [self configureRestKit];
    [self request];
}

#pragma mark - Filter Delegate

#pragma mark - Notification
- (void)updateViewDetailCatalog:(NSNotification *)notification
{
    NSDictionary *userinfo = notification.userInfo;
    [_params addEntriesFromDictionary:userinfo];
    _isrefreshseller = YES;
    [self refreshView:nil];
}



@end
