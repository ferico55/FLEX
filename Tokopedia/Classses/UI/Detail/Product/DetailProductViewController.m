//
//  DetailProductViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "search.h"

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

#pragma mark - Detail Product View Controller
@interface DetailProductViewController () <UITableViewDelegate, UITableViewDataSource, DetailProductInfoCellDelegate>
{
    NSMutableDictionary *_detailproduct;
    
    NSMutableDictionary *_datatalk;
    
    NSMutableArray *_detailwholesale;
    
    NSMutableIndexSet *expandedSections;
    BOOL _isexpanded;
    NSInteger _heightOfSection;
    
    BOOL _isnodata;
    BOOL _isnodatawholesale;
    NSTimer *_timer;
    
    NSInteger _requestcount;
    
    NSInteger _expandedsection;
    
    NSMutableArray *_headerimages;
    
    NSInteger _pageheaderimages;
    __weak RKObjectManager *_objectmanager;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *header;
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
@property (weak, nonatomic) IBOutlet StarsRateView *productrateview;
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
    
    _detailproduct = [NSMutableDictionary new];
    _datatalk = [NSMutableDictionary new];
    _detailwholesale = [NSMutableArray new];
    _headerimages = [NSMutableArray new];
    
    _isexpanded = NO;
    
    /** set inset table for different size**/
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 200;
        _table.contentInset = inset;
    }
    else{
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 120;
        _table.contentInset = inset;
    }
    
    _table.tableHeaderView = _header;
    _table.tableFooterView = _shopinformationview;
    
    if (!expandedSections)
    {
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    
    _imagescrollview.pagingEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureRestKit];
    if (_isnodata) {
        [self loadData];
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self tableView:tableView canCollapseSection:indexPath.section])
//    {
//        if (!indexPath.row)
//        {
//            // only first row toggles exapand/collapse
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            
//            NSInteger section = indexPath.section;
//            BOOL currentlyExpanded = [expandedSections containsIndex:section];
//            NSInteger rows;
//            
//            NSMutableArray *tmpArray = [NSMutableArray array];
//            
//            if (currentlyExpanded)
//            {
//                rows = [self tableView:tableView numberOfRowsInSection:section];
//                [expandedSections removeIndex:section];
//                
//            }
//            else
//            {
//                [expandedSections addIndex:section];
//                rows = [self tableView:tableView numberOfRowsInSection:section];
//            }
//            
//            if (currentlyExpanded)
//            {
//                [tableView deleteRowsAtIndexPaths:tmpArray
//                                 withRowAnimation:UITableViewRowAnimationTop];
//            }
//            else
//            {
//                [tableView insertRowsAtIndexPaths:tmpArray
//                                 withRowAnimation:UITableViewRowAnimationTop];
//            }
//        }
//    }
//}

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
                vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0)};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 13:
            {
                // got to talk page
                ProductTalkViewController *vc = [ProductTalkViewController new];
                [_datatalk setObject:[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0) forKey:kTKPDDETAIL_APIPRODUCTIDKEY];
                vc.data = _datatalk;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}


#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *mView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 200)];
    [mView setBackgroundColor:[UIColor greenColor]];
    
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 20, 20)];
    [logoView setImage:[UIImage imageNamed:@"carat.png"]];
    [mView addSubview:logoView];
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt setFrame:CGRectMake(0, 0, 150, 20)];
    [bt setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [bt setTag:section];
    [bt.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [bt.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [bt.titleLabel setTextColor:[UIColor blackColor]];
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
    //[bt addTarget:self action:@selector(addCell:) forControlEvents:UIControlEventTouchUpInside];
    [mView addSubview:bt];
    return mView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

#pragma mark - Suppose you want to hide/show section 2... then
#pragma mark  add or remove the section on toggle the section header for more info

- (void)addCell:(UIButton *)bt{
    
    // If section of more information
    if (bt.tag != 0) {
        // Initially more info is close, if more info is open
        if(_isexpanded) {
            // Set height of section
            _heightOfSection = 0;
            // Reset the parameter that more info is closed now
            _isexpanded = NO;
        }else {
            // Set height of section
            _heightOfSection = 200.0f;
            // Reset the parameter that more info is closed now
            _isexpanded = YES;
        }
        _expandedsection = bt.tag;
        [_table reloadData];
        [_table reloadSections:[NSIndexSet indexSetWithIndex:bt.tag] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -
#pragma mark  What will be the height of the section, Make it dynamic

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //if (indexPath.section == _expandedsection && indexPath.section != 0) {
    //    return _heightOfSection;
    //}else if (indexPath.section == 0)
        return 200;
    //else {
    //    return 0;
   //}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_isnodatawholesale)return 3;
    else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (_isexpanded || section == 0) {
        return 1;
    //}
    //return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    // Configure the cell...
    if (indexPath.section == 0) {
        //if (_isexpanded) {
            NSString *cellid = kTKPDDETAILPRODUCTCELLIDENTIFIER;
            cell = (DetailProductDescriptionCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [DetailProductDescriptionCell newcell];
                //((DetailProductWholesaleCell*)cell).delegate = self;
            }
        
            id products = [_detailproduct objectForKey:@""];
            Product *product = products;
            NSString *productdesc = product.result.info.product_description;
            ((DetailProductDescriptionCell*)cell).descriptionlabel.text = productdesc;
        //}
        return cell;
    }
    if (!_isnodatawholesale) {
        if (indexPath.section == 1) {
            //wholesale price view
            //if (_isexpanded) {
                NSString *cellid = kTKPDDETAILPRODUCTWHOLESALECELLIDENTIFIER;
                cell = (DetailProductWholesaleCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
                if (cell == nil) {
                    cell = [DetailProductWholesaleCell newcell];
                    //((DetailProductWholesaleCell*)cell).delegate = self;
                }
            ((DetailProductWholesaleCell*)cell).data = @{kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY :[_detailproduct objectForKey:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY]?:@[]};
            //}
            return cell;
        }
        if (indexPath.section == 2) {
            // if (_isexpanded) {
                NSString *cellid = kTKPDDETAILPRODUCTWHOLESALECELLIDENTIFIER;
                cell = (DetailProductInfoCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
                if (cell == nil) {
                    cell = [DetailProductInfoCell newcell];
                    ((DetailProductInfoCell*)cell).delegate = self;
                }
                [self productinfocell:cell withtableview:tableView];
                return cell;
            //}
        }
    }
    else
    {
        if (indexPath.section == 1) {
            //if (_isexpanded) {
            NSString *cellid = kTKPDDETAILPRODUCTWHOLESALECELLIDENTIFIER;
            cell = (DetailProductInfoCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [DetailProductInfoCell newcell];
                ((DetailProductInfoCell*)cell).delegate = self;
            }
            [self productinfocell:cell withtableview:tableView];
            
            //TODO::category & etalase label
            
            return cell;
           // }
        }

    }
    return cell;
}

-(void)productinfocell:(UITableViewCell*)cell withtableview:(UITableView*)tableView
{

    id products = [_detailproduct objectForKey:@""];
    Product *product = products;
    ((DetailProductInfoCell*)cell).minorderlabel.text = [NSString stringWithFormat:@"%d",product.result.info.product_min_order];
    ((DetailProductInfoCell*)cell).weightlabel.text = product.result.info.product_weight_unit;
    ((DetailProductInfoCell*)cell).insurancelabel.text = product.result.info.product_insurance;
    ((DetailProductInfoCell*)cell).conditionlabel.text = product.result.info.product_condition;
    NSArray *breadcrumbs = [_detailproduct objectForKey:kTKPDDETAIL_APIBREADCRUMBPATHKEY];
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
    _objectmanager =  [RKObjectManager sharedManager];
    
    // setup object mappings
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[Product class]];
    [productMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APISTATUSKEY:kTKPDDETAIL_APISTATUSKEY,kTKPDDETAIL_APISERVERPROCESSTIMEKEY:kTKPDDETAIL_APISERVERPROCESSTIMEKEY}];
    
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
                                                      kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY
                                                      }];
    
    RKObjectMapping *statisticMapping = [RKObjectMapping mappingForClass:[Statistic class]];
    [statisticMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISTATISTICKEY:kTKPDDETAILPRODUCT_APISTATISTICKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTRATINGKEY:kTKPDDETAILPRODUCT_APIPRODUCTRATINGKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY
                                                           }];
    
    RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
    [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPIDKEY:kTKPDDETAILPRODUCT_APISHOPIDKEY,
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
    
    [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY withMapping:infoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY toKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY withMapping:statisticMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY withMapping:shopinfoMapping]];
    [shopinfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY withMapping:shopstatsMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responsebreadcrumbDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:breadcrumbMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responseotherproductDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:otherproductMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responseproductimagesDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:imagesMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responsewholesaleDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wholesaleMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
    [_objectmanager addResponseDescriptor:responsebreadcrumbDescriptor];
    [_objectmanager addResponseDescriptor:responseotherproductDescriptor];
    [_objectmanager addResponseDescriptor:responseproductimagesDescriptor];
    [_objectmanager addResponseDescriptor:responsewholesaleDescriptor];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:responseDescriptor.mapping forKey:(responseDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responsebreadcrumbDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responseotherproductDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responseproductimagesDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responsewholesaleDescriptor.keyPath ?: [NSNull null])];
}

- (void)loadData
{
    _requestcount++;

    [_act startAnimating];
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETDETAILACTIONKEY,
                            kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]
                            };
    
    [_objectmanager getObjectsAtPath:kTKPDDETAILPRODUCT_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _table.hidden = NO;
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
    
    Product *product = stats;
    BOOL status = [product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {

        [_detailproduct addEntriesFromDictionary:result];
        [_detailwholesale addObjectsFromArray:[result objectForKey:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY]?:@[]];
        if (_detailwholesale.count > 0) {
            _isnodatawholesale = NO;
        }
        
        [self setHeaderviewData:(id)product];
        [self setFooterViewData:(id)product.result.shop_info];
        _isnodata = NO;
        [_table reloadData];
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
    }
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
            NSArray *breadcrumbs = [_detailproduct objectForKey:kTKPDDETAIL_APIBREADCRUMBPATHKEY];
            Breadcrumb *breadcrumb = breadcrumbs[index-10];
            
            SearchResultViewController *vc = [SearchResultViewController new];
            NSString *deptid = breadcrumb.department_id;
            vc.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
            SearchResultViewController *vc1 = [SearchResultViewController new];
            vc1.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
            SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
            vc2.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
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

#pragma mark - Methods
-(void) setHeaderviewData:(id)product{
    
    Product *p = product;
    _productnamelabel.text = p.result.info.product_name;
    _pricelabel.text = p.result.info.product_price;
    _countsoldlabel.text = [NSString stringWithFormat:@"%@ Sold", p.result.statistic.product_sold];
    _countviewlabel.text = [NSString stringWithFormat:@"%@ View", p.result.statistic.product_view];
    [_reviewbutton setTitle:[NSString stringWithFormat:@"%@ Reviews",p.result.statistic.product_review] forState:UIControlStateNormal];
    [_talkaboutbutton setTitle:[NSString stringWithFormat:@"%@ Talk About it",p.result.statistic.product_talk] forState:UIControlStateNormal];
    _qualitynumberlabel.text = [NSString stringWithFormat: @"%d ",p.result.statistic.product_rating];
    _productrateview.starscount = p.result.statistic.product_rating;
    
    NSArray *images = [_detailproduct objectForKey:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY];
    
    for(int i = 0; i< images.count; i++)
    {
        CGFloat y = i * 320;
        
        ProductImages *image = images[i];
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:image.image_src] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        //request.URL = url;
        
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
    
    [_datatalk setObject:p.result.info.product_name forKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY];
    [_datatalk setObject:p.result.info.product_price forKey:kTKPDDETAILPRODUCT_APIPRODUCTPRICEKEY];
    [_datatalk setObject:_headerimages forKey:kTKPDDETAILPRODUCT_APIPRODUCTIMAGESKEY];
    
}

-(void)setFooterViewData:(id)data
{
    ShopInfo *shopinfo = data;
    
    _shopname.text = shopinfo.shop_name;
    _shoplocation.text = shopinfo.shop_location;
    
    _ratespeedshop.starscount = shopinfo.shop_stats.shop_speed_rate;
    _rateserviceshop.starscount = shopinfo.shop_stats.shop_service_rate;
    _rateaccuracyshop.starscount = shopinfo.shop_stats.shop_accuracy_rate;
    
    UIImageView *thumb = _shopthumb;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:shopinfo.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
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

}

@end
