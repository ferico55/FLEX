//
//  DetailCatalogViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"

#import "Catalog.h"

#import "DetailCatalogViewController.h"
#import "CatalogSellerViewController.h"
#import "DetailCatalogSpecView.h"

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

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (weak, nonatomic) IBOutlet UIButton *buybutton;

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
    
    _specview = [DetailCatalogSpecView newview];
    
    [_specview removeFromSuperview];
    [_containerview setFrame:CGRectMake(_containerview.frame.origin.x, _containerview.frame.origin.y, _descriptionlabel.frame.size.width, _descriptionlabel.frame.size.height)];
    [_containerview addSubview:_descriptionlabel];
    [_continerscrollview setContentSize:CGSizeMake(self.view.frame.size.width,_descriptionlabel.frame.size.height + _headerview.frame.size.height+_buybutton.frame.size.height)];
    [_buybutton setFrame:CGRectMake(_buybutton.frame.origin.x, _descriptionlabel.frame.size.height + _headerview.frame.size.height+_buybutton.frame.size.height, _buybutton.frame.size.width, _buybutton.frame.size.height)];
    
    // add notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateViewDetailCatalog:) name:@"setfilterDetailCatalog" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureRestKit];
    if (_isnodata) {
        [self loadData];
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

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                // action image back button
                if (_pageheaderimages>0) {
                    _pageheaderimages --;
                    [_headerimagescrollview setContentOffset:CGPointMake(_headerimagescrollview.frame.size.width*_pageheaderimages, 0.0f) animated:YES];
                }
                break;
            }
            case 11:
            {
                // action image next button
                if (_pageheaderimages<_headerimages.count-1) {
                    _pageheaderimages ++;
                    [_headerimagescrollview setContentOffset:CGPointMake(_headerimagescrollview.frame.size.width*_pageheaderimages, 0.0f) animated:YES];
                }
                break;
            }
            case 12:
            {
                // action sell button
                break;
            }
            case 13:
            {
                // action description button
                [_specview removeFromSuperview];
                [_containerview setFrame:CGRectMake(_containerview.frame.origin.x, _containerview.frame.origin.y, _descriptionlabel.frame.size.width, _descriptionlabel.frame.size.height)];
                [_containerview addSubview:_descriptionlabel];
                [_continerscrollview setContentSize:CGSizeMake(self.view.frame.size.width,_descriptionlabel.frame.size.height + _headerview.frame.size.height + _buybutton.frame.size.height+64)];
                [_buybutton setFrame:CGRectMake(_buybutton.frame.origin.x, _descriptionlabel.frame.size.height + _headerview.frame.size.height+_buybutton.frame.size.height, _buybutton.frame.size.width, _buybutton.frame.size.height)];
                break;
            }
            case 14:
            {
                // action specification button
                [_specview.tabel layoutIfNeeded];
                CGSize tableViewSize=_specview.tabel.contentSize;
                [_descriptionlabel removeFromSuperview];
                [_containerview setFrame:CGRectMake(_containerview.frame.origin.x, _containerview.frame.origin.y, _specview.frame.size.width, tableViewSize.height)];
                [_containerview addSubview:_specview];
                [_continerscrollview setContentSize:CGSizeMake(self.view.frame.size.width,tableViewSize.height + _headerview.frame.size.height + _buybutton.frame.size.height+64)];
                [_buybutton setFrame:CGRectMake(_buybutton.frame.origin.x, tableViewSize.height + _headerview.frame.size.height+_buybutton.frame.size.height, _buybutton.frame.size.width, _buybutton.frame.size.height)];
                break;
            }
            case 15:
            {
                // action buy button - go to seller list
                CatalogSellerViewController *vc = [CatalogSellerViewController new];
                vc.data = @{kTKPDDETAIL_DATASHOPSKEY: (_catalog.result.catalog_shops)?:@"",
                            kTKPDDETAIL_DATALOCATIONARRAYKEY: _catalog.result.catalog_location};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

//#pragma mark - Tableview Data Source
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 0;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    UITableViewCell* cell = nil;
//    if (!_isnodata) {
//     
//	}
//	return cell;
//}
//
//#pragma mark - Table View Delegate
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	if (_isnodata) {
//		cell.backgroundColor = [UIColor whiteColor];
//	}
//    
//    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
//	if (row == indexPath.row) {
//		NSLog(@"%@", NSStringFromSelector(_cmd));
//	}
//}


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
                                                      kTKPDDETAILCATALOG_APICATALOGNAMEKEY:kTKPDDETAILCATALOG_APICATALOGNAMEKEY
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
    
    RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[CatalogImage class]];
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
    
    RKRelationshipMapping *imagesRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APICATALOGIMAGEPATHKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGIMAGESKEY withMapping:imagesMapping];
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:catalogMapping method:RKRequestMethodGET pathPattern:kTKDPDETAILCATALOG_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];

    [_objectmanager addResponseDescriptor:responseDescriptor];
    
}

- (void)loadData
{
    _requestcount++;
    
    [_act startAnimating];
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETCATALOGDETAILKEY,
                            kTKPDDETAIL_APICATALOGIDKEY : [_data objectForKey:kTKPDDETAIL_APICATALOGIDKEY]?:@(0),
                            kTKPDDETAIL_APILOCATIONKEY : [_params objectForKey:kTKPDDETAIL_APILOCATIONKEY]?:@(0),
                            kTKPDDETAIL_APIORERBYKEY : [_params objectForKey:kTKPDDETAIL_APIORERBYKEY]?:@(0),
                            kTKPDDETAIL_APICONDITIONKEY : [_params objectForKey:kTKPDDETAIL_APICONDITIONKEY]?:@(0)
                            };
    
    [_objectmanager getObjectsAtPath:kTKDPDETAILCATALOG_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        [self requestsuccess:mappingResult];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        [self requestfailure:error];
    }];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    _catalog = stats;
    BOOL status = [_catalog.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self setHeaderviewData];
        [self setSpecsViewData];
        _isnodata = NO;
        
        if(_isrefreshseller)
        {
            // go to seller list
            _isrefreshseller = NO;
            _continerscrollview.hidden = YES;
            CatalogSellerViewController *vc = [CatalogSellerViewController new];
            vc.data = @{kTKPDDETAIL_DATASHOPSKEY: (_catalog.result.catalog_shops),
                        kTKPDDETAIL_DATALOCATIONARRAYKEY: _catalog.result.catalog_location};
            [self.navigationController pushViewController:vc animated:NO];
        }
        else{
            _continerscrollview.hidden = NO;
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

-(void)requestfailure:(id)object
{
    [self cancel];
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
            //_table.tableFooterView = _footer;
            [_act startAnimating];
            [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
        else
        {
            [_act stopAnimating];
        }
    }
    else
    {
        [_act stopAnimating];
        if(_isrefreshseller)
        {
            // go to seller list
            _isrefreshseller = NO;
            CatalogSellerViewController *vc = [CatalogSellerViewController new];
            vc.data = @{kTKPDDETAIL_DATALOCATIONARRAYKEY: _catalog.result.catalog_location};
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
}

#pragma mark - Methods
-(void)setHeaderviewData{
    
    _namelabel.text = _catalog.result.catalog_info.catalog_name;
    _pricelabel.text = [NSString stringWithFormat:@"%@ - %@", _catalog.result.catalog_info.catalog_price.price_min, _catalog.result.catalog_info.catalog_price.price_max];
    _descriptionlabel.text = _catalog.result.catalog_info.catalog_description;
    
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize = [_catalog.result.catalog_info.catalog_description sizeWithFont:_descriptionlabel.font constrainedToSize:maximumLabelSize lineBreakMode:_descriptionlabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = _descriptionlabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    _descriptionlabel.frame = newFrame;
    
    [_buybutton setFrame:CGRectMake(_buybutton.frame.origin.x, _descriptionlabel.frame.size.height + _headerview.frame.size.height+_buybutton.frame.size.height, _buybutton.frame.size.width, _buybutton.frame.size.height)];
    [_continerscrollview setContentSize:CGSizeMake(self.view.frame.size.width,_descriptionlabel.frame.size.height + _headerview.frame.size.height + _buybutton.frame.size.height+64)];
    
    NSArray *images = _catalog.result.catalog_info.catalog_image;
    
    for(int i = 0; i< images.count; i++)
    {
        CGFloat y = i * 320;
        
        CatalogImage *image = images[i];
        
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
    [self loadData];
}


#pragma mark - Notification
- (void)updateViewDetailCatalog:(NSNotification *)notification
{
    NSDictionary *userinfo = notification.userInfo;
    [_params addEntriesFromDictionary:userinfo];
    _isrefreshseller = YES;
    [self refreshView:nil];
}



@end
