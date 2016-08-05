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
#import "SwipeView.h"
#import "CarouselDataSource.h"
#import "WebViewController.h"
#import "CategoryDataSource.h"
#import "Tokopedia-Swift.h"

NSInteger const bannerHeight = 115;

@interface CategoryViewController () <NotificationManagerDelegate, iCarouselDelegate, SwipeViewDelegate> {
    NotificationManager *_notifManager;
    
    NSArray<Slide*>* _banner;
    UIActivityIndicatorView *loadIndicator;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) iCarousel *slider;
@property (nonatomic, strong) SwipeView *digitalGoodsSwipeView;
@property (nonatomic, strong) UIImageView *bannerView;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) CarouselDataSource *carouselDataSource;
@property (nonatomic, strong) DigitalGoodsDataSource *digitalGoodsDataSource;
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
    
    //set change orientation
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];

    
    loadIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    [_collectionView addSubview:loadIndicator];
    
    [loadIndicator bringSubviewToFront:self.view];
    [loadIndicator startAnimating];
    
    _categoryDataSource = [[CategoryDataSource alloc]init];
    [_categoryDataSource setDelegate:self];
    
    [_collectionView setDataSource:_categoryDataSource];
    [_collectionView setDelegate:_categoryDataSource];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, IS_IPAD ? 340 : 290);
    [_collectionView setCollectionViewLayout:flowLayout];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initNotificationManager) name:@"reloadNotification" object:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"CategoryViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"CategoryViewCellIdentifier"];
    
    NSTimer* timer = [NSTimer timerWithTimeInterval:5.0f target:self selector:@selector(moveToNextSlider) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
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


#pragma mark - Request Banner 
- (void)loadBanners {
    TKPHomeBannerStore *bannersStore = [[[[self class] TKP_rootController] storeManager] homeBannerStore];
    __weak typeof(self) wself = self;
    //prevent double slider


    NSInteger sliderHeight = IS_IPAD ? 225 : 175;
    UIColor* backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    [bannersStore fetchBannerWithCompletion:^(NSArray<Slide*>* banner, NSError *error) {
        if (wself != nil) {
            [_slider removeFromSuperview];
            [loadIndicator stopAnimating];
            
            _banner = banner;
            _slider = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, sliderHeight)];
            _slider.backgroundColor = backgroundColor;
            _carouselDataSource = [[CarouselDataSource alloc] initWithBanner:banner];
            _carouselDataSource.delegate = self;

            _slider.type = iCarouselTypeLinear;
            _slider.dataSource = _carouselDataSource;
            _slider.delegate = _carouselDataSource;
            _slider.decelerationRate = 0.5;

            [_collectionView addSubview:_slider];
            [_collectionView bringSubviewToFront:_slider];
        }
    }];
    
    [bannersStore fetchMiniSlideWithCompletion:^(NSArray<MiniSlide*>*slide, NSError* error) {
        if(wself != nil) {
            [_digitalGoodsSwipeView removeFromSuperview];
            
            _digitalGoodsSwipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, sliderHeight, [UIScreen mainScreen].bounds.size.width, 120)];
            _digitalGoodsSwipeView.backgroundColor = backgroundColor;
            _digitalGoodsDataSource = [[DigitalGoodsDataSource alloc] initWithGoods:slide swipeView:_digitalGoodsSwipeView];
            
            _digitalGoodsSwipeView.dataSource = _digitalGoodsDataSource;
            _digitalGoodsSwipeView.delegate = self;
            _digitalGoodsSwipeView.clipsToBounds = YES;
            _digitalGoodsSwipeView.truncateFinalPage = YES;
            _digitalGoodsSwipeView.decelerationRate = 0.5;
            if(IS_IPAD) {
                _digitalGoodsSwipeView.alignment = SwipeViewAlignmentCenter;
                _digitalGoodsSwipeView.isCenteredChild = YES;
            }


            [_collectionView addSubview:_digitalGoodsSwipeView];
        }
    }];
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index {
//    MiniSlide *good = [_digitalGoodsDataSource goodsAtIndex:index];
//    WebViewController *webview = [[WebViewController alloc] init];
//    webview.strTitle = @"Tokopedia";
//    webview.strURL = good.redirect_url;
    
//    [self.navigationController pushViewController:webview animated:YES];
    PulsaViewController *controller = [[PulsaViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)moveToNextSlider {
    [_slider scrollToItemAtIndex:_slider.currentItemIndex+1 duration:1.0];
}



@end
