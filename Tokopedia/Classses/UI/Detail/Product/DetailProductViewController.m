//
//  DetailProductViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "search.h"
#import "stringrestkit.h"

#import "Product.h"

#import "StarsRateView.h"

#import "DetailProductViewController.h"
#import "DetailProductWholesaleCell.h"
#import "DetailProductInfoCell.h"
#import "DetailProductDescriptionCell.h"
#import "DetailProductWholesaleTableCell.h"

#import "TKPDTabNavigationController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"
#import "ProductReviewViewController.h"
#import "ProductTalkViewController.h"

#import "DetailProductOtherView.h"

#import "TKPDTabShopNavigationController.h"
#import "ShopProductViewController.h"
#import "ShopTalkViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"

#import "URLCacheController.h"

#pragma mark - Detail Product View Controller
@interface DetailProductViewController () <UITableViewDelegate, UITableViewDataSource, DetailProductInfoCellDelegate, DetailProductOtherViewDelegate>
{
    NSMutableDictionary *_datatalk;
    NSMutableArray *_otherproductviews;
    
    NSMutableArray *_expandedSections;
    CGFloat _descriptionHeight;
    CGFloat _informationHeight;
    
    BOOL _isnodata;
    BOOL _isnodatawholesale;
    NSTimer *_timer;
    
    NSInteger _requestcount;
    
    NSMutableArray *_headerimages;
    
    NSInteger _pageheaderimages;
    NSInteger _heightDescSection;
    Product *_product;
    BOOL is_dismissed;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    RKResponseDescriptor *_responseDescriptor;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UIView *sticky;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UILabel *productnamelabel;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UIButton *reviewbutton;
@property (weak, nonatomic) IBOutlet UIButton *talkaboutbutton;
@property (weak, nonatomic) IBOutlet UIImageView *shopthumb;
@property (weak, nonatomic) IBOutlet UILabel *shopname;
@property (weak, nonatomic) IBOutlet UILabel *accuracynumberlabel;
@property (weak, nonatomic) IBOutlet UILabel *qualitynumberlabel;
@property (weak, nonatomic) IBOutlet UIScrollView *imagescrollview;
@property (weak, nonatomic) IBOutlet StarsRateView *qualityrateview;
@property (weak, nonatomic) IBOutlet StarsRateView *accuracyrateview;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrol;
@property (weak, nonatomic) IBOutlet UIButton *backbutton;
@property (weak, nonatomic) IBOutlet UIButton *nextbutton;

@property (weak, nonatomic) IBOutlet StarsRateView *ratespeedshop;
@property (weak, nonatomic) IBOutlet StarsRateView *rateaccuracyshop;
@property (weak, nonatomic) IBOutlet StarsRateView *rateserviceshop;
@property (weak, nonatomic) IBOutlet UILabel *countsoldlabel;
@property (weak, nonatomic) IBOutlet UILabel *countviewlabel;

@property (weak, nonatomic) IBOutlet UILabel *shoplocation;
@property (strong, nonatomic) IBOutlet UIView *shopinformationview;
@property (strong, nonatomic) IBOutlet DetailProductOtherView *otherproductview;

@property (weak, nonatomic) IBOutlet UIScrollView *otherproductscrollview;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

@end

@implementation DetailProductViewController

@synthesize data = _data;

#pragma mark - Initializations

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _isnodatawholesale = YES;
        _requestcount = 0;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Detail Produk";
    
    _datatalk = [NSMutableDictionary new];
    _headerimages = [NSMutableArray new];
    _otherproductviews = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
//    _isexpanded = NO;
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    /** set inset table for different size**/
    is_dismissed = [[_data objectForKey:@"is_dismissed"] boolValue];
    if(is_dismissed) {
        [self.navigationController.navigationBar setTranslucent:NO];
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            
        }
    }
//    if (is4inch) {
//        UIEdgeInsets inset = _table.contentInset;
//        inset.bottom += 200;
//        _table.contentInset = inset;
//    }
//    else{
//        UIEdgeInsets inset = _table.contentInset;
//        inset.bottom += 120;
//        _table.contentInset = inset;
//    }
    
    UIEdgeInsets inset = _table.contentInset;
    inset.bottom += 190;
    _table.contentInset = inset;
    _table.tableHeaderView = _header;
    _table.tableFooterView = _shopinformationview;
    
    _expandedSections = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:1]]];
    
    _imagescrollview.pagingEnabled = YES;
    _imagescrollview.contentMode = UIViewContentModeScaleAspectFit;
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILPRODUCT_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILPRODUCT_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
    
    // UIView below table view (View More Product button)
    UIView *backgroundGreyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+100)];
    backgroundGreyView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    [self.view insertSubview:backgroundGreyView belowSubview:self.table];

    //Set initial table view cell for product information
    _informationHeight = 232;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureRestKit];
    if (_isnodata) {
        [self loadData];
        if (_product.result.wholesale_price) {
            _expandedSections = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2]]];
        } else {
            _expandedSections = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:1]]];
        }
        [self.table reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    if (section>0) return YES;
    
    return NO;
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    _nextbutton.hidden = (_pageheaderimages == _headerimages.count -1)?YES:NO;
    _backbutton.hidden = (_pageheaderimages == 0)?YES:NO;
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 10:
            {
                // back action image scroll view
                if (_pageheaderimages>0) {
                    _pageheaderimages --;
                    [_imagescrollview setContentOffset:CGPointMake(_imagescrollview.frame.size.width*_pageheaderimages, 0.0f) animated:YES];

                }
                break;
            }
            case 11:
            {
                // next action image scroll view
                if (_pageheaderimages<_headerimages.count-1) {
                    _pageheaderimages ++;
                    [_imagescrollview setContentOffset:CGPointMake(_imagescrollview.frame.size.width*_pageheaderimages, 0.0f) animated:YES];
                }
                break;
            }
            case 12:
            {
                // go to review page
                ProductReviewViewController *vc = [ProductReviewViewController new];
                NSArray *images = _product.result.product_images;
                ProductImages *image = images[0];
                
                vc.data = @{
                            kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
                            kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY : _product.result.info.product_name,
                            kTKPDDETAILPRODUCT_APIIMAGESRCKEY : image.image_src,
                            kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 13:
            {
                // got to talk page
                ProductTalkViewController *vc = [ProductTalkViewController new];
                NSArray *images = _product.result.product_images;
                ProductImages *image = images[0];
                
                [_datatalk setObject:[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0) forKey:kTKPDDETAIL_APIPRODUCTIDKEY];
                [_datatalk setObject:image.image_src?:@(0) forKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY];
                [_datatalk setObject:_product.result.statistic.product_sold forKey:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY];
                [_datatalk setObject:_product.result.statistic.product_view forKey:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY];
                [_datatalk setObject:@(_product.result.shop_info.shop_id) forKey:TKPD_TALK_SHOP_ID];
                
                NSMutableDictionary *data = [NSMutableDictionary new];
                [data addEntriesFromDictionary:_datatalk];
                [data setObject:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null] forKey:kTKPD_AUTHKEY];
                vc.data = data;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 14:
            {
                
            }
            case 15:
            {
                NSString *activityItem = [NSString stringWithFormat:@"Jual %@ - %@ | Tokopedia %@", _product.result.info.product_name,
                                          _product.result.shop_info.shop_name, _product.result.info.product_url];
                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityItem,]
                                                                                                 applicationActivities:nil];
                activityController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                [self presentViewController:activityController animated:YES completion:nil];
                break;
            }
            case 16:
            {
                break;
            }
            default:
                break;
        }
    } else {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 10:
            {
                if(is_dismissed) {
                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }
        }
    }
}

-(IBAction)gesture:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                // go to shop
                NSMutableArray *viewcontrollers = [NSMutableArray new];
                NSInteger shopid = _product.result.shop_info.shop_id;
                if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]==shopid) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    // create new view controller
                    ShopProductViewController *v = [ShopProductViewController new];
                    v.data = @{kTKPDDETAIL_APISHOPIDKEY:@(shopid?:0),
                               kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
                               kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0)
                               };
                    [viewcontrollers addObject:v];
                    ShopTalkViewController *v1 = [ShopTalkViewController new];
                    v1.data = @{kTKPDDETAIL_APISHOPIDKEY:@(shopid?:0),
                                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
                    [viewcontrollers addObject:v1];
                    ShopReviewViewController *v2 = [ShopReviewViewController new];
                    v2.data = @{kTKPDDETAIL_APISHOPIDKEY:@(shopid?:0),
                                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
                    [viewcontrollers addObject:v2];
                    ShopNotesViewController *v3 = [ShopNotesViewController new];
                    v3.data = @{kTKPDDETAIL_APISHOPIDKEY:@(shopid?:0),
                                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
                    [viewcontrollers addObject:v3];
                    /** Adjust View Controller **/
                    TKPDTabShopNavigationController *tapnavcon = [TKPDTabShopNavigationController new];
                    tapnavcon.data = @{kTKPDDETAIL_APISHOPIDKEY:@(shopid?:0),
                                       kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
                    [tapnavcon setViewControllers:viewcontrollers animated:YES];
                    [tapnavcon setSelectedIndex:0];
                    
                    [self.navigationController pushViewController:tapnavcon animated:YES];
                }
                break;
            }
        }
    }
}


#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *mView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, 50, 40)];
    [mView setBackgroundColor:[UIColor whiteColor]];
    
    BOOL sectionIsExpanded = [_expandedSections containsObject:[NSNumber numberWithInteger:section]];
    
    UIButton *expandCollapseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    expandCollapseButton.tag = section;
    [expandCollapseButton addTarget:self action:@selector(expandCollapseButton:) forControlEvents:UIControlEventTouchUpInside];
    [expandCollapseButton setFrame:CGRectMake(self.view.frame.size.width-40, 0, 40, 40)];
    if (sectionIsExpanded) {
        [expandCollapseButton setImage:[UIImage imageNamed:@"icon_arrow_up.png"] forState:UIControlStateNormal];
    } else {
        [expandCollapseButton setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateNormal];
    }
    [mView addSubview:expandCollapseButton];
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt setFrame:CGRectMake(15, 0, 170, 40)];
    [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bt setTag:section];
    [bt.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [bt setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [bt.titleLabel setFont: [UIFont fontWithName:@"GothamMedium" size:15.0f]];
    [bt addTarget:self action:@selector(expandCollapseButton:) forControlEvents:UIControlEventTouchUpInside];
    switch (section) {
        case 0:
            [bt setTitle: @"Product Description" forState: UIControlStateNormal];
            break;
        case 1:
            if (!_isnodatawholesale)
                [bt setTitle: @"Wholesale Price " forState: UIControlStateNormal];
            else
                [bt setTitle: @"Product Information" forState: UIControlStateNormal];
            break;
        case 2:
            [bt setTitle: @"Product Information" forState: UIControlStateNormal];
            break;
            
        default:
            break;
    }
    [mView addSubview:bt];

    // Add border bottom if view header section is collapse
    if (!sectionIsExpanded) {
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1];
        bottomBorder.tag = 22;
        [mView addSubview:bottomBorder];
    } else {
        UIView *view = [mView viewWithTag:22];
        [view removeFromSuperview];
    }
    
    return mView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

#pragma mark - Suppose you want to hide/show section 2... then
#pragma mark  add or remove the section on toggle the section header for more info

- (void)expandCollapseButton:(UIButton *)button
{
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:button.tag]];
    if (sectionIsExanded) {
        [_expandedSections removeObject:[NSNumber numberWithInteger:button.tag]];
    } else {
        [_expandedSections addObject:[NSNumber numberWithInteger:button.tag]];
    }
    [self.table reloadData];
}

#pragma mark -
#pragma mark  What will be the height of the section, Make it dynamic

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:indexPath.section]];
    if (sectionIsExanded) {
        if (indexPath.section == 0) {
            return _descriptionHeight+50;
        } else if (indexPath.section == 1 && _product.result.wholesale_price.count > 0) {
            return 230;
        } else {
            return _informationHeight+50;
        }
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_isnodatawholesale)return 3;
    else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;

    // Configure the cell...
    if (indexPath.section == 0) {
        NSString *cellid = kTKPDDETAILPRODUCTCELLIDENTIFIER;
        DetailProductDescriptionCell *descriptionCell = (DetailProductDescriptionCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (descriptionCell == nil) {
            descriptionCell = [DetailProductDescriptionCell newcell];
            if(!_isnodata) {
                descriptionCell.descriptionText = _product.result.info.product_description;
                _descriptionHeight = descriptionCell.descriptionlabel.frame.size.height;
            }
        }
        cell = descriptionCell;
        return cell;
    }
    if (!_isnodatawholesale) {
        if (indexPath.section == 1) {
                NSString *cellid = kTKPDDETAILPRODUCTWHOLESALECELLIDENTIFIER;
                cell = (DetailProductWholesaleCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
                if (cell == nil) {
                    cell = [DetailProductWholesaleCell newcell];
                }
            ((DetailProductWholesaleCell*)cell).data = @{kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY : _product.result.wholesale_price};

            return cell;
        }
        if (indexPath.section == 2) {
                NSString *cellid = kTKPDDETAILPRODUCTINFOCELLIDENTIFIER;
                DetailProductInfoCell *productInfoCell = (DetailProductInfoCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
                if (productInfoCell == nil) {
                    productInfoCell = [DetailProductInfoCell newcell];
                    ((DetailProductInfoCell*)cell).delegate = self;
                }
                [self productinfocell:productInfoCell withtableview:tableView];
                _informationHeight = productInfoCell.productInformationView.frame.size.height;
                cell = productInfoCell;
                return cell;
        }
    }
    else
    {
        if (indexPath.section == 1) {
            NSString *cellid = kTKPDDETAILPRODUCTINFOCELLIDENTIFIER;
            DetailProductInfoCell *productCell = (DetailProductInfoCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (productCell == nil) {
                productCell = [DetailProductInfoCell newcell];
                ((DetailProductInfoCell*)cell).delegate = self;
                _informationHeight = productCell.productInformationView.frame.size.height;
            }
            [self productinfocell:productCell withtableview:tableView];
            cell = productCell;
            return cell;
        }

    }
    return cell;
}

-(void)productinfocell:(UITableViewCell*)cell withtableview:(UITableView*)tableView
{

    ((DetailProductInfoCell*)cell).minorderlabel.text = [NSString stringWithFormat:@"%d",_product.result.info.product_min_order];
    ((DetailProductInfoCell*)cell).weightlabel.text = _product.result.info.product_weight_unit;
    ((DetailProductInfoCell*)cell).insurancelabel.text = _product.result.info.product_insurance;
    ((DetailProductInfoCell*)cell).conditionlabel.text = _product.result.info.product_condition;
    NSArray *breadcrumbs = _product.result.breadcrumb;
    for (int i = 0; i<breadcrumbs.count; i++) {
        Breadcrumb *breadcrumb = breadcrumbs[i];
        [((UIButton*)((DetailProductInfoCell*)cell).categorybuttons[i]) setTitle:breadcrumb.department_name forState:UIControlStateNormal];
        ((UIButton*)((DetailProductInfoCell*)cell).categorybuttons[i]).hidden = NO;
    }
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
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[Product class]];
    [productMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailProductResult class]];
    RKObjectMapping *infoMapping = [RKObjectMapping mappingForClass:[Info class]];
    [infoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTWEIGHTUNITKEY:kTKPDDETAILPRODUCT_APIPRODUCTWEIGHTUNITKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTDESCRIPTIONKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTPRICEKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTINSURANCEKEY:kTKPDDETAILPRODUCT_APIPRODUCTINSURANCEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTCONDITIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTCONDITIONKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTMINORDERKEY:kTKPDDETAILPRODUCT_APIPRODUCTMINORDERKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY:kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTIDKEY:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTURLKEY:kTKPDDETAILPRODUCT_APIPRODUCTURLKEY,
                                                      }];
    
    RKObjectMapping *statisticMapping = [RKObjectMapping mappingForClass:[Statistic class]];
    [statisticMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISTATISTICKEY:kTKPDDETAILPRODUCT_APISTATISTICKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY

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
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY
                                                          }];
    
    RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY
                                                           }];
    
    RKObjectMapping *wholesaleMapping = [RKObjectMapping mappingForClass:[WholesalePrice class]];
    [wholesaleMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIWHOLESALEMINKEY,kTKPDDETAILPRODUCT_APIWHOLESALEPRICEKEY,kTKPDDETAILPRODUCT_APIWHOLESALEMAXKEY]];
    
    RKObjectMapping *breadcrumbMapping = [RKObjectMapping mappingForClass:[Breadcrumb class]];
    [breadcrumbMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIDEPARTMENTNAMEKEY,kTKPDDETAILPRODUCT_APIDEPARTMENTIDKEY]];
    
    RKObjectMapping *otherproductMapping = [RKObjectMapping mappingForClass:[OtherProduct class]];
    [otherproductMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIPRODUCTPRICEKEY,kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY,kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY]];

    RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[ProductImages class]];
    [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIIMAGEIDKEY,kTKPDDETAILPRODUCT_APIIMAGESTATUSKEY,kTKPDDETAILPRODUCT_APIIMAGEDESCRIPTIONKEY,kTKPDDETAILPRODUCT_APIIMAGEPRIMARYKEY,kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
    
    // Relationship Mapping
    [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY withMapping:infoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY toKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY withMapping:statisticMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY withMapping:shopinfoMapping]];
    [shopinfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY withMapping:shopstatsMapping]];

    RKRelationshipMapping *breadcrumbRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY toKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY withMapping:breadcrumbMapping];
    [resultMapping addPropertyMapping:breadcrumbRel];
    RKRelationshipMapping *otherproductRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY toKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY withMapping:otherproductMapping];
    [resultMapping addPropertyMapping:otherproductRel];
    RKRelationshipMapping *productimageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY toKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY withMapping:imagesMapping];
    [resultMapping addPropertyMapping:productimageRel];
    RKRelationshipMapping *wholesaleRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY toKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY withMapping:wholesaleMapping];
    [resultMapping addPropertyMapping:wholesaleRel];
    
    // Response Descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)loadData
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETDETAILACTIONKEY,
                            kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILPRODUCT_APIPATH parameters:param];
	[_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval) {
        [_act startAnimating];
        
        //[_cachecontroller clearCache];
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
    id stats = [result objectForKey:@""];
    _product = stats;
    BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
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
            _product = stats;
            BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            _product = stats;
            BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                _table.hidden = NO;
                
                if (_product.result.wholesale_price.count > 0) {
                    _isnodatawholesale = NO;
                }
                
                //decide description height
                id cell = [DetailProductDescriptionCell newcell];
                NSString *productdesc = _product.result.info.product_description;
                UILabel *desclabel = ((DetailProductDescriptionCell*)cell).descriptionlabel;
                desclabel.text = productdesc;
                CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
                
                CGSize expectedLabelSize = [productdesc sizeWithFont:desclabel.font constrainedToSize:maximumLabelSize lineBreakMode:desclabel.lineBreakMode];
                _heightDescSection = lroundf(expectedLabelSize.height);
                
                [self setHeaderviewData];
                [self setFooterViewData];
                [self setOtherProducts];
                _isnodata = NO;
                [_table reloadData];
            }
        }else{
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
            }
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _imagescrollview.frame.size.width;
    _pageheaderimages = floor((_imagescrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pagecontrol.currentPage = _pageheaderimages;
    _nextbutton.hidden = (_pageheaderimages == _headerimages.count -1)?YES:NO;
    _backbutton.hidden = (_pageheaderimages == 0)?YES:NO;
    
}

#pragma mark - Cell Delegate
-(void)DetailProductInfoCell:(UITableViewCell *)cell withbuttonindex:(NSInteger)index
{
    switch (index) {
        case 10:
        case 11:
        case 12:
        {
            // Tag 10 until 12 is category
            /** Goto category **/
            NSArray *breadcrumbs = _product.result.breadcrumb;
            Breadcrumb *breadcrumb = breadcrumbs[index-10];
            
            SearchResultViewController *vc = [SearchResultViewController new];
            NSString *deptid = breadcrumb.department_id;
            vc.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY,kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:0};
            SearchResultViewController *vc1 = [SearchResultViewController new];
            vc1.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY,kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:0};
            SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
            vc2.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY,kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:0};
            NSArray *viewcontrollers = @[vc,vc1,vc2];
            
            TKPDTabNavigationController *c = [TKPDTabNavigationController new];
            
            [c setSelectedIndex:0];
            [c setViewControllers:viewcontrollers];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
            [nav.navigationBar setTranslucent:NO];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            break;
        }
        case 13:
        {
            // Etalase
            
            break;
        }
        default:
            break;
    }

}

#pragma mark - View Delegate
- (void)DetailProductOtherView:(UIView *)view withindex:(NSInteger)index
{
    OtherProduct *product = _product.result.other_product[index];
    if ([[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue] != [product.product_id integerValue]) {
        DetailProductViewController *vc = [DetailProductViewController new];
        vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : product.product_id};
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Methods
-(void)setHeaderviewData{

    CGFloat currentLabelHeight = _productnamelabel.frame.size.height;
    _productnamelabel.text = _product.result.info.product_name?:@"";

    NSString *productName = _product.result.info.product_name?:@"";
//    NSString *productName = @"Alice in Wonderland: White Rabbit Tsum Tsum Plush 3.5";

    UIFont *font = [UIFont fontWithName:@"GothamMedium" size:15];

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:productName
                                                                   attributes:attributes];

    _productnamelabel.attributedText = productNameAttributedText;
    _productnamelabel.numberOfLines = 0;
    [_productnamelabel sizeToFit];
    
    //Update header view
    CGFloat newLabelHeight = _productnamelabel.frame.size.height;
    CGFloat additionalHeightForHeader = newLabelHeight - currentLabelHeight;
    CGRect newHeaderFrame = _header.frame;
    newHeaderFrame.size.height = newHeaderFrame.size.height + additionalHeightForHeader;
    _header.frame = newHeaderFrame;
    
    _pricelabel.text = _product.result.info.product_price;
    _countsoldlabel.text = [NSString stringWithFormat:@"%@ Sold", _product.result.statistic.product_sold];
    _countviewlabel.text = [NSString stringWithFormat:@"%@ View", _product.result.statistic.product_view];

    [_reviewbutton setTitle:[NSString stringWithFormat:@"%@ Reviews",_product.result.statistic.product_review] forState:UIControlStateNormal];
    [_reviewbutton.layer setBorderWidth:1];
    [_reviewbutton.layer setBorderColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1].CGColor];
    
    [_talkaboutbutton setTitle:[NSString stringWithFormat:@"%@ Talk About it",_product.result.statistic.product_talk] forState:UIControlStateNormal];
    [_talkaboutbutton.layer setBorderWidth:1];
    [_talkaboutbutton.layer setBorderColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1].CGColor];
    
    _qualitynumberlabel.text = [NSString stringWithFormat: @"%d ",_product.result.statistic.product_quality_point];
    _qualityrateview.starscount = _product.result.statistic.product_quality_rate;
    
    _accuracynumberlabel.text = [NSString stringWithFormat:@"%d", _product.result.statistic.product_accuracy_point];
    
    NSArray *images = _product.result.product_images;
    
    for(int i = 0; i< images.count; i++)
    {
        CGFloat y = i * 320;
        
        ProductImages *image = images[i];
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:image.image_src] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = [[UIImageView alloc]initWithFrame:CGRectMake(y, 0, _imagescrollview.frame.size.width, _imagescrollview.frame.size.height)];
        
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
        
        thumb.contentMode = UIViewContentModeScaleAspectFit;
        
        [_imagescrollview addSubview:thumb];
        [_headerimages addObject:thumb];
    }
    
    _pagecontrol.hidden = _headerimages.count <= 1?YES:NO;
    _pagecontrol.numberOfPages = images.count;
    
    _nextbutton.hidden = _headerimages.count <= 1?YES:NO;
    _backbutton.hidden = _headerimages.count <= 1?YES:NO;
    
    _nextbutton.hidden = (_pageheaderimages == _headerimages.count -1)?YES:NO;
    _backbutton.hidden = (_pageheaderimages == 0)?YES:NO;
    
    _imagescrollview.contentSize = CGSizeMake(_headerimages.count*320,0);
    _imagescrollview.contentMode = UIViewContentModeScaleAspectFit;
    _imagescrollview.showsHorizontalScrollIndicator = NO;
    
    [_datatalk setObject:_product.result.info.product_name?:@"" forKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY];
    [_datatalk setObject:_product.result.info.product_price?:@"" forKey:kTKPDDETAILPRODUCT_APIPRODUCTPRICEKEY];
    [_datatalk setObject:_headerimages?:@"" forKey:kTKPDDETAILPRODUCT_APIPRODUCTIMAGESKEY];
}

-(void)setFooterViewData
{
    _shopname.text = _product.result.shop_info.shop_name;
    _shoplocation.text = _product.result.shop_info.shop_location;
    
    _ratespeedshop.starscount = _product.result.shop_info.shop_stats.shop_speed_rate;
    _rateserviceshop.starscount = _product.result.shop_info.shop_stats.shop_service_rate;
    _rateaccuracyshop.starscount = _product.result.shop_info.shop_stats.shop_accuracy_rate;
    
    UIImageView *thumb = _shopthumb;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_product.result.shop_info.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    thumb.image = nil;
    thumb.layer.cornerRadius = thumb.layer.frame.size.width/2;
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];

}

-(void)setOtherProducts
{

        for(int i = 0; i< _product.result.other_product.count; i++)
        {
            CGFloat y = i * 155;
            
            OtherProduct *product = _product.result.other_product[i];
            
            DetailProductOtherView *v = [DetailProductOtherView newview];
            [v setFrame:CGRectMake(y + 10, 0, _otherproductscrollview.frame.size.width, _otherproductscrollview.frame.size.height)];
            v.delegate = self;
            v.index = i;
            v.namelabel.text = product.product_name;
            v.pricelabel.text = product.product_price;
            //DetailProductOtherView *v = [[DetailProductOtherView alloc]initWithFrame:CGRectMake(y, 0, _otherproductscrollview.frame.size.width, _otherproductscrollview.frame.size.height)];
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            
            UIImageView *thumb = v.thumb;
            //UIImageView *thumb = [[UIImageView alloc]initWithFrame:CGRectMake(y, 0, _imagescrollview.frame.size.width, _imagescrollview.frame.size.height)];
            
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
                [v.act stopAnimating];
#pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [v.act stopAnimating];
            }];
            
            [_otherproductscrollview addSubview:v];
            [_otherproductviews addObject:v];
        }
        
        _otherproductscrollview.pagingEnabled = YES;
        _otherproductscrollview.contentSize = CGSizeMake(_otherproductviews.count*160,0);
}


@end
