//
//  HotlistViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Hotlist.h"
#import "search.h"
#import "string_home.h"
#import "HotlistViewController.h"
#import "HotlistCollectionCell.h"
#import "HotlistResultViewController.h"
#import "SearchResultViewController.h"
#import "CatalogViewController.h"
#import "TKPDTabNavigationController.h"
#import "SearchResultShopViewController.h"

#import "RetryCollectionReusableView.h"

#import "URLCacheController.h"

#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "TableViewScrollAndSwipe.h"

#import "RequestNotifyLBLM.h"
#import "NotificationManager.h"
#import "PhoneVerifRequest.h"
#import "PhoneVerifViewController.h"

#pragma mark - HotlistView

@interface HotlistViewController ()<UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,NotificationDelegate, RetryViewDelegate> {
    
    NSMutableArray *_product;
    NSInteger _page;
    NSString *_urinext;
    
    UIRefreshControl *_refreshControl;
    NSTimeInterval _timeinterval;
    TokopediaNetworkManager *_requestHotlistManager;
    
    BOOL _isFailRequest;
    
    RequestNotifyLBLM *_requestLBLM;
    NotificationManager *_notifManager;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic, readonly) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) PhoneVerifRequest *phoneVerifRequest;

@end

@implementation HotlistViewController
#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}



#pragma mark - View Lifecylce
- (void) viewDidLoad {
    [super viewDidLoad];
    
    _product = [NSMutableArray new];
    _page = 1;
    
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];

    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];

    _requestHotlistManager = [TokopediaNetworkManager new];
    _requestHotlistManager.isUsingHmac = YES;
    
    [self requestHotlist];
    _phoneVerifRequest  = [PhoneVerifRequest new];
    
    UINib *cellNib = [UINib nibWithNibName:@"HotlistCollectionCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"HotlistCollectionCellIdentifier"];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
        
}

- (void)requestHotlist {
    [_requestHotlistManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/hotlist/get_hotlist.pl"
                                 method:RKRequestMethodGET
                              parameter:@{
                                          @"page" : @(_page),
                                          @"limit"  : @10
                                          }
                                mapping:[Hotlist mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  [self didReceiveHotlist:successResult.dictionary[@""]];
                              } onFailure:^(NSError *errorResult) {
                                  _isFailRequest = YES;
                                  [_collectionView reloadData];
                              }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_requestHotlistManager requestCancel];
}

-(void)doRequestNotify {
    _requestLBLM = [RequestNotifyLBLM new];
    [_requestLBLM doRequestLBLM];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.screenName = @"Hot List Page";
    [TPAnalytics trackScreenName:@"Hot List Page"];

    [self initNotificationManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initNotificationManager) name:@"reloadNotification" object:nil];
    
    [self doRequestNotify];
    [self checkForPhoneVerification];
}


-(void)checkForPhoneVerification{
    if([self shouldShowPhoneVerif]){
        [_phoneVerifRequest requestVerifiedStatusOnSuccess:^(NSString *isVerified) {
            if(![isVerified isEqualToString:@"1"]){
                PhoneVerifViewController *controller = [PhoneVerifViewController new];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                navigationController.navigationBar.translucent = NO;
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            }else{
                
            }
        } onFailure:^(NSError *error) {
            
        }];
    }
}


/*

 apps should ask for phone verif if:
 1. is login
 2. msisdn_is_verified in secure storage is 0 ("msisdn_is_verified" is updated when: login or verifying phone number profile setting)
 3. if last appear timestamp in cache is nil, go to step 6(first login)
 4. check if phone verif last appear timestamp is already past time interval tolerance
 5. check WS, maybe user is already do phone verif in another media(other apps, website, etc)
 6. if not, do ask for verif
 
*/
- (BOOL)shouldShowPhoneVerif{
    NSString *phoneVerifLastAppear = [[NSUserDefaults standardUserDefaults] stringForKey:PHONE_VERIF_LAST_APPEAR];
    UserAuthentificationManager *userAuth = [UserAuthentificationManager new];
    
    if([userAuth isLogin]){
        if(![userAuth isUserPhoneVerified]){
            NSDate* lastAppearDate = [self NSDatefromString:phoneVerifLastAppear];
            if(lastAppearDate){
                NSTimeInterval timeIntervalSinceLastAppear = [[NSDate date]timeIntervalSinceDate:lastAppearDate];
                NSTimeInterval allowedTimeInterval = [self allowedTimeInterval];
                return timeIntervalSinceLastAppear > allowedTimeInterval;
            }else{
                return YES;
            }
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

-(NSTimeInterval)allowedTimeInterval{
    return FBTweakValue(@"Security", @"Phone Verification", @"Notice Interval(Minutes)", 60*24*1)*60;
}

-(NSDate*)NSDatefromString:(NSString*)date{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"WIB"]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    }
    return [dateFormatter dateFromString:date];
}


#pragma mark - Memory Management
- (void)dealloc {
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_requestHotlistManager requestCancel];
    _requestHotlistManager.delegate = nil;
    _requestHotlistManager.isUsingHmac = YES;
    _requestHotlistManager = nil;
}

#pragma mark - Collection View Data Source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _product.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid = @"HotlistCollectionCellIdentifier";
    HotlistCollectionCell *cell = (HotlistCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
    
    [cell setViewModel:((HotlistList*)_product[indexPath.row]).viewModel];
    
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 4;
    if (row == indexPath.row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            _isFailRequest = NO;
            [self requestHotlist];
        }
    }
    
    return cell;
}


#pragma mark - Delegate Cell
- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionFooter) {
        if(_isFailRequest) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView" forIndexPath:indexPath];
            ((RetryCollectionReusableView*)reusableView).delegate = self;
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        }
    }
    
    return reusableView;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HotlistList *hotlist = _product[indexPath.row];
    
    if ([hotlist.url rangeOfString:@"/hot/"].length) {
        HotlistCollectionCell *cell = (HotlistCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
        HotlistResultViewController *controller = [HotlistResultViewController new];
        controller.image = cell.productimageview.image;
        NSArray *query = [[[NSURL URLWithString:hotlist.url] path] componentsSeparatedByString: @"/"];
        controller.data = @{
                            kTKPDHOME_DATAQUERYKEY      : [query objectAtIndex:2]?:@"",
                            kTKPHOME_DATAHEADERIMAGEKEY : cell.productimageview,
                            kTKPDHOME_APIURLKEY         : hotlist.url,
                            kTKPDHOME_APITITLEKEY       : hotlist.title,
                            @"hotlist_id"               : hotlist.hotlist_id
                            };
        controller.hidesBottomBarWhenPushed = YES;
        
        [TPAnalytics trackClickEvent:@"clickHotlist" category:@"Hotlist" label:hotlist.title];
        
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if ([hotlist.url rangeOfString:@"/p/"].length) {
        
        NSURL *url = [NSURL URLWithString:hotlist.url];
        
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        NSMutableArray *departmentIdentifiers = [NSMutableArray new];
        
        for (int i = 2; i < url.pathComponents.count; i++) {
            if (i == 2) {
                [parameters setValue:[url.pathComponents objectAtIndex:i] forKey:kTKPDSEARCH_APIDEPARTMENT_1];
                [departmentIdentifiers addObject:[url.pathComponents objectAtIndex:i]];
            } else if (i == 3) {
                [parameters setValue:[url.pathComponents objectAtIndex:i] forKey:kTKPDSEARCH_APIDEPARTMENT_2];
                [departmentIdentifiers addObject:[url.pathComponents objectAtIndex:i]];
            } else if (i == 4) {
                [parameters setValue:[url.pathComponents objectAtIndex:i] forKey:kTKPDSEARCH_APIDEPARTMENT_3];
                [departmentIdentifiers addObject:[url.pathComponents objectAtIndex:i]];
            }
        }
        
        NSString *scIdentifier = nil;
        if(departmentIdentifiers.count > 0) {
            scIdentifier = [departmentIdentifiers componentsJoinedByString:@"_"];
            [parameters setValue:scIdentifier forKey:@"sc_identifier"];
        }
        
        for (NSString *parameter in [url.query componentsSeparatedByString:@"&"]) {
            NSString *key = [[parameter componentsSeparatedByString:@"="] objectAtIndex:0];
            if ([key isEqualToString:@"pmin"]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:@"pmin"];
            } else if ([key isEqualToString:@"pmax"]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:@"pmax"];
            } else if ([key isEqualToString:@"ob"]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:@"ob"];
            } else if ([key isEqualToString:@"floc"]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:@"floc"];
            } else if ([key isEqualToString:@"fshop"]) {
                [parameters setValue:[[parameter componentsSeparatedByString:@"="] objectAtIndex:1] forKey:@"fshop"];
            }
        }
        
        [parameters setValue:@"directory" forKey:@"type"];
        
        SearchResultViewController *controller = [SearchResultViewController new];
        controller.data = parameters;
        controller.hidesBottomBarWhenPushed = YES;
        
        NSArray *viewcontrollers = @[controller];
        
        TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
        
        [viewController setSelectedIndex:0];
        [viewController setViewControllers:viewcontrollers];
        [viewController setNavigationTitle:hotlist.title];
        
        viewController.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setsegmentcontrol" object:nil userInfo:@{@"hide_segment" : @"1"}];
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else if ([hotlist.url rangeOfString:@"/catalog/"].length) {
        
        NSString *catalogID = [[hotlist.url componentsSeparatedByString:@"/"] objectAtIndex:4];
        CatalogViewController *controller = [CatalogViewController new];
        controller.catalogID = catalogID;
        controller.catalogName = hotlist.title;
        controller.catalogImage = hotlist.image_url_600;
        controller.catalogPrice = hotlist.price_start;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat cellWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        UIDeviceOrientation *orientation = [[UIDevice currentDevice] orientation];
//        if(UIDeviceOrientationIsLandscape(orientation)) {
//            CGFloat screenWidth = screenRect.size.width/3;
//            cellWidth = screenWidth-15;
//        } else {
            CGFloat screenWidth = screenRect.size.width/2;
            cellWidth = screenWidth-15;
//        }

    } else {
        CGFloat screenWidth = screenRect.size.width;
        cellWidth = screenWidth-20;
    }
    return CGSizeMake(cellWidth, cellWidth*173/300);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(60.0f, 40.0f);
}

#pragma mark - Methods
-(void)refreshView:(UIRefreshControl*)refresh {
    _page = 1;
    [_requestHotlistManager requestCancel];
    [_product removeAllObjects];
    
    [self requestHotlist];
}


- (void)didReceiveHotlist:(Hotlist*)hotlist {
    [_refreshControl endRefreshing];
    
    _urinext =  hotlist.data.paging.uri_next;
    _page = [[_requestHotlistManager splitUriToPage:_urinext] integerValue];
    
    [_product addObjectsFromArray: hotlist.data.list];
    _isFailRequest = NO;
    
    [_collectionView reloadData];
}
#pragma mark - Delegate LoadingView
- (void)pressRetryButton {
    _isFailRequest = NO;
    [self requestHotlist];
}

#pragma mark - Notification Action
- (void)userDidTappedTabBar:(NSNotification*)notification {
    [_collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)didSwipeHomeTab:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger tag = [[userinfo objectForKey:@"tag"]integerValue];
    
    if(tag == 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTappedTabBar:) name:@"TKPDUserDidTappedTapBar" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TKPDUserDidTappedTapBar" object:nil];
    }
    
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


- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
{
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - orientation changed
- (void)orientationChanged:(NSNotification *)note {
    [_collectionView reloadData];
}


@end
