//
//  DetailProductViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#define CgapTitleAndContentDesc 20
#define CTagNoteCanReture 7

#import "ProductReputationViewController.h"
#import "CMPopTipView.h"
#import "LabelMenu.h"
#import "GalleryViewController.h"
#import "detail.h"
#import "search.h"
#import "stringrestkit.h"
#import "string_product.h"
#import "string_transaction.h"
#import "string_more.h"
#import "string_price_alert.h"
#import "string_home.h"
#import "SmileyAndMedal.h"
#import "Product.h"
#import "WishListObjectResult.h"
#import "WishListObject.h"
#import "GeneralAction.h"
#import "ShopSettings.h"
#import "RKObjectManager.h"
#import "TTTAttributedLabel.h"
#import "ShopBadgeLevel.h"

#import "StarsRateView.h"
#import "MarqueeLabel.h"
#import "PromoRequest.h"

#import "DetailProductViewController.h"
#import "DetailProductWholesaleCell.h"
#import "DetailProductInfoCell.h"
#import "DetailProductDescriptionCell.h"
#import "DetailProductWholesaleTableCell.h"

#import "TKPDTabNavigationController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"
#import "ProductTalkViewController.h"
#import "ProductAddEditViewController.h"

#import "TransactionATCViewController.h"
#import "ShopContainerViewController.h"
#import "UserAuthentificationManager.h"

#import "URLCacheController.h"
#import "TheOtherProduct.h"
#import "FavoriteShopAction.h"
#import "Promote.h"

#import "SearchAWS.h"
#import "SearchAWSProduct.h"
#import "SearchAWSResult.h"

#import "LoginViewController.h"
#import "TokopediaNetworkManager.h"
#import "ProductGalleryViewController.h"
#import "NavigateViewController.h"
#import "EtalaseViewController.h"

#import "NoResultView.h"
#import "ProductRequest.h"
#import "WebViewController.h"
#import "EtalaseList.h"

#import "UIActivityViewController+Extensions.h"

#import "NoResultReusableView.h"

#import "OtherProductDataSource.h"

#import "Tokopedia-Swift.h"
#import "NSNumberFormatter+IDRFormater.h"
#import "FavoriteShopRequest.h"

static NSInteger VIDEO_CELL_HEIGHT = 105;

#pragma mark - CustomButton Expand Desc
@interface CustomButtonExpandDesc : UIButton
@property (nonatomic) int objSection;
@end


@implementation CustomButtonExpandDesc
@synthesize objSection;
@end


#pragma mark - Detail Product View Controller
@interface DetailProductViewController ()
<
GalleryViewControllerDelegate,
UITableViewDelegate,
UITableViewDataSource,
DetailProductInfoCellDelegate,
LoginViewDelegate,
EtalaseViewControllerDelegate,
UIAlertViewDelegate,
CMPopTipViewDelegate,
UIAlertViewDelegate,
NoResultDelegate,
UICollectionViewDelegate,
OtherProductDelegate,
TTTAttributedLabelDelegate
>
{
    CMPopTipView *cmPopTitpView;
    NSMutableDictionary *_datatalk;
    NSMutableArray *_otherproductviews;
    NSArray<SearchAWSProduct*> *_otherProductObj;
    
    NSMutableArray *_expandedSections;
    CGFloat _descriptionHeight;
    CGFloat _informationHeight;
    
    NSMutableArray *_headerimages;
    
    BOOL _isnodata;
    BOOL _isnodatawholesale;
    BOOL isDoingWishList, isDoingFavorite;
    
    NSInteger _requestcount;
    
    NSInteger _pageheaderimages;
    NSInteger _heightDescSection;
    Product *_product;
    NoteDetails *notesDetail;
    BOOL is_dismissed;
    NSDictionary *_auth;
    
    OtherProduct *_otherProduct;
    
    TokopediaNetworkManager *tokopediaNetworkManagerWishList;
    
    TokopediaNetworkManager *tokopediaNetworkManagerVideo;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    UserAuthentificationManager *_userManager;
    NSTimer *_timer;
    
    TTTAttributedLabel* _descriptionLabel;
    
    BOOL isExpandDesc, isNeedLogin;
    UIActivityIndicatorView *activityIndicator, *actFav;
    UIFont *fontDesc;
    
    UIImage *_tempFirstThumb;
    TAGContainer *_gtmContainer;
    NavigateViewController *_TKPDNavigator;
    
    NSString *_detailProductBaseUrl;
    NSString *_detailProductPostUrl;
    NSString *_detailProductFullUrl;
    
    PromoRequest *_promoRequest;
    
    OtherProductDataSource *_otherProductDataSource;
}


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *otherProductIndicator;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *infoShopView;

@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UIButton *reviewbutton;
@property (weak, nonatomic) IBOutlet UIButton *talkaboutbutton;
@property (weak, nonatomic) IBOutlet UIImageView *shopthumb;
@property (weak, nonatomic) IBOutlet UIImageView *goldShop;
@property (weak, nonatomic) IBOutlet UIButton *shopname;
@property (weak, nonatomic) IBOutlet UILabel *accuracynumberlabel;
@property (weak, nonatomic) IBOutlet UILabel *qualitynumberlabel;
@property (weak, nonatomic) IBOutlet UIScrollView *imagescrollview;
@property (weak, nonatomic) IBOutlet StarsRateView *qualityrateview;
@property (weak, nonatomic) IBOutlet StarsRateView *accuracyrateview;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrol;
@property (weak, nonatomic) IBOutlet UIImageView *luckyBadgeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBadgeGoldWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBadgeLuckySpace;

@property (weak, nonatomic) IBOutlet UILabel *countsoldlabel;
@property (weak, nonatomic) IBOutlet UILabel *countviewlabel;

@property (weak, nonatomic) IBOutlet UILabel *shoplocation;
@property (strong, nonatomic) IBOutlet UIView *shopinformationview;
@property (strong, nonatomic) IBOutlet UIView *shopClickView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightBuyButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightDinkButton;

//@property (weak, nonatomic) IBOutlet UIScrollView *otherproductscrollview;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightShare;
@property (weak, nonatomic) IBOutlet UIButton *dinkButton;

@property (weak, nonatomic) IBOutlet UICollectionView *otherProductsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *otherProductsFlowLayout;
@property (weak, nonatomic) IBOutlet UILabel *otherProductNoDataLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherProductsConstraintHeight;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnReportLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnShareHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnShareTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnShareLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnReportWidthConstraint;
@property (strong, nonatomic) NSArray<DetailProductVideo*> *detailProductVideoDataArray;
@property (strong, nonatomic) IBOutlet UILabel *cashbackLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *priceLabelTop;

@end

@implementation DetailProductViewController
{
    IBOutlet UIView *viewContentTokoTutup;
    BOOL hasSetTokoTutup;
    NSString *_formattedProductDescription;
    NSString *_formattedProductTitle;
    
    NSArray *_constraint;
    EtalaseList *selectedEtalase;
    
    NSString *afterLoginRedirectTo;
}

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
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    self.title = @"Detail Produk";
    fontDesc = [UIFont smallTheme];
    
    _datatalk = [NSMutableDictionary new];
    _headerimages = [NSMutableArray new];
    _otherproductviews = [NSMutableArray new];
    _otherProductObj = [NSMutableArray new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
    _TKPDNavigator = [NavigateViewController new];
    _otherProductDataSource = [OtherProductDataSource new];
    selectedEtalase = [EtalaseList new];
    
    _constraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[viewContentWarehouse(==0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(viewContentWarehouse)];
    
    
    
    tokopediaNetworkManagerVideo = [TokopediaNetworkManager new];
    tokopediaNetworkManagerVideo.isUsingHmac = YES;
    
    tokopediaNetworkManagerWishList = [TokopediaNetworkManager new];
    
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
    
    //_table.tableHeaderView = _header;
    _table.tableFooterView = _shopinformationview;
    [_table setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [_table registerNib:[UINib nibWithNibName:@"DetailProductVideoTableViewCell" bundle:nil] forCellReuseIdentifier:kTKPDDETAILPRODUCTVIDEOCELLIDENTIFIER];
    
    _expandedSections = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2]]];
    
    _imagescrollview.pagingEnabled = YES;
    _imagescrollview.contentMode = UIViewContentModeScaleAspectFit;
    
    //add gesture to imagescrollview
    UITapGestureRecognizer* galleryGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProductGallery)];
    [_imagescrollview addGestureRecognizer:galleryGesture];
    [_imagescrollview setUserInteractionEnabled:YES];
    
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
    _dinkButton.hidden = YES;
    
    UITapGestureRecognizer *tapShopGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapShop)];
    [_shopClickView addGestureRecognizer:tapShopGes];
    [_shopClickView setUserInteractionEnabled:YES];
    
    //Add observer
    [self initNotification];
    
    _infoShopView.layer.cornerRadius = 5;
    self.infoShopView.layer.borderWidth = 0.5f;
    self.infoShopView.layer.borderColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1].CGColor;
    self.infoShopView.layer.masksToBounds = YES;
    _constraintHeightBuyButton.constant = 0;
    _constraintHeightDinkButton.constant = 0;
    
    afterLoginRedirectTo = @"";
    [self unsetWarehouse];
    _detailProductVideoDataArray = [NSArray<DetailProductVideo*> new];
}

- (void)initNotification {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(refreshRequest:) name:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil];
    [center addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    [center addObserver:self selector:@selector(userDidLogout:) name:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION object:nil];
}

- (void)setButtonFav {
    
    if(_favButton.tag == 17) {//Favorite is 17
        _favButton.tag = 18;
        //        [_favButton setTitle:@"Unfavorite" forState:UIControlStateNormal];
        [_favButton setImage:[UIImage imageNamed:@"icon_button_favorite_active.png"] forState:UIControlStateNormal];
        [_favButton.layer setBorderWidth:0];
        _favButton.tintColor = [UIColor whiteColor];
        [UIView animateWithDuration:0.3 animations:^(void) {
            [_favButton setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:60.0/255.0 blue:100.0/255.0 alpha:1]];
            //            [_favButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }];
        
    }
    else {
        _favButton.tag = 17;
        //        [_favButton setTitle:@"Favorite" forState:UIControlStateNormal];
        [_favButton setImage:[UIImage imageNamed:@"icon_button_favorite_nonactive.png"] forState:UIControlStateNormal];
        [_favButton.layer setBorderWidth:1];
        _favButton.tintColor = [UIColor lightGrayColor];
        [UIView animateWithDuration:0.3 animations:^(void) {
            [_favButton setBackgroundColor:[UIColor whiteColor]];
            //            [_favButton setTitleColor:[UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f] forState:UIControlStateNormal];
        }];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Product Information"];
    
    self.hidesBottomBarWhenPushed = YES;
    UIEdgeInsets inset = _table.contentInset;
    inset.bottom += 20;
    _table.contentInset = inset;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    _favButton.layer.cornerRadius = 3;
    _favButton.layer.borderWidth = 1;
    _favButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    _favButton.enabled = YES;
    _favButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
    if (_isnodata || _product.data.shop_info.shop_id == nil) {
        
        ProductDetail *detailProduct = [ProductDetail new];
        detailProduct.product_id = [_loadedData objectForKey:@"product_id"];
        detailProduct.product_name = [_loadedData objectForKey:@"product_name"];
        detailProduct.product_price = [_loadedData objectForKey:@"product_price"];
        
        ShopInfo *shopInfo = [ShopInfo new];
        shopInfo.shop_name = [_loadedData objectForKey:@"shop_name"];
        
        DetailProductResult *result = [DetailProductResult new];
        result.info = detailProduct;
        result.shop_info = shopInfo;
        
        ProductImages *image = [ProductImages new];
        image.image_src = [_loadedData objectForKey:@"product_image"];
        result.product_images = [NSArray arrayWithObject:image];
        
        Product *product = [Product new];
        product.data = result;
        product.status = @"OK";
        product.isDummyProduct = YES;
        [self requestprocess:product];
        
        [self loadData];

        [self.table reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    if (section>0) return YES;
    
    return NO;
}

- (void)setBackgroundWishlist:(BOOL)isWishList
{
    if(isWishList) {
        [btnWishList setImage:[UIImage imageNamed:@"icon_button_wishlist_active.png"] forState:UIControlStateNormal];
        btnWishList.backgroundColor = [UIColor colorWithRed:255/255.0f green:179/255.0f blue:0 alpha:1.0f];
        [btnWishList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnWishList.layer.borderWidth = 0;
    }
    else {
        [btnWishList setImage:[UIImage imageNamed:@"icon_button_wishlist_nonactive.png"] forState:UIControlStateNormal];
        btnWishList.backgroundColor = [UIColor whiteColor];
        [btnWishList setTitleColor:[UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f] forState:UIControlStateNormal];
        btnWishList.layer.borderWidth = 1.0f;
    }
}


#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 22 : {
                ProductAddEditViewController *editProductVC = [ProductAddEditViewController new];
                editProductVC.type = TYPE_ADD_EDIT_PRODUCT_EDIT;
                editProductVC.productID = _product.data.info.product_id;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editProductVC];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 23:
            {
                // Move To warehouse
                if ([_product.data.info.product_status integerValue] == PRODUCT_STATE_BANNED ||
                    [_product.data.info.product_status integerValue] == PRODUCT_STATE_PENDING) {
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Permintaan Anda tidak dapat diproses, produk sedang dalam pengawasan."] delegate:self];
                    [alert show];
                }
                else
                {
                    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Apakah Anda yakin ingin mengubah produk menjadi tidak dijual?" message:nil delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya", nil];
                    [alert show];
                }
                break;
            }
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 12:
            {
                if(_product.data.shop_info.shop_domain != nil) {
                    ProductReputationViewController *productReputationViewController = [ProductReputationViewController new];
                    productReputationViewController.strShopDomain = _product.data.shop_info.shop_domain;
                    productReputationViewController.strProductID = _product.data.info.product_id;
                    [self.navigationController pushViewController:productReputationViewController animated:YES];
                    [AnalyticsManager trackEventName:@"clickPDP"
                                            category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                                              action:GA_EVENT_ACTION_CLICK
                                               label:@"Review"];
                }
                break;
            }
            case 13:
            {
                // got to talk page
                ProductTalkViewController *vc = [ProductTalkViewController new];
                NSArray *images = _product.data.product_images;
                ProductImages *image = images.count>0? images[0]:nil;
                
                [_datatalk setObject:[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0) forKey:kTKPDDETAIL_APIPRODUCTIDKEY];
                [_datatalk setObject:image.image_src?:@(0) forKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY];
                [_datatalk setObject:_product.data.statistic.product_sold_count?:@"0" forKey:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY];
                [_datatalk setObject:_product.data.statistic.product_view_count?:@"0" forKey:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY];
                [_datatalk setObject:_product.data.shop_info.shop_id?:@"" forKey:TKPD_TALK_SHOP_ID];
                [_datatalk setObject:_product.data.info.product_status?:@"" forKey:TKPD_TALK_PRODUCT_STATUS];
                [_datatalk setObject:_product.data.info.product_id forKey:TKPD_PRODUCT_ID  ];
                
                NSMutableDictionary *data = [NSMutableDictionary new];
                [data addEntriesFromDictionary:_datatalk];
                [data setObject:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null] forKey:kTKPD_AUTHKEY];
                [data setObject:image.image_src==nil?@"":image.image_src forKey:@"talk_product_image"];
                
                vc.data = data;

                [self.navigationController pushViewController:vc animated:YES];
                [AnalyticsManager trackEventName:@"clickPDP"
                                        category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                                          action:GA_EVENT_ACTION_CLICK
                                           label:@"Talk"];
                break;
            }
            case 15:
            {
                if (_product) {
                    NSString *title = [NSString stringWithFormat:@"Jual %@ - %@ | Tokopedia ",
                                       _formattedProductTitle,
                                       _product.data.shop_info.shop_name];
                    NSURL *url = [NSURL URLWithString:_product.data.info.product_url];
                    UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                                      url:url
                                                                                                   anchor:btn];
                    
                    [self presentViewController:controller animated:YES completion:nil];
                }
                break;
            }
            case 16:
            {
                //Buy
                [AnalyticsManager trackEventName:@"clickBuy"
                                        category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                                          action:GA_EVENT_ACTION_CLICK
                                           label:@"Buy"];
                if(_auth) {
                    TransactionATCViewController *transactionVC = [TransactionATCViewController new];
                    transactionVC.wholeSales = _product.data.wholesale_price;
                    transactionVC.productPrice = _product.data.info.product_price;
                    transactionVC.data = @{DATA_DETAIL_PRODUCT_KEY:_product.data};
                    transactionVC.productID = _product.data.info.product_id;
                    transactionVC.isSnapSearchProduct = _isSnapSearchProduct;
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
                }
                break;
            }
            case 17 : {
                [AnalyticsManager trackEventName:@"clickFavoriteShop"
                                        category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                                          action:GA_EVENT_ACTION_CLICK
                                           label:@"Favorite Shop"];

                if(_auth) {
                    [self favoriteShop:_product.data.shop_info.shop_id];
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
                    isDoingFavorite = isNeedLogin = YES;
                    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                }
                break;
            }
            case 18 : {
                [AnalyticsManager trackEventName:@"clickFavoriteShop"
                                        category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                                          action:GA_EVENT_ACTION_CLICK
                                           label:@"Favorite Shop"];
                if(_auth) {
                    //UnLove Shop
                    [self configureFavoriteRestkit];
                    [self favoriteShop:_product.data.shop_info.shop_id];
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
                    isDoingFavorite = isNeedLogin = YES;
                    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                }
                break;
            }
            case 20 : {
                NSString *shopid = _product.data.shop_info.shop_id;
                if(!shopid) {
                    return;
                }
                if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] isEqualToString:shopid]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    
                    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
                    
                    container.data = @{kTKPDDETAIL_APISHOPIDKEY:shopid,
                                       kTKPDDETAIL_APISHOPNAMEKEY:_product.data.shop_info.shop_name,
                                       kTKPD_AUTHKEY:_auth?:@{}};
                    container.initialEtalase = selectedEtalase;
                    
                    [self.navigationController pushViewController:container animated:YES];
                    
                }
                break;
            }
            case 21 : {
                [AnalyticsManager trackEventName:@"clickProduct" category:GA_EVENT_CATEGORY_SHOP_PRODUCT action:GA_EVENT_ACTION_CLICK label:@"Promote"];
                [self requestPromote];
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
                
            }
                
            default:
                break;
        }
    }
}

-(IBAction)gestureMoveToWarehouse:(id)sender
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
                // Move To warehouse
                if ([_product.data.info.product_status integerValue] == PRODUCT_STATE_BANNED ||
                    [_product.data.info.product_status integerValue] == PRODUCT_STATE_PENDING) {
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Permintaan Anda tidak dapat diproses, produk sedang dalam pengawasan."] delegate:self];
                    [alert show];
                }
                else
                {
                    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Apakah stok produk ini kosong?" message:nil delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya", nil];
                    alert.tag = 1;
                    [alert show];
                }
                break;
            }
                
            default:
                break;
        }
    }
}

-(IBAction)gestureMoveToEtalase:(id)sender
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
                // Move To Etalase
                
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Apakah stok produk ini tersedia?" message:nil delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya", nil];
                alert.tag = 2;
                [alert show];
                
                break;
            }
                
            default:
                break;
        }
    }
}

-(IBAction)gestureSetting:(id)sender
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
                ProductAddEditViewController *editProductVC = [ProductAddEditViewController new];
                if(_product.data.info.product_move_to == nil){
                    if([_product.data.info.product_status intValue] ==PRODUCT_STATE_WAREHOUSE){
                        _product.data.info.product_move_to = [@(PRODUCT_WAREHOUSE_YES_ID) stringValue];
                    }else{
                        _product.data.info.product_move_to = [@(PRODUCT_WAREHOUSE_NO_ID) stringValue];
                    }
                }
                editProductVC.productID = _product.data.info.product_id;
                editProductVC.type = TYPE_ADD_EDIT_PRODUCT_EDIT;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editProductVC];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
                
            default:
                break;
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
        [expandCollapseButton setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
    }
    [mView addSubview:expandCollapseButton];
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt setFrame:CGRectMake(15, 0, 170, 40)];
    [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bt setTag:section];
    [bt.titleLabel setFont:[UIFont microTheme]];
    [bt setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [bt.titleLabel setFont:[UIFont title2ThemeMedium]];
    [bt addTarget:self action:@selector(expandCollapseButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if (section == 0){
        [bt setTitle:PRODUCT_INFO  forState: UIControlStateNormal];
    } else if (section == 1 && !_isnodatawholesale) {
        [bt setTitle: PRODUCT_WHOLESALE forState: UIControlStateNormal];
    } else if (section == [_table numberOfSections] - 2) {
        [bt removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [bt setTitle: @"Video Produk" forState: UIControlStateNormal];
        [expandCollapseButton removeFromSuperview];
    } else if (section == [_table numberOfSections] - 1) {
        [bt setTitle: PRODUCT_DESC forState: UIControlStateNormal];
        CGRect rectLblDesc = CGRectZero;
        CustomButtonExpandDesc *btnExpand = [CustomButtonExpandDesc buttonWithType:UIButtonTypeCustom];
        
        if(_formattedProductDescription.length>kTKPDLIMIT_TEXT_DESC && !isExpandDesc)
        {
            rectLblDesc = [self initLableDescription:mView originY:bt.frame.origin.y+bt.bounds.size.height width:self.view.bounds.size.width-35 withText:[NSString stringWithFormat:@"%@%@", [_formattedProductDescription substringToIndex:kTKPDLIMIT_TEXT_DESC], kTKPDMORE_TEXT]];
            [btnExpand setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
        }
        else
        {
            rectLblDesc = [self initLableDescription:mView originY:bt.frame.origin.y+bt.bounds.size.height width:self.view.bounds.size.width-35 withText:_formattedProductDescription];
            [btnExpand setImage:[UIImage imageNamed:@"icon_arrow_up.png"] forState:UIControlStateNormal];
        }
        
        
        if(_formattedProductDescription.length > kTKPDLIMIT_TEXT_DESC)
        {
            btnExpand.frame = CGRectMake((self.view.bounds.size.width-40)/2.0f, rectLblDesc.origin.y+rectLblDesc.size.height, 40, 40);
            [btnExpand addTarget:self action:@selector(expand:) forControlEvents:UIControlEventTouchUpInside];
            [btnExpand setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnExpand.tag = 0;
            btnExpand.objSection = (int)section;
            [mView addSubview:btnExpand];
        }
        
        [expandCollapseButton removeFromSuperview];
        [mView addSubview:bt];
        return mView;
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
    if (section == [_table numberOfSections] - 1){
        if(_formattedProductDescription.length>kTKPDLIMIT_TEXT_DESC && !isExpandDesc)
            return 40 + [self calculateHeightLabelDesc:CGSizeMake(self.view.bounds.size.width-45, 9999) withText:[NSString stringWithFormat:@"%@%@", [_formattedProductDescription substringToIndex:kTKPDLIMIT_TEXT_DESC], kTKPDMORE_TEXT] withColor:[UIColor whiteColor] withFont:nil withAlignment:NSTextAlignmentLeft] + (_formattedProductDescription.length>kTKPDLIMIT_TEXT_DESC? 40 : 25) + CgapTitleAndContentDesc;
        else
            return 40 + [self calculateHeightLabelDesc:CGSizeMake(self.view.bounds.size.width-45, 9999) withText:_formattedProductDescription withColor:[UIColor whiteColor] withFont:nil withAlignment:NSTextAlignmentLeft] + (_formattedProductDescription.length>kTKPDLIMIT_TEXT_DESC? 40 : 25) + CgapTitleAndContentDesc;
    }
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
            return _informationHeight+50;
        }
        
        if (!_isnodatawholesale) {
            if (indexPath.section == 1) {
                return (44*2) + (_product.data.wholesale_price.count*44);//44 is standart height of uitableviewcell
            }
        }
        
        if (_detailProductVideoDataArray.count > 0) {
            if (indexPath.section == [_table numberOfSections] - 2) {
                return VIDEO_CELL_HEIGHT;
            }
        }
        
        if (indexPath.section == [_table numberOfSections] - 1) {
            return _descriptionHeight+50;
        }
    }
    
    return 0;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_isnodatawholesale){
        if (_detailProductVideoDataArray.count > 0) {
            return 4;
        } else return 3;
    } else if (_detailProductVideoDataArray.count > 0){
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == [_table numberOfSections] - 1) {
        return 0;
    }
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    if (indexPath.section == [_table numberOfSections] - 1){
        return [self getDetailProductDescriptionTableViewCell];
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        
        NSString *cellid = kTKPDDETAILPRODUCTINFOCELLIDENTIFIER;
        DetailProductInfoCell *productInfoCell = (DetailProductInfoCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (productInfoCell == nil) {
            productInfoCell = [DetailProductInfoCell newcell];
            ((DetailProductInfoCell*)productInfoCell).delegate = self;
        }
        [productInfoCell layoutIfNeeded];
        [self productinfocell:productInfoCell withtableview:tableView];
        
        //Check product returnable
        BOOL isProductReturnable = _product.data.info.return_info && ![_product.data.info.return_info.content isEqualToString:@""];
        if(isProductReturnable) {
            NSArray* rgbArray = [_product.data.info.return_info.color_rgb componentsSeparatedByString:@","];
            UIColor* color = [UIColor colorWithRed:([rgbArray[0] integerValue]/255.0) green:([rgbArray[1] integerValue]/255.0) blue:([rgbArray[2] integerValue]/255.0) alpha:0.2];
            [productInfoCell setLblDescriptionToko:_product.data.info.return_info.content withImageURL:_product.data.info.return_info.icon withBGColor:color]
            ;
            productInfoCell.didTapReturnableInfo = ^(NSURL* url) {
                WebViewController* web = [[WebViewController alloc] init];
                web.strTitle = @"Keterangan Pengembalian Barang";
                web.strURL = [url absoluteString];
                [self.navigationController pushViewController:web animated:YES];
            };
        } else {
            [productInfoCell hiddenViewRetur];
        }
        
        _informationHeight = productInfoCell.productInformationView.frame.size.height+[productInfoCell getHeightReturView];
        cell = productInfoCell;
        return cell;
    }
    if (!_isnodatawholesale) {
        if (indexPath.section == 1) {
            NSString *cellid = kTKPDDETAILPRODUCTWHOLESALECELLIDENTIFIER;
            cell = (DetailProductWholesaleCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [DetailProductWholesaleCell newcell];
                CGRect tempContentView = cell.contentView.frame;
                tempContentView.size.height = (_product.data.wholesale_price.count*4)+(44*2); //44 is height that currently is used(standard height uitableviewcell)
                cell.contentView.frame = tempContentView;
            }
            ((DetailProductWholesaleCell*)cell).data = @{kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY : _product.data.wholesale_price};
            
            return cell;
        }
    }
    
    if (_detailProductVideoDataArray.count > 0)
    {
        if (indexPath.section == [_table numberOfSections] - 2) {
            return [self getDetailProductVideoTableViewCell];
        }
        
    }
    
    return cell;
}

-(DetailProductVideoTableViewCell *) getDetailProductVideoTableViewCell {
    DetailProductVideoTableViewCell *videoCell = (DetailProductVideoTableViewCell *)[_table dequeueReusableCellWithIdentifier:kTKPDDETAILPRODUCTVIDEOCELLIDENTIFIER];
    videoCell.videos = _detailProductVideoDataArray;
    return videoCell;
}

-(DetailProductDescriptionCell*) getDetailProductDescriptionTableViewCell {
    NSString *cellid = kTKPDDETAILPRODUCTCELLIDENTIFIER;
    DetailProductDescriptionCell *descriptionCell = (DetailProductDescriptionCell *)[_table dequeueReusableCellWithIdentifier:cellid];
    if (descriptionCell == nil) {
        descriptionCell = [DetailProductDescriptionCell newcell];
        if(!_isnodata) {
            descriptionCell.descriptionText = _formattedProductDescription;
            _descriptionHeight = descriptionCell.descriptionlabel.frame.size.height;
        }
    }
    
    return descriptionCell;
}

- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state==UIGestureRecognizerStateBegan && isExpandDesc) {
        UILabel *lblDesc = (UILabel *)sender.view;
        [lblDesc becomeFirstResponder];
        
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:lblDesc.frame inView:lblDesc.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

-(void)productinfocell:(DetailProductInfoCell *)cell withtableview:(UITableView*)tableView
{
    ((DetailProductInfoCell*)cell).minorderlabel.text = _product.data.info.product_min_order;
    ((DetailProductInfoCell*)cell).weightlabel.text = [NSString stringWithFormat:@"%@ %@",_product.data.info.product_weight?:@"0", _product.data.info.product_weight_unit?:@"gr"];
    ((DetailProductInfoCell*)cell).insurancelabel.text = _product.data.info.product_insurance;
    ((DetailProductInfoCell*)cell).conditionlabel.text = _product.data.info.product_condition;
    [((DetailProductInfoCell*)cell).etalasebutton setTitle:_product.data.info.product_etalase forState:UIControlStateNormal];
    
    NSArray *breadcrumbs = _product.data.breadcrumb;
    for (int i = 0; i<3; i++) {
        UIButton *button = [cell.categorybuttons objectAtIndex:i];
        if (i < breadcrumbs.count) {
            Breadcrumb *breadcrumb = breadcrumbs[i];
            button.hidden = NO;
            [button setTitle:breadcrumb.department_name forState:UIControlStateNormal];
        } else {
            button.hidden = YES;
            [button setTitle:@"" forState:UIControlStateNormal];
        }
    }
    if (![self isProductActive])
        [cell.etalasebutton setTitle:@"-" forState:UIControlStateNormal];
    else
        [cell.etalasebutton setTitle:_product.data.info.product_etalase?:@"-" forState:UIControlStateNormal];
    cell.etalasebutton.hidden = NO;
}

#pragma mark - Request
-(void)requestPromote{
    NSString *productID = _product.data.info.product_id?:@"0";

    [DetailProductRequest fetchPromoteProduct:productID onSuccess:^(PromoteResult * data) {
        
        [_dinkButton setTitle:@"Promosi" forState:UIControlStateNormal];
        [_dinkButton setEnabled:YES];
        
    }];
}

-(void)requestOtherProduct{
    
    [_otherProductIndicator setHidden:NO];
    [_otherProductIndicator startAnimating];
    
    [DetailProductRequest fetchOtherProduct:_product.data.info.product_id shopID:_product.data.shop_info.shop_id onSuccess:^(SearchAWSResult * data) {
        
        [_otherProductIndicator stopAnimating];
        _otherProductObj = data.products;
        [self setOtherProducts];
        
    } onFailure: ^{
        [_otherProductIndicator stopAnimating];
    }];
}

-(void)requestFavoriteShopID:(NSString *)shopID{
    [FavoriteShopRequest requestActionButtonFavoriteShop:shopID withAdKey:@"" onSuccess:^(FavoriteShopActionResult *data) {
        
        StickyAlertView *stickyAlertView;
        if(_favButton.tag == 17) {//Favorite
            stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessFavoriteShop] delegate:self];
        }else {
            stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessUnFavoriteShop] delegate:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavoriteShop" object:_product.data.shop_info.shop_url];
        
        [stickyAlertView show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyFav" object:nil];
        [self setButtonFav];
        
        //Change this block to method (Any in branch f_bug_fixing)
        [actFav stopAnimating];
        [actFav removeFromSuperview];
        actFav = nil;
        _favButton.hidden = NO;
        
    } onFailure:^{
        
        //Change this block to method (Any in branch f_bug_fixing)
        [actFav stopAnimating];
        [actFav removeFromSuperview];
        actFav = nil;
        _favButton.hidden = NO;
        
    }];
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{

    
}


- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    
    if(tag == CTagNoteCanReture) {
        
    }
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    
    [tokopediaNetworkManagerWishList requestCancel];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadData {
    TokopediaNetworkManager *networkManager = [[TokopediaNetworkManager alloc] init];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/product/get_detail.pl"
                                method:RKRequestMethodGET
                             parameter:@{
                                         @"product_id" : [_data objectForKey:@"product_id"]?:@"0",
                                         @"product_key" : [_data objectForKey:@"product_key"]?:@"",
                                         @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@""
                                         }
                               mapping:[Product mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 [self requestsuccess:successResult withOperation:operation];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"didSeeAProduct" object:_product.data];
                             } onFailure:^(NSError *errorResult) {
                                 
                             }];
}

- (void)displayCashbackLabel {
    _cashbackLabel.hidden = NO;
    _priceLabelTop.constant = 10;
    
    // add whitespace for padding
    _cashbackLabel.text = [NSString stringWithFormat:@"Cashback %@   ", _product.data.cashback];
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    _product = [result objectForKey:@""];
    if ([self isAbleToLoadVideo]) {
        [self getVideoData];
    } else {
        [self setExpandedSection];
    }
    
    BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (![_product.data.cashback isEqualToString:@""]) {
            [self displayCashbackLabel];
        }
        
        if (_product.data == nil) {
            WebViewController* controller = [[WebViewController alloc] init];
            controller.strURL = [NSString stringWithFormat:@"http://www.tokopedia.com/%@/%@", [self.data objectForKey:@"shop_domain"]?:@"", [self.data objectForKey:@"product_key"]?:@""];
            controller.strTitle = [NSString stringWithFormat:@"http://www.tokopedia.com/%@/%@", [self.data objectForKey:@"shop_domain"]?:@"", [self.data objectForKey:@"product_key"]?:@""];
            
            
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        
        [self loadDataOtherProduct];
        
        //Set icon speed
        [SmileyAndMedal setIconResponseSpeed:_product.data.shop_info.respond_speed.badge withImage:btnKecepatan largeImage:NO];
        [SmileyAndMedal generateMedalWithLevel:_product.data.shop_info.shop_stats.shop_badge_level.level withSet:_product.data.shop_info.shop_stats.shop_badge_level.set withImage:btnReputasi isLarge:YES];
        
        //Set image and title kecepatan
        CGFloat spacing = 6.0;
        CGSize imageSize = btnKecepatan.imageView.frame.size;
        btnKecepatan.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        CGSize titleSize = btnKecepatan.titleLabel.frame.size;
        btnKecepatan.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
        
        //Set image and title reputasi
        imageSize = btnReputasi.imageView.frame.size;
        btnReputasi.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        titleSize = btnReputasi.titleLabel.frame.size;
        btnReputasi.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
        
        if (_product.data.shop_info.shop_status != nil){
            //Set toko tutup
            if([_product.data.shop_info.shop_status isEqualToString:@"2"]) {
                viewContentTokoTutup.hidden = NO;
                lblDescTokoTutup.text = [NSString stringWithFormat:FORMAT_TOKO_TUTUP, _product.data.shop_info.shop_is_closed_until];
            }else if ([_product.data.shop_info.shop_status isEqualToString:@"3"]) {
                viewContentTokoTutup.hidden = NO;
                lblDescTokoTutup.text = @"Toko ini sedang dimoderasi";
            }else if ([_product.data.shop_info.shop_status isEqualToString:@"4"]) {
                viewContentTokoTutup.hidden = NO;
                lblDescTokoTutup.text = @"Toko ini sedang tidak aktif";
            }
        }
        
        //Set shop in warehouse
        if([_product.data.info.product_status intValue]!=PRODUCT_STATE_WAREHOUSE &&
           [_product.data.info.product_status intValue]!=PRODUCT_STATE_PENDING) {
            [self unsetWarehouse];
        } else if ([_product.data.info.product_status intValue] ==PRODUCT_STATE_WAREHOUSE||
                   [_product.data.info.product_status integerValue] == PRODUCT_STATE_PENDING) {
            
            if([_product.data.info.product_status integerValue] == PRODUCT_STATE_BANNED ||
               [_product.data.info.product_status integerValue] == PRODUCT_STATE_PENDING) {
                lblTitleWarehouse.text = CStringTitleBanned;
                [self initAttributeText:lblDescWarehouse withStrText:CStringDescBanned withColor:lblDescWarehouse.textColor withFont:lblDescWarehouse.font withAlignment:NSTextAlignmentCenter];
            }
            
            constraintHeightWarehouse.constant = 50;
            UserAuthentificationManager *userAuthentificationManager = [UserAuthentificationManager new];
            if(![userAuthentificationManager isMyShopWithShopId:_product.data.shop_info.shop_id]){
                _constraintHeightShare.constant = 50;
                _header.frame = CGRectMake(0, 0, _table.bounds.size.width, 570);
            }
            else
            {
                _constraintHeightShare.constant = 0;
                btnShare.hidden = YES;
                _header.frame = CGRectMake(0, 0, _table.bounds.size.width, 520);
            }
            [viewContentWarehouse setHidden:NO];
            [self hideReportButton:NO];
            _table.tableHeaderView = _header;
        }
        else {
            [self unsetWarehouse];
        }
        
        _table.tableHeaderView = _header;
        [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cachecontroller connectionDidFinish:_cacheconnection];
        //save response data to plist
        [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        
        [AnalyticsManager trackProductView:_product];
        [self requestprocess:object];
    }
}

- (void) getVideoData {
    __weak __typeof(self) weakSelf = self;
    [tokopediaNetworkManagerVideo requestWithBaseUrl:[NSString goldMerchantUrl] path:[NSString stringWithFormat:@"/v1/product/video/%@", _product.data.info.product_id] method:RKRequestMethodGET parameter:nil mapping:[DetailProductVideoResponse mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        [weakSelf getVideoSuccess: successResult];
        [self setExpandedSection];
    } onFailure:^(NSError *errorResult) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[errorResult.localizedDescription] delegate:self];
        [alert show];
    }];
}

- (void) getVideoSuccess: (RKMappingResult*) successResult {
    NSDictionary *result = successResult.dictionary;
    DetailProductVideoResponse *detailProductVideoResponse = [result objectForKey:@""];
    
    for (DetailProductVideoData* videoData in detailProductVideoResponse.data){
        
        if ([videoData.videos count] > 0) {
            NSArray<DetailProductVideo*> *nonBannedVideoArray = [videoData.videos bk_select:^BOOL(DetailProductVideo *obj) {
                return obj.banned == NO;
            }];
            _detailProductVideoDataArray = nonBannedVideoArray;
            return;
        }
    }
    
    return;
}

-(void) setExpandedSection {
    if (!_isnodatawholesale) {
        if (_detailProductVideoDataArray.count > 0) {
            _expandedSections = [[NSMutableArray alloc] initWithArray:@[@0, @2]];
        } else {
            _expandedSections = [[NSMutableArray alloc] initWithArray:@[@0]];
        }
        
    } else {
        if (_detailProductVideoDataArray.count > 0) {
            _expandedSections = [[NSMutableArray alloc] initWithArray:@[@0, @1]];
        } else {
            _expandedSections = [[NSMutableArray alloc] initWithArray:@[@0]];
        }
    }
    [self.table reloadData];
}

- (void) hideReportButton: (BOOL) isNeedToRemoveBtnReport{
    
    if (isNeedToRemoveBtnReport){
        [btnReport removeFromSuperview];
    } else {
        // hanya geser saja btn report ke luar layar, untuk menjaga bentuk share button tetap persegi
        _btnReportLeadingConstraint.constant = -(_btnReportWidthConstraint.constant) - 2 ;
    }
}

- (void)unsetWarehouse {
    constraintHeightWarehouse.constant = 0;
    _constraintHeightShare.constant = 50;
    //    [viewContentWarehouse removeConstraint:constraintHeightWarehouse];
    //    [viewContentWarehouse addConstraints:_constraint];
    viewContentWarehouse.hidden = YES;
    _header.frame = CGRectMake(0, 0, _table.bounds.size.width, 520);
    _table.tableHeaderView = _header;
    
}

-(void)requestprocess:(id)object
{
    if (object) {
        if([object isKindOfClass:[Product class]]) {
            _product = object;
        } else {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stats = [result objectForKey:@""];
            _product = stats;
            _product.isDummyProduct = NO;
            [self addUserActivity];
        }
        
        _formattedProductDescription = [NSString convertHTML:_product.data.info.product_description]?:@"-";
        _formattedProductTitle = [NSString stringWithFormat:@" %@", _product.data.info.product_name];
        BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            
            _constraintHeightBuyButton.constant = 48;
            _constraintHeightDinkButton.constant = 48;
            
            if (_product.data.wholesale_price.count > 0) {
                _isnodatawholesale = NO;
            }
            if([_formattedProductDescription isEqualToString:@"0"])
                _formattedProductDescription = NO_DESCRIPTION;
            
            selectedEtalase.etalase_id = [_product.data.info.product_etalase_id stringValue];;
            selectedEtalase.etalase_name = _product.data.info.product_etalase;
            
            UserAuthentificationManager *userAuthentificationManager = [UserAuthentificationManager new];
            self.navigationItem.rightBarButtonItems = nil;
            
            if([userAuthentificationManager isMyShopWithShopId:_product.data.shop_info.shop_id] && [userAuthentificationManager isLogin] && !_product.isDummyProduct) {
                //MyShop
                [_dinkButton setHidden:NO];
                UIBarButtonItem *barbutton;
                barbutton = [self createBarButton:CGRectMake(0,0,22,22) withImage:[UIImage imageNamed:@"icon_shop_setting.png"] withAction:@selector(gestureSetting:)];
                
                [barbutton setTag:22];
                
                UIBarButtonItem *barbutton1;
                if ([_product.data.info.product_status integerValue] == PRODUCT_STATE_WAREHOUSE) {
                    barbutton1 = [self createBarButton:CGRectMake(0,0,22,22) withImage:[UIImage imageNamed:@"icon_move_etalase.png"] withAction:@selector(gestureMoveToEtalase:)];
                    [barbutton1 setTag:23];
                }
                else
                {
                    barbutton1 = [self createBarButton:CGRectMake(0,0,22,22) withImage:[UIImage imageNamed:@"icon_move_gudang.png"] withAction:@selector(gestureMoveToWarehouse:)];
                    [barbutton1 setTag:24];
                }
                
                if([_product.data.info.product_status integerValue] == PRODUCT_STATE_BANNED ||
                   [_product.data.info.product_status integerValue] == PRODUCT_STATE_PENDING) {
                    self.navigationItem.rightBarButtonItems = nil;
                } else {
                    self.navigationItem.rightBarButtonItems = @[barbutton, barbutton1];
                }
                
                [btnWishList removeFromSuperview];
                
                [btnShare removeConstraint:_btnShareTrailingConstraint];
                [btnShare removeConstraint:_btnShareLeadingConstraint];
                
                [btnShare mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(viewContentWishList).offset(10);
                    make.right.equalTo(viewContentWishList).offset(10);
                }];
                
                
                [self hideReportButton:YES];
            } else {
                if(!_product.isDummyProduct) {
                    [_buyButton setHidden:NO];
                }
                
                
                activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
                activityIndicator.color = [UIColor lightGrayColor];
                btnWishList.hidden = NO;
                
                //Set background wishlist
                if([_product.data.info.product_already_wishlist isEqualToString:@"1"])
                {
                    [self setBackgroundWishlist:YES];
                    btnWishList.tag = 0;
                }
                else
                {
                    [self setBackgroundWishlist:NO];
                    btnWishList.tag = 1;
                }
                
            }
            
            if(_product.isDummyProduct) {
                [viewContentWishList setHidden:YES];
                self.navigationItem.rightBarButtonItems = nil;
            } else {
                [viewContentWishList setHidden:NO];
            }
            
            //decide description height
            id cell = [DetailProductDescriptionCell newcell];
            NSString *productdesc = _formattedProductDescription;
            UILabel *desclabel = ((DetailProductDescriptionCell*)cell).descriptionlabel;
            desclabel.text = productdesc;
            CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
            
            CGSize expectedLabelSize = [productdesc sizeWithFont:desclabel.font constrainedToSize:maximumLabelSize lineBreakMode:desclabel.lineBreakMode];
            _heightDescSection = lroundf(expectedLabelSize.height);
            
            [self setHeaderviewData];
            [self setFooterViewData];
            [self setOtherProducts];
            
            if(!_product.isDummyProduct && [_data objectForKey:@"ad_click_url"]){
                [self addImpressionClick];
            }
            
            //Track in GA
            
            _isnodata = NO;
            [_table reloadData];
            
            _table.hidden = NO;
            
            if(_product.data.shop_info.shop_status!=nil && [_product.data.shop_info.shop_status isEqualToString:@"2"]) {
                if(hasSetTokoTutup){
                    return;
                }
                
                hasSetTokoTutup = !hasSetTokoTutup;
                [self hiddenButtonBuyAndPromo];
            }else {
                //Check is in warehouse
                if([_product.data.info.product_status integerValue]==PRODUCT_STATE_WAREHOUSE || [_product.data.info.product_status integerValue]==PRODUCT_STATE_PENDING) {
                    [self hiddenButtonBuyAndPromo];
                }
            }
            
            if(_product.data.shop_info.shop_already_favorited == 1) {
                _favButton.tag = 17;
                [self setButtonFav];
            } else {
                _favButton.tag = 18;
                [self setButtonFav];
            }
            
            if([_userManager isMyShopWithShopId:_product.data.shop_info.shop_id]) {
                _favButton.hidden = YES;
            } else {
                _favButton.hidden = NO;
                
            }
            
            // UIView below table view (View More Product button)
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+100);
            UIView *backgroundGreyView = [[UIView alloc] initWithFrame:frame];
            backgroundGreyView.backgroundColor = [UIColor clearColor];
            [self.view insertSubview:backgroundGreyView belowSubview:self.table];
        }
    }
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
- (void)gotToSearchWithDepartment:(NSInteger)index {
    NSArray *breadcrumbs = _product.data.breadcrumb;
    Breadcrumb *breadcrumb = breadcrumbs[index-10];
    
    SearchResultViewController *vc = [SearchResultViewController new];
    NSString *deptid = breadcrumb.department_id;
    vc.data =@{@"sc" : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY,kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    SearchResultViewController *vc1 = [SearchResultViewController new];
    vc1.data =@{@"sc" : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY,kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
    vc2.data =@{@"sc" : deptid?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY,kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *c = [TKPDTabNavigationController new];
    
    [c setSelectedIndex:0];
    [c setViewControllers:viewcontrollers];
    [c setNavigationTitle:breadcrumb.department_name];
    [self.navigationController pushViewController:c animated:YES];
}

-(void)DetailProductInfoCell:(UITableViewCell *)cell withbuttonindex:(NSInteger)index {
    switch (index) {
        case 10: {
            [self gotToSearchWithDepartment:10];
            break;
        }
        case 11: {
            [self gotToSearchWithDepartment:11];
            break;
        }
        case 12:
        {
            NSArray *breadcrumbs = _product.data.breadcrumb;
            if([breadcrumbs count] == 3) {
                [self gotToSearchWithDepartment:12];
            }
            
            break;
        }
        case 13:
        {
            // Etalase
            if(_product.data.info.product_etalase_id != nil && [self isProductActive]) {
                
                ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
                
                container.data = @{kTKPDDETAIL_APISHOPIDKEY:_product.data.shop_info.shop_id,
                                   kTKPD_AUTHKEY:_auth?:[NSNull null],
                                   @"product_etalase_name" : _product.data.info.product_etalase,
                                   @"product_etalase_id" : _product.data.info.product_etalase_id};
                
                if([_product.data.info.product_etalase_id respondsToSelector:@selector(stringValue)]){
                    EtalaseList *initEtalase = [EtalaseList new];
                    [initEtalase setEtalase_id:[_product.data.info.product_etalase_id stringValue]];
                    [initEtalase setEtalase_name:_product.data.info.product_etalase];
                    container.initialEtalase = initEtalase;
                }
                [self.navigationController pushViewController:container animated:YES];
            
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
- (void)initPopUp:(NSString *)strText withSender:(id)sender withRangeDesc:(NSRange)range
{
    UILabel *lblShow = [[UILabel alloc] init];
    UIFont *boldFont = [UIFont smallThemeMedium];
    UIFont *regularFont = [UIFont smallTheme];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strText attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    [lblShow setAttributedText:attributedText];
    
    
    CGSize tempSize = [lblShow sizeThatFits:CGSizeMake(self.view.bounds.size.width-40, 9999)];
    lblShow.frame = CGRectMake(0, 0, tempSize.width, tempSize.height);
    lblShow.backgroundColor = [UIColor clearColor];
    
    //Init pop up
    cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    cmPopTitpView.delegate = self;
    cmPopTitpView.backgroundColor = [UIColor blackColor];
    cmPopTitpView.animation = CMPopTipAnimationSlide;
    cmPopTitpView.dismissTapAnywhere = YES;
    cmPopTitpView.leftPopUp = YES;
    
    UIButton *button = (UIButton *)sender;
    [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
}

- (IBAction)actionReputasi:(id)sender
{
    NSString *strText = [NSString stringWithFormat:@"%@ %@", _product.data.shop_info.shop_stats.shop_reputation_score, CStringPoin];
    [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
}

- (IBAction)actionKecepatan:(id)sender
{
    [self initPopUp:_product.data.shop_info.respond_speed.speed_level withSender:sender withRangeDesc:NSMakeRange(0, 0)];
}


- (void)setRequestingAction:(UIButton *)tempBtn isLoading:(BOOL)isLoading
{
    if(isLoading) {
        activityIndicator.frame = tempBtn.frame;
        [viewContentWishList addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [tempBtn setHidden:YES];
    }
    else {
        [activityIndicator removeFromSuperview];
        [activityIndicator stopAnimating];
        [tempBtn setHidden:NO];
    }
}

- (void)hiddenButtonBuyAndPromo
{
    _dinkButton.hidden = YES;
    _buyButton.hidden = YES;
    
    _constraintHeightBuyButton.constant = 0;
    _constraintHeightDinkButton.constant = 0;
    
    //    [_dinkButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_dinkButton(==0)]"
    //                                                                        options:0
    //                                                                        metrics:nil
    //                                                                          views:NSDictionaryOfVariableBindings(_dinkButton)]];
    //
    //    [_buyButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_buyButton(==0)]"
    //                                                                       options:0
    //                                                                       metrics:nil
    //                                                                         views:NSDictionaryOfVariableBindings(_buyButton)]];
}

- (void)initAttributeText:(UILabel *)lblDesc withStrText:(NSString *)strText withColor:(UIColor *)color withFont:(UIFont *)font withAlignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = alignment;
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: (color == nil) ? [UIColor whiteColor] : color,
                                 NSFontAttributeName:(font == nil)? fontDesc : font,
                                 };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:strText attributes:attributes];
    lblDesc.attributedText = attributedText;
    
}

- (float)calculateHeightLabelDesc:(CGSize)size withText:(NSString *)strText withColor:(UIColor *)color withFont:(UIFont *)font withAlignment:(NSTextAlignment)textAlignment
{
    if(strText == nil)  return 0.0f;
    UILabel *lblSize = [[UILabel alloc] init];
    [self initAttributeText:lblSize withStrText:strText withColor:color withFont:font withAlignment:textAlignment];
    lblSize.numberOfLines = 0;
    
    return [lblSize sizeThatFits:size].height;
}


- (CGRect)initLableDescription:(UIView *)mView originY:(float)originY width:(float)width withText:(NSString *)strText
{
    if(strText == nil)  return CGRectZero;
    CGRect rectLblDesc = CGRectMake(20, originY, width, 9999);
    rectLblDesc.size.height = [self calculateHeightLabelDesc:rectLblDesc.size withText:strText withColor:[UIColor whiteColor] withFont:[UIFont smallTheme] withAlignment:NSTextAlignmentLeft];
    
    _descriptionLabel = [[TTTAttributedLabel alloc] initWithFrame:rectLblDesc];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    [_descriptionLabel setNumberOfLines:0];
    _descriptionLabel.delegate = self;
    _descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString: [NSString extracTKPMEUrl:strText] attributes: @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                                                                  NSFontAttributeName: [UIFont smallTheme]}];
    _descriptionLabel.textColor = [UIColor lightGrayColor];
    _descriptionLabel.userInteractionEnabled = YES;
    [_descriptionLabel addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    
    
    _descriptionLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:_descriptionLabel.text options:0 range:NSMakeRange(0, [_descriptionLabel.text length])];
    
    for(NSTextCheckingResult* match in matches) {
        [_descriptionLabel addLinkToURL:match.URL withRange:match.range];
    }
    
    [mView addSubview:_descriptionLabel];
    
    return rectLblDesc;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    __weak __typeof(self) weakSelf = self;
    
    NSString* theRealUrl;
    if([url.host isEqualToString:@"www.tokopedia.com"]) {
        theRealUrl = url.absoluteString;
    } else {
        theRealUrl = [NSString stringWithFormat:@"https://tkp.me/r?url=%@", [url.absoluteString stringByReplacingOccurrencesOfString:@"*" withString:@"."]];
    }
    
    WebViewController *controller = [[WebViewController alloc] init];
    controller.strURL = theRealUrl;
    controller.strTitle = @"Mengarahkan...";
    controller.onTapLinkWithUrl = ^(NSURL* url) {
        if([url.absoluteString isEqualToString:@"https://www.tokopedia.com/"]) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)expand:(CustomButtonExpandDesc *)sender
{
    [AnalyticsManager trackEventName:@"clickPDP"
                            category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                              action:GA_EVENT_ACTION_CLICK
                               label:@"Product Description"];
    isExpandDesc = !isExpandDesc;
    [_table reloadData];
}

- (IBAction)actionShare:(id)sender
{
    if (_product.data.info.product_url) {
        NSString *title = [NSString stringWithFormat:@"%@ - %@ | Tokopedia ",
                           _formattedProductTitle,
                           _product.data.shop_info.shop_name];
        NSURL *url = [NSURL URLWithString:_product.data.info.product_url];
        UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                          url:url
                                                                                       anchor:sender];
        
        [self presentViewController:controller animated:YES completion:^{
            [AnalyticsManager trackEventName:@"clickPDP"
                                    category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Share"];
        }];
        
    }
}


- (IBAction)actionWishList:(UIButton *)sender
{
    if(sender.tag == 1)
        [self setWishList];
    else
        [self setUnWishList];
}

- (IBAction)actionReport:(UIButton *)sender {
    if ([_userManager isLogin]) {
        [AnalyticsManager trackEventName:@"clickReport"
                                category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                                  action:GA_EVENT_ACTION_CLICK
                                   label:@"Report"];
        [self goToReportProductViewController];
    } else {
        LoginViewController *loginVC = [LoginViewController new];
        loginVC.delegate = self;
        loginVC.redirectViewController = self;
        loginVC.isPresentedViewController = YES;
        afterLoginRedirectTo = @"ReportProductViewController";
        UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        loginNavController.navigationBar.translucent = NO;
        [self.navigationController presentViewController:loginNavController animated:YES completion:nil];
    }
}

- (void) goToReportProductViewController {
    ReportProductViewController *reportProductVC = [ReportProductViewController new];
    reportProductVC.productId = _product.data.info.product_id;
    [self.navigationController pushViewController:reportProductVC animated:YES];
}

- (UIBarButtonItem *)createBarButton:(CGRect)frame withImage:(UIImage*)image withAction:(SEL)action
{
    UIImageView *infoImageView = [[UIImageView alloc] initWithImage:image];
    infoImageView.frame = frame;
    infoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [infoImageView addGestureRecognizer:tapGesture];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoImageView];
    
    return infoBarButton;
}

-(void)setHeaderviewData{
    NSString *productName = _formattedProductTitle?:@"";
    
    
    CGRect labelCGRectFrame = CGRectMake(self.navigationItem.titleView.frame.origin.x, 0, [UIScreen mainScreen].bounds.size.width, 44);
    MarqueeLabel *productLabel = [[MarqueeLabel alloc] initWithFrame:labelCGRectFrame duration:6.0 andFadeLength:10.0f];
    
    
    productLabel.backgroundColor = [UIColor clearColor];
    productLabel.numberOfLines = 2;
    UIFont *productLabelFont = [UIFont title1ThemeMedium];
    
    NSMutableParagraphStyle *productLabelStyle = [[NSMutableParagraphStyle alloc] init];
    productLabelStyle.lineSpacing = 4.0;
    
    NSDictionary *productLabelAtts = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSFontAttributeName: productLabelFont,
                                       NSParagraphStyleAttributeName: productLabelStyle,
                                       };
    
    NSAttributedString *productNameLabeAttributedText = [[NSAttributedString alloc] initWithString:productName
                                                                                        attributes:productLabelAtts];
    
    productLabel.attributedText = productNameLabeAttributedText;
    productLabel.textAlignment = NSTextAlignmentLeft;
    
    self.navigationItem.titleView = productLabel;
    
    
    //Update header view
    _pricelabel.text = _product.data.info.product_price;
    _countsoldlabel.text = [NSString stringWithFormat:@"%@", _product.data.statistic.product_sold_count?:@""];
    _countviewlabel.text = [NSString stringWithFormat:@"%@", _product.data.statistic.product_view_count?:@""];
    
    [_reviewbutton setTitle:[NSString stringWithFormat:@"%@ Ulasan",_product.data.statistic.product_review_count?:@""] forState:UIControlStateNormal];
    [_reviewbutton.layer setBorderWidth:1];
    [_reviewbutton.layer setBorderColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1].CGColor];
    
    [_talkaboutbutton setTitle:[NSString stringWithFormat:@"%@ Diskusi",_product.data.statistic.product_talk_count?:@""] forState:UIControlStateNormal];
    [_talkaboutbutton.layer setBorderWidth:1];
    [_talkaboutbutton.layer setBorderColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1].CGColor];
    
    _qualitynumberlabel.text = _product.data.rating.product_rating_point;
    _qualityrateview.starscount = [_product.data.rating.product_rating_star_point integerValue];
    
    _accuracynumberlabel.text = _product.data.rating.product_rate_accuracy_point;
    _accuracyrateview.starscount = [_product.data.rating.product_accuracy_star_rate integerValue];
    
    NSArray *images = _product.data.product_images;
    
    NSMutableArray *headerImages = [NSMutableArray new];
    
    [[_imagescrollview subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_headerimages removeAllObjects];
    
    for(int i = 0; i< images.count; i++)
    {
        CGFloat y = i * _table.frame.size.width;
        
        ProductImages *image = images[i];
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:image.image_src] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        
        UIImageView *thumb = [[UIImageView alloc]initWithFrame:CGRectMake(y, 0, _table.frame.size.width, _imagescrollview.frame.size.height)];
        
        thumb.image = nil;
        //thumb.hidden = YES;	//@prepareforreuse then @reset
        if(i == 0) {
            thumb.image = _tempFirstThumb;
        }
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            //NSLOG(@"thumb: %@", thumb);
            //            if([[request.URL absoluteString] isEqualToString:[_loadedData objectForKey:@"product_image"]]) {
            _tempFirstThumb = image;
            //            }
            [thumb setImage:image];
            
#pragma clang diagnostic pop
            [headerActivityIndicator removeFromSuperview];
            [headerActivityIndicator stopAnimating];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
        
        thumb.contentMode = UIViewContentModeScaleAspectFit;
        
        [_imagescrollview addSubview:thumb];
        [headerImages addObject:thumb];
        [_headerimages addObject:thumb];
    }
    
    if(images.count == 0) {
        UIImageView *thumb = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _table.bounds.size.width, _imagescrollview.bounds.size.height)];
        thumb.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Icon_no_photo_transparan@2x" ofType:@"png"]];
        thumb.contentMode = UIViewContentModeScaleAspectFit;
        [_imagescrollview addSubview:thumb];
        
        [headerActivityIndicator removeFromSuperview];
        [headerActivityIndicator stopAnimating];
    }
    
    _pagecontrol.hidden = _headerimages.count <= 1?YES:NO;
    _pagecontrol.numberOfPages = images.count;
    
    _imagescrollview.contentSize = CGSizeMake(images.count*self.view.frame.size.width,0);
    _imagescrollview.contentMode = UIViewContentModeScaleAspectFit;
    _imagescrollview.showsHorizontalScrollIndicator = NO;
    
    [_datatalk setObject:_formattedProductTitle?:@"" forKey:API_PRODUCT_NAME_KEY];
    [_datatalk setObject:_product.data.info.product_price?:@"" forKey:API_PRODUCT_PRICE_KEY];
    [_datatalk setObject:_headerimages?:@"" forKey:kTKPDDETAILPRODUCT_APIPRODUCTIMAGESKEY];
}

-(void)setFooterViewData
{
    [_shopname setTitle:_product.data.shop_info.shop_name forState:UIControlStateNormal];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"icon_location.png"];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc]initWithAttributedString:attachmentString ];
    NSAttributedString *newAttString = [[NSAttributedString alloc] initWithString:_product.data.shop_info.shop_location?:@"" attributes:nil];
    [myString appendAttributedString:newAttString];
    _shoplocation.attributedText = myString;
    //_shoplocation.text = _product.data.shop_info.shop_location?:@"";
    
    if(_product.data.shop_info.shop_is_gold == 1 || _product.data.shop_info.official) {
        _goldShop.hidden = NO;
    } else {
        _goldShop.hidden = YES;
    }
    
    if (_product.data.shop_info.official) {
        _goldShop.image = [UIImage imageNamed:@"badge_official_small"];
    }
    
    _constraintBadgeGoldWidth.constant = (_product.data.shop_info.shop_is_gold == 1)?20:0;
    _constraintBadgeLuckySpace.constant = (_product.data.shop_info.shop_is_gold == 1)?4:0;
    
    
    UIImageView *thumb = _shopthumb;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_product.data.shop_info.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    thumb.image = [UIImage imageNamed:@"icon_default_shop.jpg"];
    thumb.layer.cornerRadius = thumb.layer.frame.size.width/2;
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
#pragma clang diagnostic pop
        [merchantActivityIndicator removeFromSuperview];
        [merchantActivityIndicator stopAnimating];
        merchantActivityIndicator = nil;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_product.data.shop_info.shop_lucky] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [self.luckyBadgeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        self.luckyBadgeImageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        self.luckyBadgeImageView.image = [UIImage imageNamed:@""];
    }];
}

-(void)setOtherProducts {
    [self.otherProductIndicator stopAnimating];
    
    if (_otherProductObj.count > 0) {
        
        self.otherProductNoDataLabel.hidden = YES;
        otherProductPageControl.hidden = NO;
        
        UINib *cellNib = [UINib nibWithNibName:@"ProductCell" bundle:nil];
        [self.otherProductsCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"ProductCellIdentifier"];
        
        otherProductPageControl.numberOfPages = _otherProductObj.count;
        
        _otherProductDataSource.products = _otherProductObj;
        _otherProductDataSource.collectionView = _otherProductsCollectionView;
        _otherProductDataSource.pageControl = otherProductPageControl;
        _otherProductDataSource.delegate = self;
        
        self.otherProductsCollectionView.dataSource = _otherProductDataSource;
        self.otherProductsCollectionView.delegate = _otherProductDataSource;
        self.otherProductsCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        self.otherProductsConstraintHeight.constant = _otherProductDataSource.collectionViewItemSize.height + 20; // padding top bottom
        
        [self.otherProductsCollectionView performBatchUpdates:^{
            [self.otherProductsCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:nil];
        
        CGRect frame = _shopinformationview.frame;
        frame.size.height = 467;
        _shopinformationview.frame = frame;
        
        _table.tableFooterView = _shopinformationview;
        [_table reloadData];
        
        [self.otherProductsCollectionView flashScrollIndicators];
        
    } else {
        self.otherProductNoDataLabel.hidden = NO;
        otherProductPageControl.hidden = YES;
    }
}


#pragma mark - Request & Mapping Other Product
- (void)configureGetOtherProductRestkit {
}

- (void)loadDataOtherProduct {

    [self requestOtherProduct];
}
- (void)requestTimeoutOtherProduct {
    
}

- (void)cancelOtherProduct {
    [self setBackgroundWishlist:NO];
    //    [btnWishList setImage:imgWishList forState:UIControlStateNormal];
}

#pragma mark - Request and mapping favorite action

-(void)configureFavoriteRestkit {
    
}

- (void)configureWishListRestKit
{
    
}


- (void)setUnWishList
{
    if(_auth) {
        [self setRequestingAction:btnWishList isLoading:YES];
        __weak __typeof(self) weakSelf = self;
        NSString *productId = _product.data.info.product_id?:@"";
        tokopediaNetworkManagerWishList.isUsingHmac = YES;
        [tokopediaNetworkManagerWishList requestWithBaseUrl:[NSString mojitoUrl] path:[self getWishlistUrlPathWithProductId:productId] method:RKRequestMethodDELETE header: @{@"X-User-ID" : [_userManager getUserId]} parameter: nil mapping:[GeneralAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
            [weakSelf didSuccessRemoveWishlistWithSuccessResult: successResult withOperation:operation];
        } onFailure:^(NSError *errorResult) {
            [weakSelf didFailedRemoveWishListWithErrorResult:errorResult];
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
        isNeedLogin = YES;
        isDoingWishList = YES;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)setWishList
{
    [AnalyticsManager trackEventName:@"clickWishlist"
                            category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                              action:GA_EVENT_ACTION_CLICK
                               label:@"Add to Wishlist"];
    if(_auth) {
        [self setRequestingAction:btnWishList isLoading:YES];
        
        NSString *productId = _product.data.info.product_id?:@"";
        __weak __typeof(self) weakSelf = self;
        tokopediaNetworkManagerWishList.isUsingHmac = YES;
       
        [tokopediaNetworkManagerWishList requestWithBaseUrl:[NSString mojitoUrl] path:[self getWishlistUrlPathWithProductId:productId] method:RKRequestMethodPOST header: @{@"X-User-ID" : [_userManager getUserId]} parameter: nil mapping:[GeneralAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
            [weakSelf didSuccessAddWishlistWithSuccessResult: successResult withOperation:operation];
        } onFailure:^(NSError *errorResult) {
            [weakSelf didFailedAddWishListWithErrorResult:errorResult];
        }];
        
        NSNumber *price = [[NSNumberFormatter IDRFormatter] numberFromString:_product.data.info.price?:_product.data.info.product_price];
        
        [[AppsFlyerTracker sharedTracker] trackEvent:AFEventAddToWishlist withValues:@{
                                                                                       AFEventParamPrice : price?:@"",
                                                                                       AFEventParamContentType : @"Product",
                                                                                       AFEventParamContentId : _product.data.info.product_id?:@"",
                                                                                       AFEventParamCurrency : _product.data.info.product_currency?:@"IDR",
                                                                                       AFEventParamQuantity : @(1)
                                                                                       }];
        
        NSArray *categories = _product.data.breadcrumb;
        Breadcrumb *lastCategory = [categories objectAtIndex:categories.count - 1];
        NSString *productCategory = lastCategory.department_name?:@"";
        
        NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
        NSString *productPrice = [[_product.data.info.product_price componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]?:@"";
        
        NSDictionary *attributes = @{
                                     @"Product Id" : _product.data.info.product_id,
                                     @"Product Name" : _product.data.info.product_name,
                                     @"Product Price" : productPrice,
                                     @"Product Category" : productCategory
                                     };
        
        [AnalyticsManager localyticsEvent:@"Event : Add To Wishlist" attributes:attributes];
        
        [AnalyticsManager localyticsIncrementValue:1 profileAttribute:@"Profile : Has Wishlist" scope:LLProfileScopeApplication];
                
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didAddedProductToWishList" object:_product.data.info.product_id];
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
        isNeedLogin = YES;
        isDoingWishList = YES;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

-(void)favoriteShop:(NSString*)shop_id
{
    //Change this block to method (Any in branch f_bug_fixing)
    if(actFav == nil) {
        actFav = [[UIActivityIndicatorView alloc] init];
        actFav.color = [UIColor lightGrayColor];
    }
    actFav.frame = _favButton.frame;
    [actFav startAnimating];
    [_favButton.superview addSubview:actFav];
    _favButton.hidden = YES;
    
    [self requestFavoriteShopID:shop_id];
}

-(void)requestFavoriteResult:(id)mappingResult withOperation:(RKObjectRequestOperation *)operation {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyFav" object:nil];
}

-(void)requestFavoriteError:(id)object {
    
}

- (void)requestTimeoutFavorite {
    
}

#pragma mark - LoginView Delegate
- (void)redirectViewController:(id)viewController{
    if ([afterLoginRedirectTo isEqualToString:@"ReportProductViewController"]) {
        [self goToReportProductViewController];
    }
}

- (void)cancelLoginView {
    isDoingWishList = isDoingFavorite = isNeedLogin = NO;
}

#pragma mark - Tap View
- (void)tapProductGallery {
    //    NSDictionary *data = @{
    //                           @"image_index" : @(_pageheaderimages),
    //                           @"images" : _product.data.product_images
    //                           };
    //
    //    ProductGalleryViewController *vc = [ProductGalleryViewController new];
    //    vc.data = data;
    //
    //    [self.navigationController presentViewController:vc animated:YES completion:nil];
    //    [self.navigationController pushViewController:vc animated:YES];
    
    
    //    GalleryViewController *gallery = [[GalleryViewController alloc] initWithPhotoSource:self withStartingIndex:(int)_pageheaderimages];
    if(_headerimages.count > 0) {
        GalleryViewController *gallery = [GalleryViewController new];
        gallery.canDownload = YES;
        [gallery initWithPhotoSource:self withStartingIndex:(int)_pageheaderimages];
        [self.navigationController presentViewController:gallery animated:YES completion:nil];
    }
}

- (void)tapShop {
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    if(!_product.data.shop_info.shop_id) {
        return;
    }
    container.data = @{kTKPDDETAIL_APISHOPIDKEY:_product.data.shop_info.shop_id,
                       kTKPDDETAIL_APISHOPNAMEKEY:_product.data.shop_info.shop_name,
                       kTKPD_AUTHKEY:_auth?:[NSNull null]};
    [self.navigationController pushViewController:container animated:YES];
}

-(void)refreshRequest:(NSNotification*)notification {
    [self loadData];
}

#pragma mark - GalleryPhoto Delegate
- (int)numberOfPhotosForPhotoGallery:(GalleryViewController *)gallery
{
    if(_headerimages == nil)
        return 0;
    
    return (int)_headerimages.count;
}



- (NSString*)photoGallery:(GalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    if(((int) index) < 0)
        return ((ProductImages *) [_product.data.product_images objectAtIndex:0]).image_description;
    else if(((int)index) > _product.data.product_images.count-1)
        return ((ProductImages *) [_product.data.product_images objectAtIndex:_product.data.product_images.count-1]).image_description;
    
    return ((ProductImages *) [_product.data.product_images objectAtIndex:index]).image_description;
}

- (UIImage *)photoGallery:(NSUInteger)index {
    if(((int) index) < 0)
        return ((UIImageView *) [_headerimages objectAtIndex:0]).image;
    else if(((int)index) > _headerimages.count-1)
        return ((UIImageView *) [_headerimages objectAtIndex:_headerimages.count-1]).image;
    return ((UIImageView *) [_headerimages objectAtIndex:index]).image;
}

- (NSString*)photoGallery:(GalleryViewController *)gallery urlForPhotoSize:(GalleryPhotoSize)size atIndex:(NSUInteger)index {
    return nil;
}

- (void)handleTrashButtonTouch:(id)sender {
}


- (void)handleEditCaptionButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1){
        if (buttonIndex == 1) {
            NSString *productId = _product.data.info.product_id;
            [ProductRequest moveProductToWarehouse:productId
                     setCompletionBlockWithSuccess:^(ShopSettings *response) {
                         
                     } failure:^(NSArray *errorMessages) {
                         
                     }];
        }
    }else{
        if(buttonIndex == 1){
            EtalaseViewController *controller = [EtalaseViewController new];
            controller.delegate = self;
            controller.shopId =_product.data.shop_info.shop_id;
            controller.isEditable = NO;
            controller.showOtherEtalase = NO;
            controller.enableAddEtalase = YES;
            
            [controller setInitialSelectedEtalase:selectedEtalase];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}
-(void)didSelectEtalase:(EtalaseList *)selectedEtalasee{
    selectedEtalase = selectedEtalasee;
    NSString *productId = _product.data.info.product_id;
    [ProductRequest moveProduct:productId
                      toEtalase:selectedEtalase
  setCompletionBlockWithSuccess:^(ShopSettings *response) {
      NSArray *messages = @[@"Produk berhasil tampil di etalase"];
      StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:messages delegate:self];
      [alert show];
      [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PRODUCT_POST_NOTIFICATION_NAME
                                                          object:nil
                                                        userInfo:nil];
  } failure:^(NSArray *errorMessages) {
      StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
      [alert show];
  }];
}

- (void)userDidLogin:(NSNotification*)notification {
    _userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
    
    if(isNeedLogin) {
        [self loadData];
    }
}

- (void)userDidLogout:(NSNotification*)notification {
    _userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
}



#pragma mark - PopUp
- (void)dismissAllPopTipViews
{
    [cmPopTitpView dismissAnimated:YES];
    cmPopTitpView = nil;
}


#pragma mark - CMPopTipView Delegate
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - LabelMenu Delegate
- (void)duplicate:(int)tag
{
    [UIPasteboard generalPasteboard].string = _descriptionLabel.text;
}

- (void)addImpressionClick {
    _promoRequest = [[PromoRequest alloc] init];
    [_promoRequest requestForClickURL:[_data objectForKey:PromoClickURL]
                            onSuccess:^{
                                
                            } onFailure:^(NSError *error) {
                                
                            }];
}

- (void)initNoResultView {
    NoResultReusableView *noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    noResultView.delegate = self;
    [noResultView generateAllElements:@"icon_no_data_grey.png"
                                title:@"Produk tidak ditemukan"
                                 desc:@"Untuk informasi lebih lanjut silakan\nhubungi penjual"
                             btnTitle:@"Kembali ke halaman sebelumnya"];
    [self.view addSubview:noResultView];
}

- (void)buttonDidTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addUserActivity {
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        self.userActivity = [TPSpotlight productDetailActivity:_product.data];
    }
}

#pragma mark - Push other product

- (void)didSelectOtherProduct:(SearchAWSProduct *)product {
    [AnalyticsManager trackProductClick:product];
    NavigateViewController *navigateController = [NavigateViewController new];
    [navigateController navigateToProductFromViewController:self
                                                   withName:product.product_name
                                                  withPrice:product.product_price
                                                     withId:product.product_id
                                               withImageurl:product.product_image
                                               withShopName:product.shop_name];
}

- (BOOL)isProductActive {
    if ([_product.data.info.product_status integerValue]==PRODUCT_STATE_WAREHOUSE || [_product.data.info.product_status integerValue]==PRODUCT_STATE_PENDING) {
        return NO;
    }
    
    return YES;
}

#pragma mark - WishList method

-(void) didSuccessRemoveWishlistWithSuccessResult: (RKMappingResult *) successResult withOperation: (RKObjectRequestOperation *) operation{
    StickyAlertView *alert;
 
    alert = [[StickyAlertView alloc] initWithSuccessMessages:@[kTKPDSUCCESS_REMOVE_WISHLIST] delegate:self];
    [self setBackgroundWishlist:NO];
    btnWishList.tag = 1;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRemovedProductFromWishList" object:_product.data.info.product_id];

    [self setRequestingAction:btnWishList isLoading:NO];
    [alert show];
}

-(void) didSuccessAddWishlistWithSuccessResult: (RKMappingResult *) successResult withOperation: (RKObjectRequestOperation *) operation {
    StickyAlertView *alert;

    alert = [[StickyAlertView alloc] initWithSuccessMessages:@[kTKPDSUCCESS_ADD_WISHLIST] delegate:self];
    [self setBackgroundWishlist:YES];
    btnWishList.tag = 0;
    [self setRequestingAction:btnWishList isLoading:NO];
    [alert show];
    [self bk_performBlock:^(id obj) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPDOBSERVER_WISHLIST object:nil];
    } afterDelay:2.0];
}

-(void) didFailedAddWishListWithErrorResult: (NSError *) error {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[kTKPDFAILED_ADD_WISHLIST] delegate:self];
    [alert show];
    [self setBackgroundWishlist:NO];
    btnWishList.tag = 1;
    [self setRequestingAction:btnWishList isLoading:NO];
}

-(void) didFailedRemoveWishListWithErrorResult: (NSError *) error {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[kTKPDFAILED_REMOVE_WISHLIST] delegate:self];
    [self setBackgroundWishlist:YES];
    [alert show];
    btnWishList.tag = 0;
    [self setRequestingAction:btnWishList isLoading:NO];
}


-(NSString *) getWishlistUrlPathWithProductId: (NSString *)productId {
    return [NSString stringWithFormat:@"/v1/products/%@/wishlist", productId];
}

-(BOOL) isAbleToLoadVideo {
    return _product.data.shop_info.shop_is_gold == 1 ? YES : NO;
}

@end
