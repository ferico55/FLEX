//
//  CategoryViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "category.h"
#import "search.h"
#import "DBManager.h"
#import "CategoryViewController.h"
#import "CategoryViewCell.h"
#import "TKPDTabNavigationController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"
#import "NotificationManager.h"

#import "Localytics.h"
#import "UIViewController+TKPAdditions.h"
#import "TKPHomeBannerStore.h"
#import "TKPStoreManager.h"
#import "iCarousel.h"
#import "CarouselDataSource.h"
#import "WebViewController.h"
#import "CategoryDataSource.h"

NSInteger const bannerHeight = 115;

@interface CategoryViewController () <NotificationManagerDelegate, iCarouselDelegate> {
    NSMutableArray *_category;
    NotificationManager *_notifManager;
    NSURL *_deeplinkUrl;
    
    Banner *_banner;
    UIActivityIndicatorView *loadIndicator;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) iCarousel *slider;
@property (nonatomic, strong) UIImageView *bannerView;
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
    
    /** Initialization variable **/
//    _category = [NSMutableArray new];
    
    [_collectionView setContentSize:CGSizeMake(_collectionView.frame.size.width , _collectionView.frame.size.height)];
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, ([[UIScreen mainScreen]bounds].size.height) )];
    
    loadIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    [loadIndicator setBackgroundColor:[UIColor redColor]];
    [_collectionView addSubview:loadIndicator];
    
    [loadIndicator bringSubviewToFront:self.view];
    [loadIndicator startAnimating];
    
    _categoryDataSource = [[CategoryDataSource alloc]init];
    [_collectionView setDataSource:_categoryDataSource];
    
    /** Set title and icon for category **/
//    NSArray *titles = kTKPDCATEGORY_TITLEARRAY;
//    NSArray *dataids = kTKPDCATEGORY_IDARRAY;
//    
//    for (int i = 0; i < 22; i++) {
//        NSString * imagename = [NSString stringWithFormat:@"icon_%zd",i];
//        [_category addObject:@{kTKPDCATEGORY_DATATITLEKEY : titles[i], kTKPDCATEGORY_DATADIDKEY : dataids[i],kTKPDCATEGORY_DATAICONKEY:imagename}];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification) name:@"reloadNotification" object:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"CategoryViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"CategoryViewCellIdentifier"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.tabBarController.title = @"Kategori";

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Collection
//- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return _category.count;
//
//}
//
//- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *cellid = @"CategoryViewCellIdentifier";
//    CategoryViewCell *cell = (CategoryViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
//    
//    NSString *title =[_category[indexPath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY];
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
//    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragrahStyle setLineSpacing:6];
//    [paragrahStyle setAlignment:NSTextAlignmentCenter];
//    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [title length])];
//    
//    cell.categoryLabel.attributedText = attributedString;
//    
//    NSString *icon = [_category[indexPath.row] objectForKey:kTKPDCATEGORY_DATAICONKEY];
//    cell.icon.image = [UIImage imageNamed:icon];
//    
//    cell.backgroundColor = [UIColor whiteColor];
//    
//	return cell;
//}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGSize cellSize = CGSizeMake(0, 0);
    
    NSInteger cellCount;
    float heightRatio;
    float widhtRatio;
    float inset;
    
    cellCount = 3;
    heightRatio = 128;
    widhtRatio = 106;
    inset = 1;
    
    CGFloat cellWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        screenWidth = screenRect.size.width/2;
        cellWidth = screenWidth/cellCount-inset;
    } else {
        screenWidth = screenRect.size.width;
        cellWidth = screenWidth/cellCount-inset;
    }
    
    cellSize = CGSizeMake(cellWidth, cellWidth*heightRatio/widhtRatio);
    return cellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index =  indexPath.row;
    NSString *title = [_category[index] objectForKey:kTKPDCATEGORY_DATATITLEKEY];
    NSString *id = [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"";
    
    [Localytics tagEvent:@"Event : Clicked Category" attributes:@{@"Category Name" : title}];

    SearchResultViewController *vc = [SearchResultViewController new];
	vc.hidesBottomBarWhenPushed = YES;
    vc.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : id,
               kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : title,
               kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
    
    SearchResultViewController *vc1 = [SearchResultViewController new];
	vc1.hidesBottomBarWhenPushed = YES;
    vc1.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : id,
                kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : title,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
    
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
	vc2.hidesBottomBarWhenPushed = YES;
    vc2.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : id,
                kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : title,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
    
    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
    NSDictionary *data = @{
        kTKPDCATEGORY_DATATYPEKEY : @(kTKPDCATEGORY_DATATYPECATEGORYKEY),
        kTKPDSEARCH_APIDEPARTMENTIDKEY : id
    };
    [viewController setData:data];
    [viewController setNavigationTitle:title];
    [viewController setSelectedIndex:0];
    [viewController setViewControllers:viewcontrollers];
    viewController.hidesBottomBarWhenPushed = YES;
    [viewController setNavigationTitle:[_category[index] objectForKey:@"title"]?:@""];
    
    [self.navigationController pushViewController:viewController animated:YES];
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
            
            BOOL bannerExists = ![_banner.result.ticker.img_uri isEqualToString:@""];
            
            if(bannerExists) {
                [self setBanner:_banner.result.ticker.img_uri];
                sliderHeight += bannerHeight;
            }

            _slider = [[iCarousel alloc] initWithFrame:CGRectMake(0, -sliderHeight, [UIScreen mainScreen].bounds.size.width, sliderHeight)];
            _carouselDataSource = [[CarouselDataSource alloc] initWithBanner:banner.result.banner];
            _carouselDataSource.delegate = self;

            _slider.type = iCarouselTypeLinear;
            _slider.dataSource = _carouselDataSource;
            _slider.delegate = _carouselDataSource;
            _slider.decelerationRate = 0.5;
            if (bannerExists) _slider.contentOffset = CGSizeMake(0, -(bannerHeight/2));
            _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

            [_collectionView addSubview:_slider];
            [_collectionView bringSubviewToFront:_slider];
            [_collectionView setContentInset:UIEdgeInsetsMake(sliderHeight, 0, 0, 0)];
            [_collectionView setContentOffset:CGPointMake(0, -sliderHeight)];
        }
    }];
}

- (void)setBanner:(NSString*)bannerURL {
    if(_bannerView) {
        [_bannerView removeFromSuperview];
    }
    _bannerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -bannerHeight, [UIScreen mainScreen].bounds.size.width, bannerHeight)];
    [_bannerView setImageWithURL:[NSURL URLWithString:bannerURL] placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    [_bannerView setContentMode:UIViewContentModeScaleAspectFit];
    
    UITapGestureRecognizer *tapBanner = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBanner)];
    [_bannerView addGestureRecognizer:tapBanner];
    [_bannerView setUserInteractionEnabled:YES];
    
    [_collectionView addSubview:_bannerView];
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
