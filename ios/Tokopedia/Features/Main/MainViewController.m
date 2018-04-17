//
//  MainViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "MainViewController.h"
#import "SearchViewController.h"
#import "TransactionCartViewController.h"
#import "MoreViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "HotlistViewController.h"
#import "HistoryProductViewController.h"
#import "FavoritedShopViewController.h"

#import "activation.h"

#import "TKPDSecureStorage.h"
#import "URLCacheController.h"
#import "UserAuthentificationManager.h"
#import "HomeTabViewController.h"

#import "TokopediaNetworkManager.h"
#import "UserAuthentificationManager.h"
#import "Logout.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "TKPAppFlow.h"
#import "TKPStoreManager.h"
#import "MoreWrapperViewController.h"
#import "Tokopedia-Swift.h"
#import "MyWishlistViewController.h"
#import <MessageUI/MessageUI.h>

#import "UIActivityViewController+Extensions.h"
#import "ReactEventManager.h"
#import "UIApplication+React.h"
#import <Lottie/Lottie.h>

@interface MainViewController ()
<
    UITabBarControllerDelegate,
    UIAlertViewDelegate,
    TKPAppFlow,
    MFMailComposeViewControllerDelegate
>
{
    HomeTabViewController *_swipevc;
    URLCacheController *_cacheController;
    
    UserAuthentificationManager *_userManager;
    NSString *_persistToken;
    NSString *_persistBaseUrl;
    
    UIAlertView *_logingOutAlertView;
    NSTimer *_containerTimer;
    
    TKPStoreManager *_storeManager;
    
    MainViewControllerPage _page;
    ScreenshotAlertView *_screenshotAlert;
    
    NSUInteger previousSelectedHomeIndex;
    HomeTabBarItem *animatedHomeTabButton;
    BOOL isJumperDisabled;
    BOOL shouldAnimate;
}

@property (strong, nonatomic) ScreenshotHelper *screenshotHelper;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

- (instancetype)initWithPage:(MainViewControllerPage)page {
    if (self = [super init]) {
        _page = page;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _page = MainViewControllerPageDefault;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isJumperDisabled = [[[FIRRemoteConfig remoteConfig] configValueForKey:@"ios_app_is_home_jumper_disabled"] boolValue];
    shouldAnimate = YES;
    
    _userManager = [UserAuthentificationManager new];
    
    self.delegate = self;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
    _auth = [NSMutableDictionary new];
    _cacheController = [URLCacheController new];

    [[UISegmentedControl appearance] setTintColor:[UIColor tpGreen]];
    
    [self viewDidLoadQueued];

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(applicationLogin:) name:kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION object:nil];
    [center addObserver:self selector:@selector(forceLogout) name:TkpdNotificationForcedLogout object:nil];
    [center addObserver:self selector:@selector(applicationlogout:) name:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION object:nil];
    [center addObserver:self selector:@selector(redirectNotification:) name:@"redirectNotification" object:nil];
    [center addObserver:self selector:@selector(updateTabBarMore:) name:UPDATE_TABBAR object:nil];
    [center addObserver:self selector:@selector(didReceiveShowRatingNotification:) name:kTKPD_SHOW_RATING_ALERT object:nil];
    [center addObserver:self selector:@selector(redirectToHomeViewController) name:kTKPD_REDIRECT_TO_HOME object:nil];
    [center addObserver:self selector:@selector(navigateToPageInTabBar:) name:@"navigateToPageInTabBar" object:nil];
    [center addObserver:self selector:@selector(redirectToSearch) name:@"redirectToSearch"object:nil];
    [center addObserver:self selector:@selector(redirectToHotlist) name:@"redirectToHotlist"object:nil];
    [center addObserver:self selector:@selector(didSwipeHomePage:) name:@"didSwipeHomeTab" object:nil];
    
    [center addObserver:self
               selector:@selector(showSuccessActivation)
                   name:@"didSuccessActivateAccount"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(redirectToMore)
                   name:@"redirectToMore"
                 object:nil];
    
    //refresh timer for GTM Container
    _containerTimer = [NSTimer scheduledTimerWithTimeInterval:7200.0f target:self selector:@selector(didRefreshContainer:) userInfo:nil repeats:YES];
    
    [self makeSureDeviceTokenExists];
    
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIApplicationUserDidTakeScreenshotNotification
     object:nil
     queue:mainQueue
     usingBlock:^(NSNotification * _Nonnull note) {
         if(FBTweakValue(@"Others", @"Enable Share Screenshot", @"Enabled", YES)) {
             [AnalyticsManager trackEventName:@"clickScreenshot" category:GA_EVENT_CATEGORY_SCREENSHOT action:GA_EVENT_ACTION_CLICK label:@"Take Screenshot"];
             
             [self.screenshotHelper takeScreenshot];
         }
     }];
    
    FBTweakAction(@"Others", @"NPS Review", @"Reset NPS Review", ^{
        [NSUserDefaults standardUserDefaults].lastVersionNPSRated = NULL;
    });
    
    [center addObserver:self selector:@selector(changeHomeTabBarButtonToHome:) name:@"onScrollHomeChangeTabBarButtonToHome" object:nil];
    [center addObserver:self selector:@selector(changeHomeTabBarButtonToRecommendation:) name:@"onScrollHomeChangeTabBarButtonToRecommendation" object:nil];
}

- (void)makeSureDeviceTokenExists {
    // Perhaps this method should be called at more appropriate places,
    // such as before logging in and registration.
    
    [UserAuthentificationManager ensureDeviceIdExistence];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma methods

- (void)viewDidLoadQueued
{
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
	NSDictionary* auth = [secureStorage keychainDictionary];
	_auth = [auth mutableCopy];
    	
    _data = nil;
    [self presentcontrollers];
}

-(void)presentcontrollers
{
    [self createtabbarController];
    
    UIViewController *topViewController = [UIApplication topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    VersionChecker *versionChecker = [[VersionChecker alloc]init];
    
    [versionChecker checkForceUpdate];
    
    self.screenshotHelper = [[ScreenshotHelper alloc] initWithTabBarController:self topViewController:topViewController];

}

-(void)createtabbarController
{
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];
    BOOL isauth = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : kTKPDNAVIGATION_TABBARTITLECOLOR }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1] }
                                             forState:UIControlStateSelected];

    _swipevc = [[HomeTabViewController alloc] init];
    _swipevc.edgesForExtendedLayout = UIRectEdgeNone;
    
    /** TAB BAR INDEX 2 **/
    HotlistViewController *categoryvc = [HotlistViewController new];
    categoryvc.edgesForExtendedLayout = UIRectEdgeNone;
    
    /** TAB BAR INDEX 3 **/
    MyWishlistViewController *wishlistController = [MyWishlistViewController new];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        wishlistController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    /** TAB BAR INDEX 4 **/
    TransactionCartViewController *cart = [TransactionCartViewController new];
    cart.edgesForExtendedLayout = UIRectEdgeNone;
    
    /** TAB BAR INDEX 5 **/
    UIViewController *moreVC;
    if (!isauth) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *more = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        moreVC = more;
        if (_page == MainViewControllerPageRegister) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [more navigateToRegister];
            });
        }
    }
    else{
        MoreWrapperViewController *controller = [[MoreWrapperViewController alloc] init];
        moreVC = controller;
    }
    
    NSArray* viewControllers = [NSArray arrayWithObjects:_swipevc, categoryvc, wishlistController, cart, moreVC, nil];
    
    self.viewControllers = [viewControllers bk_map:^UIViewController *(UIViewController *vc) {
        return [[UINavigationController alloc] initWithRootViewController:vc];
    }];
    //tabBarController.tabBarItem.title = nil;
    
    NSInteger pageIndex = [self pageIndex];
    
    self.selectedIndex = pageIndex;
    
    [self initTabBar];
}

- (void) initJumperButton: (UITabBarItem*) tabBarItem {
    if (isJumperDisabled) {
        return;
    }
    if (animatedHomeTabButton) {
        [animatedHomeTabButton removeFromSuperview];
    }
    
    // need to handle ipad specially as in ios 11, title and icon positioning are different
    // before 11, bottom bar has horizontal margin
    BOOL useCustomValue = SYSTEM_VERSION_LESS_THAN(@"11.0") && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    BOOL useLargerTopMargin = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")  && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    CGFloat width = useCustomValue ? 76 : self.view.frame.size.width / 5;
    CGFloat originX = useCustomValue ? 126 : 0;
    CGFloat originY = useLargerTopMargin ? 8 : 4;
    CGRect animationRect = CGRectMake(originX, originY, width, 29.5);
    
    animatedHomeTabButton = [[HomeTabBarItem alloc] initWithTabBarItem:tabBarItem rect: animationRect];
    [self.tabBar addSubview: animatedHomeTabButton];
}

-(void)initTabBar {
    NSArray* items = @[@{@"name" : @"Home", @"image" : @"icon_home.png", @"selectedImage" : @"icon_home_active.png"},
                       @{@"name" : @"Hot List", @"image" : @"icon_hotlist.png", @"selectedImage" : @"icon_hotlist_active.png"},
                       @{@"name" : @"Wishlist", @"image" : @"icon_wishlist.png", @"selectedImage" : @"icon_wishlist_active.png"},
                       @{@"name" : @"Keranjang", @"image" : @"icon_cart.png", @"selectedImage" : @"icon_cart_active.png"},
                       @{@"name" : @"Lainnya", @"image" : @"icon_more.png", @"selectedImage" : @"icon_more_active.png"}];
    UITabBar *tabBar = self.tabBar;
    tabBar.tintColor = [UIColor colorWithRed:(66/255.0) green:(189/255.0) blue:(65/255.0) alpha:1];
    tabBar.backgroundColor = [UIColor whiteColor];
    [self initJumperButton: [tabBar.items objectAtIndex:0]];
    
    NSUInteger index = 0;
    NSDictionary *textAttributes = @{
                                     NSForegroundColorAttributeName:[UIColor colorWithRed:(102/255.0) green:(102/255.0) blue:(102/255.0) alpha:1],
                                     NSFontAttributeName:IS_IPAD?[UIFont microTheme]:[UIFont systemFontOfSize:11]};
    for(NSDictionary* item in items) {
        UITabBarItem *tabBarItem = [tabBar.items objectAtIndex:index];
        if(index == items.count - 1) {
            // setup more page tab bar item
            UserAuthentificationManager* userManager = [UserAuthentificationManager new];
            if(!userManager.isLogin) {
                [tabBarItem setTitle:@"Login"];
                [tabBarItem setImage:[[UIImage imageNamed:@"icon_login.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                [tabBarItem setSelectedImage:[[UIImage imageNamed:@"icon_login_active.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            } else {
                [tabBarItem setTitle:[item objectForKey:@"name"]];
                [tabBarItem setImage:[[UIImage imageNamed:[item objectForKey:@"image"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                [tabBarItem setSelectedImage:[[UIImage imageNamed:[item objectForKey:@"selectedImage"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            }
        } else if (index == 0) {
            // setup home tab bar item
            if (isJumperDisabled) {
                [tabBarItem setImage:[[UIImage imageNamed:[item objectForKey:@"image"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                [tabBarItem setSelectedImage:[[UIImage imageNamed:[item objectForKey:@"selectedImage"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                [tabBarItem setTitle:[item objectForKey:@"name"]];
                
                // dealloc immediately to save memory
                animatedHomeTabButton = nil;
            } else if (_userManager.isLogin) {
                [animatedHomeTabButton setState:HomeIconStateJumpingRocket animated:NO];
            } else {
                [animatedHomeTabButton setFocused:NO];
            }
        } else {
            // setup others tab bar item
            [tabBarItem setImage:[[UIImage imageNamed:[item objectForKey:@"image"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [tabBarItem setSelectedImage:[[UIImage imageNamed:[item objectForKey:@"selectedImage"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [tabBarItem setTitle:[item objectForKey:@"name"]];
        }
        
        [tabBarItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        index++;
    }
}

- (NSInteger)pageIndex {
    switch (_page) {
        case MainViewControllerPageLogin:
            return 4;
            break;
        
        case MainViewControllerPageRegister:
            return 4;
            break;
            
        case MainViewControllerPageSearch:
            return 0;
            break;
            
        default:
            return 0;
            break;
    }
}

#pragma mark - Notification observers

- (void)applicationLogin:(NSNotification*)notification
{
    _userManager = [UserAuthentificationManager new];
    _auth = [NSMutableDictionary dictionaryWithDictionary:[_userManager getUserLoginData]];
    
    BOOL isauth = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
    
    //refreshing cart when first login
    [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshingCart" object:nil userInfo:nil];

	// Assume tabController is the tab controller
    // and newVC is the controller you want to be the new view controller at index 0
    NSMutableArray *newControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    UINavigationController *swipevcNav = [[UINavigationController alloc]initWithRootViewController:_swipevc];
    swipevcNav.navigationBar.translucent = NO;
    
    UINavigationController *moreNavBar = nil;
    if (!isauth) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *more = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        __weak typeof(self) welf = self;
        more.onLoginFinished = ^(LoginResult* result){
            [welf redirectToTabBarIndex:0];
            UINavigationController *homeNavController = (UINavigationController *)[welf.viewControllers firstObject];
            [homeNavController popToRootViewControllerAnimated:NO];
        };
        
        moreNavBar = [[UINavigationController alloc]initWithRootViewController:more];
        [[self.viewControllers objectAtIndex:3] tabBarItem].badgeValue = nil;
    }
    else{
        MoreWrapperViewController *controller = [[MoreWrapperViewController alloc] init];
        moreNavBar = [[UINavigationController alloc] initWithRootViewController:controller];
        
    }
    [moreNavBar.navigationBar setTranslucent:NO];

    [newControllers replaceObjectAtIndex:0 withObject:swipevcNav];
    [newControllers replaceObjectAtIndex:4 withObject:moreNavBar];

    [self setViewControllers:newControllers animated:YES];

    [self initTabBar];
}

- (void)updateTabBarMore:(NSNotification*)notification {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshingCart" object:nil userInfo:nil];
    
    NSMutableArray *newControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    
    MoreWrapperViewController *controller = [[MoreWrapperViewController alloc] init];
    UINavigationController *moreNavController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [moreNavController.navigationBar setTranslucent:NO];
    [newControllers replaceObjectAtIndex:4 withObject:moreNavController];
    [self setViewControllers:newControllers animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initTabBar];
    });
}

- (void)applicationlogout:(NSNotification*)notification
{
    _userManager = [UserAuthentificationManager new];
    _persistToken = [_userManager getMyDeviceToken]; //token device from ios

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Apakah Anda ingin keluar?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Batal" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Iya" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf doApplicationLogout];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)removeWebViewCookies {
    /*
     remove all cache from webview, all credential that been logged in, will be removed
     example : login kereta api, login pulsa, tokocash
     */
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN(@"9.0")) {
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                         completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                             [records bk_each:^(WKWebsiteDataRecord *record) {
                                 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:[NSSet setWithObject:WKWebsiteDataTypeCookies]
                                                                            modifiedSince:[NSDate dateWithTimeIntervalSince1970:0]
                                                                        completionHandler:^{}];
                             }];
                             
                         }];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}


- (void)doApplicationLogout {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    _logingOutAlertView = [[UIAlertView alloc] initWithTitle:@"Tunggu sebentar.."
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:nil, nil];
    [_logingOutAlertView show];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clearCacheNotificationBar"
                                                        object:nil];

    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    [[GIDSignIn sharedInstance] signOut];
    [[GIDSignIn sharedInstance] disconnect];
    [[Branch getInstance] logout];
    [AnalyticsManager moEngageTrackLogout];

    [self requestLogout];
    
    TKPDSecureStorage* storage = [TKPDSecureStorage standardKeyChains];
    _persistBaseUrl = [[storage keychainDictionary] objectForKey:@"AppBaseUrl"]?:kTkpdBaseURLString;
    
    NSString* securityQuestionUUID = [[storage keychainDictionary] objectForKey:@"securityQuestionUUID"];
    
    [storage resetKeychain];
    [_auth removeAllObjects];
    
    NSMutableDictionary *dictionary = [@{
                                        @"device_token": _persistToken?:@"",
                                        @"AppBaseUrl": _persistBaseUrl
                                        } mutableCopy];
    if(securityQuestionUUID) {
        [dictionary setObject: securityQuestionUUID forKey:@"securityQuestionUUID"];
    }
    [storage setKeychainWithDictionary:dictionary];
    
    
    [self removeCacheUser];
    
    [[self.viewControllers objectAtIndex:3] tabBarItem].badgeValue = nil;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"total_cart"];
    [prefs removeObjectForKey:@"hachiko_enabled"];
    [prefs removeObjectForKey:@"coupon_onboarding_shown"];
    [prefs synchronize];
    
    [((UINavigationController*)[self.viewControllers objectAtIndex:3]) popToRootViewControllerAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION
                                                        object:nil
                                                      userInfo:@{}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_REMOVE_SEARCH_HISTORY object:nil];
    
    if (_logingOutAlertView) {
        [_logingOutAlertView dismissWithClickedButtonIndex:0 animated:YES];
        _logingOutAlertView = nil;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"phone_verif_last_appear"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [NotificationCache.sharedManager pruneCache];
    
    [self performSelector:@selector(applicationLogin:) withObject:nil afterDelay:kTKPDMAIN_PRESENTATIONDELAY];
    
    [self reinitCartTabBar];
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLogoutNotification object:nil];
    
    ReactEventManager *tabManager = [[UIApplication sharedApplication].reactBridge moduleForClass:[ReactEventManager class]];
    [tabManager sendLogoutEvent];
    
    [[QuickActionHelper sharedInstance] registerShortcutItems];
    [ReferralManager new].referralCode = nil;
}

- (void)removeCacheUser {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    [_cacheController initCacheWithDocumentPath:path];
    [_cacheController clearCache];
    [[PulsaCache new] clearLastOrder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2) {
        [self ratingAlertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void) sendClickTrackingForState: (HomeIconState) state {
    NSString *action = state == HomeIconStateJumpingRocket ? @"click on infinite product jumper" : @"click on home jumper";
    [AnalyticsManager trackEventName:@"userInteractionHomePage" category:@"homepage" action:action label:@""];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    static UIViewController *previousController = nil;
    if (previousController == viewController) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidTappedTapBar object:nil userInfo:nil];
        if ([[UIApplication topViewController] respondsToSelector:@selector(scrollToTop)]) {
            [[UIApplication topViewController] performSelector:@selector(scrollToTop)];
        }
    }
    
    [AnalyticsManager trackEventName:GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE
                            category:GA_EVENT_CATEGORY_HOMEPAGE_BOTTOM_NAV
                              action:[NSString stringWithFormat:@"click %@ nav", tabBarController.tabBar.selectedItem.title]
                               label:@""];
    if (tabBarController.selectedIndex == 0) {
        ReactEventManager *tabManager = [[UIApplication sharedApplication].reactBridge moduleForClass:[ReactEventManager class]];

        if (previousSelectedHomeIndex == 0) { // clicked home while on home
            if (!shouldAnimate) {
                previousController = viewController;
                previousSelectedHomeIndex = tabBarController.selectedIndex;
                return;
            } else if (!_userManager.isLogin) {
                [tabManager shouldScrollToSection: HomeSectionHeader];
                previousController = viewController;
                previousSelectedHomeIndex = tabBarController.selectedIndex;
                return;
            } else if (isJumperDisabled) {
                [tabManager shouldScrollToSection: HomeSectionHeader];
                previousController = viewController;
                previousSelectedHomeIndex = tabBarController.selectedIndex;
                return;
            }
            
            [self sendClickTrackingForState:animatedHomeTabButton.state];
            if (animatedHomeTabButton.state == HomeIconStateHomeActivated) {
                [animatedHomeTabButton setState:HomeIconStateJumpingRocket animated:YES];
                [tabManager shouldScrollToSection: HomeSectionHeader];
            } else {
                [animatedHomeTabButton setState:HomeIconStateHomeActivated animated:YES];
                [tabManager shouldScrollToSection: HomeSectionRecommendation];
            }
        } else {
            [animatedHomeTabButton setFocused: _userManager.isLogin];
        }

        [tabManager sendRedirectHomeTabEvent];
    } else {
        [animatedHomeTabButton setFocused: NO];
    }
    
    previousController = viewController;
    previousSelectedHomeIndex = tabBarController.selectedIndex;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)redirectToSearch {
    [self redirectToTabBarIndex:2];
}

- (void)redirectToHotlist {
    [self redirectToTabBarIndex:1];
}

- (void)showSuccessActivation {
    [NavigateViewController navigateToAccountActivationSuccess];
}

#pragma mark - Logout Controller
-(LogoutRequestParameter*) logoutObjectRequest{
    UserAuthentificationManager* auth = [UserAuthentificationManager new];
    LogoutRequestParameter *object = [LogoutRequestParameter new];
    object.deviceID = [auth getMyDeviceToken]; //token device from ios
    return object;
}

-(void)requestLogout{
    [LogoutRequest fetchLogout:[self logoutObjectRequest] onSuccess:^(LogoutResult * data) {
        [self removeWebViewCookies];
    }];
}

- (void)redirectNotification:(NSNotification*)notification {
    [self redirectToTabBarIndex:0];

    [self popToRootAllViewControllers];
}

- (void)popToRootAllViewControllers{
    for(UIViewController *viewController in self.viewControllers) {
        if([viewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
        }
    }
}

#pragma mark - Notification Observer Method
- (void)forceLogout {
    // Need to use new UserAuthentificationManager becase the old one has wrong device token
    _persistToken = [[UserAuthentificationManager new] getMyDeviceToken]; //token device from ios
    [self doApplicationLogout];
}

- (void)didRefreshContainer:(NSTimer*)timer {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *container = appDelegate.container;
    [container refresh];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRefreshGTM" object:nil];
}

- (void)didReceiveShowRatingNotification:(NSNotification *)notification {
    if ([[notification userInfo] objectForKey:kTKPD_ALWAYS_SHOW_RATING_ALERT]) {
        if ([[[notification userInfo] objectForKey:kTKPD_ALWAYS_SHOW_RATING_ALERT] boolValue]) {
            [self showRatingAlertFromNotification:notification];
        }
    } else {
        [self checkUserRating:notification];
    }
}

- (void) didSwipeHomePage: (NSNotification *) notification {
    UserAuthentificationManager *authManager = [UserAuthentificationManager new];
    if (!authManager.isLogin) {
        return;
    }
    NSDictionary *userinfo = notification.userInfo;
    NSInteger pageNumber = [[userinfo objectForKey:@"tag"]integerValue];

    [animatedHomeTabButton setFocused: (pageNumber == 0)];
    shouldAnimate = pageNumber == 0;
}

- (void)checkUserRating:(NSNotification *)notification {
    _userManager = [UserAuthentificationManager new];
    // Reviews data structure
    // ReviewData (Dictionary containing belows data)
    //   -> UserIds (Array containing user ids that already rated the app)
    //   -> UsersDueDates (Dictionary consist of user ids and due dates)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *reviewData = [defaults objectForKey:kTKPD_USER_REVIEW_DATA];
    if (reviewData) {
        reviewData = [reviewData mutableCopy];
        NSMutableArray *userids = [reviewData objectForKey:kTKPD_USER_REVIEW_IDS];
        if (userids) {
            userids = [userids mutableCopy];
            if (![userids containsObject:_userManager.getUserId]) {
                NSMutableDictionary *dueDates = [reviewData objectForKey:kTKPD_USER_REVIEW_DUE_DATE];
                if (dueDates) {
                    dueDates = [dueDates mutableCopy];
                    NSDate *userDueDate = [dueDates objectForKey:_userManager.getUserId];
                    if (userDueDate) {
                        NSDate *today = [NSDate new];
                        if (today.timeIntervalSince1970 >= userDueDate.timeIntervalSince1970) {
                            [self showRatingAlertFromNotification:notification];
                        }
                    } else {
                        [self showRatingAlertFromNotification:notification];
                    }
                } else {
                    NSMutableDictionary *newUsersDueDates = [NSMutableDictionary new];
                    [reviewData setObject:newUsersDueDates forKey:kTKPD_USER_REVIEW_DUE_DATE];
                    [self showRatingAlertFromNotification:notification];
                }
            }
        } else {
            NSMutableArray *newUserIds = [NSMutableArray new];
            [reviewData setObject:newUserIds forKey:kTKPD_USER_REVIEW_IDS];
            if (![reviewData objectForKey:kTKPD_USER_REVIEW_DUE_DATE]) {
                NSMutableDictionary *dueDates = [NSMutableDictionary new];
                [reviewData setObject:dueDates forKey:kTKPD_USER_REVIEW_DUE_DATE];
            }
            [self showRatingAlertFromNotification:notification];
        }
    } else {
        NSMutableDictionary *newReviewData = [NSMutableDictionary new];
        NSMutableArray *newUserIds = [NSMutableArray new];
        NSMutableDictionary *newUsersDueDates = [NSMutableDictionary new];
        [newReviewData setObject:newUserIds forKey:kTKPD_USER_REVIEW_IDS];
        [newReviewData setObject:newUsersDueDates forKey:kTKPD_USER_REVIEW_DUE_DATE];
        reviewData = newReviewData;
        [self showRatingAlertFromNotification:notification];
    }
    [defaults setObject:reviewData forKey:kTKPD_USER_REVIEW_DATA];
    [defaults synchronize];
}

- (void)showRatingAlertFromNotification:(NSNotification *)notification {
    [NativeNPS show];
}

- (void)ratingAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTKPD_ITUNES_APP_URL]];
    }
    else if (alertView.tag == 2) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *reviewData = [[defaults objectForKey:kTKPD_USER_REVIEW_DATA] mutableCopy];
        if (buttonIndex == 0) {
            NSMutableDictionary *dueDates = [[reviewData objectForKey:kTKPD_USER_REVIEW_DUE_DATE] mutableCopy];
            NSDate *today = [NSDate date];
            int daysInterval = 7;
            NSDate *nextWeek = [today dateByAddingTimeInterval:60*60*24*daysInterval];
            [dueDates setObject:nextWeek forKey:_userManager.getUserId];
            [reviewData setObject:dueDates forKey:kTKPD_USER_REVIEW_DUE_DATE];
        } else if (buttonIndex == 1) {
            NSMutableArray *userids = [[reviewData objectForKey:kTKPD_USER_REVIEW_IDS] mutableCopy];
            [userids addObject:_userManager.getUserId];
            [reviewData setObject:userids forKey:kTKPD_USER_REVIEW_IDS];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTKPD_ITUNES_APP_URL]];
        }
        [defaults setObject:reviewData forKey:kTKPD_USER_REVIEW_DATA];
        [defaults synchronize];
    }
}

- (void)redirectToHomeViewController {
    [self redirectToTabBarIndex: 0];
}

- (void) redirectToTabBarIndex: (int) index {
    UserAuthentificationManager* userManager = [UserAuthentificationManager new];
    if (userManager.isLogin) {
        [animatedHomeTabButton setFocused: (index == 0)];
    }
    
    self.selectedIndex = index;
    previousSelectedHomeIndex = index;
}

- (void) navigateToPageInTabBar:(NSNotification*) notification{
    NSString *pageId = [notification object];
    int pagenum = [pageId intValue];
    [self redirectToTabBarIndex:pagenum];
}

- (void)redirectToMore {
    [self redirectToTabBarIndex:5];
}

- (void) changeHomeTabBarButtonToHome:(NSNotification*) notification {
    if (shouldAnimate && self.selectedIndex == 0 && _userManager.isLogin) {
        [animatedHomeTabButton setState:HomeIconStateHomeActivated animated:YES];
    }
}

- (void) changeHomeTabBarButtonToRecommendation:(NSNotification*) notification {
    if (shouldAnimate && self.selectedIndex == 0 && _userManager.isLogin) {
        [animatedHomeTabButton setState:HomeIconStateJumpingRocket animated:YES];
    }
}

// MARK: TKPAppFlow methods

- (TKPStoreManager *)storeManager {
    if (_storeManager == nil) {
        _storeManager = [[TKPStoreManager alloc] init];
    }
    return _storeManager;
}

// MARK: Reinit Cart TabBar

- (void) reinitCartTabBar {
    UINavigationController *transactionCartRootNavController = [self.viewControllers objectAtIndex: 3];
    if ([[transactionCartRootNavController.viewControllers objectAtIndex:0] isKindOfClass:[TransactionCartViewController class]]) {
        TransactionCartViewController *transactionCartRootVC = (TransactionCartViewController *)[transactionCartRootNavController.viewControllers objectAtIndex:0];
        
        // Pakai remove observer karena iOS 7 tidak mau otomatis remove observer ketika TransactionCartRootVC dealloc
        [[NSNotificationCenter defaultCenter]removeObserver:transactionCartRootVC];
        [transactionCartRootNavController setViewControllers:[NSArray arrayWithObject: [TransactionCartViewController new]]];
    }
}

@end
