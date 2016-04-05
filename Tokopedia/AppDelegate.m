//
//  AppDelegate.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "MainViewController.h"
#import "TKPDSecureStorage.h"
#import "AppsFlyerTracker.h"
#import "Localytics.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleAppIndexing/GoogleAppIndexing.h>
#import <Google/Analytics.h>
#import "NavigateViewController.h"
#import "DeeplinkController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Rollout/Rollout.h>
#import "FBTweakShakeWindow.h"

#ifdef DEBUG
#import "FlexManager.h"
#endif

@implementation AppDelegate

@synthesize viewController = _viewController;

#ifdef DEBUG
- (void)onThreeFingerTap {
    [[FLEXManager sharedManager] showExplorer];
}

- (void)showFlexManagerOnSecretGesture {
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onThreeFingerTap)];
    gesture.numberOfTouchesRequired = 3;
    gesture.cancelsTouchesInView = YES;
    [_window addGestureRecognizer:gesture];
}
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    

    [self hideTitleBackButton];
    
    _viewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
    _window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _window.backgroundColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
    _window.rootViewController = _viewController;
    [_window makeKeyAndVisible];
    
#ifdef DEBUG
    [self showFlexManagerOnSecretGesture];
#endif
    
    [Rollout setupWithKey:@"56a717aed7bed00574f5169c"
#ifdef DEBUG
        developmentDevice:YES
#endif
     ];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Init Fabric
        [Fabric with:@[CrashlyticsKit]];

        // Configure Third Party Apps
        [self configureGTMInApplication:application withOptions:launchOptions];
        [self configureLocalyticsInApplication:application withOptions:launchOptions];
        [self configureAppsflyer];
        [self configureAppIndexing];
        [self configureGoogleAnalytics];
        [self configurePushNotificationsInApplication:application];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

        [GMSServices provideAPIKey:@"AIzaSyBxw-YVxwb9BQ491BikmOO02TOnPIOuYYU"];
        
        [self preparePersistData];
        
        //change app language for google mapp address become indonesia
        NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if (![[languages firstObject] isEqualToString:@"id"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@[@"id"] forKey:@"AppleLanguages"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
    
    //opening URL in background state
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
        if(url) {
            [DeeplinkController handleURL:url];
        } else {
            //universal search link, only available in iOS 9
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
                NSDictionary *userActivityDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
                if (userActivityDictionary) {
                    [userActivityDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[NSUserActivity class]]) {
                            NSUserActivity *userActivity = obj;
                            NSURL *url = userActivity.webpageURL;
                            [DeeplinkController handleURL:url];
                        }
                    }];
                }
            }
        }

    });
    BOOL didFinishLaunching = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                       didFinishLaunchingWithOptions:launchOptions];
    return didFinishLaunching;
}

- (void)configureAppIndexing {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [[GSDAppIndexing sharedInstance] registerApp:1001394201];
    }
}

- (void)configureGoogleAnalytics {
    //Google Analytics init
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 60;
    [[GAI sharedInstance] trackerWithTrackingId:GATrackingId];
    [[[GAI sharedInstance] trackerWithTrackingId:GATrackingId] setAllowIDFACollection:YES];
}

- (void)configureAppsflyer {
    //appsflyer init
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"SdSopxGtYr9yK8QEjFVHXL";
    [AppsFlyerTracker sharedTracker].appleAppID = @"1001394201";
    [AppsFlyerTracker sharedTracker].currencyCode = @"IDR";
}

- (void)configureGTMInApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {
    //GTM init
    _tagManager = [TAGManager instance];
    [_tagManager.logger setLogLevel:kTAGLoggerLogLevelVerbose];
    
    NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if(url != nil) {
        [_tagManager previewWithUrl:url];
        [DeeplinkController handleURL:url];
    }
    
    [TAGContainerOpener openContainerWithId:@"GTM-NCTWRP"   // Update with your Container ID.
                                 tagManager:self.tagManager
                                   openType:kTAGOpenTypePreferFresh
                                    timeout:nil
                                   notifier:self];
}

- (void)configureLocalyticsInApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {
    [Localytics autoIntegrate:@"97b3341c7dfdf3b18a19401-84d7f640-4d6a-11e5-8930-003e57fecdee"
                launchOptions:launchOptions];
#ifdef DEBUG
    [Localytics setTestModeEnabled:YES];
    [Localytics tagEvent:@"Developer Options"];
#endif
}

- (void)configurePushNotificationsInApplication:(UIApplication *)application {
    // If you are using Localytics Messaging include the following code to register for push notifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)] ||
        [application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    [[AppsFlyerTracker sharedTracker]trackAppLaunch];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    
    NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [secureStorage setKeychainWithValue:deviceTokenString withKey:kTKPD_DEVICETOKENKEY];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //opened when application is on background
    if(application.applicationState == UIApplicationStateInactive ||
       application.applicationState == UIApplicationStateBackground) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TokopediaNotificationRedirect object:nil userInfo:userInfo];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:TokopediaNotificationReload object:self];
    }
    if ([userInfo objectForKey:@"Localytics Campaign"]) {
        NSString *campaign = [userInfo objectForKey:@"Localytics Campaign"];
        NSDictionary *attributes = @{@"Campaign" : campaign};
        [Localytics tagEvent:@"Event : App Launch" attributes:attributes];
    }
    if ([userInfo objectForKey:@"Localytics Deeplink"]) {
        NSURL *url = [NSURL URLWithString:[userInfo objectForKey:@"Localytics Deeplink"]];
        [DeeplinkController handleURL:url];
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL shouldOpenURL = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                        openURL:url
                                                              sourceApplication:sourceApplication
                                                                     annotation:annotation];
    if (shouldOpenURL) {
        return YES;
    } else if ([GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation]) {
        return YES;
    } else if ([self.tagManager previewWithUrl:url]) {
        return YES;
    } else if ([Localytics handleTestModeURL:url]) {
        return YES;
    } else if ([DeeplinkController handleURL:url]) {
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    NSURL *url;
    BOOL shouldContinue = NO;
    if ([userActivity.activityType isEqualToString:@"com.apple.corespotlightitem"]) {
        NSString *activityIdentifier = [userActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"];
        url = [NSURL URLWithString:activityIdentifier];
    } else {
        url = userActivity.webpageURL;
    }
    if (url) {
        [DeeplinkController handleURL:url];
        shouldContinue = YES;
    }
    return shouldContinue;
}

#pragma mark - reset persist data if freshly installed
- (void)preparePersistData
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* application = [defaults dictionaryForKey:kTKPD_APPLICATIONKEY];
    
    BOOL isInstalled = [[application objectForKey:kTKPD_INSTALLEDKEY]boolValue];
    if (!isInstalled) {
        NSMutableDictionary* mutable = (application != nil) ? [application mutableCopy] : [[NSMutableDictionary alloc] initWithCapacity:1];
        [mutable setValue:@(YES) forKey:kTKPD_INSTALLEDKEY];
        [defaults setObject:mutable forKey:kTKPD_APPLICATIONKEY];
        
        TKPDSecureStorage* storage = [TKPDSecureStorage standardKeyChains];
        [storage resetKeychain];
    }
}

- (void)containerAvailable:(TAGContainer *)container {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.container = container;
    });
}

- (void)hideTitleBackButton {
    //hide title back button globally
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}
@end
