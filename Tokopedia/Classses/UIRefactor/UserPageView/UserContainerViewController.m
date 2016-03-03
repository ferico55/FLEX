//
//  ContainerViewController.m
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//
#import "LoginViewController.h"
#import "UserContainerViewController.h"
#import "ShopTalkPageViewController.h"
#import "ShopProductPageViewController.h"
#import "ShopReviewPageViewController.h"
#import "ShopNotesPageViewController.h"
#import "ShopInfoViewController.h"
#import "SendMessageViewController.h"
#import "ShopBadgeLevel.h"
#import "ShopSettingViewController.h"
#import "ProductAddEditViewController.h"
#import "UserProfileBiodataViewController.h"
#import "ProfileFavoriteShopViewController.h"
#import "ProfileContactViewController.h"
#import "ProfileSettingViewController.h"
#import "URLCacheController.h"

#import "sortfiltershare.h"
#import "detail.h"
#import "string_product.h"
#import "profile.h"

#import "TokopediaNetworkManager.h"
#import "FavoriteShopAction.h"
#import "UserAuthentificationManager.h"
#import "SettingUserProfileViewController.h"
#import "ShopContainerViewController.h"
#import "UIView+HVDLayout.h"


@interface UserContainerViewController ()
<
    UIScrollViewDelegate,
    LoginViewDelegate,
    TokopediaNetworkManagerDelegate,
    SettingUserProfileDelegate,
    UIPageViewControllerDelegate
>
{
    BOOL _isNoData;
    BOOL _isRefreshView;
    
    NSInteger _requestCount;
    
    __weak RKObjectManager *_objectmanager;
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
    
    NSDictionary *_auth;
    UIBarButtonItem *_favoriteBarButton;
    UIBarButtonItem *_unfavoriteBarButton;
    UIBarButtonItem *_infoBarButton;
    UIBarButtonItem *_addProductBarButton;
    UIBarButtonItem *_settingBarButton;
    UIBarButtonItem *_messageBarButton;
    ProfileInfo *_profileinfo;
    TokopediaNetworkManager *_networkManager;
    UserAuthentificationManager *_userManager;
    
}

@property (strong, nonatomic) UserProfileBiodataViewController *biodataController;
@property (strong, nonatomic) ProfileFavoriteShopViewController *favoriteShopController;
@property (strong, nonatomic) ProfileContactViewController *contactViewController;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UILabel *productLabel;
@property (strong, nonatomic) IBOutlet UILabel *talkLabel;
@property (strong, nonatomic) IBOutlet UILabel *reviewLabel;
@property (strong, nonatomic) IBOutlet UILabel *notesLabel;

@end




@implementation UserContainerViewController

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
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    UIBarButtonItem *barbuttonright = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:(self)
                                                                      action:@selector(tap:)];
    
    if([_userManager isLogin]) {
        if([_userManager isMyUser:[_data objectForKey:@"user_id"]]) {
            //button config
            UIImage *infoImage = [UIImage imageNamed:@"icon_shop_setting@2x.png"];
            
            CGRect frame = CGRectMake(0, 0, 20, 20);
            UIButton* button = [[UIButton alloc] initWithFrame:frame];
            [button setBackgroundImage:infoImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchDown];
            [button setTag:14];
            
            [barbuttonright setCustomView:button];
            self.navigationItem.rightBarButtonItem = barbuttonright;
        } else {
            //button message
            UIImage *infoImage = [UIImage imageNamed:@"icon_shop_message@2x.png"];
            
            CGRect frame = CGRectMake(0, 0, 20, 20);
            UIButton* button = [[UIButton alloc] initWithFrame:frame];
            [button setBackgroundImage:infoImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchDown];
            [button setTag:15];
            
            [barbuttonright setCustomView:button];
            self.navigationItem.rightBarButtonItem = barbuttonright;
        }
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    _userManager = [UserAuthentificationManager new];
    
    [self initNotificationCenter];
    [self initBarButton];
    // Do any additional setup after loading the view from its nib.
    
    _isNoData = YES;
    _isRefreshView = NO;
    _requestCount = 0;
    
    _operationQueue = [NSOperationQueue new];
    _operationFavoriteQueue = [NSOperationQueue new];
    
    _cacheController = [URLCacheController new];
    _cacheController.URLCacheInterval = 86400.0;
    _cacheConnection = [URLCacheConnection new];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _pageController.dataSource = self;
    _pageController.delegate = self;
    
    _biodataController = [UserProfileBiodataViewController new];
    _biodataController.data = _data;
    
    _favoriteShopController = [ProfileFavoriteShopViewController new];
    _favoriteShopController.data = _data;
    

    NSArray *viewControllers = [NSArray arrayWithObject:_biodataController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    [self addChildViewController:self.pageController];

    [self.view addSubview:[self.pageController view]];
    [self.view setBackgroundColor:[UIColor colorWithRed:(231/255.0) green:(231/255.0) blue:(231/255.0) alpha:1]];
    if(IS_IPAD) {
        [self.pageController.view HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(20, 70, 0, 70)];
    }

    
    NSArray *subviews = self.pageController.view.subviews;
    UIPageControl *thisControl = nil;
    for (int i=0; i<[subviews count]; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            thisControl = (UIPageControl *)[subviews objectAtIndex:i];
        }
    }
    
    thisControl.hidden = true;
    
    
    
    [_networkManager doRequest];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    [self.pageController didMoveToParentViewController:self];
    [self setScrollEnabled:NO forPageViewController:_pageController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_networkManager requestCancel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+40);
    _userManager = [UserAuthentificationManager new];
    
}

#pragma  - UIPageViewController Methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UserProfileBiodataViewController class]]) {
        return nil;
    }
    if ([viewController isKindOfClass:[ProfileFavoriteShopViewController class]]) {
        return _biodataController;
    }
    
    return nil;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UserProfileBiodataViewController class]]) {
        return _favoriteShopController;
    }
    
    else if ([viewController isKindOfClass:[ProfileFavoriteShopViewController class]]) {
        return nil;
    }
    
    return nil;
    
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}


#pragma mark - Init Notification
- (void)initNotificationCenter {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(showNavigationShopTitle:) name:@"showNavigationShopTitle" object:nil];
    [nc addObserver:self selector:@selector(hideNavigationShopTitle:) name:@"hideNavigationShopTitle" object:nil];
    
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
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}



#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    _networkManager.delegate = nil;
    _networkManager = nil;
}


#pragma mark - Notification Action

- (void)checkIsLogin {
    if(_auth) {
        
    }
}
- (void)showNavigationShopTitle:(NSNotification *)notification
{
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.title = [_data objectForKey:kTKPDDETAIL_APISHOPNAMEKEY];
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

#pragma mark - Tap Action


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
                [_pageController setViewControllers:@[_favoriteShopController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self postNotificationSetProfileHeader];
                break;
            }
            case 11:
            {
                [_pageController setViewControllers:@[_contactViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self postNotificationSetProfileHeader];
                break;
            }
                
            case 13:
            {
                
                [_pageController setViewControllers:@[_biodataController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [self postNotificationSetProfileHeader];
                break;
            }
            default:
                break;
        }
    }
}




#pragma mark - LoginView Delegate
- (void)redirectViewController:(id)viewController
{
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *tempAuth = [secureStorage keychainDictionary];
    _auth = [tempAuth mutableCopy];
    
}

#pragma mark - Reload Profile
- (void)reloadProfile {
    [_networkManager doRequest];
}

#pragma mark - Tokopedia Network Delegate
- (NSDictionary *)getParameter:(int)tag {
    NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETPROFILEINFOKEY,
                            kTKPDPROFILE_APIPROFILEUSERIDKEY : @([[_data objectForKey:kTKPDPROFILE_APIUSERIDKEY]integerValue])
                            };
    
    return param;
}

- (NSString *)getPath:(int)tag {
    return kTKPDPROFILE_PEOPLEAPIPATH;
}

- (id)getObjectManager:(int)tag {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileInfo class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileInfoResult class]];
    
    RKObjectMapping *userinfoMapping = [RKObjectMapping mappingForClass:[UserInfo class]];
    [userinfoMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILE_APIUSEREMAILKEY:kTKPDPROFILE_APIUSEREMAILKEY,
                                                          kTKPDPROFILE_APIUSERMESSENGERKEY:kTKPDPROFILE_APIUSERMESSENGERKEY,
                                                          kTKPDPROFILE_APIUSERHOBBIESKEY:kTKPDPROFILE_APIUSERHOBBIESKEY,
                                                          kTKPDPROFILE_APIUSERPHONEKEY:kTKPDPROFILE_APIUSERPHONEKEY,
                                                          kTKPDPROFILE_APIUSERIDKEY:kTKPDPROFILE_APIUSERIDKEY,
                                                          kTKPDPROFILE_APIUSERIMAGEKEY:kTKPDPROFILE_APIUSERIMAGEKEY,
                                                          kTKPDPROFILE_APIUSERNAMEKEY:kTKPDPROFILE_APIUSERNAMEKEY
                                                          }];
    
    RKObjectMapping *userReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [userReputationMapping addAttributeMappingsFromDictionary:@{CPositivePercentage:CPositivePercentage,
                                                                CNegative:CNegative,
                                                                CPositif:CPositif,
                                                                CNoReputation:CNoReputation,
                                                                CNeutral:CNeutral}];
    
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
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY,
                                                           CShopReputationScore:CShopReputationScore
                                                           }];
    
    RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
    [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
    
    RKObjectMapping *countRatingMapping = [RKObjectMapping mappingForClass:[CountRatingResult class]];
    [countRatingMapping addAttributeMappingsFromDictionary:@{CCountScoreGood:CCountScoreGood,
                                                             CCountScoreNeutral:CCountScoreNeutral,
                                                             CCountScoreBad:CCountScoreBad}];
    
//    RKObjectMapping *responseSpeedMapping = [RKObjectMapping mappingForClass:[ResponseSpeed class]];
//    [responseSpeedMapping addAttributeMappingsFromDictionary:@{COneDay:COneDay,
//                                                               CTwoDay:CTwoDay,
//                                                               CThreeDay:CThreeDay,
//                                                               CSpeedLevel:CSpeedLevel,
//                                                               CBadge:CBadge,
//                                                               CCountTotal:CCountTotal}];
    
    // Relationship Mapping
    [shopstatsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopBadgeLevel toKeyPath:CShopBadgeLevel withMapping:shopBadgeMapping]];
    [shopstatsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopLastOneMonth toKeyPath:CShopLastOneMonth withMapping:countRatingMapping]];
    [shopstatsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopLastSixMonth toKeyPath:CShopLastSixMonth withMapping:countRatingMapping]];
    [shopstatsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopLastTwelveMonth toKeyPath:CShopLastTwelveMonth withMapping:countRatingMapping]];
    [userinfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CUserReputation toKeyPath:CUserReputation withMapping:userReputationMapping]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDPROFILE_APIUSERINFOKEY
                                                                                  toKeyPath:kTKPDPROFILE_APIUSERINFOKEY
                                                                                withMapping:userinfoMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY
                                                                                  toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY
                                                                                withMapping:shopinfoMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY
                                                                                  toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY
                                                                                withMapping:shopstatsMapping]];
//    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CResponseSpeed toKeyPath:CResponseSpeed withMapping:responseSpeedMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_PEOPLEAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
    
    return _objectmanager;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    ProfileInfo *info = stat;
    
    return info.status;
}

- (void)actionBeforeRequest:(int)tag {

}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    _profile = [result objectForKey:@""];
    
    if(_profile.status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setHeaderProfilePage" object:nil userInfo:@{@"profile" : _profile}];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

#pragma mark - Notification
- (void)postNotificationSetProfileHeader {
    if(_profile) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setHeaderProfilePage" object:nil userInfo:@{@"profile" : _profile}];
    }

}


- (IBAction)tapButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 14:
        {
            ProfileSettingViewController *controller = [[ProfileSettingViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
            
        case 15 : {
            if(_profile != nil) {
                SendMessageViewController *messageController = [SendMessageViewController new];
                messageController.data = @{
                                       kTKPDSHOPEDIT_APIUSERIDKEY:[_data objectForKey:kTKPDSHOPEDIT_APIUSERIDKEY]?:@"",
                                       kTKPDDETAIL_APISHOPNAMEKEY:_profile.result.user_info.user_name
                                       };
                [self.navigationController pushViewController:messageController animated:YES];
            }
            break;
        }
            
        case 16 : {
            ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
            
            NSDictionary *auth = [_data objectForKey:@"auth"];
            container.data = @{kTKPDDETAIL_APISHOPIDKEY:_profile.result.shop_info.shop_id?:@"0",
                               kTKPD_AUTHKEY:auth?:@{}};
            [self.navigationController pushViewController:container animated:YES];
        }
            
            
        default:
            break;
    }
}

#pragma mark - Setting user profile delegate

- (void)successEditUserProfile
{
    [self reloadProfile];
}

@end