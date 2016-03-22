//
//  ContainerViewController.m
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//
#import "CMPopTipView.h"
#import "DetailProductViewController.h"
#import "LoginViewController.h"
#import "ShopPageHeader.h"
#import "ShopContainerViewController.h"
#import "ShopTalkPageViewController.h"
#import "ShopProductPageViewController.h"
#import "ShopReviewPageViewController.h"
#import "ShopNotesPageViewController.h"
#import "ShopInfoViewController.h"
#import "SendMessageViewController.h"
#import "ShopSettingViewController.h"
#import "ShopBadgeLevel.h"
#import "ReputationDetail.h"
#import "ResponseSpeed.h"
#import "Rating.h"
#import "TTTAttributedLabel.h"
#import "ProductAddEditViewController.h"

#import "URLCacheController.h"

#import "sortfiltershare.h"
#import "detail.h"
#import "string_product.h"

#import "ShopBadgeLevel.h"
#import "FavoriteShopAction.h"
#import "UserAuthentificationManager.h"
#import "PromoRequest.h"


@interface ShopContainerViewController () <UIScrollViewDelegate, LoginViewDelegate, UIPageViewControllerDelegate, CMPopTipViewDelegate> {
    BOOL _isNoData, isDoingFavorite, isDoingMessage;
    BOOL _isRefreshView;
    
    NSInteger _requestCount;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    
    NSInteger _requestFavoriteCount;
    
    __weak RKObjectManager *_objectFavoriteManager;
    __weak RKManagedObjectRequestOperation *_requestFavorite;
    NSOperationQueue *_operationFavoriteQueue;
    NSTimer *_timerFavorite;
    
    NSString *_cachePath;
    URLCacheController *_cacheController;
    URLCacheConnection *_cacheConnection;
    NSTimeInterval _timeInterval;
    
    CMPopTipView *cmPopTitpView;
    NSDictionary *_auth;
    UIBarButtonItem *_favoriteBarButton;
    UIBarButtonItem *_unfavoriteBarButton;
    UIBarButtonItem *_infoBarButton;
    UIBarButtonItem *_addProductBarButton;
    UIBarButtonItem *_settingBarButton;
    UIBarButtonItem *_messageBarButton;
    UserAuthentificationManager *_userManager;
    
    UIBarButtonItem *_fixedSpace;
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
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)initBarButton {
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    barButtonItem.tag = 1;
    [self.navigationItem setBackBarButtonItem:barButtonItem];
    
    _infoBarButton = [self createBarButton:CGRectMake(0,0,22,22) withImage:[UIImage imageNamed:@"icon_shop_info@2x.png"] withAction:@selector(infoTap:)];
    _addProductBarButton = [self createBarButton:CGRectMake(22,0,22,22) withImage:[UIImage imageNamed:@"icon_shop_addproduct@2x.png"] withAction:@selector(addProductTap:)];
    _settingBarButton = [self createBarButton:CGRectMake(44,0,22,22) withImage:[UIImage imageNamed:@"icon_shop_setting@2x.png"] withAction:@selector(settingTap:)];
    
    _messageBarButton = [self createBarButton:CGRectMake(22,0,22,22) withImage:[UIImage imageNamed:@"icon_shop_message@2x.png"] withAction:@selector(messageTap:)];

    _favoriteBarButton = [self createBarButton:CGRectMake(44,0,22,22) withImage:[UIImage imageNamed:@"icon_love_active@2x.png"] withAction:@selector(favoriteTap:)];

    _unfavoriteBarButton = [self createBarButton:CGRectMake(44,0,22,22) withImage:[UIImage imageNamed:@"icon_love_white@2x.png"] withAction:@selector(unfavoriteTap:)];
    _fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    _fixedSpace.width = 15;
    
    _unfavoriteBarButton.enabled = NO;
    _favoriteBarButton.enabled = NO;
    _messageBarButton.enabled = NO;
    _settingBarButton.enabled = NO;
    _addProductBarButton.enabled = NO;
    _infoBarButton.enabled = NO;
}

- (UIBarButtonItem*)createBarButton:(CGRect)frame withImage:(UIImage*)image withAction:(SEL)action {
    UIImageView *infoImageView = [[UIImageView alloc] initWithImage:image];
    infoImageView.frame = frame;
    infoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [infoImageView addGestureRecognizer:tapGesture];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoImageView];
    
    return infoBarButton;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    [_blurController removeNavigationImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNotificationCenter];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];

    // Do any additional setup after loading the view from its nib.
    
    _isNoData = YES;
    _isRefreshView = NO;
    _requestCount = 0;
    
    _operationQueue = [NSOperationQueue new];
    _operationFavoriteQueue = [NSOperationQueue new];
    
    _cacheController = [URLCacheController new];
    _cacheController.URLCacheInterval = 86400.0;
    _cacheConnection = [URLCacheConnection new];
    
    _userManager = [UserAuthentificationManager new];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initBarButton];
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
    
    [nc addObserver:self selector:@selector(showNavigationShopTitle:) name:@"showNavigationShopTitle" object:nil];
    [nc addObserver:self selector:@selector(hideNavigationShopTitle:) name:@"hideNavigationShopTitle" object:nil];
    [nc addObserver:self selector:@selector(reloadShop) name:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout:) name:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION object:nil];

}

- (void)updateHeaderShopPage
{
    [_shopNotesViewController.shopPageHeader setHeaderShopPage:_shop];
    [_shopProductViewController.shopPageHeader setHeaderShopPage:_shop];
    [_shopReviewViewController.shopPageHeader setHeaderShopPage:_shop];
    [_shopTalkViewController.shopPageHeader setHeaderShopPage:_shop];
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
    
    RKObjectMapping *ownerReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [ownerReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                            CNoReputation,
                                                            CNegative,
                                                            CPositif,
                                                            CNeutral]];
    
    
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
                                                          API_IS_OWNER_SHOP_KEY:API_IS_OWNER_SHOP_KEY,
                                                          @"shop_has_terms" : @"shop_has_terms",
                                                          @"lucky_merchant" : @"lucky_merchant",
                                                          @"shop_lucky" : @"shop_lucky"
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
                                                           kTKPDSHOP_APISHOPTOTALSOLDKEY:kTKPDSHOP_APISHOPTOTALSOLDKEY,
                                                           CTxCount:CTxCount,
                                                           CHideRate:CHideRate,
                                                           CTxCountSuccess:CTxCountSuccess,
                                                           CRateFailure:CRateFailure,
                                                           CShopTotalTransactionCancel:CShopTotalTransactionCancel,
                                                           CShopReputationScore:CShopReputationScore,
                                                           CRateSuccess:CRateSuccess
                                                           }];
    
    RKObjectMapping *shopTransactionTxMapping = [RKObjectMapping mappingForClass:[ShopTransactionStats class]];
    [shopTransactionTxMapping addAttributeMappingsFromDictionary:@{
                                                                   @"shop_tx_has_transaction_3_month":@"shop_tx_has_transaction_3_month",
                                                                   @"shop_tx_success_rate_1_month":@"shop_tx_success_rate_1_month",
                                                                   @"shop_tx_show_percentage_3_month":@"shop_tx_show_percentage_3_month",
                                                                   @"shop_tx_has_transaction":@"shop_tx_has_transaction",
                                                                   @"shop_tx_success_3_month_fmt":@"shop_tx_success_3_month_fmt",
                                                                   @"shop_tx_show_percentage_1_month":@"shop_tx_show_percentage_1_month",
                                                                   @"shop_tx_success_1_year_fmt":@"shop_tx_success_1_year_fmt",
                                                                   @"shop_tx_has_transaction_1_month":@"shop_tx_has_transaction_1_month",
                                                                   @"shop_tx_success_rate_1_year":@"shop_tx_success_rate_1_year",
                                                                   @"shop_tx_has_transaction_1_year":@"shop_tx_has_transaction_1_year",
                                                                   @"shop_tx_success_1_month_fmt":@"shop_tx_success_1_month_fmt",
                                                                   @"shop_tx_show_percentage_1_year":@"shop_tx_show_percentage_1_year",
                                                                   @"shop_tx_success_rate_3_month":@"shop_tx_success_rate_3_month"

                                                                   }];
    
    RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
    [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
    
    
    RKObjectMapping *countScoreMapping = [RKObjectMapping mappingForClass:[CountRatingResult class]];
    [countScoreMapping addAttributeMappingsFromDictionary:@{CCountScoreBad:CCountScoreBad,
                                                            CCountScoreGood:CCountScoreGood,
                                                            CCountScoreNeutral:CCountScoreNeutral}];
    
    RKObjectMapping *ratingMapping = [RKObjectMapping mappingForClass:[Rating class]];
    RKObjectMapping *qualityMapping = [RKObjectMapping mappingForClass:[Quality class]];
    [qualityMapping addAttributeMappingsFromDictionary:@{CRatingStar:CRatingStar,
                                                         CAverage:CAverage,
                                                         COneStarRank:COneStarRank,
                                                         CCountTotal:CCountTotal,
                                                         CFourStarRank:CFourStarRank,
                                                         CFiveStarRank:CFiveStarRank,
                                                         CTwoStarRank:CTwoStarRank,
                                                         CThreeStarRank:CThreeStarRank}];

    
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
                                                    kTKPDSHOP_APIPROVINCEIDKEY,
                                                    kTKPDSHOP_APICITYNAMEKEY,
                                                    kTKPDSHOP_APIPROVINCENAMEKEY,
                                                    kTKPDSHOP_APIDISTRICTNAMEKEY,
                                                    kTKPDSHOP_APIADDRESSKEY
                                                    ]];
    
//    RKObjectMapping *responseSpeedMapping = [RKObjectMapping mappingForClass:[ResponseSpeed class]];
//    [responseSpeedMapping addAttributeMappingsFromDictionary:@{COneDay:COneDay,
//                                                                     CTwoDay:CTwoDay,
//                                                                     CThreeDay:CThreeDay,
//                                                                     CSpeedLevel:CSpeedLevel,
//                                                                     CBadge:CBadge,
//                                                                     CCountTotal:CCountTotal}];
    
    // Relationship Mapping
    [ownerMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:COwnerReputation toKeyPath:COwnerReputation withMapping:ownerReputationMapping]];
    [ratingMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CQuality toKeyPath:CQuality withMapping:qualityMapping]];
    [ratingMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CAccuracy toKeyPath:CAccuracy withMapping:qualityMapping]];
    [shopstatsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopLastOneMonth toKeyPath:CShopLastOneMonth withMapping:countScoreMapping]];
    [shopstatsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopLastSixMonth toKeyPath:CShopLastSixMonth withMapping:countScoreMapping]];
    [shopstatsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopLastTwelveMonth toKeyPath:CShopLastTwelveMonth withMapping:countScoreMapping]];
    [shopstatsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopBadgeLevel toKeyPath:CShopBadgeLevel withMapping:shopBadgeMapping]];
    
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
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_tx_stats"
                                                                                  toKeyPath:@"shop_tx_stats"
                                                                                withMapping:shopTransactionTxMapping]];
//    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CResponseSpeed toKeyPath:CResponseSpeed withMapping:responseSpeedMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CRatings toKeyPath:CRatings withMapping:ratingMapping]];
    
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
                            kTKPDDETAIL_APISHOPIDKEY : @([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue]),
                            @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@""
                            };
    
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
                if ([_userManager isMyShopWithShopId:[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]]) {
                    self.navigationItem.rightBarButtonItems = @[_settingBarButton,_fixedSpace, _addProductBarButton,_fixedSpace, _infoBarButton];
                    _addProductBarButton.enabled = YES;
                    _settingBarButton.enabled = YES;
                } else {
                    if(_shop.result.info.shop_already_favorited == 1) {
                        self.navigationItem.rightBarButtonItems = @[_favoriteBarButton,_fixedSpace, _messageBarButton,_fixedSpace, _infoBarButton];
                        _favoriteBarButton.enabled = YES;
                        _unfavoriteBarButton.enabled = YES;
                        _messageBarButton.enabled = YES;
                        
                        if(isDoingFavorite) {
                            isDoingFavorite = !isDoingFavorite;
                        
                            [self favoriteTap:nil];
                        }
                        else if(isDoingMessage) {
                            isDoingMessage = !isDoingMessage;
                            [self messageTap:nil];
                        }
                    } else {
                        self.navigationItem.rightBarButtonItems = @[_unfavoriteBarButton,_fixedSpace, _messageBarButton, _fixedSpace, _infoBarButton];
                        _messageBarButton.enabled = YES;
                        _unfavoriteBarButton.enabled = YES;
                        _favoriteBarButton.enabled = YES;
                        
                        if(isDoingFavorite) {
                            isDoingFavorite = !isDoingFavorite;
                            [self unfavoriteTap:nil];
                        }
                        else if(isDoingMessage) {
                            isDoingMessage = !isDoingMessage;
                            [self messageTap:nil];
                        }
                    }
                }
                

                _infoBarButton.enabled = YES;
                
                TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
                [secureStorage setKeychainWithValue:_shop.result.info.shop_has_terms?:@"" withKey:@"shop_has_terms"];
                [[NSNotificationCenter defaultCenter] postNotificationName:DID_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME object:nil userInfo:nil];
                _isNoData = NO;
                [self updateHeaderShopPage];
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestCount);
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

#pragma mark - Notification Action

- (void)checkIsLogin {
    if(_auth) {
        
    }
}
- (void)showNavigationShopTitle:(NSNotification *)notification
{
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.title = _shop.result.info.shop_name;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)hideNavigationShopTitle:(NSNotification *)notification
{
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.title = @"";
    } completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - CMPopTipView Delegate
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - Method
- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc {
    lblDesc.backgroundColor = [UIColor clearColor];
    lblDesc.textAlignment = NSTextAlignmentLeft;
    lblDesc.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    lblDesc.textColor = [UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f];
    lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
    lblDesc.numberOfLines = 0;
}

- (void)dismissAllPopTipViews
{
    [cmPopTitpView dismissAnimated:YES];
    cmPopTitpView = nil;
}

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
    
    UIButton *button = (UIButton *)sender;
    [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
}


- (void)showPopUp:(NSString *)strText withSender:(id)sender {
    [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-4, 4)];
}

- (UIViewController *)getActiveViewController {
    return [_pageController.viewControllers lastObject];
}

- (void)setFavoriteRightButtonItem
{
    StickyAlertView *stickyAlertView;
    if([self.navigationItem.rightBarButtonItems firstObject] == _favoriteBarButton) {
        self.navigationItem.rightBarButtonItems = @[_unfavoriteBarButton, _fixedSpace, _messageBarButton, _fixedSpace, _infoBarButton];
        stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessUnFavoriteShop] delegate:self];
    }
    else {
        self.navigationItem.rightBarButtonItems = @[_favoriteBarButton,_fixedSpace, _messageBarButton,_fixedSpace, _infoBarButton];
        stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessFavoriteShop] delegate:self];
    }
    
    [stickyAlertView show];
}


#pragma mark - Tap Action
- (IBAction)infoTap:(id)sender {
    if (_shop) {
        ShopInfoViewController *vc = [[ShopInfoViewController alloc] init];
        vc.data = @{kTKPDDETAIL_DATAINFOSHOPSKEY : _shop,
                    kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY] && [_data objectForKey:kTKPD_AUTHKEY]!=[NSNull null]?[_data objectForKey:kTKPD_AUTHKEY]:@{}};
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)messageTap:(id)sender {
    if([_userManager isLogin]) {
        SendMessageViewController *messageController = [SendMessageViewController new];
        messageController.data = @{
                                   kTKPDDETAIL_APISHOPIDKEY:@([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                                   kTKPDDETAIL_APISHOPNAMEKEY:_shop.result.info.shop_name
                                   };
        [self.navigationController pushViewController:messageController animated:YES];
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
        isDoingMessage = YES;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

//this function called when user tap RED HEART button, with intention to UNFAVORITE a shop
- (IBAction)favoriteTap:(id)sender {
    if(_requestFavorite.isExecuting) return;
    
    if([_userManager isLogin]) {
        _requestFavoriteCount = 0;
        [self configureFavoriteRestkit];
        [self favoriteShop:_shop.result.info.shop_id];

    }
}

//this function called when user tap WHITE HEART button, with intention to FAVORITE a shop
- (IBAction)unfavoriteTap:(id)sender {
    if(_requestFavorite.isExecuting) return;
    
    if([_userManager isLogin]) {
        _requestFavoriteCount = 0;
        [self configureFavoriteRestkit];
        [self favoriteShop:_shop.result.info.shop_id];
    }else {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
        navigationController.navigationBar.translucent = NO;
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        
        LoginViewController *controller = [LoginViewController new];
        controller.delegate = self;
        controller.isPresentedViewController = YES;
        controller.redirectViewController = self;
        navigationController.viewControllers = @[controller];
        isDoingFavorite = YES;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (IBAction)settingTap:(id)sender {
    if (_shop) {
        ShopSettingViewController *settingController = [ShopSettingViewController new];
        settingController.data = @{
                                   kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                   kTKPDDETAIL_DATAINFOSHOPSKEY:_shop.result
                                   };
        [self.navigationController pushViewController:settingController animated:YES];
    }
}

- (IBAction)addProductTap:(id)sender {
    ProductAddEditViewController *productViewController = [ProductAddEditViewController new];
    productViewController.data = @{
                                   kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                   DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(TYPE_ADD_EDIT_PRODUCT_ADD),
                                   };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:productViewController];
    nav.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)tap:(id)sender {
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case 1:
            {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 2:
            {
                if (_shop) {
                    ShopInfoViewController *vc = [[ShopInfoViewController alloc] init];
                    vc.data = @{kTKPDDETAIL_DATAINFOSHOPSKEY : _shop,
                                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            }
            default:
                break;
        }
    }
    
    if ([sender isKindOfClass: [UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        
        switch (btn.tag) {
            case 10:
            {
                [_pageController setViewControllers:@[_shopTalkViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self updateHeaderShopPage];
                break;
            }
            case 11:
            {
                [_pageController setViewControllers:@[_shopReviewViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self updateHeaderShopPage];
                break;
            }
            case 12:
            {
                
                [_pageController setViewControllers:@[_shopNotesViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self updateHeaderShopPage];
                break;
            }
                
            case 13:
            {
                
                [_pageController setViewControllers:@[_shopProductViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self updateHeaderShopPage];
                break;
            }
            default:
                break;
        }
    }
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
    if (_requestFavorite.isExecuting) return;
    
    _requestFavoriteCount ++;
    
    
    
    NSString* adKey = @"";
    if([_data objectForKey:PromoRefKey]){
        adKey = [_data objectForKey:PromoRefKey];
    }
    
    NSDictionary *param = @{kTKPDDETAIL_ACTIONKEY   :   @"fav_shop",
                            @"ad_key"               :   adKey,
                            @"shop_id"              :   shop_id};
    
    _requestFavorite = [_objectFavoriteManager appropriateObjectRequestOperationWithObject:self
                                                                                    method:RKRequestMethodPOST
                                                                                      path:@"action/favorite-shop.pl"
                                                                                parameters:[param encrypt]];
    
    [_requestFavorite setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestFavoriteResult:mappingResult withOperation:operation];
        [_timer invalidate];
        _timer = nil;
        [self setFavoriteRightButtonItem];
        NSArray *tempArr = self.navigationController.viewControllers;
        if([[tempArr objectAtIndex:tempArr.count-2] isMemberOfClass:[DetailProductViewController class]]) {
            [((DetailProductViewController *) [tempArr objectAtIndex:tempArr.count-2]) setButtonFav];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavoriteShop" object:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFavoriteError:error];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationFavoriteQueue addOperation:_requestFavorite];
    
    _timerFavorite = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(requestTimeout)
                                                    userInfo:nil
                                                     repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timerFavorite forMode:NSRunLoopCommonModes];
}

-(void)requestFavoriteResult:(id)mappingResult withOperation:(NSOperation *)operation {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyFav" object:nil];
}

-(void)requestFavoriteError:(id)object {
    
}

#pragma mark - LoginView Delegate
- (void)redirectViewController:(id)viewController
{
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *tempAuth = [secureStorage keychainDictionary];
    _auth = [tempAuth mutableCopy];
    
    [self configureRestKit];
    [self request];
}

#pragma mark - Reload Shop
- (void)reloadShop {
    [self configureRestKit];
    [self request];
}

#pragma mark - Notification Center Action

#pragma mark - Notification Delegate
- (void)userDidLogin:(NSNotification*)notification {
    _userManager = [UserAuthentificationManager new];
}

- (void)userDidLogout:(NSNotification*)notification {
    _userManager = [UserAuthentificationManager new];
}

@end