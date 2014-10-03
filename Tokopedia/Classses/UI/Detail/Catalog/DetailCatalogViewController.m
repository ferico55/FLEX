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

@interface DetailCatalogViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableDictionary *_params;
    
    NSMutableDictionary *_detailcatalog;
    BOOL _isnodata;
    BOOL _isrefreshseller;
    NSTimer *_timer;
    NSInteger _requestcount;
    
    NSMutableArray *_headerimages;
    
    NSInteger _pageheaderimages;
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

@property (strong, nonatomic) IBOutlet UIView *specificationview;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (weak, nonatomic) IBOutlet UIButton *buybutton;

@property (weak, nonatomic) IBOutlet UITableView *table;


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
    
    _detailcatalog = [NSMutableDictionary new];
    _headerimages = [NSMutableArray new];
    _params = [NSMutableDictionary new];
    
    [_specificationview removeFromSuperview];
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
                [_specificationview removeFromSuperview];
                [_containerview setFrame:CGRectMake(_containerview.frame.origin.x, _containerview.frame.origin.y, _descriptionlabel.frame.size.width, _descriptionlabel.frame.size.height)];
                [_containerview addSubview:_descriptionlabel];
                [_continerscrollview setContentSize:CGSizeMake(self.view.frame.size.width,_descriptionlabel.frame.size.height + _headerview.frame.size.height + _buybutton.frame.size.height+64)];
                [_buybutton setFrame:CGRectMake(_buybutton.frame.origin.x, _descriptionlabel.frame.size.height + _headerview.frame.size.height+_buybutton.frame.size.height, _buybutton.frame.size.width, _buybutton.frame.size.height)];
                break;
            }
            case 14:
            {
                // action specification button
                [_descriptionlabel removeFromSuperview];
                [_containerview setFrame:CGRectMake(_containerview.frame.origin.x, _containerview.frame.origin.y, _specificationview.frame.size.width, _specificationview.frame.size.height)];
                [_containerview addSubview:_specificationview];
                [_continerscrollview setContentSize:CGSizeMake(self.view.frame.size.width,_specificationview.frame.size.height + _headerview.frame.size.height + _buybutton.frame.size.height+64)];
                [_buybutton setFrame:CGRectMake(_buybutton.frame.origin.x, _specificationview.frame.size.height + _headerview.frame.size.height+_buybutton.frame.size.height, _buybutton.frame.size.width, _buybutton.frame.size.height)];
                break;
            }
            case 15:
            {
                // action buy button - go to seller list
                CatalogSellerViewController *vc = [CatalogSellerViewController new];
                //TODO::
                //vc.data = @{kTKPDDETAIL_DATASHOPSKEY: [_detailcatalog objectForKey:kTKPDDETAIL_APICATALOGSHOPPATHKEY]?:@[]};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Tableview Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
     
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
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
        
    // setup object mappings
    RKObjectMapping *catalogMapping = [RKObjectMapping mappingForClass:[Catalog class]];
    [catalogMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APISTATUSKEY:kTKPDDETAIL_APISTATUSKEY,kTKPDDETAIL_APISERVERPROCESSTIMEKEY:kTKPDDETAIL_APISERVERPROCESSTIMEKEY}];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailCatalogResult class]];

    
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
    [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILCATALOG_APIIMAGEPRIMARYKEY,kTKPDDETAILCATALOG_APIIMAGESRCKEY]];

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
                                                    kTKPDDETAILCATALOG_APISHOPIDKEY,
                                                    kTKPDDETAILCATALOG_APISHOPLOCATIONKEY,
                                                    kTKPDDETAILCATALOG_APISHOPRATESPEEDKEY,
                                                    kTKPDDETAILCATALOG_APIISGOLDSHOPKEY,
                                                    kTKPDDETAILCATALOG_APISHOPNAMEKEY,
                                                    kTKPDDETAILCATALOG_APISHOPTOTALADDRESSKEY,
                                                    kTKPDDETAILCATALOG_APISHOPTOTALPRODUCTKEY,
                                                    kTKPDDETAILCATALOG_APISHOPRATESERVICEKEY
                                                    ]];
    
    RKObjectMapping *productlistMapping = [RKObjectMapping mappingForClass:[ProductList class]];
    [productlistMapping addAttributeMappingsFromArray:@[kTKPDDETAILCATALOG_APIPRODUCTPRICEKEY,kTKPDDETAILCATALOG_APIPRODUCTIDKEY,kTKPDDETAILCATALOG_APIPRODUCTCONDITIONKEY,kTKPDDETAILCATALOG_APIPRODUCTNAMEKEY]];

    [catalogMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
    
    [infoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGPRICEKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGPRICEKEY withMapping:priceMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGINFOKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGINFOKEY withMapping:infoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGREVIEWKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGREVIEWKEY withMapping:reviewMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGMARKETPRICEKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGMARKETPRICEKEY withMapping:marketpriceMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APICATALOGSPECSPATHKEY toKeyPath:kTKPDDETAILCATALOG_APISPECSKEY withMapping:specsMapping]];
    
    RKRelationshipMapping *imagesRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APICATALOGIMAGEPATHKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGIMAGESKEY withMapping:imagesMapping];
    [resultMapping addPropertyMapping:imagesRel];
    
    RKRelationshipMapping *locationRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APILOCATIONKEY toKeyPath:kTKPDDETAILCATALOG_APILOCATIONKEY withMapping:locationMapping];
    [resultMapping addPropertyMapping:locationRel];
    RKRelationshipMapping *shopsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILCATALOG_APICATALOGSHOPSKEY toKeyPath:kTKPDDETAILCATALOG_APICATALOGSHOPSKEY withMapping:shopsMapping];
    [resultMapping addPropertyMapping:shopsRel];
    
    //TODO::
    RKRelationshipMapping *productlistRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPRODUCTLISTPATHKEY toKeyPath:kTKPDDETAILCATALOG_APIPRODUCTLISTKEY withMapping:productlistMapping];
    [shopsMapping addPropertyMapping:productlistRel];
    
    [specsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APICATALOGSPECCHILDSPATHKEY toKeyPath:kTKPDDETAILCATALOG_APISPECCHILDSKEY withMapping:specchildsMapping]];
    
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
    
    Catalog *catalog = stats;
    BOOL status = [catalog.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [_detailcatalog addEntriesFromDictionary:result];
        [self setHeaderviewData:catalog];
        _isnodata = NO;
        
        if(_isrefreshseller)
        {
            // go to seller list
            _isrefreshseller = NO;
            _continerscrollview.hidden = YES;
            CatalogSellerViewController *vc = [CatalogSellerViewController new];
            //TODO::
            //vc.data = @{kTKPDDETAIL_DATASHOPSKEY: [_detailcatalog objectForKey:kTKPDDETAIL_APICATALOGSHOPPATHKEY]?:@[]};
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
            //TODO::
            //vc.data = @{kTKPDDETAIL_DATASHOPSKEY: [_detailcatalog objectForKey:kTKPDDETAIL_APICATALOGSHOPPATHKEY]?:@[]};
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
}

#pragma mark - Methods
-(void)setHeaderviewData:(id)catalog{
    
    Catalog *c = catalog;
    _namelabel.text = c.result.catalog_info.catalog_name;
    _pricelabel.text = [NSString stringWithFormat:@"%@ - %@", c.result.catalog_info.catalog_price.price_min, c.result.catalog_info.catalog_price.price_max];
    _descriptionlabel.text = c.result.catalog_info.catalog_description;
    
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize = [c.result.catalog_info.catalog_description sizeWithFont:_descriptionlabel.font constrainedToSize:maximumLabelSize lineBreakMode:_descriptionlabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = _descriptionlabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    _descriptionlabel.frame = newFrame;
    
    [_buybutton setFrame:CGRectMake(_buybutton.frame.origin.x, _descriptionlabel.frame.size.height + _headerview.frame.size.height+_buybutton.frame.size.height, _buybutton.frame.size.width, _buybutton.frame.size.height)];
    [_continerscrollview setContentSize:CGSizeMake(self.view.frame.size.width,_descriptionlabel.frame.size.height + _headerview.frame.size.height + _buybutton.frame.size.height+64)];
    
    NSArray *images = c.result.catalog_info.catalog_image;
    
    for(int i = 0; i< images.count; i++)
    {
        CGFloat y = i * 320;
        
        NSDictionary *image = images[i];
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[image objectForKey:kTKPDDETAILCATALOG_APIIMAGESRCKEY]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        //request.URL = url;
        
        UIImageView *thumb = [[UIImageView alloc]initWithFrame:CGRectMake(y, 0, _headerimagescrollview.frame.size.width, _headerimagescrollview.frame.size.height)];
        
        thumb.image = nil;
        //thumb.hidden = YES;	//@prepareforreuse then @reset
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            //NSLOG(@"thumb: %@", thumb);
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

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    [_detailcatalog removeAllObjects];
    
    _requestcount = 0;
    
    [_table reloadData];
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
