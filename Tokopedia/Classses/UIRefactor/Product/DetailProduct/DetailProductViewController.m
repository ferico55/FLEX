//
//  DetailProductViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#define CgapTitleAndContentDesc 20
#define CTagPromote 1
#define CTagTokopediaNetworkManager 2
#define CTagOtherProduct 3
#define CTagFavorite 4
#define CTagWishList 5
#define CTagUnWishList 6
#define CTagNoteCanReture 7
#define CTagPriceAlert 8

#import "ProductReputationViewController.h"
#import "CMPopTipView.h"
#import "LabelMenu.h"
#import "AlertPriceNotificationViewController.h"
#import "PriceAlertViewController.h"
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
#import "ProductReviewViewController.h"
#import "ProductTalkViewController.h"
#import "ProductAddEditViewController.h"

#import "DetailProductOtherView.h"
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

#import "Localytics.h"
#import "UIActivityViewController+Extensions.h"

#import "NoResultReusableView.h"

#import "OtherProductDataSource.h"

#import "PriceAlertRequest.h"

#import "TPLocalytics.h"

#import "Tokopedia-Swift.h"

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
LabelMenuDelegate,
TTTAttributedLabelDelegate,
GalleryViewControllerDelegate,
UITableViewDelegate,
UITableViewDataSource,
DetailProductInfoCellDelegate,
DetailProductOtherViewDelegate,
LoginViewDelegate,
TokopediaNetworkManagerDelegate,
EtalaseViewControllerDelegate,
UIAlertViewDelegate,
CMPopTipViewDelegate,
UIAlertViewDelegate,
NoResultDelegate,
UICollectionViewDelegate,
OtherProductDelegate
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
    BOOL isDoingWishList, isDoingFavorite, redirectToPriceAlert;
    
    NSInteger _requestcount;
    
    NSInteger _pageheaderimages;
    NSInteger _heightDescSection;
    Product *_product;
    NoteDetails *notesDetail;
    BOOL is_dismissed;
    NSDictionary *_auth;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *tokopediaNetworkManager;
    RKResponseDescriptor *_responseDescriptor;
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectOtherProductManager;
    TokopediaNetworkManager *tokopediaOtherProduct;
    NSOperationQueue *_operationOtherProductQueue;
    OtherProduct *_otherProduct;
    NSInteger _requestOtherProductCount;
    
    __weak RKObjectManager *_objectFavoriteManager;
    TokopediaNetworkManager *tokopediaNetworkManagerFavorite;
    NSOperationQueue *_operationFavoriteQueue;
    NSInteger _requestFavoriteCount;
    NSString *tempShopID;
    
    __weak RKObjectManager *_objectWishListManager;
    TokopediaNetworkManager *tokopediaNetworkManagerWishList;
    NSOperationQueue *operationWishList;
    
    __weak RKObjectManager *_objectNoteCanReture;
    TokopediaNetworkManager *tokopediaNoteCanReture;
    
    __weak RKObjectManager *_objectmanagerActionMoveToWarehouse;
    __weak RKManagedObjectRequestOperation *_requestActionMoveToWarehouse;
    
    TokopediaNetworkManager *tokopediaNetworkManagerPriceAlert;
    RKObjectManager *objectPriceAlertManager;
    
    __weak RKObjectManager *_objectmanagerActionMoveToEtalase;
    __weak RKManagedObjectRequestOperation *_requestActionMoveToEtalase;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    UserAuthentificationManager *_userManager;
    NSTimer *_timer;
    
    __weak RKObjectManager  *_objectPromoteManager;
    LabelMenu *lblDescription;
    
    BOOL isExpandDesc, isNeedLogin;
    TokopediaNetworkManager *_promoteNetworkManager;
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

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
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
@property (strong, nonatomic) IBOutlet DetailProductOtherView *otherproductview;

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

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestprocess:(id)object;

@end

@implementation DetailProductViewController
{
    IBOutlet UIView *viewContentTokoTutup;
    BOOL hasSetTokoTutup;
    NSString *_formattedProductDescription;
    NSString *_formattedProductTitle;
    
    NSArray *_constraint;
    EtalaseList *selectedEtalase;
    
    PriceAlertRequest *_request;
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
    fontDesc = [UIFont fontWithName:@"GothamBook" size:13.0f];
    
    _datatalk = [NSMutableDictionary new];
    _headerimages = [NSMutableArray new];
    _otherproductviews = [NSMutableArray new];
    _otherProductObj = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _operationOtherProductQueue = [NSOperationQueue new];
    _operationFavoriteQueue = [NSOperationQueue new];
    operationWishList = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
    _TKPDNavigator = [NavigateViewController new];
    _otherProductDataSource = [OtherProductDataSource new];
    selectedEtalase = [EtalaseList new];
    
    _constraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[viewContentWarehouse(==0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(viewContentWarehouse)];
    
    // GTM
    [self configureGTM];
    
    _promoteNetworkManager = [TokopediaNetworkManager new];
    _promoteNetworkManager.tagRequest = CTagPromote;
    _promoteNetworkManager.delegate = self;
    
    tokopediaNetworkManagerPriceAlert = [TokopediaNetworkManager new];
    tokopediaNetworkManagerPriceAlert.tagRequest = CTagPriceAlert;
    tokopediaNetworkManagerPriceAlert.delegate = self;
    
    tokopediaNetworkManagerFavorite = [TokopediaNetworkManager new];
    tokopediaNetworkManagerFavorite.delegate = self;
    tokopediaNetworkManagerFavorite.tagRequest = CTagFavorite;
    
    tokopediaNetworkManager = [TokopediaNetworkManager new];
    tokopediaNetworkManager.delegate = self;
    tokopediaNetworkManager.tagRequest = CTagTokopediaNetworkManager;
    
    tokopediaOtherProduct = [TokopediaNetworkManager new];
    tokopediaOtherProduct.delegate = self;
    tokopediaOtherProduct.tagRequest = CTagOtherProduct;
    tokopediaOtherProduct.isParameterNotEncrypted = YES;
    tokopediaOtherProduct.isUsingHmac = NO;
    
    tokopediaNetworkManagerWishList = [TokopediaNetworkManager new];
    tokopediaNetworkManagerWishList.delegate = self;
    tokopediaNetworkManagerWishList.tagRequest = CTagWishList;
    
    _request = [PriceAlertRequest new];
    
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
    
    //    if([[_userManager getShopName] isEqualToString:[_loadedData objectForKey:@"shop_name"]]) {
    //        _dinkButton.hidden = NO;
    //        _buyButton.hidden = YES;
    //    } else {
    //        _dinkButton.hidden = YES;
    //        _buyButton.hidden = NO;
    //    }
    
    //Set corner btn share
    btnShare.layer.cornerRadius = 5.0f;
    btnShare.layer.borderWidth = 1;
    btnShare.layer.borderColor = [[UIColor colorWithRed:219/255.0f green:219/255.0f blue:219/255.0f alpha:1.0f] CGColor];
    btnShare.layer.masksToBounds = YES;
    
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [tokopediaNetworkManager requestCancel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"Product Information";
    [TPAnalytics trackScreenName:@"Product Information"];
    
    _promoteNetworkManager.delegate = self;
    
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
    
    if (_isnodata || _product.result.shop_info.shop_id == nil) {
        
        ProductDetail *detailProduct = [ProductDetail new];
        detailProduct.product_id = [_loadedData objectForKey:@"product_id"];
        detailProduct.product_name = [_loadedData objectForKey:@"product_name"];
        detailProduct.product_price = [_loadedData objectForKey:@"product_price"];
        
        ShopInfo *shopInfo = [ShopInfo new];
        shopInfo.shop_name = [_loadedData objectForKey:@"shop_name"];
        
        DetailProductResult *result = [DetailProductResult new];
        result.product = detailProduct;
        result.shop_info = shopInfo;
        
        ProductImages *image = [ProductImages new];
        image.image_src = [_loadedData objectForKey:@"product_image"];
        result.product_images = [NSArray arrayWithObject:image];
        
        Product *product = [Product new];
        product.result = result;
        product.status = @"OK";
        product.isDummyProduct = YES;
        [self requestprocess:product];
        
        [self configureRestKit];
        [self loadData];
        if (_product.result.wholesale_price) {
            _expandedSections = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:1]]];
        } else {
            _expandedSections = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:0]]];
        }
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
                editProductVC.data = @{kTKPDDETAIL_APIPRODUCTIDKEY: _product.result.product.product_id,
                                       kTKPD_AUTHKEY : _auth?:@{},
                                       DATA_PRODUCT_DETAIL_KEY : _product.result.product,
                                       DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(TYPE_ADD_EDIT_PRODUCT_EDIT),
                                       DATA_IS_GOLD_MERCHANT :@(0) //TODO:: Change Value
                                       };
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editProductVC];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 23:
            {
                // Move To warehouse
                if ([_product.result.product.product_status integerValue] == PRODUCT_STATE_BANNED ||
                    [_product.result.product.product_status integerValue] == PRODUCT_STATE_PENDING) {
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
                if(_product.result.shop_info.shop_domain != nil) {
                    ProductReputationViewController *productReputationViewController = [ProductReputationViewController new];
                    productReputationViewController.strShopDomain = _product.result.shop_info.shop_domain;
                    productReputationViewController.strProductID = _product.result.product.product_id;
                    [self.navigationController pushViewController:productReputationViewController animated:YES];
                }
                return;
                
                
                
                // go to review page
                ProductReviewViewController *vc = [ProductReviewViewController new];
                NSArray *images = _product.result.product_images;
                ProductImages *image = images[0];
                
                vc.data = @{
                            kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
                            API_PRODUCT_NAME_KEY : _formattedProductTitle,
                            kTKPDDETAILPRODUCT_APIIMAGESRCKEY : image.image_src,
                            kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]
                            };
                [self.navigationController pushViewController:vc animated:YES];
                
                [TPAnalytics trackClickEvent:@"clickPDP" category:@"Product Detail Page" label:@"Review"];
                
                break;
            }
            case 13:
            {
                // got to talk page
                ProductTalkViewController *vc = [ProductTalkViewController new];
                NSArray *images = _product.result.product_images;
                ProductImages *image = images.count>0? images[0]:nil;
                
                [_datatalk setObject:[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0) forKey:kTKPDDETAIL_APIPRODUCTIDKEY];
                [_datatalk setObject:image.image_src?:@(0) forKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY];
                [_datatalk setObject:_product.result.statistic.product_sold_count?:@"0" forKey:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY];
                [_datatalk setObject:_product.result.statistic.product_view_count?:@"0" forKey:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY];
                [_datatalk setObject:_product.result.shop_info.shop_id?:@"" forKey:TKPD_TALK_SHOP_ID];
                [_datatalk setObject:_product.result.product.product_status?:@"" forKey:TKPD_TALK_PRODUCT_STATUS];
                [_datatalk setObject:_product.result.product.product_id forKey:TKPD_PRODUCT_ID  ];
                
                NSMutableDictionary *data = [NSMutableDictionary new];
                [data addEntriesFromDictionary:_datatalk];
                [data setObject:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null] forKey:kTKPD_AUTHKEY];
                [data setObject:image.image_src==nil?@"":image.image_src forKey:@"talk_product_image"];
                
                vc.data = data;

                [self.navigationController pushViewController:vc animated:YES];
                
                [TPAnalytics trackClickEvent:@"clickPDP" category:@"Product Detail Page" label:@"Review"];

                break;
            }
            case 15:
            {
                if (_product) {
                    NSString *title = [NSString stringWithFormat:@"Jual %@ - %@ | Tokopedia ",
                                       _formattedProductTitle,
                                       _product.result.shop_info.shop_name];
                    NSURL *url = [NSURL URLWithString:_product.result.product.product_url];
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
                if(_auth) {
                    TransactionATCViewController *transactionVC = [TransactionATCViewController new];
                    transactionVC.wholeSales = _product.result.wholesale_price;
                    transactionVC.productPrice = _product.result.product.product_price;
                    transactionVC.data = @{DATA_DETAIL_PRODUCT_KEY:_product.result};
                    transactionVC.productID = _product.result.product.product_id;
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
                if (tokopediaNetworkManagerFavorite.getObjectRequest!=nil && tokopediaNetworkManagerFavorite.getObjectRequest.isExecuting) return;
                if(_auth) {
                    [self favoriteShop:_product.result.shop_info.shop_id];
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
                if (tokopediaNetworkManagerFavorite.getObjectRequest!=nil && tokopediaNetworkManagerFavorite.getObjectRequest.isExecuting) return;
                if(_auth) {
                    //UnLove Shop
                    [self configureFavoriteRestkit];
                    [self favoriteShop:_product.result.shop_info.shop_id];
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
                NSString *shopid = _product.result.shop_info.shop_id;
                if(!shopid) {
                    return;
                }
                if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] isEqualToString:shopid]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    
                    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
                    
                    container.data = @{kTKPDDETAIL_APISHOPIDKEY:shopid,
                                       kTKPDDETAIL_APISHOPNAMEKEY:_product.result.shop_info.shop_name,
                                       kTKPD_AUTHKEY:_auth?:@{}};
                    container.initialEtalase = selectedEtalase;
                    
                    [self.navigationController pushViewController:container animated:YES];
                    
                }
                break;
            }
            case 21 : {
                [_promoteNetworkManager resetRequestCount];
                [_promoteNetworkManager doRequest];
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
                if ([_product.result.product.product_status integerValue] == PRODUCT_STATE_BANNED ||
                    [_product.result.product.product_status integerValue] == PRODUCT_STATE_PENDING) {
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
                if(_product.result.product.product_move_to == nil){
                    if([_product.result.product.product_status intValue] ==PRODUCT_STATE_WAREHOUSE){
                        _product.result.product.product_move_to = [@(PRODUCT_WAREHOUSE_YES_ID) stringValue];
                    }else{
                        _product.result.product.product_move_to = [@(PRODUCT_WAREHOUSE_NO_ID) stringValue];
                    }
                }
                editProductVC.data = @{kTKPDDETAIL_APIPRODUCTIDKEY: _product.result.product.product_id,
                                       kTKPD_AUTHKEY : _auth?:@{},
                                       DATA_PRODUCT_DETAIL_KEY : _product.result.product,
                                       DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(TYPE_ADD_EDIT_PRODUCT_EDIT),
                                       DATA_IS_GOLD_MERCHANT :@(0) //TODO:: Change Value
                                       };
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
    [bt.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [bt setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [bt.titleLabel setFont: [UIFont fontWithName:@"GothamMedium" size:15.0f]];
    [bt addTarget:self action:@selector(expandCollapseButton:) forControlEvents:UIControlEventTouchUpInside];
    switch (section) {
        case 0:
            [bt setTitle:PRODUCT_INFO  forState: UIControlStateNormal];
            break;
        case 1:
            if (!_isnodatawholesale)
                [bt setTitle: PRODUCT_WHOLESALE forState: UIControlStateNormal];
            else
            {
                CGRect rectLblDesc = CGRectZero;
                [bt setTitle: PRODUCT_DESC forState: UIControlStateNormal];
                
                CustomButtonExpandDesc *btnExpand = [CustomButtonExpandDesc buttonWithType:UIButtonTypeCustom];
                if(_formattedProductDescription.length>kTKPDLIMIT_TEXT_DESC && !isExpandDesc)
                {
                    rectLblDesc = [self initLableDescription:mView originY:bt.frame.origin.y+bt.bounds.size.height+CgapTitleAndContentDesc width:self.view.bounds.size.width-35 withText:[NSString stringWithFormat:@"%@%@", [_formattedProductDescription substringToIndex:kTKPDLIMIT_TEXT_DESC], kTKPDMORE_TEXT]];
                    
                    [btnExpand setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
                }
                else
                {
                    rectLblDesc = [self initLableDescription:mView originY:bt.frame.origin.y+bt.bounds.size.height+CgapTitleAndContentDesc width:self.view.bounds.size.width-35 withText:_formattedProductDescription];
                    [btnExpand setImage:[UIImage imageNamed:@"icon_arrow_up.png"] forState:UIControlStateNormal];
                }
                [expandCollapseButton removeFromSuperview];
                
                
                if(_formattedProductDescription.length > kTKPDLIMIT_TEXT_DESC) {
                    btnExpand.frame = CGRectMake((self.view.bounds.size.width-40)/2.0f, rectLblDesc.origin.y+rectLblDesc.size.height, 40, 40);
                    [btnExpand addTarget:self action:@selector(expand:) forControlEvents:UIControlEventTouchUpInside];
                    [btnExpand setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btnExpand.tag = 0;
                    btnExpand.objSection = (int)section;
                    
                    [mView addSubview:btnExpand];
                }
                
                [mView addSubview:bt];
                return mView;
            }
            break;
        case 2:
        {
            [bt setTitle: PRODUCT_DESC forState: UIControlStateNormal];
            CGRect rectLblDesc = CGRectZero;
            CustomButtonExpandDesc *btnExpand = [CustomButtonExpandDesc buttonWithType:UIButtonTypeCustom];
            
            if(_formattedProductDescription.length>kTKPDLIMIT_TEXT_DESC && !isExpandDesc)
            {
                rectLblDesc = [self initLableDescription:mView originY:bt.frame.origin.y+bt.bounds.size.height+CgapTitleAndContentDesc width:self.view.bounds.size.width-35 withText:[NSString stringWithFormat:@"%@%@", [_formattedProductDescription substringToIndex:kTKPDLIMIT_TEXT_DESC], kTKPDMORE_TEXT]];
                [btnExpand setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
            }
            else
            {
                rectLblDesc = [self initLableDescription:mView originY:bt.frame.origin.y+bt.bounds.size.height+CgapTitleAndContentDesc width:self.view.bounds.size.width-35 withText:_formattedProductDescription];
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
    if(! _isnodatawholesale)
    {
        //40 is height default of title description
        if(section == 2)
        {
            if(_formattedProductDescription.length>kTKPDLIMIT_TEXT_DESC && !isExpandDesc)
                return 40 + [self calculateHeightLabelDesc:CGSizeMake(self.view.bounds.size.width-45, 9999) withText:[NSString stringWithFormat:@"%@%@", [_formattedProductDescription substringToIndex:kTKPDLIMIT_TEXT_DESC], kTKPDMORE_TEXT] withColor:[UIColor whiteColor] withFont:nil withAlignment:NSTextAlignmentLeft] + (_formattedProductDescription.length>kTKPDLIMIT_TEXT_DESC? 40 : 25) + CgapTitleAndContentDesc;
            else
                return 40 + [self calculateHeightLabelDesc:CGSizeMake(self.view.bounds.size.width-45, 9999) withText:_formattedProductDescription withColor:[UIColor whiteColor] withFont:nil withAlignment:NSTextAlignmentLeft] + (_formattedProductDescription.length>kTKPDLIMIT_TEXT_DESC? 40 : 25) + CgapTitleAndContentDesc;
        }
    }
    else if(section == 1)
    {
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
        } else if (indexPath.section == 1 && _product.result.wholesale_price.count > 0) {
            return (44*2) + (_product.result.wholesale_price.count*44);//44 is standart height of uitableviewcell
        } else {
            return _descriptionHeight+50;
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
    if(! _isnodatawholesale)
    {
        if(section == 2)
            return 0;
    }
    else if(section == 1)
        return 0;
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    // Configure the cell...
    if (indexPath.section == 0) {
        
        NSString *cellid = kTKPDDETAILPRODUCTINFOCELLIDENTIFIER;
        DetailProductInfoCell *productInfoCell = (DetailProductInfoCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (productInfoCell == nil) {
            productInfoCell = [DetailProductInfoCell newcell];
            ((DetailProductInfoCell*)productInfoCell).delegate = self;
        }
        [self productinfocell:productInfoCell withtableview:tableView];
        
        //Check product returnable
        if(_product.result.product.product_returnable!=nil && [_product.result.product.product_returnable isEqualToString:@"1"]) {
            if([_product.result.shop_info.shop_has_terms isEqualToString:@"0"]) {
                NSString *strCanReture = [CStringCanReture stringByReplacingOccurrencesOfString:CStringCanRetureReplace withString:@""];
                [productInfoCell setLblDescriptionToko:strCanReture];
            }
            else {
                [productInfoCell setLblDescriptionToko:CStringCanReture];
                NSRange range = [CStringCanReture rangeOfString:CStringCanRetureLinkDetection];
                [productInfoCell getLblRetur].delegate = self;
                
                [[productInfoCell getLblRetur] addLinkToURL:[NSURL URLWithString:@""] withRange:range];
                
                tokopediaNoteCanReture = [TokopediaNetworkManager new];
                tokopediaNoteCanReture.delegate = self;
                tokopediaNoteCanReture.tagRequest = CTagNoteCanReture;
                [tokopediaNoteCanReture doRequest];
            }
        }
        else if(_product.result.product.product_returnable!=nil && [_product.result.product.product_returnable isEqualToString:@"2"]) {
            [productInfoCell setLblDescriptionToko:CStringCannotReture];
        }
        else {
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
                tempContentView.size.height = (_product.result.wholesale_price.count*4)+(44*2); //44 is height that currently is used(standard height uitableviewcell)
                cell.contentView.frame = tempContentView;
            }
            ((DetailProductWholesaleCell*)cell).data = @{kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY : _product.result.wholesale_price};
            
            return cell;
        }
        if (indexPath.section == 2) {
            NSString *cellid = kTKPDDETAILPRODUCTCELLIDENTIFIER;
            DetailProductDescriptionCell *descriptionCell = (DetailProductDescriptionCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (descriptionCell == nil) {
                descriptionCell = [DetailProductDescriptionCell newcell];
                if(!_isnodata) {
                    descriptionCell.descriptionText = _formattedProductDescription;
                    _descriptionHeight = descriptionCell.descriptionlabel.frame.size.height;
                }
            }
            cell = descriptionCell;
            return cell;
            
        }
    }
    else
    {
        if (indexPath.section == 1) {
            NSString *cellid = kTKPDDETAILPRODUCTCELLIDENTIFIER;
            DetailProductDescriptionCell *descriptionCell = (DetailProductDescriptionCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (descriptionCell == nil) {
                descriptionCell = [DetailProductDescriptionCell newcell];
                if(!_isnodata) {
                    descriptionCell.descriptionText = _formattedProductDescription;
                    _descriptionHeight = descriptionCell.descriptionlabel.frame.size.height;
                }
            }
            cell = descriptionCell;
            return cell;
        }
        
    }
    return cell;
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
    ((DetailProductInfoCell*)cell).minorderlabel.text = _product.result.product.product_min_order;
    ((DetailProductInfoCell*)cell).weightlabel.text = [NSString stringWithFormat:@"%@ %@",_product.result.product.product_weight?:@"0", _product.result.product.product_weight_unit?:@"gr"];
    ((DetailProductInfoCell*)cell).insurancelabel.text = _product.result.product.product_insurance;
    ((DetailProductInfoCell*)cell).conditionlabel.text = _product.result.product.product_condition;
    [((DetailProductInfoCell*)cell).etalasebutton setTitle:_product.result.product.product_etalase forState:UIControlStateNormal];
    
    NSArray *breadcrumbs = _product.result.breadcrumb;
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
    if ([_product.result.product.product_status integerValue]==PRODUCT_STATE_WAREHOUSE || [_product.result.product.product_status integerValue]==PRODUCT_STATE_PENDING)
        [cell.etalasebutton setTitle:@"-" forState:UIControlStateNormal];
    else
        [cell.etalasebutton setTitle:_product.result.product.product_etalase?:@"-" forState:UIControlStateNormal];
    cell.etalasebutton.hidden = NO;
}

#pragma mark - TokopediaNetwork Delegate
- (NSDictionary*)getParameter:(int)tag
{
    NSString *productID = _product.result.product.product_id?:@"0";
    if(tag == CTagPromote)
        return @{@"action" : @"promote_product", @"product_id" : productID};
    else if(tag == CTagTokopediaNetworkManager)
        return @{
                 kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETDETAILACTIONKEY,
                 kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@"0",
                 @"product_key" : [_data objectForKey:@"product_key"]?:@"",
                 @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@""
                 };
    else if(tag == CTagOtherProduct)
        return @{@"shop_id" : _product.result.shop_info.shop_id,
                 @"device" : @"ios",
                 @"-id" : _product.result.product.product_id,
                 @"source":@"other_product"
                 };
    else if(tag == CTagFavorite)
    {
        NSString *strShopID = [[NSString alloc] initWithString:tempShopID?:@"0"];
        tempShopID = nil;
        return @{kTKPDDETAIL_ACTIONKEY:@"fav_shop", @"shop_id":strShopID};
    }
    else if(tag == CTagUnWishList)
        return @{kTKPDDETAIL_ACTIONKEY : kTKPDREMOVE_WISHLIST_PRODUCT,
                 kTKPDDETAIL_APIPRODUCTIDKEY : productID};
    else if(tag == CTagWishList)
        return @{kTKPDDETAIL_ACTIONKEY : kTKPDADD_WISHLIST_PRODUCT,
                 kTKPDDETAIL_APIPRODUCTIDKEY : productID};
    else if(tag == CTagNoteCanReture)
        return @{kTKPDDETAIL_ACTIONKEY:kTKPDDETAIL_APIGETNOTESDETAILKEY,
                 kTKPDNOTES_APINOTEIDKEY:_product.result.shop_info.shop_has_terms?:@"0",
                 NOTES_TERMS_FLAG_KEY:@(1),
                 kTKPDDETAIL_APISHOPIDKEY:_product.result.shop_info.shop_id?:@"0"};
    else if(tag == CTagPriceAlert) {
        return @{kTKPDDETAIL_APIPRODUCTIDKEY:_product.result.product.product_id,
                 kTKPDDETAIL_ACTIONKEY : kTKPDREMOVE_PRODUCT_PRICE_ALERT};
    }
    
    return nil;
}

-(int)getRequestMethod:(int)tag{
    if(tag == CTagPromote)
        return RKRequestMethodPOST;
    else if(tag == CTagTokopediaNetworkManager)
        return RKRequestMethodPOST;
    else if(tag == CTagOtherProduct)
        return RKRequestMethodGET;
    else if(tag == CTagFavorite)
        return RKRequestMethodPOST;
    else if(tag == CTagUnWishList)
        return RKRequestMethodPOST;
    else if(tag == CTagWishList)
        return RKRequestMethodPOST;
    else if(tag == CTagNoteCanReture)
        return RKRequestMethodPOST;
    else if(tag == CTagPriceAlert)
        return RKRequestMethodPOST;
    
    return RKRequestMethodPOST;;
    
}

- (NSString*)getPath:(int)tag
{
    if(tag == CTagPromote)
        return @"action/product.pl";
    else if(tag == CTagTokopediaNetworkManager)
        return [_detailProductPostUrl isEqualToString:@""] ? kTKPDDETAILPRODUCT_APIPATH : _detailProductPostUrl;
    else if(tag == CTagOtherProduct)
        //return [_detailProductPostUrl isEqualToString:@""] ? kTKPDDETAILPRODUCT_APIPATH : _detailProductPostUrl;
        return @"/search/v2.1/product";
    else if(tag == CTagFavorite)
        return @"action/favorite-shop.pl";
    else if(tag == CTagUnWishList)
        return [NSString stringWithFormat:@"action/%@", kTKPDWISHLIST_APIPATH];
    else if(tag == CTagWishList)
        return [NSString stringWithFormat:@"action/%@", kTKPDWISHLIST_APIPATH];
    else if(tag == CTagNoteCanReture)
        return kTKPDDETAILNOTES_APIPATH;
    else if(tag == CTagPriceAlert)
        return [NSString stringWithFormat:@"action/%@", CPriceAlertPL];
    
    return nil;
}

- (id)getObjectManager:(int)tag
{
    if(tag == CTagPromote)
    {
        _objectPromoteManager = [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Promote class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PromoteResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{@"is_dink":@"is_dink"}];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                      toKeyPath:kTKPD_APIRESULTKEY
                                                                                    withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectPromoteManager addResponseDescriptor:responseDescriptorStatus];
        
        return _objectPromoteManager;
    }
    else if(tag == CTagTokopediaNetworkManager)
    {
        // initialize RestKit
        //        _objectmanager =  [RKObjectManager sharedClient];
        //        _objectmanager =  ![_detailProductBaseUrl isEqualToString:kTkpdBaseURLString]?[RKObjectManager sharedClient:_detailProductBaseUrl]:[RKObjectManager sharedClient];
        if([_detailProductBaseUrl isEqualToString:kTkpdBaseURLString] || [_detailProductBaseUrl isEqualToString:@""]) {
            _objectmanager = [RKObjectManager sharedClient];
        } else {
            _objectmanager = [RKObjectManager sharedClient:_detailProductBaseUrl];
        }
        
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
                                                          KTKPDPRODUCT_RETURNABLE:KTKPDPRODUCT_RETURNABLE,
                                                          API_PRODUCT_ETALASE_KEY:API_PRODUCT_ETALASE_KEY,
                                                          API_PRODUCT_MINIMUM_ORDER_KEY:API_PRODUCT_MINIMUM_ORDER_KEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY:kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTIDKEY:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTURLKEY:kTKPDDETAILPRODUCT_APIPRODUCTURLKEY,
                                                          kTKPDPRODUCT_ALREADY_WISHLIST:kTKPDPRODUCT_ALREADY_WISHLIST
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
                                                              kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPHASTERMKEY:kTKPDDETAILPRODUCT_APISHOPHASTERMKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY,
                                                              API_IS_GOLD_SHOP_KEY:API_IS_GOLD_SHOP_KEY,
                                                              kTKPDDETAILPRODUCT_APISHOPSTATUSKEY:kTKPDDETAILPRODUCT_APISHOPSTATUSKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPCLOSEDUNTIL:kTKPDDETAILPRODUCT_APISHOPCLOSEDUNTIL,
                                                              kTKPDDETAILPRODUCT_APISHOPCLOSEDREASON:kTKPDDETAILPRODUCT_APISHOPCLOSEDREASON,
                                                              kTKPDDETAILPRODUCT_APISHOPCLOSEDNOTE:kTKPDDETAILPRODUCT_APISHOPCLOSEDNOTE,
                                                              kTKPDDETAILPRODUCT_APISHOPURLKEY:kTKPDDETAILPRODUCT_APISHOPURLKEY
                                                              ,@"shop_lucky":@"shop_lucky"
                                                              }];
        
        RKObjectMapping *productRatingMapping = [RKObjectMapping mappingForClass:[Rating class]];
        [productRatingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APIQUALITYRATE:kTKPDDETAILPRODUCT_APIQUALITYRATE,
                                                                   kTKPDDETAILPRODUCT_APIQUALITYSTAR:kTKPDDETAILPRODUCT_APIQUALITYSTAR,
                                                                   kTKPDDETAILPRODUCT_APIACCURACYRATE:kTKPDDETAILPRODUCT_APIACCURACYRATE,
                                                                   kTKPDDETAILPRODUCT_APIACCURACYSTAR:kTKPDDETAILPRODUCT_APIACCURACYSTAR
                                                                   }];
        
        
        RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
        [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                               CShopReputationScore:CShopReputationScore,
                                                               CShopSpeedDesc:CShopSpeedDesc,
                                                               kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY
                                                               }];
        
        
        RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
        [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
        
        RKObjectMapping *wholesaleMapping = [RKObjectMapping mappingForClass:[WholesalePrice class]];
        [wholesaleMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIWHOLESALEMINKEY,kTKPDDETAILPRODUCT_APIWHOLESALEPRICEKEY,kTKPDDETAILPRODUCT_APIWHOLESALEMAXKEY]];
        
        RKObjectMapping *breadcrumbMapping = [RKObjectMapping mappingForClass:[Breadcrumb class]];
        [breadcrumbMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIDEPARTMENTNAMEKEY,API_DEPARTMENT_ID_KEY]];
        
        RKObjectMapping *otherproductMapping = [RKObjectMapping mappingForClass:[OtherProduct class]];
        [otherproductMapping addAttributeMappingsFromArray:@[API_PRODUCT_PRICE_KEY,API_PRODUCT_NAME_KEY,kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY]];
        
        RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[ProductImages class]];
        [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIIMAGEIDKEY,kTKPDDETAILPRODUCT_APIIMAGESTATUSKEY,kTKPDDETAILPRODUCT_APIIMAGEDESCRIPTIONKEY,kTKPDDETAILPRODUCT_APIIMAGEPRIMARYKEY,kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
        
        
        //        RKObjectMapping *responseSpeedMapping = [RKObjectMapping mappingForClass:[ResponseSpeed class]];
        //        [responseSpeedMapping addAttributeMappingsFromDictionary:@{COneDay:COneDay,
        //                                                                   CTwoDay:CTwoDay,
        //                                                                   CThreeDay:CThreeDay,
        //                                                                   CSpeedLevel:CSpeedLevel,
        //                                                                   CBadge:CBadge,
        //                                                                   CCountTotal:CCountTotal}];
        
        // Relationship Mapping
        [shopstatsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopBadgeLevel toKeyPath:CShopBadgeLevel withMapping:shopBadgeMapping]];
        //        [shopinfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CResponseFast toKeyPath:CResponseFast withMapping:responseSpeedMapping]];
        
        [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY toKeyPath:API_PRODUCT_INFO_KEY withMapping:infoMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY toKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY withMapping:statisticMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY withMapping:shopinfoMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIRATINGKEY toKeyPath:kTKPDDETAILPRODUCT_APIRATINGKEY withMapping:productRatingMapping]];
        
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
                                                                                           pathPattern:[self getPath:tag]
                                                                                               keyPath:@""
                                                                                           statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptor];
        return _objectmanager;
    }
    else if(tag == CTagOtherProduct)
    {
        //_objectOtherProductManager = [RKObjectManager sharedClient];
        _objectOtherProductManager = [RKObjectManager sharedClient:[NSString aceUrl]];
        
        
        // register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[SearchAWS mapping]
                                                                                                method:[self getRequestMethod:CTagOtherProduct]
                                                                                           pathPattern:[self getPath:CTagOtherProduct]
                                                                                               keyPath:@""
                                                                                           statusCodes:kTkpdIndexSetStatusCodeOK];
        
        //add response description to object manager
        [_objectOtherProductManager addResponseDescriptor:responseDescriptor];
        
        return _objectOtherProductManager;
        
    }
    else if(tag == CTagFavorite)
    {
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
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectFavoriteManager addResponseDescriptor:responseDescriptorStatus];
        return _objectFavoriteManager;
    }
    else if(tag==CTagUnWishList || tag==CTagWishList)
    {
        _objectWishListManager =  [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectWishListManager addResponseDescriptor:responseDescriptorStatus];
        
        return _objectWishListManager;
    }
    else if(tag == CTagNoteCanReture) {
        _objectNoteCanReture = [RKObjectManager sharedClient];
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Notes class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[NotesResult class]];
        RKObjectMapping *noteDetailMapping = [RKObjectMapping mappingForClass:[NoteDetails class]];
        [noteDetailMapping addAttributeMappingsFromDictionary:@{
                                                                @"notes_position" : @"notes_position",
                                                                @"notes_status" : @"notes_status",
                                                                @"notes_create_time" : @"notes_create_time",
                                                                @"notes_id" : @"notes_id",
                                                                @"notes_title" : @"notes_title",
                                                                @"notes_active" : @"notes_active",
                                                                @"notes_update_time" : @"notes_update_time",
                                                                @"notes_content" : @"notes_content"
                                                                }];
        
        //Relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        RKRelationshipMapping *detailRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"detail" toKeyPath:@"detail" withMapping:noteDetailMapping];
        [resultMapping addPropertyMapping:detailRel];
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [_objectNoteCanReture addResponseDescriptor:responseDescriptor];
        
        return _objectNoteCanReture;
    }
    else if(tag == CTagPriceAlert) {
        objectPriceAlertManager = [RKObjectManager sharedClient];
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectPriceAlertManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectPriceAlertManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    
    if(tag == CTagPromote)
    {
        Promote *action = stat;
        return action.status;
    }
    else if (tag == CTagOtherProduct)
    {
        TheOtherProduct *theOtherProduct = stat;
        return theOtherProduct.status;
    }
    else if(tag == CTagTokopediaNetworkManager)
    {
        Product *product = stat;
        return product.status;
    }
    else if(tag == CTagFavorite)
    {
        tempShopID = nil;
        FavoriteShopAction *favoriteShopAction = stat;
        return favoriteShopAction.status;
    }
    else if(tag == CTagUnWishList)
    {
        GeneralAction *wishlistAction = stat;
        return wishlistAction.status;
    }
    else if(tag == CTagWishList)
    {
        GeneralAction *wishlistAction = stat;
        return wishlistAction.status;
    }
    else if(tag == CTagNoteCanReture) {
        Notes *notes = stat;
        return notes.status;
    }
    else if(tag == CTagPriceAlert) {
        GeneralAction *generalAction = stat;
        return generalAction.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if(tag == CTagPromote)
    {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        Promote* promoteObject = [result objectForKey:@""];
        
        if([promoteObject.result.is_dink isEqualToString:@"1"]) {
            NSString *successMessage = [NSString stringWithFormat:@"Promo pada product %@ telah berhasil! Fitur Promo berlaku setiap 60 menit sekali untuk masing-masing toko.", _formattedProductTitle];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[successMessage]
                                                                             delegate:self];
            [alert show];
        } else {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda belum dapat menggunakan fitur Promo pada saat ini. Fitur Promo berlaku setiap 60 menit sekali untuk masing-masing toko."]
                                                                           delegate:self];
            [alert show];
        }
        
        [_dinkButton setTitle:@"Promosi" forState:UIControlStateNormal];
        [_dinkButton setEnabled:YES];
    }
    else if(tag == CTagTokopediaNetworkManager)
    {
        [_act stopAnimating];
        _buyButton.enabled = YES;
        [self configureGetOtherProductRestkit];
        
        [self requestsuccess:successResult withOperation:operation];
        
        if(isNeedLogin) {
            isNeedLogin = !isNeedLogin;
            if(isDoingWishList) {
                isDoingWishList = !isDoingWishList;
                [btnWishList sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else if(isDoingFavorite) {
                isDoingFavorite = !isDoingFavorite;
                [_favButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else if(redirectToPriceAlert) {
                redirectToPriceAlert = !redirectToPriceAlert;
                [btnPriceAlert sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    else if(tag == CTagOtherProduct)
    {
        [_otherProductIndicator stopAnimating];
        [self requestSuccessOtherProduct:successResult withOperation:operation];
    }
    else if(tag == CTagFavorite)
    {
        StickyAlertView *stickyAlertView;
        if(_favButton.tag == 17) {//Favorite
            stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessFavoriteShop] delegate:self];
        }else {
            stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessUnFavoriteShop] delegate:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavoriteShop" object:_product.result.shop_info.shop_url];
        
        [stickyAlertView show];
        [self requestFavoriteResult:successResult withOperation:operation];
        [self setButtonFav];
        
        //Change this block to method (Any in branch f_bug_fixing)
        [actFav stopAnimating];
        [actFav removeFromSuperview];
        actFav = nil;
        _favButton.hidden = NO;
    }
    else if(tag == CTagUnWishList)
    {
        NSDictionary *result = ((RKMappingResult*) successResult).dictionary;
        WishListObject *wishListObject = [result objectForKey:@""];
        BOOL status = [wishListObject.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        StickyAlertView *alert;
        
        if(status && [wishListObject.result.is_success isEqualToString:@"1"])
        {
            alert = [[StickyAlertView alloc] initWithSuccessMessages:@[kTKPDSUCCESS_REMOVE_WISHLIST] delegate:self];
            [self setBackgroundWishlist:NO];
            btnWishList.tag = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPDOBSERVER_WISHLIST object:nil];
            [self setRequestingAction:btnWishList isLoading:NO];
        }
        else
        {
            alert = [[StickyAlertView alloc] initWithErrorMessages:@[kTKPDFAILED_REMOVE_WISHLIST] delegate:self];
            [self setBackgroundWishlist:YES];
            btnWishList.tag = 0;
            [self setRequestingAction:btnWishList isLoading:NO];
        }
        [alert show];
    }
    else if(tag == CTagWishList)
    {
        NSDictionary *result = ((RKMappingResult*) successResult).dictionary;
        WishListObject *wishListObject = [result objectForKey:@""];
        BOOL status = [wishListObject.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        StickyAlertView *alert;
        
        if(status && [wishListObject.result.is_success isEqualToString:@"1"])
        {
            alert = [[StickyAlertView alloc] initWithSuccessMessages:@[kTKPDSUCCESS_ADD_WISHLIST] delegate:self];
            [self setBackgroundWishlist:YES];
            btnWishList.tag = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPDOBSERVER_WISHLIST object:nil];
            [self setRequestingAction:btnWishList isLoading:NO];
        }
        else
        {
            //wishlist max is 1000, set custom error message. If other error happened, use default error message.
            if([wishListObject.message_error[0] isEqual:@"Wishlist sudah mencapai batas (1000)."]){
                alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Maksimum wishlist Anda adalah 1000 produk"] delegate:self];
            }else{
                alert = [[StickyAlertView alloc] initWithErrorMessages:@[kTKPDFAILED_ADD_WISHLIST] delegate:self];
            }
            
            
            [self setBackgroundWishlist:NO];
            btnWishList.tag = 1;
            [self setRequestingAction:btnWishList isLoading:NO];
        }
        
        [alert show];
    }
    else if(tag == CTagNoteCanReture) {
        NSDictionary *result = ((RKMappingResult *) successResult).dictionary;
        Notes *tempNotes = [result objectForKey:@""];
        notesDetail = tempNotes.result.detail;
    }
    else if(tag == CTagPriceAlert) {
        NSDictionary *result = ((RKMappingResult*) successResult).dictionary;
        GeneralAction *generalAction = [result objectForKey:@""];
        if([generalAction.result.is_success isEqualToString:@"1"]) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessRemovePriceAlert] delegate:self];
            [stickyAlertView show];
            
            _product.result.product.product_price_alert = @"0";
            [self setBackgroundPriceAlert:[_product.result.product.product_price_alert isEqualToString:@"x"]];
        }
        [self setRequestingAction:btnPriceAlert isLoading:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSeeAProduct" object:_product.result];
}


- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    
    if(tag == CTagPromote)
    {
        
    }
    else if(tag == CTagTokopediaNetworkManager)
    {
        
    }
    else if(tag == CTagOtherProduct)
        [self requestFailureOtherProduct:errorResult];
    else if(tag == CTagFavorite)
        [self requestFavoriteError:errorResult];
    else if(tag == CTagUnWishList)
    {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[kTKPDFAILED_REMOVE_WISHLIST] delegate:self];
        [alert show];
        [self setBackgroundWishlist:YES];
        btnWishList.tag = 0;
        
        [self setRequestingAction:btnWishList isLoading:NO];
    }
    else if(tag == CTagWishList)
    {
        NSDictionary *result = ((RKMappingResult*) errorResult).dictionary;
        NSString *errorMessage = [result objectForKey:kTKPD_APIERRORMESSAGEKEY];
        
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[kTKPDFAILED_ADD_WISHLIST] delegate:self];
        [alert show];
        [self setBackgroundWishlist:NO];
        btnWishList.tag = 1;
        [self setRequestingAction:btnWishList isLoading:NO];
    }
    else if(tag == CTagNoteCanReture) {
        
    }
    else if(tag == CTagPriceAlert) {
        [self setRequestingAction:btnPriceAlert isLoading:NO];
    }
}

- (void)actionBeforeRequest:(int)tag
{
    if(tag == CTagPromote)
    {
        [_dinkButton setTitle:@"Sedang Mempromosikan.." forState:UIControlStateNormal];
        [_dinkButton setEnabled:NO];
    }
    else if(tag == CTagTokopediaNetworkManager)
    {
        _act.hidden = YES;
        [_act stopAnimating];
        [self unsetWarehouse];
        
    }
    else if(tag == CTagOtherProduct)
    {
        
    }
    else if(tag == CTagFavorite)
    {}
    else if(tag == CTagUnWishList)
    {}
    else if(tag == CTagWishList)
    {}
    else if(tag == CTagPriceAlert) {
        
    }
}

- (void)actionRequestAsync:(int)tag
{
    if(tag == CTagPromote)
    {
        
    }
    else if(tag == CTagTokopediaNetworkManager)
    {
    }
    else if(tag == CTagOtherProduct)
    {
    }
    else if(tag == CTagFavorite)
    {}
    else if(tag == CTagUnWishList)
    {}
    else if(tag == CTagWishList)
    {}
    else if(tag == CTagPriceAlert)
    {}
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    if(tag == CTagPromote)
    {
        
    }
    else if(tag == CTagTokopediaNetworkManager)
    {
        
    }
    else if(tag == CTagOtherProduct)
    {
    }
    else if(tag == CTagFavorite)
    {
        //Change this block to method (Any in branch f_bug_fixing)
        [actFav stopAnimating];
        [actFav removeFromSuperview];
        actFav = nil;
        _favButton.hidden = NO;
    }
    else if(tag == CTagUnWishList)
    {}
    else if(tag == CTagWishList)
    {}
    else if(tag == CTagPriceAlert)
    {}
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    
    [tokopediaNetworkManager requestCancel];
    _promoteNetworkManager.delegate = nil;
    [self cancel];
    
    tokopediaNetworkManagerWishList.delegate = nil;
    [tokopediaNetworkManagerWishList requestCancel];
    
    _promoteNetworkManager.delegate = nil;
    [_promoteNetworkManager requestCancel];
    
    tokopediaNetworkManagerFavorite.delegate = nil;
    [tokopediaNetworkManagerFavorite requestCancel];
    
    tokopediaNetworkManager.delegate = nil;
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager = nil;
    
    tokopediaOtherProduct.delegate = nil;
    [tokopediaOtherProduct requestCancel];
    tokopediaOtherProduct = nil;
    
    tokopediaNoteCanReture.delegate = nil;
    [tokopediaNoteCanReture requestCancel];
    tokopediaNoteCanReture = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
}

- (void)loadData
{
    [_cachecontroller getFileModificationDate];
    _timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    if (_timeinterval > _cachecontroller.URLCacheInterval) {
        //        [_act startAnimating];
        //        _buyButton.enabled = NO;
        [tokopediaNetworkManager doRequest];
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
    }
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    _product = [result objectForKey:@""];
    
    
    BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        
        if (_product.result == nil) {
            [self initNoResultView];
            self.table.hidden = YES;
            return;
        }
        
        [self loadDataOtherProduct];
        
        //Set icon speed
        [SmileyAndMedal setIconResponseSpeed:_product.result.shop_info.respond_speed.badge withImage:btnKecepatan largeImage:NO];
        [SmileyAndMedal generateMedalWithLevel:_product.result.shop_info.shop_stats.shop_badge_level.level withSet:_product.result.shop_info.shop_stats.shop_badge_level.set withImage:btnReputasi isLarge:YES];
        
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
        
        
        
        //Set toko tutup
        if(_product.result.shop_info.shop_status!=nil && [_product.result.shop_info.shop_status isEqualToString:@"2"]) {
            viewContentTokoTutup.hidden = NO;
            lblDescTokoTutup.text = [NSString stringWithFormat:FORMAT_TOKO_TUTUP, _product.result.shop_info.shop_is_closed_until];
        } else if (_product.result.shop_info.shop_status != nil && [_product.result.shop_info.shop_status isEqualToString:@"3"]) {
            viewContentTokoTutup.hidden = NO;
            lblDescTokoTutup.text = @"Toko ini sedang dimoderasi";
        }
        
        //Set shop in warehouse
        if([_product.result.product.product_status intValue]!=PRODUCT_STATE_WAREHOUSE &&
           [_product.result.product.product_status intValue]!=PRODUCT_STATE_PENDING) {
            [self unsetWarehouse];
        } else if ([_product.result.product.product_status intValue] ==PRODUCT_STATE_WAREHOUSE||
                   [_product.result.product.product_status integerValue] == PRODUCT_STATE_PENDING) {
            
            if([_product.result.product.product_status integerValue] == PRODUCT_STATE_BANNED ||
               [_product.result.product.product_status integerValue] == PRODUCT_STATE_PENDING) {
                lblTitleWarehouse.text = CStringTitleBanned;
                [self initAttributeText:lblDescWarehouse withStrText:CStringDescBanned withColor:lblDescWarehouse.textColor withFont:lblDescWarehouse.font withAlignment:NSTextAlignmentCenter];
            }
            
            constraintHeightWarehouse.constant = 50;
            UserAuthentificationManager *userAuthentificationManager = [UserAuthentificationManager new];
            if(![userAuthentificationManager isMyShopWithShopId:_product.result.shop_info.shop_id]){
                _constraintHeightShare.constant = 50;
                _header.frame = CGRectMake(0, 0, _table.bounds.size.width, 570);
            }
            else
            {
                _constraintHeightShare.constant = 0;
                _header.frame = CGRectMake(0, 0, _table.bounds.size.width, 520);
            }
            [viewContentWarehouse setHidden:NO];
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
        
        [self requestprocess:object];
    }
}

- (void)unsetWarehouse {
    constraintHeightWarehouse.constant = 0;
    _constraintHeightShare.constant = 50;
    //    [viewContentWarehouse removeConstraint:constraintHeightWarehouse];
    //    [viewContentWarehouse addConstraints:_constraint];
    viewContentWarehouse.hidden = YES;
    _header.frame = CGRectMake(0, 0, _table.bounds.size.width, 520
                               );
    _table.tableHeaderView = _header;
    
}

- (void)requestfailure:(id)object {
    
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
        
        _formattedProductDescription = [NSString convertHTML:_product.result.product.product_description]?:@"-";
        _formattedProductTitle = [NSString stringWithFormat:@" %@", _product.result.product.product_name];
        BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            
            _constraintHeightBuyButton.constant = 48;
            _constraintHeightDinkButton.constant = 48;
            
            if (_product.result.wholesale_price.count > 0) {
                _isnodatawholesale = NO;
            }
            if([_formattedProductDescription isEqualToString:@"0"])
                _formattedProductDescription = NO_DESCRIPTION;
            
            selectedEtalase.etalase_id = [_product.result.product.product_etalase_id stringValue];;
            selectedEtalase.etalase_name = _product.result.product.product_etalase;
            
            UserAuthentificationManager *userAuthentificationManager = [UserAuthentificationManager new];
            self.navigationItem.rightBarButtonItems = nil;
            
            if([userAuthentificationManager isMyShopWithShopId:_product.result.shop_info.shop_id] && [userAuthentificationManager isLogin] && !_product.isDummyProduct) {
                //MyShop
                [_dinkButton setHidden:NO];
                UIBarButtonItem *barbutton;
                barbutton = [self createBarButton:CGRectMake(0,0,22,22) withImage:[UIImage imageNamed:@"icon_shop_setting.png"] withAction:@selector(gestureSetting:)];
                
                [barbutton setTag:22];
                
                UIBarButtonItem *barbutton1;
                if ([_product.result.product.product_status integerValue] == PRODUCT_STATE_WAREHOUSE) {
                    barbutton1 = [self createBarButton:CGRectMake(0,0,22,22) withImage:[UIImage imageNamed:@"icon_move_etalase.png"] withAction:@selector(gestureMoveToEtalase:)];
                    [barbutton1 setTag:23];
                }
                else
                {
                    barbutton1 = [self createBarButton:CGRectMake(0,0,22,22) withImage:[UIImage imageNamed:@"icon_move_gudang.png"] withAction:@selector(gestureMoveToWarehouse:)];
                    [barbutton1 setTag:24];
                }
                
                if([_product.result.product.product_status integerValue] == PRODUCT_STATE_BANNED ||
                   [_product.result.product.product_status integerValue] == PRODUCT_STATE_PENDING) {
                    self.navigationItem.rightBarButtonItems = nil;
                } else {
                    self.navigationItem.rightBarButtonItems = @[barbutton, barbutton1];
                }
                
                [btnWishList removeFromSuperview];
                
                //Set position btn share
                int n = (int)btnShare.constraints.count;
                NSMutableArray *arrRemoveConstraint = [NSMutableArray new];
                
                for(int i=0;i<n;i++) {
                    if([[btnShare.constraints objectAtIndex:i] isMemberOfClass:[NSLayoutConstraint class]]) {
                        [arrRemoveConstraint addObject:[btnShare.constraints objectAtIndex:i]];
                    }
                }
                [btnShare removeConstraints:arrRemoveConstraint];
                [arrRemoveConstraint removeAllObjects];
                arrRemoveConstraint = nil;
                
                [btnShare removeConstraints:btnShare.constraints];
                [viewContentWishList addConstraint:[NSLayoutConstraint constraintWithItem:viewContentWishList attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:btnShare attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
                [viewContentWishList addConstraint:[NSLayoutConstraint constraintWithItem:viewContentWishList attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:btnShare attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
                
            } else {
                if(!_product.isDummyProduct) {
                    [_buyButton setHidden:NO];
                }
                
                
                activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
                activityIndicator.color = [UIColor lightGrayColor];
                btnWishList.hidden = btnPriceAlert.hidden = NO;
                [btnWishList setTitle:@"Wishlist" forState:UIControlStateNormal];
                btnWishList.titleLabel.font = [UIFont fontWithName:@"Gotham Book" size:12.0f];
                btnWishList.layer.cornerRadius = btnPriceAlert.layer.cornerRadius = 5;
                btnWishList.layer.masksToBounds = btnPriceAlert.layer.masksToBounds = YES;
                btnWishList.layer.borderColor = btnPriceAlert.layer.borderColor = [[UIColor colorWithRed:219/255.0f green:219/255.0f blue:219/255.0f alpha:1.0f] CGColor];
                btnWishList.layer.borderWidth = btnPriceAlert.layer.borderWidth = 1.0f;
                btnWishList.imageEdgeInsets = btnPriceAlert.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
                btnWishList.titleEdgeInsets = btnPriceAlert.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
                
                //Set background wishlist
                if([_product.result.product.product_already_wishlist isEqualToString:@"1"])
                {
                    [self setBackgroundWishlist:YES];
                    btnWishList.tag = 0;
                }
                else
                {
                    [self setBackgroundWishlist:NO];
                    btnWishList.tag = 1;
                }
                
                
                //Set background priceAlert
                [self setBackgroundPriceAlert:[_product.result.product.product_price_alert isEqualToString:@"x"]];
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
            [TPAnalytics trackProductView:_product.result.product];
            [TPLocalytics trackProductView:_product];

            _isnodata = NO;
            [_table reloadData];
            
            _table.hidden = NO;
            
            if(_product.result.shop_info.shop_status!=nil && [_product.result.shop_info.shop_status isEqualToString:@"2"]) {
                if(hasSetTokoTutup){
                    return;
                }
                
                hasSetTokoTutup = !hasSetTokoTutup;
                [self hiddenButtonBuyAndPromo];
            }
            else {
                //Check is in warehouse
                if([_product.result.product.product_status integerValue]==PRODUCT_STATE_WAREHOUSE || [_product.result.product.product_status integerValue]==PRODUCT_STATE_PENDING) {
                    [self hiddenButtonBuyAndPromo];
                }
            }
            
            if(_product.result.shop_info.shop_already_favorited == 1) {
                _favButton.tag = 17;
                [self setButtonFav];
            } else {
                _favButton.tag = 18;
                [self setButtonFav];
            }
            
            if([_userManager isMyShopWithShopId:_product.result.shop_info.shop_id]) {
                _favButton.hidden = YES;
            } else {
                _favButton.hidden = NO;
                
            }
            
            // UIView below table view (View More Product button)
            //TODO::
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
    NSArray *breadcrumbs = _product.result.breadcrumb;
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
            NSArray *breadcrumbs = _product.result.breadcrumb;
            if([breadcrumbs count] == 3) {
                [self gotToSearchWithDepartment:12];
            }
            
            break;
        }
        case 13:
        {
            // Etalase
            if(_product.result.product.product_etalase_id != nil) {
                ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
                
                container.data = @{kTKPDDETAIL_APISHOPIDKEY:_product.result.shop_info.shop_id,
                                   kTKPD_AUTHKEY:_auth?:[NSNull null],
                                   @"product_etalase_name" : _product.result.product.product_etalase,
                                   @"product_etalase_id" : _product.result.product.product_etalase_id};
                
                if([_product.result.product.product_etalase_id respondsToSelector:@selector(stringValue)]){
                    EtalaseList *initEtalase = [EtalaseList new];
                    [initEtalase setEtalase_id:[_product.result.product.product_etalase_id stringValue]];
                    [initEtalase setEtalase_name:_product.result.product.product_etalase];
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

#pragma mark - View Delegate
- (void)DetailProductOtherView:(UIView *)view withindex:(NSInteger)index
{
    SearchAWSProduct *product = _otherProductObj[index];
    if ([[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue] != [product.product_id integerValue]) {
        [_TKPDNavigator navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_image withShopName:_product.result.shop_info.shop_name];
    }
}

#pragma mark - Methods
- (void)initPopUp:(NSString *)strText withSender:(id)sender withRangeDesc:(NSRange)range
{
    UILabel *lblShow = [[UILabel alloc] init];
    CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
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
    NSString *strText = [NSString stringWithFormat:@"%@ %@", _product.result.shop_info.shop_stats.shop_reputation_score, CStringPoin];
    [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
}

- (IBAction)actionKecepatan:(id)sender
{
    [self initPopUp:_product.result.shop_info.respond_speed.speed_level withSender:sender withRangeDesc:NSMakeRange(0, 0)];
}

- (void)setBackgroundPriceAlert:(BOOL)isActive
{
    if(isActive) {
        [btnPriceAlert setImage:[UIImage imageNamed:@"icon_button_pricealert_active.png"] forState:UIControlStateNormal];
        btnPriceAlert.backgroundColor = [UIColor colorWithRed:255/255.0f green:179/255.0f blue:0 alpha:1.0f];
        [btnPriceAlert setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        [btnPriceAlert setImage:[UIImage imageNamed:@"icon_button_pricealert_nonactive.png"] forState:UIControlStateNormal];
        btnPriceAlert.backgroundColor = [UIColor whiteColor];
        [btnPriceAlert setTitleColor:[UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
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

- (void)initAttributeText:(UILabel *)lblDesc withStrText:(NSString *)strText withColor:(UIColor *)color withFont:(UIFont *)font withAlignment:(NSTextAlignment)alignment
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = alignment;
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: (color == nil) ? [UIColor whiteColor] : color,
                                 NSFontAttributeName:(font == nil)? fontDesc : font,
                                 NSParagraphStyleAttributeName: style,
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
    rectLblDesc.size.height = [self calculateHeightLabelDesc:rectLblDesc.size withText:strText withColor:[UIColor whiteColor] withFont:nil withAlignment:NSTextAlignmentLeft];
    
    lblDescription = [[LabelMenu alloc] initWithFrame:rectLblDesc];
    lblDescription.backgroundColor = [UIColor clearColor];
    [lblDescription setNumberOfLines:0];
    lblDescription.delegate = self;
    [self initAttributeText:lblDescription withStrText:strText withColor:[UIColor whiteColor] withFont:nil withAlignment:NSTextAlignmentLeft];
    lblDescription.textColor = [UIColor blackColor];
    lblDescription.userInteractionEnabled = YES;
    [lblDescription addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    [mView addSubview:lblDescription];
    
    return rectLblDesc;
}

- (void)expand:(CustomButtonExpandDesc *)sender
{
    isExpandDesc = !isExpandDesc;
    [_table reloadData];
}

- (IBAction)actionShare:(id)sender
{
    if (_product.result.product.product_url) {
        NSString *title = [NSString stringWithFormat:@"%@ - %@ | Tokopedia ",
                           _formattedProductTitle,
                           _product.result.shop_info.shop_name];
        NSURL *url = [NSURL URLWithString:_product.result.product.product_url];
        UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                          url:url
                                                                                       anchor:sender];
        
        [self presentViewController:controller animated:YES completion:^{
            [TPAnalytics trackClickEvent:@"clickPDP" category:@"Product Detail Page" label:@"Share"];
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

- (IBAction)actionPriceAlert:(id)sender
{
    if(_auth) {
        if(btnPriceAlert.backgroundColor == [UIColor whiteColor]) { //Not price alert yet
            PriceAlertViewController *priceAlertViewController = [PriceAlertViewController new];
            priceAlertViewController.productDetail = _product.result.product;
            [self.navigationController pushViewController:priceAlertViewController animated:YES];
        }
        else {
            [self setRequestingAction:btnPriceAlert isLoading:YES];
//            [tokopediaNetworkManagerPriceAlert doRequest];
            [_request requestRemoveProductPriceAlertWithProductID:_product.result.product.product_id
                                                        onSuccess:^(GeneralAction *obj) {
                                                            if([obj.data.is_success isEqualToString:@"1"]) {
                                                                StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessRemovePriceAlert] delegate:self];
                                                                [stickyAlertView show];
                                                                
                                                                _product.result.product.product_price_alert = @"0";
                                                                [self setBackgroundPriceAlert:[_product.result.product.product_price_alert isEqualToString:@"x"]];
                                                            }
                                                            [self setRequestingAction:btnPriceAlert isLoading:NO];
                                                        }
                                                        onFailure:^(NSError *error) {
                                                            [self setRequestingAction:btnPriceAlert isLoading:NO];
                                                        }];
        }
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
        redirectToPriceAlert = YES;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
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
    UIFont *productLabelFont = [UIFont fontWithName:@"GothamMedium" size:15];
    
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
    _pricelabel.text = _product.result.product.product_price;
    _countsoldlabel.text = [NSString stringWithFormat:@"%@", _product.result.statistic.product_sold_count?:@""];
    _countviewlabel.text = [NSString stringWithFormat:@"%@", _product.result.statistic.product_view_count?:@""];
    
    [_reviewbutton setTitle:[NSString stringWithFormat:@"%@ Ulasan",_product.result.statistic.product_review_count?:@""] forState:UIControlStateNormal];
    [_reviewbutton.layer setBorderWidth:1];
    [_reviewbutton.layer setBorderColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1].CGColor];
    
    [_talkaboutbutton setTitle:[NSString stringWithFormat:@"%@ Diskusi",_product.result.statistic.product_talk_count?:@""] forState:UIControlStateNormal];
    [_talkaboutbutton.layer setBorderWidth:1];
    [_talkaboutbutton.layer setBorderColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1].CGColor];
    
    _qualitynumberlabel.text = _product.result.rating.product_rating_point;
    _qualityrateview.starscount = [_product.result.rating.product_rating_star_point integerValue];
    
    _accuracynumberlabel.text = _product.result.rating.product_rate_accuracy_point;
    _accuracyrateview.starscount = [_product.result.rating.product_accuracy_star_rate integerValue];
    
    NSArray *images = _product.result.product_images;
    
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
    [_datatalk setObject:_product.result.product.product_price?:@"" forKey:API_PRODUCT_PRICE_KEY];
    [_datatalk setObject:_headerimages?:@"" forKey:kTKPDDETAILPRODUCT_APIPRODUCTIMAGESKEY];
}

-(void)setFooterViewData
{
    [_shopname setTitle:_product.result.shop_info.shop_name forState:UIControlStateNormal];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"icon_location.png"];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc]initWithAttributedString:attachmentString ];
    NSAttributedString *newAttString = [[NSAttributedString alloc] initWithString:_product.result.shop_info.shop_location?:@"" attributes:nil];
    [myString appendAttributedString:newAttString];
    _shoplocation.attributedText = myString;
    //_shoplocation.text = _product.result.shop_info.shop_location?:@"";
    
    if(_product.result.shop_info.shop_is_gold == 1) {
        _goldShop.hidden = NO;
    } else {
        _goldShop.hidden = YES;
    }
    _constraintBadgeGoldWidth.constant = (_product.result.shop_info.shop_is_gold == 1)?20:0;
    _constraintBadgeLuckySpace.constant = (_product.result.shop_info.shop_is_gold == 1)?4:0;
    
    
    UIImageView *thumb = _shopthumb;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_product.result.shop_info.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
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
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_product.result.shop_info.shop_lucky] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
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
        frame.size.height = 457;
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
    [_otherProductIndicator setHidden:NO];
    [_otherProductIndicator startAnimating];
    [tokopediaOtherProduct doRequest];
}

- (void)requestSuccessOtherProduct:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    SearchAWS *otherProduct = [result objectForKey:@""];
    
    BOOL status = [otherProduct.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        [self requestProcessOtherProduct:object];
    }
    
}

- (void)requestFailureOtherProduct:(id)error {
    [self cancel];
    if ([(NSError*)error code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
            //_table.tableFooterView = _footer;
            [_act startAnimating];
            //                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
        else
            [_act stopAnimating];
    }
    else
        [_act stopAnimating];
}

- (void)requestProcessOtherProduct:(id)object {
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            SearchAWS *otherProduct = [result objectForKey:@""];
            BOOL status = [otherProduct.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            if (status) {
                _otherProductObj = [NSArray arrayWithArray:otherProduct.data.products];
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
        tokopediaNetworkManagerWishList.tagRequest = CTagUnWishList;
        [tokopediaNetworkManagerWishList doRequest];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didRemovedProductFromWishList" object:_product.result.product.product_id];
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
    if(_auth) {
        [self setRequestingAction:btnWishList isLoading:YES];
        tokopediaNetworkManagerWishList.tagRequest = CTagWishList;
        [tokopediaNetworkManagerWishList doRequest];
        
        NSString *productId = _product.result.product.product_id?:@"";
        NSString *productName = _product.result.product.product_name?:@"";
        
        NSArray *categories = [[_data objectForKey:@"product"] breadcrumb];
        Breadcrumb *lastCategory = [categories objectAtIndex:categories.count - 1];
        NSString *productCategory = lastCategory.department_name?:@"";
        
        NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
        NSString *productPrice = [[_product.result.product.product_price componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]?:@"";
        
        NSDictionary *attributes = @{
                                     @"Product Id" : productId,
                                     @"Product Name" : productName,
                                     @"Product Price" : productPrice,
                                     @"Product Category" : productCategory
                                     };
        
        [Localytics tagEvent:@"Event : Add To Wishlist" attributes:attributes];
        
        [Localytics incrementValueBy:1
                 forProfileAttribute:@"Profile : Has Wishlist"
                           withScope:LLProfileScopeApplication];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didAddedProductToWishList" object:_product.result.product.product_id];
        
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
    
    tempShopID = shop_id;
    [tokopediaNetworkManagerFavorite doRequest];
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
    
}

- (void)cancelLoginView {
    isDoingWishList = isDoingFavorite = isNeedLogin = NO;
}

#pragma mark - Tap View
- (void)tapProductGallery {
    //    NSDictionary *data = @{
    //                           @"image_index" : @(_pageheaderimages),
    //                           @"images" : _product.result.product_images
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
    if(!_product.result.shop_info.shop_id) {
        return;
    }
    container.data = @{kTKPDDETAIL_APISHOPIDKEY:_product.result.shop_info.shop_id,
                       kTKPDDETAIL_APISHOPNAMEKEY:_product.result.shop_info.shop_name,
                       kTKPD_AUTHKEY:_auth?:[NSNull null]};
    [self.navigationController pushViewController:container animated:YES];
}

-(void)refreshRequest:(NSNotification*)notification
{
    tokopediaNetworkManager.delegate = self;
    [tokopediaNetworkManager doRequest];
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
        return ((ProductImages *) [_product.result.product_images objectAtIndex:0]).image_description;
    else if(((int)index) > _product.result.product_images.count-1)
        return ((ProductImages *) [_product.result.product_images objectAtIndex:_product.result.product_images.count-1]).image_description;
    
    return ((ProductImages *) [_product.result.product_images objectAtIndex:index]).image_description;
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
            NSString *productId = _product.result.product.product_id;
            [ProductRequest moveProductToWarehouse:productId
                     setCompletionBlockWithSuccess:^(ShopSettings *response) {
                         
                     } failure:^(NSArray *errorMessages) {
                         
                     }];
        }
    }else{
        if(buttonIndex == 1){
            EtalaseViewController *controller = [EtalaseViewController new];
            controller.delegate = self;
            controller.shopId =_product.result.shop_info.shop_id;
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
    NSString *productId = _product.result.product.product_id;
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

#pragma mark - TTTAttributeLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point
{
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if(notesDetail!=nil && notesDetail.notes_content!=nil) {
        WebViewController *webViewController = [WebViewController new];
        webViewController.strTitle = CStringSyaratDanKetentuan;
        webViewController.strContentHTML = [NSString stringWithFormat:@"<font face='Gotham Book' size='2'>%@</font>", notesDetail.notes_content];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
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
    [UIPasteboard generalPasteboard].string = lblDescription.text;
}

#pragma mark - Other Method

- (void)configureGTM {
    //    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _detailProductBaseUrl = [_gtmContainer stringForKey:GTMKeyProductBase];
    _detailProductPostUrl = [_gtmContainer stringForKey:GTMKeyProductPost];
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
        self.userActivity = [TPSpotlight productDetailActivity:_product.result];
    }
}

#pragma mark - Push other product

- (void)didSelectOtherProduct:(SearchAWSProduct *)product {
    [TPAnalytics trackProductClick:product];
    NavigateViewController *navigateController = [NavigateViewController new];
    [navigateController navigateToProductFromViewController:self
                                                   withName:product.product_name
                                                  withPrice:product.product_price
                                                     withId:product.product_id
                                               withImageurl:product.product_image
                                               withShopName:product.shop_name];
}

@end