//
//  MainViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "SearchViewController.h"
#import "TransactionCartRootViewController.h"   
#import "MoreViewController.h"
#import "CategoryViewController.h"

#import "TKPDTabHomeViewController.h"

#import "HotlistViewController.h"
#import "ProductFeedViewController.h"
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
#import "AlertBaseUrl.h"

#import "InboxRootViewController.h"
#import "CategoryViewController.h"

#import "RequestNotifyLBLM.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "Localytics.h"

#import "TKPAppFlow.h"
#import "TKPStoreManager.h"
#import "MoreWrapperViewController.h"
#import "PhoneVerifViewController.h"

#define TkpdNotificationForcedLogout @"NOTIFICATION_FORCE_LOGOUT"

@interface MainViewController ()
<
    UITabBarControllerDelegate,
    UIAlertViewDelegate,
    LoginViewDelegate,
    TokopediaNetworkManagerDelegate,
    TKPAppFlow
>
{
    UITabBarController *_tabBarController;
    HomeTabViewController *_swipevc;
    URLCacheController *_cacheController;
    
    UserAuthentificationManager *_userManager;
    TokopediaNetworkManager *_logoutRequestManager;
    __weak RKObjectManager *_objectmanager;
    
    NSString *_persistToken;
    NSString *_persistBaseUrl;
    
    UIAlertView *_logingOutAlertView;
    NSTimer *_containerTimer;
    
    RequestNotifyLBLM *_requestLBLM;
    TKPStoreManager *_storeManager;
    
    MainViewControllerPage _page;
}

@end

typedef enum TagRequest {
    LogoutTag
} TagRequest;

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       [self.navigationController.navigationBar setTranslucent:NO];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
    [Localytics tagEvent:@"Enter Main Page"];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
    [self adjustnavigationbar];
        
    _auth = [NSMutableDictionary new];
    _cacheController = [URLCacheController new];
    
    _logoutRequestManager = [TokopediaNetworkManager new];
    _logoutRequestManager.delegate = self;
    _logoutRequestManager.tagRequest = LogoutTag;
    
    [[UISegmentedControl appearance] setTintColor:kTKPDNAVIGATION_NAVIGATIONBGCOLOR];
    
    [self performSelector:@selector(viewDidLoadQueued) withObject:nil afterDelay:kTKPDMAIN_PRESENTATIONDELAY];	//app launch delay presentation

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(applicationLogin:)
                   name:kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION
                 object:nil];
    
    [center addObserver:self
               selector:@selector(forceLogout)
                   name:TkpdNotificationForcedLogout
                 object:nil];
    
    [center addObserver:self
               selector:@selector(applicationlogout:)
                   name:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION
                 object:nil];
    
    [center addObserver:self
               selector:@selector(redirectNotification:)
                   name:@"redirectNotification"
                 object:nil];

    [center addObserver:self
               selector:@selector(updateTabBarMore:)
                   name:UPDATE_TABBAR object:nil];

    [center addObserver:self
               selector:@selector(didReceiveShowRatingNotification:)
                   name:kTKPD_SHOW_RATING_ALERT
                 object:nil];
    
    [center addObserver:self
               selector:@selector(redirectToHomeViewController)
                   name:kTKPD_REDIRECT_TO_HOME
                 object:nil];
    
    [center addObserver:self
               selector:@selector(navigateToPageInTabBar:)
                   name:@"navigateToPageInTabBar"
                 object:nil];

    [center addObserver:self
               selector:@selector(redirectToSearch)
                   name:@"redirectToSearch"
                 object:nil];
    
    //refresh timer for GTM Container
    _containerTimer = [NSTimer scheduledTimerWithTimeInterval:7200.0f target:self selector:@selector(didRefreshContainer:) userInfo:nil repeats:YES];
    
    [self makeSureDeviceTokenExists];
}

- (void)makeSureDeviceTokenExists {
    // Perhaps this method should be called at more appropriate places,
    // such as before logging in and registration.
    
    [UserAuthentificationManager ensureDeviceIdExistence];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _userManager = [UserAuthentificationManager new];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_logoutRequestManager requestCancel];
    _logoutRequestManager.delegate = nil;
    _logoutRequestManager = nil;
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
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [Localytics setCustomerId:[_userManager getUserId]];
        [Localytics setValue:[_userManager getUserId] forProfileAttribute:@"user_id"];
    });
    
}

-(void)presentcontrollers
{
    [self createtabbarController];
    
    _tabBarController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:_tabBarController animated:YES completion:^{

	}];
}

-(void)createtabbarController
{
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];
    BOOL isauth = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
    _tabBarController = [UITabBarController new];
    _tabBarController.delegate = self;
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : kTKPDNAVIGATION_TABBARTITLECOLOR }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1] }
                                             forState:UIControlStateSelected];
//    
//    /** TAB BAR INDEX 1 **/
//    /** adjust view controllers at tab bar controller **/
//    NSMutableArray *viewcontrollers = [NSMutableArray new];
//    /** create new view controller **/
//    if (!isauth) {
//        // before login
////        HotlistViewController *v = [HotlistViewController new];
////        v.data = @{kTKPD_AUTHKEY : _auth?:@{}};
////        [viewcontrollers addObject:v];
//        CategoryViewController *controller = [[CategoryViewController alloc] init];
//        controller.data = @{@"auth" : _auth?:@{}};
//        [viewcontrollers addObject:controller];
//    }
//    else{
//        // after login
//        HotlistViewController *controller = [[HotlistViewController alloc] init];
//        controller.data = @{@"auth" : _auth?:@{}};
//        [viewcontrollers addObject:controller];
//        ProductFeedViewController *v1 = [ProductFeedViewController new];
//        [viewcontrollers addObject:v1];
//        HistoryProductViewController *v2 = [HistoryProductViewController new];
//        [viewcontrollers addObject:v2];
//        FavoritedShopViewController *v3 = [FavoritedShopViewController new];
//        [viewcontrollers addObject:v3];
//    }
    
    _swipevc = [[HomeTabViewController alloc] init];
    UINavigationController *swipevcNav = [[UINavigationController alloc] initWithRootViewController:_swipevc];
    [swipevcNav.navigationBar setTranslucent:NO];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        _swipevc.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    /** TAB BAR INDEX 2 **/
    HotlistViewController *categoryvc = [HotlistViewController new];
    UINavigationController *categoryNavBar = [[UINavigationController alloc]initWithRootViewController:categoryvc];

    [categoryNavBar.navigationBar setTranslucent:NO];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        categoryvc.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    /** TAB BAR INDEX 3 **/
    SearchViewController *search = [SearchViewController new];
    if (_auth) {
        search.data = @{kTKPD_AUTHKEY:_auth?:@{}};
    }
    UINavigationController *searchNavBar = [[UINavigationController alloc]initWithRootViewController:search];
    searchNavBar.navigationBar.translucent = NO;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        search.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    /** TAB BAR INDEX 4 **/
    TransactionCartRootViewController *cart = [TransactionCartRootViewController new];
    UINavigationController *cartNavBar = [[UINavigationController alloc]initWithRootViewController:cart];
    [cartNavBar.navigationBar setTranslucent:NO];
    //[cartNavBar.navigationItem setTitleView:logo];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        cart.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    /** TAB BAR INDEX 5 **/
    UINavigationController *moreNavBar;
    if (!isauth) {
        LoginViewController *more = [LoginViewController new];
        moreNavBar = [[UINavigationController alloc]initWithRootViewController:more];
        
        if (_page == MainViewControllerPageRegister) {
            [more navigateToRegister];
        }
    }
    else{
        MoreWrapperViewController *controller = [[MoreWrapperViewController alloc] init];
        moreNavBar = [[UINavigationController alloc] initWithRootViewController:controller];
    }

    [moreNavBar.navigationBar setTranslucent:NO];
    
    /** for ios 7 need to set automatically adjust scrooll view inset **/
    if([self respondsToSelector:@selector(setExtendedLayoutIncludesOpaqueBars:)])
    {
        _swipevc.extendedLayoutIncludesOpaqueBars = YES;
        categoryvc.extendedLayoutIncludesOpaqueBars = YES;
        search.extendedLayoutIncludesOpaqueBars = YES;
        cart.extendedLayoutIncludesOpaqueBars = YES;
        moreNavBar.extendedLayoutIncludesOpaqueBars = YES;
        [moreNavBar.navigationBar setTranslucent:NO];
    }
    
    NSArray* controllers = [NSArray arrayWithObjects:swipevcNav, categoryNavBar, searchNavBar, cartNavBar, moreNavBar, nil];
    _tabBarController.viewControllers = controllers;
    _tabBarController.delegate = self;
    //tabBarController.tabBarItem.title = nil;
    
    NSInteger pageIndex = [self pageIndex];
    
    _tabBarController.selectedIndex = pageIndex;
    
    [self adjusttabbar];
}

- (void)adjustnavigationbar
{
    // Move to root view controller
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_NAVBARBG ofType:@"png"]];
    
    id proxy = [UINavigationBar appearance];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) { // iOS 7
        [proxy setBarTintColor:kTKPDNAVIGATION_NAVIGATIONBGCOLOR];
    } else {
        [proxy setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    [proxy setTintColor:[UIColor whiteColor]];
    [proxy setBackgroundColor:[UIColor colorWithRed:(18/255.0) green:(199/255.0) blue:(0/255.0) alpha:1]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    NSDictionary *titleTextAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         kTKPDNAVIGATION_TITLEFONT, UITextAttributeFont,
                                         kTKPDNAVIGATION_TITLECOLOR, UITextAttributeTextColor,
                                         kTKPDNAVIGATION_TITLESHADOWCOLOR, UITextAttributeTextShadowColor, nil];
    [proxy setTitleTextAttributes:titleTextAttributes];
}

-(void)adjusttabbar
{
    UITabBar *tabbar = _tabBarController.tabBar;
    
    UITabBarItem *tabBarItem1 = [tabbar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabbar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabbar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabbar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [tabbar.items objectAtIndex:4];
    
    UIImage *image;
    UIImage *image_active;
    /** set tab bar item 1**/
    image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_HOME];
    image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_HOME];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem1 setImage:image];
        [tabBarItem1 setSelectedImage:image_active];

    }
    else{
        [tabBarItem1 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    }
    //tabBarItem1.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem1.title = kTKPDNAVIGATION_TABBARTITLEARRAY[0];
    
    NSDictionary *textAttributes = @{
                                    UITextAttributeTextColor:[UIColor blackColor],
                                    UITextAttributeFont:[UIFont fontWithName:@"GothamBook" size:9.0]
                                    };
    [tabBarItem1 setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
    /** set tab bar item 2**/
    image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_CATEGORY];
    image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_CATEGORY];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem2 setImage:image];
        [tabBarItem2 setSelectedImage:image_active];
    }
    else
        [tabBarItem2 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    //tabBarItem2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem2.title = kTKPDNAVIGATION_TABBARTITLEARRAY[1];
    
    [tabBarItem2 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamBook" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
    /** set tab bar item 3*/
    image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_SEARCH];
    image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_SEARCH];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem3 setImage:image];
        [tabBarItem3 setSelectedImage:image_active];
    }
    else
        [tabBarItem3 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    //tabBarItem3.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem3.title = kTKPDNAVIGATION_TABBARTITLEARRAY[2];
    
    [tabBarItem3 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamBook" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
    /** set tab bar item 4*/
    image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_CART];
    image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_CART];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem4 setImage:image];
        [tabBarItem4 setSelectedImage:image_active];
    }
    else
        [tabBarItem4 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    //tabBarItem4.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem4.title = kTKPDNAVIGATION_TABBARTITLEARRAY[3];
    
    [tabBarItem4 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamBook" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
    /** set tab bar item 5*/
    BOOL isauth = [[_auth objectForKey:kTKPD_ISLOGINKEY]boolValue];
    if(isauth) {
        image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_MORE];
        image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_MORE];
    } else {
        image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_LOGIN];
        image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_LOGIN];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem5 setImage:image];
        [tabBarItem5 setSelectedImage:image_active];
    }
    else
        [tabBarItem5 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    //tabBarItem5.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    if(isauth) {
        tabBarItem5.title = kTKPDNAVIGATION_TABBARTITLEARRAY[4];
    } else {
        tabBarItem5.title = kTKPDNAVIGATION_TABBARTITLEARRAY[5];
    }

    [tabBarItem5 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamBook" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
    
    NSBundle* bundle = [NSBundle mainBundle];
	//UIImage* image;
	id proxy = [UITabBar appearance];
    
	image = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_TABBARBG ofType:@"png"]]; //navigation-bg
    
    [proxy setBackgroundImage:image];
    [proxy setSelectedImageTintColor:[UIColor blackColor]];
    
    //[proxy setShadowImage:[UIImage imageNamed:kTKPDIMAGE_NAVBARBG]];
    
    // Omit the conditional if minimum OS is iOS 6 or above
    if ([UITabBar instancesRespondToSelector:@selector(setShadowBlurRadius:)]) {
        [proxy setShadowBlurRadius:0];
    }
    
    [proxy setShadowImage:[[UIImage alloc] init]];
    
#endif
    // redirect to home after login or register
//    _tabBarController.selectedViewController=[_tabBarController.viewControllers objectAtIndex:0];
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
            return 2;
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
    _auth = [_userManager getUserLoginData];
    
    BOOL isauth = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
    
    //refreshing cart when first login
    [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshingCart" object:nil userInfo:nil];

	// Assume tabController is the tab controller
    // and newVC is the controller you want to be the new view controller at index 0
    NSMutableArray *newControllers = [NSMutableArray arrayWithArray:_tabBarController.viewControllers];
    UINavigationController *swipevcNav = [[UINavigationController alloc]initWithRootViewController:_swipevc];
    swipevcNav.navigationBar.translucent = NO;
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    _swipevc.navigationItem.titleView = logo;

    UINavigationController *searchNavBar = newControllers[2];
    id search = searchNavBar.viewControllers[0];
    if (_auth) {
        ((SearchViewController*)search).data = @{kTKPD_AUTHKEY:_auth?:@{}};
    }
    
    UINavigationController *moreNavBar = nil;
    if (!isauth) {
        LoginViewController *more = [LoginViewController new];
        moreNavBar = [[UINavigationController alloc]initWithRootViewController:more];
        [[_tabBarController.viewControllers objectAtIndex:3] tabBarItem].badgeValue = nil;
    }
    else{
        MoreWrapperViewController *controller = [[MoreWrapperViewController alloc] init];
        moreNavBar = [[UINavigationController alloc] initWithRootViewController:controller];
        
    }
    [moreNavBar.navigationBar setTranslucent:NO];

    [newControllers replaceObjectAtIndex:0 withObject:swipevcNav];
    [newControllers replaceObjectAtIndex:4 withObject:moreNavBar];

    [_tabBarController setViewControllers:newControllers animated:YES];

    [self adjusttabbar];
}

- (void)updateTabBarMore:(NSNotification*)notification
{
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshingCart" object:nil userInfo:nil];
    
    NSMutableArray *newControllers = [NSMutableArray arrayWithArray:_tabBarController.viewControllers];
    
    MoreWrapperViewController *controller = [[MoreWrapperViewController alloc] init];
    UINavigationController *moreNavController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [moreNavController.navigationBar setTranslucent:NO];
    [newControllers replaceObjectAtIndex:4 withObject:moreNavController];
    [_tabBarController setViewControllers:newControllers animated:YES];
    
    [self adjusttabbar];
}

- (void)applicationlogout:(NSNotification*)notification
{
    _userManager = [UserAuthentificationManager new];
    _persistToken = [_userManager getMyDeviceToken]; //token device from ios

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Apakah Anda ingin keluar ?"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Batal"
                                              otherButtonTitles:@"Iya", nil];
    alertView.tag = 1;
    [alertView show];
}

- (void)doApplicationLogout {
    /*
    remove all cache from webview, all credential that been logged in, will be removed
    example : login kereta api, login pulsa
    */
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieStorage cookies]) {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"tokopedia"];
        if(domainRange.length > 0) {
            [cookieStorage deleteCookie:cookie];
        }
    }
    
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
    
//    [[GPPSignIn sharedInstance] signOut];
//    [[GPPSignIn sharedInstance] disconnect];
    [[GIDSignIn sharedInstance] signOut];
    [[GIDSignIn sharedInstance] disconnect];

    [_logoutRequestManager doRequest];
    
    TKPDSecureStorage* storage = [TKPDSecureStorage standardKeyChains];
    _persistBaseUrl = [[storage keychainDictionary] objectForKey:@"AppBaseUrl"]?:kTkpdBaseURLString;
    
    NSString* securityQuestionUUID = [[storage keychainDictionary] objectForKey:@"securityQuestionUUID"];
    
    [storage resetKeychain];
    [_auth removeAllObjects];
    
    [storage setKeychainWithValue:_persistToken?:@"" withKey:@"device_token"];
    [storage setKeychainWithValue:_persistBaseUrl?:@"" withKey:@"AppBaseUrl"];
    if(securityQuestionUUID) {
        [storage setKeychainWithValue:securityQuestionUUID withKey:@"securityQuestionUUID"];
    }
    
    
    [self removeCacheUser];
    
    [[_tabBarController.viewControllers objectAtIndex:3] tabBarItem].badgeValue = nil;
    [((UINavigationController*)[_tabBarController.viewControllers objectAtIndex:3]) popToRootViewControllerAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION
                                                        object:nil
                                                      userInfo:@{}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_REMOVE_SEARCH_HISTORY object:nil];
    
    if (_logingOutAlertView) {
        [_logingOutAlertView dismissWithClickedButtonIndex:0 animated:YES];
        _logingOutAlertView = nil;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHONE_VERIF_LAST_APPEAR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSelector:@selector(applicationLogin:) withObject:nil afterDelay:kTKPDMAIN_PRESENTATIONDELAY];
    
    [Localytics setValue:@"No" forProfileAttribute:@"Is Login"];
    
    [self reinitCartTabBar];
}

- (void)removeCacheUser {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    [_cacheController initCacheWithDocumentPath:path];
    [_cacheController clearCache];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if(buttonIndex == 1) {
            [self doApplicationLogout];
        }
    } else if (alertView.tag == 2) {
        [self ratingAlertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    static UIViewController *previousController = nil;
    if (previousController == viewController) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidTappedTapBar object:nil userInfo:nil];
    }
    previousController = viewController;

}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

-(void)redirectViewController:(id)viewController {
    
}

- (void)redirectToSearch {
    _tabBarController.selectedIndex = 2;
}

#pragma mark - Logout Controller
- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *param;
    if(tag == LogoutTag) {
        param = @{@"device_token_id" : [_userManager getMyDeviceIdToken],
                  @"device_id" : [_userManager getMyDeviceToken] //token device from ios
                  };
    }
    
    return param;
}

- (NSString *)getPath:(int)tag {
    NSString *path;
    if(tag == LogoutTag) {
        path = kTKPDLOGOUT_APIPATH;
    }
    
    return path;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    Logout *logout = stat;
    
    return logout.status;
}

- (id)getObjectManager:(int)tag {
    if(tag == LogoutTag) {
        _objectmanager =  [RKObjectManager sharedClient];
        
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Logout class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LogoutResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{kTKPDLOGOUT_ISDELETEDEVICE    : kTKPDLOGOUT_ISDELETEDEVICE,
                                                            kTKPDLOGOUT_ISLOGOUT     : kTKPDLOGOUT_ISLOGOUT,
                                                            }];
        //add relationship mapping
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                      toKeyPath:kTKPD_APIRESULTKEY
                                                                                    withMapping:resultMapping]];
        
        // register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:kTKPDLOGOUT_APIPATH
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptorStatus];
        
        return _objectmanager;
    }
    
    return nil;
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

- (void)actionBeforeRequest:(int)tag {
    if(tag == LogoutTag) {
        
    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    if(tag == LogoutTag) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        Logout *logout = [result objectForKey:@""];
        
        if([logout.result.is_logout isEqualToString:@"1"]) {
            
        }
    }
}


- (void)redirectNotification:(NSNotification*)notification {
    _tabBarController.selectedIndex = 0;
    for(UIViewController *viewController in _tabBarController.viewControllers) {
        if([viewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
        }
    }
    
}

#pragma mark - Notification Observer Method
- (void)forceLogout {
    _persistToken = [_userManager getMyDeviceToken]; //token device from ios
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
    NSString *title = @"Suka dengan aplikasi iOS Tokopedia?";
    NSString *message = @"Rate 5 bintang untuk aplikasi ini. Setiap rating yang kalian berikan adalah semangat bagi kami! Terima kasih Toppers.";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Tidak"
                                          otherButtonTitles:@"Ya", nil];

    if ([[notification userInfo] objectForKey:kTKPD_ALWAYS_SHOW_RATING_ALERT]) {
        if ([[[notification userInfo] objectForKey:kTKPD_ALWAYS_SHOW_RATING_ALERT] boolValue]) {
            alert.tag = 1;
        }
    } else {
        alert.tag = 2;
    }
    alert.delegate = self;
    [alert show];
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
    _tabBarController.selectedIndex = 0;
}

- (void) navigateToPageInTabBar:(NSNotification*) notification{
    NSString *pageId = [notification object];
    int pagenum = [pageId intValue];
    _tabBarController.selectedIndex = pagenum;
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
    UINavigationController *transactionCartRootNavController = [_tabBarController.viewControllers objectAtIndex: 3];
    if ([[transactionCartRootNavController.viewControllers objectAtIndex:0] isKindOfClass:[TransactionCartRootViewController class]]) {
        TransactionCartRootViewController *transactionCartRootVC = (TransactionCartRootViewController *)[transactionCartRootNavController.viewControllers objectAtIndex:0];
        
        // Pakai remove observer karena iOS 7 tidak mau otomatis remove observer ketika TransactionCartRootVC dealloc
        [[NSNotificationCenter defaultCenter]removeObserver:transactionCartRootVC];
        [transactionCartRootNavController setViewControllers:[NSArray arrayWithObject: [TransactionCartRootViewController new]]];
    }
}



@end
