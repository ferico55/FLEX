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
#import "DeeplinkController.h"


@interface CategoryViewController ()
<
    NotificationManagerDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate
>
{
    NSMutableArray *_category;
    NotificationManager *_notifManager;
    NSURL *_deeplinkUrl;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *cellView;


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
    _category = [NSMutableArray new];
    
    /** Set title and icon for category **/
    NSArray *titles = kTKPDCATEGORY_TITLEARRAY;
    NSArray *dataids = kTKPDCATEGORY_IDARRAY;
    
    for (int i = 0; i<22; i++) {
        NSString * imagename = [NSString stringWithFormat:@"icon_%zd",i];
        [_category addObject:@{kTKPDCATEGORY_DATATITLEKEY : titles[i], kTKPDCATEGORY_DATADIDKEY : dataids[i],kTKPDCATEGORY_DATAICONKEY:imagename}];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDeeplinkUrl:)
                                                 name:@"didReceiveDeeplinkUrl" object:nil];


    UINib *cellNib = [UINib nibWithNibName:@"CategoryViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"CategoryViewCellIdentifier"];


}

#pragma mark - Deeplink Delegate
- (NSURL *)sanitizedURL {
    return _deeplinkUrl;
}

- (void)didReceiveDeeplinkUrl:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSURL *deeplinkUrl = [userInfo objectForKey:@"url"];
    
    if(deeplinkUrl) {
        DeeplinkController *dlc = [DeeplinkController new];
        __weak typeof(self) weakSelf = self;
        dlc.delegate = weakSelf;
        _deeplinkUrl = deeplinkUrl;
        [dlc doRedirect];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.tabBarController.title = @"Kategori";
    self.screenName = @"Top Category";
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self initNotificationManager];
    

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
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
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _category.count;

}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid = @"CategoryViewCellIdentifier";
    CategoryViewCell *cell = (CategoryViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
    
    NSString *title =[_category[indexPath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:6];
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [title length])];
    
    cell.categoryLabel.attributedText = attributedString;
    
    NSString *icon = [_category[indexPath.row] objectForKey:kTKPDCATEGORY_DATAICONKEY];
    cell.icon.image = [UIImage imageNamed:icon];
    
    cell.backgroundColor = [UIColor whiteColor];
    
	return cell;
}

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
    
    SearchResultViewController *vc = [SearchResultViewController new];
    vc.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"",
               kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : [_category[index] objectForKey:kTKPDSEARCH_APITITLEKEY?:@""],
               kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
    
    SearchResultViewController *vc1 = [SearchResultViewController new];
    vc1.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"",
                kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : [_category[index] objectForKey:kTKPDSEARCH_APITITLEKEY?:@""],
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
    
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
    vc2.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"",
                kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : [_category[index] objectForKey:kTKPDSEARCH_APITITLEKEY?:@""],
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};

    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
    [viewController setData:@{kTKPDCATEGORY_DATATYPEKEY: @(kTKPDCATEGORY_DATATYPECATEGORYKEY), kTKPDSEARCH_APIDEPARTMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"", }];
    [viewController setNavigationTitle:[_category[index] objectForKey:kTKPDCATEGORY_DATATITLEKEY]];
    [viewController setSelectedIndex:0];
    [viewController setViewControllers:viewcontrollers];
    [viewController setNavigationTitle:[_category[index] objectForKey:@"title"]?:@""];

    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
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

@end
