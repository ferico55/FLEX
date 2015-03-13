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
#import "string_product.h"
#import "string_transaction.h"
#import "string_more.h"
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

#import "TKPDTabShopViewController.h"
#import "ShopTalkViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"

#import "TransactionATCViewController.h"
#import "ShopContainerViewController.h"
#import "UserAuthentificationManager.h"

#import "URLCacheController.h"
#import "TheOtherProduct.h"
#import "FavoriteShopAction.h"

#import "LoginViewController.h"

#pragma mark - Detail Product View Controller
@interface DetailProductViewController () <UITableViewDelegate, UITableViewDataSource, DetailProductInfoCellDelegate, DetailProductOtherViewDelegate, LoginViewDelegate>
{
    NSMutableDictionary *_datatalk;
    NSMutableArray *_otherproductviews;
    NSMutableArray *_otherProductObj;
    
    NSMutableArray *_expandedSections;
    CGFloat _descriptionHeight;
    CGFloat _informationHeight;
    
    BOOL _isnodata;
    BOOL _isnodatawholesale;
    
    NSInteger _requestcount;
    
    NSMutableArray *_headerimages;
    
    NSInteger _pageheaderimages;
    NSInteger _heightDescSection;
    Product *_product;
    BOOL is_dismissed;
    NSDictionary *_auth;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    RKResponseDescriptor *_responseDescriptor;
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectOtherProductManager;
    __weak RKManagedObjectRequestOperation *_requestOtherProduct;
    NSOperationQueue *_operationOtherProductQueue;
    OtherProduct *_otherProduct;
    NSInteger _requestOtherProductCount;
    
    __weak RKObjectManager *_objectFavoriteManager;
    __weak RKManagedObjectRequestOperation *_requestFavorite;
    NSOperationQueue *_operationFavoriteQueue;
    NSInteger _requestFavoriteCount;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    UserAuthentificationManager *_userManager;
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *otherProductIndicator;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UILabel *productnamelabel;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UIButton *reviewbutton;
@property (weak, nonatomic) IBOutlet UIButton *talkaboutbutton;
@property (weak, nonatomic) IBOutlet UIImageView *shopthumb;
@property (weak, nonatomic) IBOutlet UIButton *shopname;
@property (weak, nonatomic) IBOutlet UILabel *accuracynumberlabel;
@property (weak, nonatomic) IBOutlet UILabel *qualitynumberlabel;
@property (weak, nonatomic) IBOutlet UIScrollView *imagescrollview;
@property (weak, nonatomic) IBOutlet StarsRateView *qualityrateview;
@property (weak, nonatomic) IBOutlet StarsRateView *accuracyrateview;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrol;

@property (weak, nonatomic) IBOutlet StarsRateView *ratespeedshop;
@property (weak, nonatomic) IBOutlet StarsRateView *rateaccuracyshop;
@property (weak, nonatomic) IBOutlet StarsRateView *rateserviceshop;
@property (weak, nonatomic) IBOutlet UILabel *countsoldlabel;
@property (weak, nonatomic) IBOutlet UILabel *countviewlabel;

@property (weak, nonatomic) IBOutlet UILabel *shoplocation;
@property (strong, nonatomic) IBOutlet UIView *shopinformationview;
@property (strong, nonatomic) IBOutlet DetailProductOtherView *otherproductview;

@property (weak, nonatomic) IBOutlet UIScrollView *otherproductscrollview;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

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
    _otherProductObj = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _operationOtherProductQueue = [NSOperationQueue new];
    _operationFavoriteQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    /** set inset table for different size**/
    is_dismissed = [[_data objectForKey:@"is_dismissed"] boolValue];
    if(is_dismissed) {
        [self.navigationController.navigationBar setTranslucent:NO];
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            
        }
    }
    
    
    _table.tableHeaderView = _header;
    _table.tableFooterView = _shopinformationview;
    
    _expandedSections = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:1]]];
    
    _imagescrollview.pagingEnabled = YES;
    _imagescrollview.contentMode = UIViewContentModeScaleAspectFit;
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILPRODUCT_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILPRODUCT_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 0;
//    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
    
    //Set initial table view cell for product information
    _informationHeight = 232;
    
    self.table.hidden = YES;
    _buyButton.hidden = YES;
}


- (void)setButtonFav {
    _favButton.tag = 18;
    [_favButton setTitle:@"Unfavorite" forState:UIControlStateNormal];
    [_favButton setImage:[UIImage imageNamed:@"icon_love_white.png"] forState:UIControlStateNormal];
    [_favButton.layer setBorderWidth:0];
    _favButton.tintColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_favButton setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:60.0/255.0 blue:100.0/255.0 alpha:1]];
        [_favButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.hidesBottomBarWhenPushed = YES;
    UIEdgeInsets inset = _table.contentInset;
    inset.bottom += 20;
    _table.contentInset = inset;
    _auth = [_userManager getUserLoginData];
    
    [self configureRestKit];
    
    _favButton.layer.cornerRadius = 3;
    _favButton.layer.borderWidth = 1;
    _favButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    _favButton.enabled = YES;
    _favButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
 
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
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 12:
            {
                // go to review page
                ProductReviewViewController *vc = [ProductReviewViewController new];
                NSArray *images = _product.result.product_images;
                ProductImages *image = images[0];
                
                vc.data = @{
                            kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
                            API_PRODUCT_NAME_KEY : _product.result.product.product_name,
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
                [_datatalk setObject:_product.result.shop_info.shop_id?:@"" forKey:TKPD_TALK_SHOP_ID];
                
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
                NSString *activityItem = [NSString stringWithFormat:@"Jual %@ - %@ | Tokopedia %@", _product.result.product.product_name,_product.result.shop_info.shop_name, _product.result.product.product_url];
                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityItem,]
                                                                                                 applicationActivities:nil];
                activityController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                [self presentViewController:activityController animated:YES completion:nil];
                break;
            }
            case 16:
            {
                //Buy
                if(_auth) {
                    TransactionATCViewController *transactionVC = [TransactionATCViewController new];
                    transactionVC.data = @{DATA_DETAIL_PRODUCT_KEY:_product.result};
                    [self.navigationController pushViewController:transactionVC animated:YES];
                } else {
                    UINavigationController *navigationController = [[UINavigationController alloc] init];
                    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
                    navigationController.navigationBar.translucent = NO;
                    navigationController.navigationBar.tintColor = [UIColor whiteColor];
                    
                    
                    LoginViewController *controller = [LoginViewController new];
                    controller.delegate = self;
                    controller.isPresentedViewController = YES;
                    controller.redirectViewController = self;
                    navigationController.viewControllers = @[controller];
                    
                    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                    
//                    LoginViewController *loginVc = [LoginViewController new];
//                    loginVc.isPresentedViewController = YES;
//                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginVc];
//                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }

                break;
            }
                
            case 17 : {
                if (_requestFavorite.isExecuting) return;
                if(_auth) {
                    //Love Shop
                    [self configureFavoriteRestkit];
                    [self favoriteShop:_product.result.shop_info.shop_id];
                    [self setButtonFav];
                } else {
                    UINavigationController *navigationController = [[UINavigationController alloc] init];
                    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
                    navigationController.navigationBar.translucent = NO;
                    navigationController.navigationBar.tintColor = [UIColor whiteColor];
                    
                    
                    LoginViewController *controller = [LoginViewController new];
                    controller.delegate = self;
                    controller.isPresentedViewController = YES;
                    controller.redirectViewController = self;
                    navigationController.viewControllers = @[controller];
                    
                    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                }

                
                break;

            }
                
            case 18 : {
                if (_requestFavorite.isExecuting) return;
                if(_auth) {
                    //UnLove Shop
                    [self configureFavoriteRestkit];
                    [self favoriteShop:_product.result.shop_info.shop_id];
                    
                    _favButton.tag = 17;
                    
                    [_favButton setTitle:@"Favorite" forState:UIControlStateNormal];
                    [_favButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
                    [_favButton.layer setBorderWidth:1];
                    _favButton.tintColor = [UIColor lightGrayColor];
                    [UIView animateWithDuration:0.3 animations:^(void) {
                        [_favButton setBackgroundColor:[UIColor whiteColor]];
                        [_favButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }];
                } else {
                    UINavigationController *navigationController = [[UINavigationController alloc] init];
                    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
                    navigationController.navigationBar.translucent = NO;
                    navigationController.navigationBar.tintColor = [UIColor whiteColor];
                    
                    
                    LoginViewController *controller = [LoginViewController new];
                    controller.delegate = self;
                    controller.isPresentedViewController = YES;
                    controller.redirectViewController = self;
                    navigationController.viewControllers = @[controller];
                    
                    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                }
                
                
                break;
            }
                
            case 20 : {
                NSMutableArray *viewcontrollers = [NSMutableArray new];
                NSString *shopid = _product.result.shop_info.shop_id;
                if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] isEqualToString:shopid]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{

                    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
                    
                    container.data = @{kTKPDDETAIL_APISHOPIDKEY:shopid,
                                       kTKPD_AUTHKEY:_auth?:@{}};
                    [self.navigationController pushViewController:container animated:YES];
                    
                }
                
                break;
            }
            case 21 : {
                
                break;
            }
            default:
                break;
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
            [bt setTitle: PRODUCT_DESC forState: UIControlStateNormal];
            break;
        case 1:
            if (!_isnodatawholesale)
                [bt setTitle: PRODUCT_WHOLESALE forState: UIControlStateNormal];
            else
                [bt setTitle: PRODUCT_INFO forState: UIControlStateNormal];
            break;
        case 2:
            [bt setTitle: PRODUCT_INFO forState: UIControlStateNormal];
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
                descriptionCell.descriptionText = _product.result.product.product_description;
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
                ((DetailProductInfoCell*)productCell).delegate = self;
                _informationHeight = productCell.productInformationView.frame.size.height;
            }
            [self productinfocell:productCell withtableview:tableView];
            cell = productCell;
            return cell;
        }

    }
    return cell;
}

-(void)productinfocell:(DetailProductInfoCell *)cell withtableview:(UITableView*)tableView
{
    ((DetailProductInfoCell*)cell).minorderlabel.text = _product.result.product.product_min_order;
    ((DetailProductInfoCell*)cell).weightlabel.text = [NSString stringWithFormat:@"%@ %@",_product.result.product.product_weight, _product.result.product.product_weight_unit];
    ((DetailProductInfoCell*)cell).insurancelabel.text = _product.result.product.product_insurance;
    ((DetailProductInfoCell*)cell).conditionlabel.text = _product.result.product.product_condition;
    [((DetailProductInfoCell*)cell).etalasebutton setTitle:_product.result.product.product_etalase forState:UIControlStateNormal];
    
    NSArray *breadcrumbs = _product.result.breadcrumb;
    for (int i = 0; i<breadcrumbs.count; i++) {
        Breadcrumb *breadcrumb = breadcrumbs[i];
        UIButton *button = [cell.categorybuttons objectAtIndex:i];
        button.hidden = NO;
        [button setTitle:breadcrumb.department_name forState:UIControlStateNormal];
    }
    [cell.etalasebutton setTitle:_product.result.product.product_etalase?:@"-" forState:UIControlStateNormal];
    cell.etalasebutton.hidden = NO;
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
    RKObjectMapping *infoMapping = [RKObjectMapping mappingForClass:[ProductDetail class]];
    [infoMapping addAttributeMappingsFromDictionary:@{API_PRODUCT_NAME_KEY:API_PRODUCT_NAME_KEY,
                                                      API_PRODUCT_WEIGHT_UNIT_KEY:API_PRODUCT_WEIGHT_UNIT_KEY,
                                                      API_PRODUCT_WEIGHT_KEY:API_PRODUCT_WEIGHT_KEY,
                                                      API_PRODUCT_DESCRIPTION_KEY:API_PRODUCT_DESCRIPTION_KEY,
                                                      API_PRODUCT_PRICE_KEY:API_PRODUCT_PRICE_KEY,
                                                      API_PRODUCT_INSURANCE_KEY:API_PRODUCT_INSURANCE_KEY,
                                                      API_PRODUCT_CONDITION_KEY:API_PRODUCT_CONDITION_KEY,
                                                      API_PRODUCT_ETALASE_ID_KEY:API_PRODUCT_ETALASE_ID_KEY,
                                                      API_PRODUCT_ETALASE_KEY:API_PRODUCT_ETALASE_KEY,
                                                      API_PRODUCT_MINIMUM_ORDER_KEY:API_PRODUCT_MINIMUM_ORDER_KEY,
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
    [breadcrumbMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIDEPARTMENTNAMEKEY,API_DEPARTMENT_ID_KEY]];
    
    RKObjectMapping *otherproductMapping = [RKObjectMapping mappingForClass:[OtherProduct class]];
    [otherproductMapping addAttributeMappingsFromArray:@[API_PRODUCT_PRICE_KEY,API_PRODUCT_NAME_KEY,kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY]];

    RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[ProductImages class]];
    [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIIMAGEIDKEY,kTKPDDETAILPRODUCT_APIIMAGESTATUSKEY,kTKPDDETAILPRODUCT_APIIMAGEDESCRIPTIONKEY,kTKPDDETAILPRODUCT_APIIMAGEPRIMARYKEY,kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
    
    // Relationship Mapping
    [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY toKeyPath:API_PRODUCT_INFO_KEY withMapping:infoMapping]];
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDDETAILPRODUCT_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
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
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDDETAILPRODUCT_APIPATH
                                                                parameters:[param encrypt]];
	[_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    NSTimer *timer;
	if (_timeinterval > _cachecontroller.URLCacheInterval) {
        [_act startAnimating];
        _buyButton.enabled = NO;

        //[_cachecontroller clearCache];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [timer invalidate];
            [_act stopAnimating];
            _buyButton.enabled = YES;
            [self configureGetOtherProductRestkit];
            [self loadDataOtherProduct];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [timer invalidate];
            [_act stopAnimating];
            _buyButton.enabled = YES;
            [self requestfailure:error];
        }];
        
        [_operationQueue addOperation:_request];
    
        timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
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
                
                if (_product.result.wholesale_price.count > 0) {
                    _isnodatawholesale = NO;
                }
                
                //decide description height
                id cell = [DetailProductDescriptionCell newcell];
                NSString *productdesc = _product.result.product.product_description;
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
                
                _table.hidden = NO;
                _buyButton.hidden = NO;
                
                if(_product.result.shop_info.shop_already_favorited == 1) {
                    [self setButtonFav];
                } else {
                    [_favButton setTitle:@"Favorite" forState:UIControlStateNormal];
                    [_favButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
                    _favButton.tintColor = [UIColor lightGrayColor];
                    _favButton.tag = 17;
                }
                
                if(_auth && [[([_auth objectForKey:@"shop_id"]) stringValue] isEqualToString:_product.result.shop_info.shop_id]) {
                    _favButton.hidden = YES;
                } else {
                    _favButton.hidden = NO;
                }
                
                // UIView below table view (View More Product button)
                CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+100);
                UIView *backgroundGreyView = [[UIView alloc] initWithFrame:frame];
                backgroundGreyView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
                [self.view insertSubview:backgroundGreyView belowSubview:self.table];

            }
        }else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    //_table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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
                [_act stopAnimating];
                NSError *error = object;
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
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
            vc.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY,kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:0};
            SearchResultViewController *vc1 = [SearchResultViewController new];
            vc1.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY,kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:0};
            SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
            vc2.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY,kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:0};
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
            ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
            
            container.data = @{kTKPDDETAIL_APISHOPIDKEY:_product.result.shop_info.shop_id,
                               kTKPD_AUTHKEY:_auth?:[NSNull null],
                               @"product_etalase_id" : _product.result.product.product_etalase_id};
            [self.navigationController pushViewController:container animated:YES];
            
            break;
        }
        default:
            break;
    }

}

#pragma mark - View Delegate
- (void)DetailProductOtherView:(UIView *)view withindex:(NSInteger)index
{
    OtherProduct *product = _otherProductObj[index];
    if ([[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue] != [product.product_id integerValue]) {
        DetailProductViewController *vc = [DetailProductViewController new];
        vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : product.product_id};
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Methods
-(void)setHeaderviewData{

    CGFloat currentLabelHeight = _productnamelabel.frame.size.height;
    _productnamelabel.text = _product.result.product.product_name?:@"";

    NSString *productName = _product.result.product.product_name?:@"";
    self.title = productName;

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
    
    _pricelabel.text = _product.result.product.product_price;
    _countsoldlabel.text = [NSString stringWithFormat:@"%@ Terjual", _product.result.statistic.product_sold];
    _countviewlabel.text = [NSString stringWithFormat:@"%@ Dilihat", _product.result.statistic.product_view];

    [_reviewbutton setTitle:[NSString stringWithFormat:@"%@ Ulasan",_product.result.statistic.product_review] forState:UIControlStateNormal];
    [_reviewbutton.layer setBorderWidth:1];
    [_reviewbutton.layer setBorderColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1].CGColor];
    
    [_talkaboutbutton setTitle:[NSString stringWithFormat:@"%@ Diskusi",_product.result.statistic.product_talk] forState:UIControlStateNormal];
    [_talkaboutbutton.layer setBorderWidth:1];
    [_talkaboutbutton.layer setBorderColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1].CGColor];
    
    _qualitynumberlabel.text = [NSString stringWithFormat: @"%zd ",_product.result.statistic.product_quality_point];
    _qualityrateview.starscount = _product.result.statistic.product_quality_rate;
    
    _accuracynumberlabel.text = [NSString stringWithFormat:@"%zd", _product.result.statistic.product_accuracy_point];
    _accuracyrateview.starscount = _product.result.statistic.product_accuracy_rate;
    
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
            [thumb setImage:image animated:YES];
            
#pragma clang diagnostic pop
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];

        thumb.contentMode = UIViewContentModeScaleAspectFit;
        
        [_imagescrollview addSubview:thumb];
        [_headerimages addObject:thumb];
    }
    
    _pagecontrol.hidden = _headerimages.count <= 1?YES:NO;
    _pagecontrol.numberOfPages = images.count;
    
    _imagescrollview.contentSize = CGSizeMake(_headerimages.count*320,0);
    _imagescrollview.contentMode = UIViewContentModeScaleAspectFit;
    _imagescrollview.showsHorizontalScrollIndicator = NO;
    
    [_datatalk setObject:_product.result.product.product_name?:@"" forKey:API_PRODUCT_NAME_KEY];
    [_datatalk setObject:_product.result.product.product_price?:@"" forKey:API_PRODUCT_PRICE_KEY];
    [_datatalk setObject:_headerimages?:@"" forKey:kTKPDDETAILPRODUCT_APIPRODUCTIMAGESKEY];
}

-(void)setFooterViewData
{
    [_shopname setTitle:_product.result.shop_info.shop_name forState:UIControlStateNormal];
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

        for(int i = 0; i< _otherProductObj.count; i++)
        {
            OtherProduct *product = _otherProductObj[i];
            
            DetailProductOtherView *v = [DetailProductOtherView newview];
            
            int x;
            if(i == 0) {
                x = 10;
            } else if(i == 1) {
                x = 165;
            } else if(i == 2) {
                x = 330;
            } else if(i == 3) {
                x = 485;
            } else if(i == 4) {
                x = 650;
            } else if(i == 5) {
                x = 805;
            }
            [v setFrame:CGRectMake(x, 0, _otherproductscrollview.frame.size.width, _otherproductscrollview.frame.size.height)];
            v.delegate = self;
            v.index = i;
            [v.act startAnimating];
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


#pragma mark - Request & Mapping Other Product
- (void)configureGetOtherProductRestkit {
    _objectOtherProductManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TheOtherProduct class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TheOtherProductResult class]];
    
    RKObjectMapping *otherProductListMapping = [RKObjectMapping mappingForClass:[TheOtherProductList class]];
    [otherProductListMapping addAttributeMappingsFromArray:@[API_PRODUCT_PRICE_KEY,API_PRODUCT_NAME_KEY,kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY toKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY withMapping:otherProductListMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectOtherProductManager addResponseDescriptor:responseDescriptor];

}

- (void)loadDataOtherProduct {
    if(_requestOtherProduct.isExecuting) return;
    
    _requestOtherProductCount++;
    NSDictionary *param = @{@"action" : @"get_other_product", @"product_id" : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]};
    [_otherProductIndicator startAnimating];
    
    _requestOtherProduct = [_objectOtherProductManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILPRODUCT_APIPATH parameters:[param encrypt]];
    NSTimer *timer;
    
    [_requestOtherProduct setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [timer invalidate];
        [_otherProductIndicator stopAnimating];
        [self requestSuccessOtherProduct:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [timer invalidate];
        [self requestFailureOtherProduct:error];
    }];
    
    [_operationOtherProductQueue addOperation:_requestOtherProduct];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutOtherProduct) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

}

- (void)requestSuccessOtherProduct:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TheOtherProduct *otherProduct = stat;
    BOOL status = [otherProduct.status isEqualToString:kTKPDREQUEST_OKSTATUS];

    if(status) {
        [self requestProcessOtherProduct:object];
    }
    
}

- (void)requestFailureOtherProduct:(id)error {
    
}

- (void)requestProcessOtherProduct:(id)object {
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TheOtherProduct *otherProduct = stat;
            BOOL status = [otherProduct.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [_otherProductObj addObjectsFromArray: otherProduct.result.other_product];
                [self setOtherProducts];
            }
        }
        else{
            
            [self cancelOtherProduct];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestOtherProductCount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestOtherProductCount);

                    [_otherProductIndicator startAnimating];
                    [self performSelector:@selector(configureGetOtherProductRestkit)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadDataOtherProduct)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_otherProductIndicator stopAnimating];
                }
            }
            else
            {
                [_otherProductIndicator stopAnimating];
                NSError *error = object;
                if (!([error code] == NSURLErrorCancelled)){
                    NSString *errorDescription = error.localizedDescription;
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [errorAlert show];
                }
            }
            
        }
    }
}

- (void)requestTimeoutOtherProduct {
    
}

- (void)cancelOtherProduct {
    
}

#pragma mark - Request and mapping favorite action

-(void)configureFavoriteRestkit {
    
    // initialize RestKit
    _objectFavoriteManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoriteShopAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[FavoriteShopActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"content":@"content",
                                                        @"is_success":@"is_success"}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:@"action/favorite-shop.pl"
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectFavoriteManager addResponseDescriptor:responseDescriptorStatus];
}


-(void)favoriteShop:(NSString*)shop_id
{
    
    
    _requestFavoriteCount ++;
    
    NSDictionary *param = @{kTKPDDETAIL_ACTIONKEY   :   @"fav_shop",
                            @"shop_id"              :   shop_id};
    
    _requestFavorite = [_objectFavoriteManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:@"action/favorite-shop.pl"
                                                                parameters:[param encrypt]];
    
    [_requestFavorite setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestFavoriteResult:mappingResult withOperation:operation];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFavoriteError:error];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationFavoriteQueue addOperation:_requestFavorite];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeoutFavorite)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestFavoriteResult:(id)mappingResult withOperation:(NSOperationQueue *)operation {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyFav" object:nil];
}

-(void)requestFavoriteError:(id)object {
    
}

- (void)requestTimeoutFavorite {
    
}

#pragma mark - LoginView Delegate
- (void)redirectViewController:(id)viewController{
    
}

@end
