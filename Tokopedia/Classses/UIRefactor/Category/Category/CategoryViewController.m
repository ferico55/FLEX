//
//  CategoryViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CategoryViewController.h"
#import "CategoryViewCell.h"
#import "NotificationManager.h"

#import "UIViewController+TKPAdditions.h"
#import "TKPHomeBannerStore.h"
#import "TKPStoreManager.h"
#import "iCarousel.h"
#import "CarouselDataSource.h"
#import "WebViewController.h"
#import "CategoryDataSource.h"

NSInteger const bannerHeight = 115;

@interface CategoryViewController () <NotificationManagerDelegate, iCarouselDelegate> {
    NotificationManager *_notifManager;
    
    Banner *_banner;
    UIActivityIndicatorView *loadIndicator;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) iCarousel *slider;
@property (nonatomic, strong) UIImageView *bannerView;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) CarouselDataSource *carouselDataSource;
@property (nonatomic, strong) CategoryDataSource *categoryDataSource;


@end

@implementation CategoryViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"CategoryViewController" bundle:nibBundleOrNil];
    if (self) {
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_collectionView setContentSize:self.view.bounds.size];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];

    
    loadIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    [_collectionView addSubview:loadIndicator];
    
    [loadIndicator bringSubviewToFront:self.view];
    [loadIndicator startAnimating];
    
    _categoryDataSource = [[CategoryDataSource alloc]init];
    [_categoryDataSource setDelegate:self];
    
    [_collectionView setDataSource:_categoryDataSource];
    [_collectionView setDelegate:_categoryDataSource];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 175);
    [_collectionView setCollectionViewLayout:flowLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification) name:@"reloadNotification" object:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"CategoryViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"CategoryViewCellIdentifier"];
    
}

- (void)orientationChanged:(NSNotification *)note {
    [_collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.tabBarController.title = @"Kategori";

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self initNotificationManager];
    [self loadBanners];
    
    self.screenName = @"Top Category";
    [TPAnalytics trackScreenName:@"Top Category"];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    TKPHomeBannerStore *bannersStore = [[[[self class] TKP_rootController] storeManager] homeBannerStore];
    [bannersStore stopBannerRequest];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Manager
- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    _notifManager.delegate = self;
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}

#pragma mark - Notification delegate
- (void)reloadNotification{
    [self initNotificationManager];
}

- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController {
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - Request Banner 
- (void)loadBanners {
    TKPHomeBannerStore *bannersStore = [[[[self class] TKP_rootController] storeManager] homeBannerStore];
    __weak typeof(self) wself = self;
    
    [bannersStore fetchBannerWithCompletion:^(Banner *banner, NSError *error) {
        if (wself != nil) {
            [loadIndicator stopAnimating];
            
            NSInteger sliderHeight = 175;
            _banner = banner;
            //prevent double slider
            if(_slider) {
                [_slider removeFromSuperview];                
            }
            
            //remove banner if ipad
//            BOOL bannerExists = ![_banner.result.ticker.img_uri isEqualToString:@""] && !IS_IPAD;
            BOOL bannerExists = false;
            
            if(bannerExists) {
                [self setBanner:_banner.result.ticker.img_uri];
                sliderHeight += bannerHeight;
            }
            _slider = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, sliderHeight)];
            _carouselDataSource = [[CarouselDataSource alloc] initWithBanner:banner.result.banner];
            _carouselDataSource.delegate = self;

            _slider.type = iCarouselTypeLinear;
            _slider.dataSource = _carouselDataSource;
            _slider.delegate = _carouselDataSource;
            _slider.decelerationRate = 0.5;
//            if (bannerExists) _slider.contentOffset = CGSizeMake(0, -(bannerHeight/2));


            [self.collectionView addSubview:_slider];
            [_collectionView bringSubviewToFront:_slider];

        }
    }];
}

- (void)setBanner:(NSString*)bannerURL {
    if(_bannerView) {
        [_bannerView removeFromSuperview];
    }
    _bannerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -bannerHeight, [UIScreen mainScreen].bounds.size.width, bannerHeight)];
    [_bannerView setBackgroundColor:[UIColor whiteColor]];
    [_bannerView setImageWithURL:[NSURL URLWithString:bannerURL] placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    [_bannerView setContentMode:UIViewContentModeScaleAspectFit];
    
    UITapGestureRecognizer *tapBanner = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBanner)];
    [_bannerView addGestureRecognizer:tapBanner];
    [_bannerView setUserInteractionEnabled:YES];
    
    [self.collectionView addSubview:_bannerView];
}

- (void)didTapBanner {
    if(_banner) {
        WebViewController *webView = [[WebViewController alloc] init];
        webView.strTitle = @"Promo";
        webView.strURL = _banner.result.ticker.url;
        
        [self.navigationController pushViewController:webView animated:YES];
    }
}


@end
