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
#import <AppsFlyer/AppsFlyer.h>
#import <GoogleAppIndexing/GoogleAppIndexing.h>
#import "NavigateViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "FBTweakShakeWindow.h"
#import <JLPermissions/JLNotificationPermission.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "Tokopedia-Swift.h"
#import <Appsee/Appsee.h>
#import "JLRoutes.h"
#import <MoEngage_iOS_SDK/MoEngage.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "ReactViewController.h"
#import "UserContainerViewController.h"
#import "HybridNavigationManager.h"
#import <AppHub/AppHub.h>
#import "ProcessingAddProducts.h"
#import "UIApplication+React.h"

#ifdef DEBUG
#import "FlexManager.h"
#endif

@implementation AppDelegate

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

- (BOOL)shouldShowOnboarding {
    BOOL hasShownOnboarding = [[NSUserDefaults standardUserDefaults] boolForKey:@"has_shown_onboarding"];
    
    BOOL alwaysShowOnboarding = FBTweakValue(@"Onboarding", @"General", @"Always show onboarding", NO);
    
    BOOL shouldShowOnboarding = alwaysShowOnboarding?YES:!hasShownOnboarding;
    return shouldShowOnboarding;
}

- (UIViewController*)frontViewController {
    return [self shouldShowOnboarding]?
        [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil]:
        [MainViewController new];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    [[MoEngage sharedInstance] userNotificationCenter:center didReceiveNotificationResponse:response];
    NSDictionary *pushNotificationData = response.notification.request.content.userInfo;
    if (pushNotificationData) {
        [self handlePushNotificationWithData:pushNotificationData];
    }
    
    completionHandler();
}

#pragma mark AppNavigationDelegate

- (void)openViewWithName:(NSString *)name andParams:(NSDictionary *)params
{
    if ([name isEqualToString:@"tproutes"]) {
        NSString* url = params[@"url"];

        [TPRoutes routeURL:[NSURL URLWithString:url]];
        return;
    }
    
    ReactViewController *reactView = [[ReactViewController alloc]
                                      initWithDelegate:self
                                      bridge:[UIApplication sharedApplication].reactBridge
                                      viewName:name
                                      viewParams:params];
    
    [_nav pushViewController:reactView animated:true];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UNUserNotificationCenter* notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    notificationCenter.delegate = self;

    [TPRoutes configureRoutes];
    [AppHub setApplicationID:@"lpyi0FLrC4LNGTm6R7UJ"];
    
    [self startAppsee];
    [self hideTitleBackButton];
    [JLRoutes setShouldDecodePlusSymbols:NO];
    
    UIViewController* viewController = [self frontViewController];
    _window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _window.backgroundColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
    _window.rootViewController = viewController;
    _nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [_window makeKeyAndVisible];
    
#ifdef DEBUG
    [self showFlexManagerOnSecretGesture];
#endif
        
    dispatch_async(dispatch_get_main_queue(), ^{
        // Init Fabric
        [Fabric with:@[CrashlyticsKit]];

        // Configure Third Party Apps
        [self configureGTMInApplication:application withOptions:launchOptions];
        [self configureLocalyticsInApplication:application withOptions:launchOptions];
        [self configureAppsflyer];
        [self configureAppIndexing];
        [self configureGoogleAnalytics];
        [self configureMoEngageInApplication:application withLaunchOptions:launchOptions];
        [self sendAppStatusToMoEngage];
        
        [[AFRKNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

        [GMSServices provideAPIKey:@"AIzaSyBxw-YVxwb9BQ491BikmOO02TOnPIOuYYU"];
        
        [self preparePersistData];
        
        //register quick action items
        [[QuickActionHelper sharedInstance] registerShortcutItems];
        
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
            [TPRoutes routeURL:url];
        } else {
            //universal search link, only available in iOS 9
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
                NSDictionary *userActivityDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
                if (userActivityDictionary) {
                    [userActivityDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[NSUserActivity class]]) {
                            NSUserActivity *userActivity = obj;
                            NSURL *url = userActivity.webpageURL;
                            [TPRoutes routeURL:url];
                        }
                    }];
                }
            }
        }
        
        NSDictionary *pushNotificationData = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationData) {
            
            [self handlePushNotificationWithData:pushNotificationData];
        }
    });
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.1")) {
        //opening Quick Action in background state
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
            if(shortcutItem){
                [[QuickActionHelper sharedInstance] handleQuickAction:shortcutItem];
            }
        });
    }
    
    BOOL didFinishLaunching = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                       didFinishLaunchingWithOptions:launchOptions];
    return didFinishLaunching;
}

-(void)startAppsee{
    [Appsee start:@"f2c02b28ccd54635a7c73eb9dac5038f"];
}

- (void)handlePushNotificationWithData:(NSDictionary *)pushNotificationData {
    if ([pushNotificationData objectForKey:@"url_deeplink"]) {
        NSURL *url = [NSURL URLWithString:[pushNotificationData objectForKey:@"url_deeplink"]];
        [TPRoutes routeURL:url];
    } else if ([pushNotificationData objectForKey:@"moe_deeplink"]) {
        NSURL *url = [NSURL URLWithString:[pushNotificationData objectForKey:@"moe_deeplink"]];
        [TPRoutes routeURL:url];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:TokopediaNotificationRedirect
                                                            object:nil
                                                          userInfo:pushNotificationData];
    }
}

- (void)configureAppIndexing {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
//        [[GSDAppIndexing sharedInstance] registerApp:1001394201];
    }
}

- (void)configureMoEngageInApplication:(UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
    [[MoEngage sharedInstance] initializeDevWithApiKey:@"LNCME8HVKUEJIGXE2N0698H0" inApplication:application withLaunchOptions:launchOptions openDeeplinkUrlAutomatically:YES];
    [MoEngage debug:LOG_ALL];
#else
    [[MoEngage sharedInstance] initializeProdWithApiKey:@"LNCME8HVKUEJIGXE2N0698H0" inApplication:application withLaunchOptions:launchOptions openDeeplinkUrlAutomatically:YES];
#endif
}

- (NSString *)getGAPropertyID {
    return @"UA-9801603-10";
}

- (void)configureGoogleAnalytics {
    //Google Analytics init
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:[self getGAPropertyID]];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 60;
    [[GAI sharedInstance] setDryRun:NO];
    [[[GAI sharedInstance] trackerWithTrackingId:[self getGAPropertyID]] setAllowIDFACollection:YES];
}

- (void)configureAppsflyer {
    //appsflyer init
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"SdSopxGtYr9yK8QEjFVHXL";
    [AppsFlyerTracker sharedTracker].appleAppID = @"1001394201";
    [AppsFlyerTracker sharedTracker].currencyCode = @"IDR";
    #ifdef DEBUG
    [AppsFlyerTracker sharedTracker].isDebug = YES;
    #endif
}

- (void)configureGTMInApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {
    //GTM init
    _tagManager = [TAGManager instance];
    [_tagManager.logger setLogLevel:kTAGLoggerLogLevelVerbose];
    
    NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if(url != nil) {
        [_tagManager previewWithUrl:url];
    }
    
    [TAGContainerOpener openContainerWithId:@"GTM-NCTWRP"   // Update with your Container ID.
                                 tagManager:self.tagManager
                                   openType:kTAGOpenTypePreferFresh
                                    timeout:nil
                                   notifier:self];
}

- (BOOL)shouldShowLocalyticsTab {
    return FBTweakValue(@"Localytics Tab", @"General", @"Show Localytics Tab", NO);
}

- (void)configureLocalyticsInApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {
    [Localytics autoIntegrate:@"97b3341c7dfdf3b18a19401-84d7f640-4d6a-11e5-8930-003e57fecdee"
                launchOptions:launchOptions];
#ifdef DEBUG
    [Localytics setTestModeEnabled:[self shouldShowLocalyticsTab]];
    [Localytics tagEvent:@"Developer Options"];
#endif
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    [[AppsFlyerTracker sharedTracker]trackAppLaunch];
    
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    
    if ([userManager isLogin]) {
        if (![[userManager getUserEmail] isEqualToString:@"0"]) {
            [AnalyticsManager moEngageTrackUserAttributes];
        } else {
            [UserRequest getUserInformationWithUserID:[userManager getUserId]
                                            onSuccess:^(ProfileInfo * _Nonnull profile) {
                                                [AnalyticsManager moEngageTrackUserAttributes];
                                            }
                                            onFailure:^{
                                                
                                            }];
        }
    }
    
    // we always refresh device token, to recover from a bug in 1.80
    // that causes every device to use 'SIMULATORDUMMY'.
    // this is also a solution to retrieve device token after a user
    // activates push notification from iOS settings.
    [self refreshDeviceTokenIfAuthorized];
}

- (void)refreshDeviceTokenIfAuthorized {
    JLNotificationPermission* permission = [JLNotificationPermission sharedInstance];
    if (permission.authorizationStatus == JLPermissionAuthorized) {
        [permission authorize:nil];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    [[JLNotificationPermission sharedInstance] notificationResult:deviceToken error:nil];

    [[AppsFlyerTracker sharedTracker] registerUninstall:deviceToken];

    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    
    NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [secureStorage setKeychainWithValue:deviceTokenString withKey:kTKPD_DEVICETOKENKEY];
    
    [[MoEngage sharedInstance] registerForPush:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[JLNotificationPermission sharedInstance] notificationResult:nil error:error];
    [[MoEngage sharedInstance] didFailToRegisterForPush];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[MoEngage sharedInstance] didReceieveNotificationinApplication:application withInfo:userInfo openDeeplinkUrlAutomatically:YES];
    
    //opened when application is on background
    if(application.applicationState == UIApplicationStateInactive ||
       application.applicationState == UIApplicationStateBackground) {
        [self handlePushNotificationWithData:userInfo];
    } else {
        [self handlePushNotificationWithData:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:TokopediaNotificationReload object:self];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [[MoEngage sharedInstance] didRegisterForUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [UIViewController showNotificationWithMessage:notification.alertBody type:NotificationTypeError duration:10.0 buttonTitle:notification.userInfo[@"button_title"] dismissable:YES action:^{
            [self handlePushNotificationWithData:notification.userInfo];
        }];
    });
    
    notification.fireDate = nil;
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    [self handlePushNotificationWithData:notification.userInfo];
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
    } else if ([[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation]) {
        return YES;
    } else if ([self.tagManager previewWithUrl:url]) {
        return YES;
    } else if ([Localytics handleTestModeURL:url]) {
        return YES;
    } else if([TPRoutes routeURL: url]) {
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
        [TPRoutes routeURL: url];
        shouldContinue = YES;
    }
    return shouldContinue;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    [[QuickActionHelper sharedInstance] handleQuickAction:shortcutItem];
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

#pragma mark - Send app status to MoEngage

- (NSString *)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (void)saveAppVersionToDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:[self getAppVersion] forKey:@"app version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sendAppStatusToMoEngage {
    // check install. if app version does not exist in defaults, it means it is an install for sure.
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"app version"]) {
        [[MoEngage sharedInstance] appStatus:INSTALL];
        [self saveAppVersionToDefaults];
        return;
    }
    
    // It is an update. Check if the latest app version is greater than that saved in the user defaults
    if(![[self getAppVersion] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"app version"]]) {
        [[MoEngage sharedInstance] appStatus:UPDATE];
        [self saveAppVersionToDefaults];
    }
}

@end
