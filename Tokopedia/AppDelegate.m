 //
//  AppDelegate.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "AppDelegate.h"

#import "MainViewController.h"
#import "TKPDSecureStorage.h"
#import "StickyAlert.h"

@implementation AppDelegate
{
    UITabBarController *_tabBarController;
    BOOL _isauth;
    NSDictionary* _parameters;
    NSDictionary* _auth;
    
    BOOL _isalertshown;
	RKObjectManager* _objectManager;
    NSError *_error;
}

@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     NSLog(@"path:%@",[[NSBundle mainBundle]bundlePath]);
    //[self monitornetwork];
    
    [self adjustnavigationbar];
    
    // for setting status bar
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:kTKPDNETWORK_ERRORTITLE message:kTKPDNETWORK_ERRORDESCS delegate:self cancelButtonTitle:kTKPDBUTTON_OKTITLE otherButtonTitles:nil];
//    alert.delegate = self;
//    [alert show];
    
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_window.tag = 0xCAFEBABE;	//used globally to identify main application window
	_window.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//#ifdef __IPHONE_7_0
//	if ([_window respondsToSelector:@selector(setTintColor:)]) {
//		_window.tintColor = kTKPDWINDOW_TINTLCOLOR;	//compatibility
//	}
//#endif
	
    _viewController = [MainViewController new];

	//_viewController.data = _parameters;
	//_parameters = nil;
    _window.backgroundColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
	_window.rootViewController = _viewController;
	[_window makeKeyAndVisible];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self didFinishLaunchingWithOptionsQueued];
	});
	
    //TODO:: CACHE
    //NSlog(@"window frame: %@", NSStringFromCGRect(_window.frame));
    //NSlog(@"tabbar frame: %@", NSStringFromCGRect(_viewController.view.frame));
    //
    //NSURLCache* cache = [NSURLCache sharedURLCache];
    //NSLOG(@"nsurlcache capacity:%dKB, %dKB - current:%dKB, %dKB", cache.memoryCapacity >> 10, cache.diskCapacity >> 10, cache.currentMemoryUsage >> 10, cache.currentDiskUsage >> 10);
    ////[cache removeAllCachedResponses];

    
    return YES;
}

- (void)didFinishLaunchingWithOptionsQueued
{
	[self performSelector:@selector(monitornetwork) withObject:nil afterDelay:1.0];	//minimize app launch process
	
	UIApplication* application = [UIApplication sharedApplication];
	application.applicationIconBadgeNumber = (0 + 0);	//reset app badge on launch
	
	[self preparepersistencedata];
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
- (void)adjustnavigationbar
{
    
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
    
	NSBundle* bundle = [NSBundle mainBundle];
	UIImage* image;
	id proxy = [UINavigationBar appearance];

	image = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_NAVBARBG ofType:@"png"]]; //navigation-bg
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) { // iOS 7
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

    //image = [[[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_NAVBARBG ofType:@"png"]] resizableImageWithCapInsets:kTKPDNAVIGATION_BUTTONINSET resizingMode:UIImageResizingModeStretch];
    //
    //[proxy setBackButtonBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //[proxy setBackButtonBackgroundImage:image forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

	//[proxy setBackButtonBackgroundVerticalPositionAdjustment:kJYNAVIGATION_ITEMVERTICALADJUSTMENT forBarMetrics:UIBarMetricsDefault];	//TODO: navigation bar animation corruption

#endif
}

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveStickyMessage:)
                                                 name:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveStickyMessage:)
                                                 name:kTKPD_SETUSERSTICKYERRORMESSAGEKEY
                                               object:nil];
    
    return self;
}

- (void) receiveStickyMessage:(NSNotification *) notification
{
    
    StickyAlert *stickyalert = [[StickyAlert alloc]init];
    
    UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topRootViewController.presentedViewController) {
        topRootViewController = topRootViewController.presentedViewController;
    }
    
    [stickyalert initView:topRootViewController.view];
    NSArray *string = [notification.userInfo objectForKey:@"messages"];
    
    if ([[notification name] isEqualToString:kTKPD_SETUSERSTICKYERRORMESSAGEKEY]) {
        [stickyalert alertError:string];
    }
    
    if ([[notification name] isEqualToString:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY]) {
        [stickyalert alertSuccess:string];
    }

}




#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	_isalertshown = NO;
}

#pragma mark -
#pragma mark Methods availability

- (void)monitornetwork
{
	_isalertshown = NO;
	_isNetworkAvailable = YES;
	_isNetworkWiFi = NO;
	_isPushNotificationRegistered = NO;
	
    //_objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kTKPD_REACHABILITYURL]];
	_objectManager = [RKObjectManager sharedClient];
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
	[_objectManager.HTTPClient setReachabilityStatusChangeBlock:
	 ^(AFNetworkReachabilityStatus status)
	 {
		 if (status == AFNetworkReachabilityStatusNotReachable) {
			 _isNetworkAvailable = NO;
		 } else {
			 _isNetworkAvailable = YES;
		 }
		 
		 if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
			 _isNetworkWiFi = YES;
		 } else {
			 _isNetworkWiFi = NO;
		 }
		 
		 if (!_isNetworkAvailable) {
			 [self performSelector:@selector(shownetworkalert) withObject:nil afterDelay:kTKPD_REACHABILITYDELAY];
			 
		 } else {
             //TODO:: push notification
			 if (!_isPushNotificationRegistered) {
				 [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
			 }
		 }
	 }
	 ];
#pragma clang diagnostic pop
}

- (void)shownetworkalert
{
	if (!_isNetworkAvailable) {
		
		if (!_isalertshown) {
			_isalertshown = YES;
			
            //TODO::alert view crash customButtonCell
            //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:kTKPDNETWORK_ERRORTITLE message:kTKPDNETWORK_ERRORDESCS delegate:self cancelButtonTitle:kTKPDBUTTON_OKTITLE otherButtonTitles:nil];
            //[alert show];
            NSLog(@"%@ : %@ NETWORK NOT AVAILABLE",[self class], NSStringFromSelector(_cmd));
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_INTERRUPTNOTIFICATIONNAMEKEY object:self userInfo:nil];
		}
	}
}

#pragma mark - Methods persistence
- (void)preparepersistencedata
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* application = [defaults dictionaryForKey:kTKPD_APPLICATIONKEY]; //TODO::Set default data(edit profile dll)
	
    // To know is application installed
	BOOL installed = [[application objectForKey:kTKPD_INSTALLEDKEY]boolValue];
	if (!installed) {
		
		NSMutableDictionary* mutable = (application != nil) ? [application mutableCopy] : [[NSMutableDictionary alloc] initWithCapacity:1];
		[mutable setValue:@(YES) forKey:kTKPD_INSTALLEDKEY];
		[defaults setObject:mutable forKey:kTKPD_APPLICATIONKEY];
		//[defaults synchronize];
		
		TKPDSecureStorage* storage = [TKPDSecureStorage standardKeyChains];
		[storage resetKeychain];	//clear all previous sensitive data
	}
}


@end
