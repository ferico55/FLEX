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
#import "UIView+HVDLayout.h"
#import "Tokopedia-Swift.h"


@interface UserContainerViewController ()
<
    UIScrollViewDelegate,
    LoginViewDelegate,
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
        if([_userManager isMyUser:_profileUserID]) {
            //button config
            UIImage *infoImage = [UIImage imageNamed:@"icon_shop_setting"];
            
            CGRect frame = CGRectMake(0, 0, 20, 20);
            UIButton* button = [[UIButton alloc] initWithFrame:frame];
            [button setBackgroundImage:infoImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchDown];
            [button setTag:14];
            
            [barbuttonright setCustomView:button];
            self.navigationItem.rightBarButtonItem = barbuttonright;
        } else {
            //button message
            UIImage *infoImage = [UIImage imageNamed:@"icon_shop_message"];
            
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
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _pageController.dataSource = self;
    _pageController.delegate = self;
    
    _biodataController = [UserProfileBiodataViewController new];
    _biodataController.profileUserID = _profileUserID;
    
    _favoriteShopController = [ProfileFavoriteShopViewController new];
    _favoriteShopController.profileUserID = _profileUserID?:@"";

    NSArray *viewControllers = [NSArray arrayWithObject:_biodataController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    [self addChildViewController:self.pageController];

    [self.view addSubview:[self.pageController view]];
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
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
    
    [self reloadProfile];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+40);
    _userManager = [UserAuthentificationManager new];
    [AnalyticsManager trackScreenName:@"Profile Page"];
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

- (void)setScrollEnabled:(BOOL)enabled forPageViewController:(UIPageViewController*)pageViewController{
    for(UIView* view in pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]){
            UIScrollView* scrollView=(UIScrollView*)view;
            [scrollView setScrollEnabled:enabled];
            return;
        }
    }
}

#pragma mark - Request And Mapping

-(void)cancel {
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}



#pragma mark - Memory Management
-(void)dealloc {
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

- (void)showNavigationShopTitle:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.title = _profile.result.user_info.user_name;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)hideNavigationShopTitle:(NSNotification *)notification {
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
                [_favoriteShopController setHeaderData:_profile];
                break;
            }
            case 11:
            {
                [_pageController setViewControllers:@[_contactViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [_contactViewController setHeaderData:_profile];
                break;
            }
                
            case 13: 
            {
                
                [_pageController setViewControllers:@[_biodataController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
                [_biodataController setHeaderData:_profile];
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
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    _networkManager.isParameterNotEncrypted = NO;
    
    [_networkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/people/get_people_info.pl"
                                 method:RKRequestMethodGET
                              parameter:@{@"profile_user_id" : _profileUserID}
                                mapping:[ProfileInfo mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  _profile = [successResult.dictionary objectForKey:@""];
                                  _profile.result.user_info.user_name = [_profile.result.user_info.user_name kv_decodeHTMLCharacterEntities];
                                  if (_profile.status) {
                                      [_biodataController setHeaderData: _profile];
                                      [_favoriteShopController setHeaderData: _profile];
                                  }
                              }
                              onFailure:^(NSError *errorResult) {
                                  
                                  
                              }];
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
                                       kTKPDSHOPEDIT_APIUSERIDKEY:_profileUserID?:@"",
                                       kTKPDDETAIL_APISHOPNAMEKEY:_profile.result.user_info.user_name
                                       };
                [self.navigationController pushViewController:messageController animated:YES];
            }
            break;
        }
            
        case 16 : {
            ShopViewController *container = [[ShopViewController alloc] init];
            
            container.data = @{kTKPDDETAIL_APISHOPIDKEY:_profile.result.shop_info.shop_id?:@"0"};
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
