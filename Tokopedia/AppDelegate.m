//
//  AppDelegate.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>

#import "AppDelegate.h"

#import "MainViewController.h"

#import "LoginViewController.h"
#import "SearchViewController.h"
#import "CartViewController.h"
#import "MoreViewController.h"
#import "CategoryViewController.h"

#import "TKPDTabHomeNavigationController.h"

#import "HotlistViewController.h"
#import "ProductFeedViewController.h"
#import "LogoutViewController.h"

#import "LoginResult.h"
#import "activation.h"

@implementation AppDelegate
{
    UITabBarController *_tabBarController;
    BOOL _isauth;
    LoginResult *_login;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id auth = [defaults loadCustomObjectWithKey:kTKPD_AUTHKEY];
    _login = auth;
    _isauth = _login.is_login;
    
    [self adjustnavigationbar];
    
    // for setting status bar
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor greenColor];
    [self.window makeKeyAndVisible];
    
    [self createtabbarController];
    [self adjusttabbar];
    
    // Register for changes in network availability
    NSNotificationCenter* ns = [NSNotificationCenter defaultCenter];
    [ns addObserver:self selector:@selector(applicationLogin:) name:TKPD_ISLOGINNOTIFICATIONNAME object:nil];
//    [center addObserver:self selector:@selector(reachabilityDidChange:) name:RKReachabilityDidChangeNotification object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - methods
-(void)createtabbarController
{
    _tabBarController = [UITabBarController new];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : kTKPDNAVIGATION_TABBARTITLECOLOR }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : kTKPDNAVIGATION_TABBARACTIVETITLECOLOR }
                                             forState:UIControlStateSelected];
    
    /** TAB BAR INDEX 1 **/
    /** adjust view controllers at tab bar controller **/
    NSMutableArray *viewcontrollers = [NSMutableArray new];
    /** create new view controller **/
    if (!_isauth) {
        // before login
        HotlistViewController *v = [HotlistViewController new];
        [viewcontrollers addObject:v];
    }
    else{
        // after login
        HotlistViewController *v = [HotlistViewController new];
        [viewcontrollers addObject:v];
        ProductFeedViewController *v1 = [ProductFeedViewController new];
        [viewcontrollers addObject:v1];
        ProductFeedViewController *v2 = [ProductFeedViewController new];
        [viewcontrollers addObject:v2];
        ProductFeedViewController *v3 = [ProductFeedViewController new];
        [viewcontrollers addObject:v3];
    }

    NSArray *titles = kTKPD_HOMETITLEARRAY;
    /** Adjust View Controller **/
    TKPDTabHomeNavigationController *swipevc = [TKPDTabHomeNavigationController new];
    UINavigationController *swipevcNav = [[UINavigationController alloc]initWithRootViewController:swipevc];
    [swipevc setViewControllers:viewcontrollers animated:YES withtitles:titles];
    [swipevc setSelectedIndex:0];
    //[swipevc AdjustViewControllers:viewcontrollers withtitles:titles];
    [swipevcNav.navigationBar setTranslucent:NO];
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [swipevc.navigationItem setTitleView:logo];
    
    
    /** TAB BAR INDEX 2 **/
    CategoryViewController *categoryvc = [CategoryViewController new];
    UINavigationController *categoryNavBar = [[UINavigationController alloc]initWithRootViewController:categoryvc];
    [categoryNavBar.navigationBar setTranslucent:NO];
    
    /** TAB BAR INDEX 3 **/
    SearchViewController *search = [SearchViewController new];
    UINavigationController *searchNavBar = [[UINavigationController alloc]initWithRootViewController:search];
    [searchNavBar.navigationBar setTranslucent:NO];
    
    /** TAB BAR INDEX 4 **/
    CartViewController *cart = [CartViewController new];
    UINavigationController *cartNavBar = [[UINavigationController alloc]initWithRootViewController:cart];
    [cartNavBar.navigationBar setTranslucent:NO];
    
    /** TAB BAR INDEX 5 **/
    UINavigationController *moreNavBar;
    if (!_isauth) {
        LoginViewController *more = [LoginViewController new];
        moreNavBar = [[UINavigationController alloc]initWithRootViewController:more];
    }
    else{
        LogoutViewController *more = [LogoutViewController new];
        moreNavBar = [[UINavigationController alloc]initWithRootViewController:more];
    }
    [moreNavBar.navigationBar setTranslucent:NO];
    
    /** for ios 7 need to set automatically adjust scrooll view inset **/
    if([self respondsToSelector:@selector(setExtendedLayoutIncludesOpaqueBars:)])
    {
        swipevc.extendedLayoutIncludesOpaqueBars = YES;
        categoryvc.extendedLayoutIncludesOpaqueBars = YES;
        search.extendedLayoutIncludesOpaqueBars = YES;
        cart.extendedLayoutIncludesOpaqueBars = YES;
        //more.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    NSArray* controllers = [NSArray arrayWithObjects:swipevcNav, categoryNavBar, searchNavBar, cartNavBar, moreNavBar, nil];
    _tabBarController.viewControllers = controllers;
    //tabBarController.tabBarItem.title = nil;

    _window.rootViewController = _tabBarController;
    
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
    
    [tabBarItem1 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamLight" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
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
      [UIFont fontWithName:@"GothamLight" size:9.0], UITextAttributeFont,
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
      [UIFont fontWithName:@"GothamLight" size:9.0], UITextAttributeFont,
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
      [UIFont fontWithName:@"GothamLight" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
    /** set tab bar item 5*/
    image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_MORE];
    image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_MORE];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem5 setImage:image];
        [tabBarItem5 setSelectedImage:image_active];
    }
    else
        [tabBarItem5 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    //tabBarItem5.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem5.title = kTKPDNAVIGATION_TABBARTITLEARRAY[4];
    [tabBarItem5 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamLight" size:9.0], UITextAttributeFont,
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
}

- (void)adjustnavigationbar
{
    
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
    
	NSBundle* bundle = [NSBundle mainBundle];
	UIImage* image;
	id proxy = [UINavigationBar appearance];

	image = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_NAVBARBG ofType:@"png"]]; //navigation-bg
	//image = [[[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"image-1" ofType:@"png"]] resizableImageWithCapInsets:kJYNAVIGATION_BACKGROUNDINSET];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        [proxy setBarTintColor:kTKPDNAVIGATION_NAVIGATIONBGCOLOR];
    }
    else
    {
        [proxy setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        //[proxy setTintColor:[UIColor colorWithRed:(66/255.0) green:(189/255.0) blue:(65/255.0) alpha:1]];
    }
	//[proxy setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
	//[proxy setTitleVerticalPositionAdjustment:kJYNAVIGATION_ITEMVERTICALADJUSTMENT forBarMetrics:UIBarMetricsDefault];	//TODO: navigation bar animation corruption
        
	[proxy setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:kTKPDNAVIGATION_TITLEFONT, UITextAttributeFont,kTKPDNAVIGATION_TITLECOLOR, UITextAttributeTextColor, kTKPDNAVIGATION_TITLESHADOWCOLOR, UITextAttributeTextShadowColor, nil]];
	
	proxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
	image = [[[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"navigation-button-bg-pt" ofType:@"png"]] resizableImageWithCapInsets:kTKPDNAVIGATION_BUTTONINSET]; //navigation button bg pt
	[proxy setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[proxy setBackgroundImage:image forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	//[proxy setBackgroundVerticalPositionAdjustment:kJYNAVIGATION_ITEMVERTICALADJUSTMENT forBarMetrics:UIBarMetricsDefault];	//TODO: navigation bar animation corruption
	
	image = [[[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"navigation-button" ofType:@"png"]] resizableImageWithCapInsets:kTKPDNAVIGATION_BACKBUTTONINSET];
	[proxy setBackButtonBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[proxy setBackButtonBackgroundImage:image forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	//[proxy setBackButtonBackgroundVerticalPositionAdjustment:kJYNAVIGATION_ITEMVERTICALADJUSTMENT forBarMetrics:UIBarMetricsDefault];	//TODO: navigation bar animation corruption

    #endif
}

#pragma mark - Notification observers

- (void)applicationLogin:(NSNotification*)notification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id auth = [defaults loadCustomObjectWithKey:kTKPD_AUTHKEY];
    _login = auth;
    _isauth = _login.is_login;
    
	// Assume tabController is the tab controller
    // and newVC is the controller you want to be the new view controller at index 0
    NSMutableArray *newControllers = [NSMutableArray arrayWithArray:_tabBarController.viewControllers];
    
    // after login
    NSMutableArray *viewcontrollers = [NSMutableArray new];
    if (!_isauth) {
        // before login
        HotlistViewController *v = [HotlistViewController new];
        [viewcontrollers addObject:v];
    }
    else{
        // after login
        HotlistViewController *v = [HotlistViewController new];
        [viewcontrollers addObject:v];
        ProductFeedViewController *v1 = [ProductFeedViewController new];
        [viewcontrollers addObject:v1];
        ProductFeedViewController *v2 = [ProductFeedViewController new];
        [viewcontrollers addObject:v2];
        ProductFeedViewController *v3 = [ProductFeedViewController new];
        [viewcontrollers addObject:v3];
    }

    NSArray *titles = kTKPD_HOMETITLEARRAY;
    /** Adjust View Controller **/
    TKPDTabHomeNavigationController *swipevc = [TKPDTabHomeNavigationController new];
    UINavigationController *swipevcNav = [[UINavigationController alloc]initWithRootViewController:swipevc];
    [swipevc setViewControllers:viewcontrollers animated:YES withtitles:titles];
    [swipevc setSelectedIndex:0];
    //[swipevc AdjustViewControllers:viewcontrollers withtitles:titles];
    [swipevcNav.navigationBar setTranslucent:NO];
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [swipevc.navigationItem setTitleView:logo];
    
    UINavigationController *moreNavBar;
    if (!_isauth) {
        LoginViewController *more = [LoginViewController new];
        moreNavBar = [[UINavigationController alloc]initWithRootViewController:more];
    }
    else{
        LogoutViewController *more = [LogoutViewController new];
        moreNavBar = [[UINavigationController alloc]initWithRootViewController:more];
    }
    [moreNavBar.navigationBar setTranslucent:NO];
    
    [newControllers replaceObjectAtIndex:0 withObject:swipevcNav];
    [newControllers replaceObjectAtIndex:4 withObject:moreNavBar];
    
    [_tabBarController setViewControllers:newControllers animated:YES];
    
    [self adjusttabbar];
}

#pragma mark -
#pragma mark Methods availability
- (void)reachabilityChanged:(NSNotification *)notification
{
    RKObjectManager *objectManager =  [RKObjectManager sharedClient];

    //TODO:: set reachability
    //[objectManager.HTTPClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
    //    if (status == AFNetworkReachabilityStatusNotReachable) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
    //                                                        message:@"You must be connected to the internet to use this app."
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"OK"
    //                                              otherButtonTitles:nil];
    //        [alert show];
    //    }
    //}];
}


@end
