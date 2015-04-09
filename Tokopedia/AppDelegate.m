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
#import "NotificationManager.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Helpshift.h"

@implementation AppDelegate
{
    UITabBarController *_tabBarController;
    BOOL _isauth;
    NSDictionary* _parameters;
    
    BOOL _isalertshown;
	RKObjectManager* _objectManager;
    NSError *_error;
}

@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     NSLog(@"path:%@",[[NSBundle mainBundle]bundlePath]);
    
    [Fabric with:@[CrashlyticsKit]];
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 20;
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-9801603-10"];
    
//    [Helpshift installForApiKey:@"a61b53892e353d1828be5154db0ac6c2" domainName:@"tokopedia.helpshift.com" appID:@"tokopedia_platform_20150407082530564-f41c14c841c644e"];
    
    [self adjustnavigationbar];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#ifdef __IPHONE_8_0
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
#endif
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    // for setting status bar
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_window.tag = 0xCAFEBABE;	//used globally to identify main application window
	_window.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

//#ifdef __IPHONE_7_0
//	if ([_window respondsToSelector:@selector(setTintColor:)]) {
//		_window.tintColor = kTKPDWINDOW_TINTLCOLOR;	//compatibility
//	}
//#endif
	
    _viewController = [MainViewController new];

    _window.backgroundColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
	_window.rootViewController = _viewController;
	[_window makeKeyAndVisible];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self didFinishLaunchingWithOptionsQueued];
	});
    
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)applicationDidBecomeActive:(UIApplication *)application {    
    // Logs 'install' and 'app activate' App Events.
    [FBAppEvents activateApp];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //opened when application is on background
    if(application.applicationState == UIApplicationStateInactive ||
       application.applicationState == UIApplicationStateBackground) {
        NotificationManager *notifManager = [NotificationManager new];
        [notifManager selectViewControllerToOpen:[[userInfo objectForKey:@"data"] objectForKey:@"tkp_code"]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadNotification" object:self];
    }
}

- (void)didFinishLaunchingWithOptionsQueued
{
	[self performSelector:@selector(monitornetwork) withObject:nil afterDelay:1.0];	//minimize app launch process
	
	UIApplication* application = [UIApplication sharedApplication];
	application.applicationIconBadgeNumber = (0 + 0);	//reset app badge on launch
	
	[self preparepersistencedata];
}

#pragma mark - methods
- (void)adjustnavigationbar
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
    //navigation background
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_NAVBARBG ofType:@"png"]];
    
    id proxy = [UINavigationBar appearance];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) { // iOS 7
        [proxy setBarTintColor:kTKPDNAVIGATION_NAVIGATIONBGCOLOR];
    } else {
        [proxy setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    [proxy setTintColor:[UIColor whiteColor]];
    
    NSDictionary *titleTextAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         kTKPDNAVIGATION_TITLEFONT, UITextAttributeFont,
                                         kTKPDNAVIGATION_TITLECOLOR, UITextAttributeTextColor,
                                         kTKPDNAVIGATION_TITLESHADOWCOLOR, UITextAttributeTextShadowColor, nil];
	[proxy setTitleTextAttributes:titleTextAttributes];
	proxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
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

- (void)receiveStickyMessage:(NSNotification *) notification
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
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:kTKPDNETWORK_ERRORTITLE message:kTKPDNETWORK_ERRORDESCS delegate:self cancelButtonTitle:kTKPDBUTTON_OKTITLE otherButtonTitles:nil];
            [alert show];			
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

#pragma mark - Facebook login

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}


@end
