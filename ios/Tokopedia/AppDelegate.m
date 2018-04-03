//
//  AppDelegate.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import <SystemConfiguration/SystemConfiguration.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "MainViewController.h"
#import "TKPDSecureStorage.h"
#import <AppsFlyer/AppsFlyer.h>
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
#import "ReactHybridViewController.h"
#import "HybridNavigationManager.h"
#import "UIApplication+React.h"
#import "lecore.h"

@import NativeNavigation;
@import GooglePlaces;
@import Fabric;
@import Crashlytics;

#ifdef DEBUG
@import FLEX;
@import HockeySDK;
#import "ReactOnboardingHelper.h"
#endif
@import FirebaseCore;

@interface AppDelegate(Extensions) <ReactNavigationCoordinatorDelegate>
@end

@implementation AppDelegate {
}

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
    
    BOOL alwaysShowOnboarding = FBTweakValue(@"Others", @"Onboarding", @"Always show onboarding", NO);
    
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
        [self didReceiveNotificationBackgroundState:pushNotificationData];
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
    
    ReactHybridViewController *reactView = [[ReactHybridViewController alloc]
                                      initWithDelegate:self
                                      bridge:[UIApplication sharedApplication].reactBridge
                                      viewName:name
                                      viewParams:params];
    [[UIApplication topViewController].navigationController pushViewController:reactView animated:true];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    [[FIRAnalyticsConfiguration sharedInstance] setAnalyticsCollectionEnabled:NO];
    ReactNavigationCoordinator.sharedInstance.bridge = UIApplication.sharedApplication.reactBridge;
    ReactNavigationCoordinator.sharedInstance.delegate = self;
    
    UNUserNotificationCenter* notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    notificationCenter.delegate = self;

    [TPRoutes configureRoutes];
    
    [self startAppsee];
    [self hideTitleBackButton];
    [JLRoutes setShouldDecodePlusSymbols:NO];
    
    _window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _window.backgroundColor = [UIColor whiteColor];
    [self setupInitialViewController];
    [_window makeKeyAndVisible];

#ifdef DEBUG
    [self showFlexManagerOnSecretGesture];
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"4b779275ebcf4c80ba9ead4639424033"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus:BITCrashManagerStatusAutoSend];
#endif
	
    dispatch_async(dispatch_get_main_queue(), ^{
#ifndef DEBUG
        // Init Fabric
        [Fabric with:@[CrashlyticsKit]];
#endif

        // Configure Third Party Apps
        [self configureGTMInApplication:application withOptions:launchOptions];
        [self configureAppsflyer];
        [self configureAppIndexing];
        [self configureGoogleAnalytics];
        [self configureMoEngageInApplication:application withLaunchOptions:launchOptions];
        [self sendAppStatusToMoEngage];
        [self configureLogEntries];
        
        [[AFRKNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

        [GMSServices provideAPIKey:@"AIzaSyBxw-YVxwb9BQ491BikmOO02TOnPIOuYYU"];
        [GMSPlacesClient provideAPIKey:@"AIzaSyBxw-YVxwb9BQ491BikmOO02TOnPIOuYYU"];
        
        [self preparePersistData];
        
        //register quick action items
        [[QuickActionHelper sharedInstance] registerShortcutItems];
        
        //change app language for google mapp address become indonesia
        NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if (![[languages firstObject] isEqualToString:@"id"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@[@"id"] forKey:@"AppleLanguages"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self configureBranchIOWith:launchOptions];
    });

    //opening URL in background state
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //universal search link, only available in iOS 9
        NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
        if (url != nil && ![url.host containsString:@".link"]) {
            [TPRoutes routeURL:url];
        } else {
            NSDictionary *userActivityDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
            if (userActivityDictionary) {
                [userActivityDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSUserActivity class]]) {
                        NSUserActivity *userActivity = obj;
                        BOOL canHandle = [[Branch getInstance] continueUserActivity:userActivity];
                        if(canHandle == NO) {
                            NSURL *url = userActivity.webpageURL;
                            [TPRoutes routeURL:url];
                        }
                    }
                }];
            }
        }

        
        // fetch new remote config value and apply fetched value
        // need to be here so it does not block main UI thread
        FIRRemoteConfig *remoteConfig = [[FIRRemoteConfig class] remoteConfig];
        __weak typeof(FIRRemoteConfig) *weakRemoteConfig = remoteConfig;
        [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
            [weakRemoteConfig activateFetched];
        }];
    });
    
    if (SYSTEM_VERSION_LESS_THAN(@"10.0.0")) {
        NSDictionary *pushNotificationData = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationData) {
            [self didReceiveNotificationBackgroundState:pushNotificationData];
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.1")) {
        //opening Quick Action in background state
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
            if(shortcutItem){
                [[QuickActionHelper sharedInstance] handleQuickAction:shortcutItem];
            }
        });
    }
    
    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1]]; //to set allert button color
    
    BOOL didFinishLaunching = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                       didFinishLaunchingWithOptions:launchOptions];
    
    return didFinishLaunching;
}
- (void)setupInitialViewController {
    UIViewController* viewController = [self frontViewController];
    _window.rootViewController = viewController;
}

-(void)startAppsee{
    [Appsee start:@"f2c02b28ccd54635a7c73eb9dac5038f"];
}

- (BOOL)handleDeeplinkFromDictionary:(NSDictionary *)data {
    NSString *urlString = data[@"url_deeplink"] ?: data[@"app_extra"][@"moe_deeplink"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        [TPRoutes routeURL: url];
        return YES;
    }
    
    NSURL *applinksURL = [NSURL URLWithString:data[@"data"][@"applinks"]];
    JLRoutes *router = [JLRoutes new];
    [router addRoute:@"/ride/uber/:requestId" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        NSString *descriptionJSONString = data[@"data"][@"desc"];
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[descriptionJSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:0
                                                               error:&error];
        
        NSString *status = json[@"status"];
        
        UILocalNotification *notification = [UILocalNotification new];
        notification.category = @"ride-hailing";
        
        if ([status isEqualToString:@"processing"]) {
            notification.alertTitle = @"Trip Started";
            notification.alertBody = @"Track your ride";
        } else if ([status isEqualToString:@"accepted"] || [status isEqualToString:@"arriving"]) {
            notification.alertBody = @"Your Uber is arriving now";
        } else if ([status isEqualToString:@"completed"]) {
            notification.alertTitle = @"Trip Completed";
            notification.alertBody = @"Tap to view trip details";
        } else if ([status isEqualToString:@"driver_cancelled"]) {
            notification.alertTitle = @"Driver canceled your booking";
            notification.alertBody = @"Please book another Uber";
        } else if ([status isEqualToString:@"no_drivers_available"]) {
            notification.alertTitle = @"No Driver Found";
            notification.alertBody = @"Sorry no driver found immediately, you can try again";
        }
        
        [UIApplication.sharedApplication scheduleLocalNotification:notification];
        
        return YES;
    }];
    
    [router routeURL:applinksURL];
    
    return NO;
}

- (void)didReceiveNotificationActiveState:(NSDictionary *)data {
    [self handleDeeplinkFromDictionary:data];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TokopediaNotificationReload object:self];
}

- (void)didReceiveNotificationBackgroundState:(NSDictionary*)data {
    if (![self handleDeeplinkFromDictionary:data]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TokopediaNotificationRedirect object:nil userInfo:data];
    }
}



- (void)configureAppIndexing {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
//        [[GSDAppIndexing sharedInstance] registerApp:1001394201];
    }
}


- (void)configureMoEngageInApplication:(UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
    [[MoEngage sharedInstance] initializeDevWithApiKey:@"LNCME8HVKUEJIGXE2N0698H0" inApplication:application withLaunchOptions:launchOptions openDeeplinkUrlAutomatically:NO];
    [MoEngage debug:LOG_ALL];
#else
    [[MoEngage sharedInstance] initializeProdWithApiKey:@"LNCME8HVKUEJIGXE2N0698H0" inApplication:application withLaunchOptions:launchOptions openDeeplinkUrlAutomatically:NO];
#endif
}

- (void)configureLogEntries {
    le_init();
    le_set_token("078965b7-d9aa-42a6-b6fe-485485c62205");
}

- (NSString *)getGAPropertyID {
    return @"UA-9801603-10";
}

- (void)configureGoogleAnalytics {
    //Google Analytics init
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:[self getGAPropertyID]];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
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
    
    FBTweakBind(TAGManager.instance.logger,
                logLevel,
                @"Others",
                @"Google Tag Manager",
                @"Log Level",
                kTAGLoggerLogLevelError,
                (@{
                   @(kTAGLoggerLogLevelNone): @"None",
                   @(kTAGLoggerLogLevelVerbose): @"Verbose",
                   @(kTAGLoggerLogLevelInfo): @"Info",
                   @(kTAGLoggerLogLevelWarning): @"Warning",
                   @(kTAGLoggerLogLevelError): @"Error"
                   }));
    
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
#pragma mark: - Branch Integration
- (void)configureBranchIOWith:(NSDictionary *)launchOptions {
    Branch *branch = [Branch getInstance];
    NSString * gaClientId = [self.tracker get:kGAIClientId];
    [branch setRequestMetadataKey:@"$google_analytics_client_id" value:gaClientId];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error && params) {
            NSString *urlString;
            if (params[@"branch_promo"]) {
                [[NSUserDefaults standardUserDefaults] setValue:params[@"branch_promo"] forKey:API_VOUCHER_CODE_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (params[@"$web_only"]) {
                urlString = params[@"$original_url"];
            } else if (params[@"$ios_deeplink_path"]) {
                NSString *ios_deeplink_path = params[@"$ios_deeplink_path"];
                urlString = [NSString stringWithFormat:@"tokopedia://%@",ios_deeplink_path];
                BOOL containsReferralCode = [ios_deeplink_path containsString:@"referral"];
                if ([_window.rootViewController isKindOfClass:[IntroViewController class]] && containsReferralCode == NO) {
                    MainViewController *viewController = [MainViewController new];
                    _window.rootViewController = viewController;
                }
            }
            if (urlString != nil) {
                urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSURL *url = [NSURL URLWithString:urlString];
                if (url != nil) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [TPRoutes routeURL:url];
                    });
                }
            }
        }
    }];
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    if ([userManager isLogin]) {
        [branch setIdentity:[userManager getUserId]];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
#ifdef DEBUG
    if (![NSProcessInfo.processInfo.arguments containsObject:@"UI_TESTING"]) {
        [FLEXManager.sharedManager showExplorer];
    }
    [ReactOnboardingHelper resetOnboarding];
#endif
    
    [FBSDKAppEvents activateApp];
    [[AppsFlyerTracker sharedTracker]trackAppLaunch];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [UserAuthentificationManager trackAppLocation];
    });
    
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    
    if ([userManager isLogin]) {
        if (![[userManager getUserEmail] isEqualToString:@"0"] && ![[userManager getCity] isEqualToString:@""]) {
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
    
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([topVC isKindOfClass:[MainViewController class]] == false){
        VersionChecker *versionChecker = [[VersionChecker alloc]init];
        [versionChecker checkForceUpdate];
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
        [permission authorize:^(NSString * _Nullable deviceID, NSError * _Nullable error) {
            // do nothing
        }];
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
    [[MoEngage sharedInstance] didReceieveNotificationinApplication:application withInfo:userInfo openDeeplinkUrlAutomatically:NO];
    
    //opened when application is on background
    if(application.applicationState == UIApplicationStateInactive ||
       application.applicationState == UIApplicationStateBackground) {
        [self didReceiveNotificationBackgroundState:userInfo];
    } else {
        [self didReceiveNotificationActiveState:userInfo];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [[MoEngage sharedInstance] didRegisterForUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([notification.category isEqualToString:@"ride-hailing"]) {
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [UIViewController showNotificationWithMessage:notification.alertBody type:NotificationTypeError duration:10.0 buttonTitle:notification.userInfo[@"button_title"] dismissable:YES action:^{
                [self didReceiveNotificationActiveState:notification.userInfo];
            }];
        });
        
        notification.fireDate = nil;
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    [self didReceiveNotificationActiveState:notification.userInfo];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL shouldOpenURL = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                        openURL:url
                                                              sourceApplication:sourceApplication
                                                                     annotation:annotation];

    [[AppsFlyerTracker sharedTracker] handleOpenURL:url sourceApplication:sourceApplication withAnnotation:annotation];

    if (shouldOpenURL) {
        return YES;
    } else if ([[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation]) {
        return YES;
    } else if ([self.tagManager previewWithUrl:url]) {
        return YES;
    } else if ([[Branch getInstance]
                application:application
                openURL:url
                sourceApplication:sourceApplication
                annotation:annotation] == YES) {
        return YES;
    } else {
        return [TPRoutes routeURL: url];
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
        if ([userActivity.webpageURL.absoluteString containsString:@"onelink"]) {
            NSDictionary *queryStringDictionary = userActivity.webpageURL.parameters;
            url = [NSURL URLWithString:[queryStringDictionary objectForKey:@"af_dp"]];
            [[AppsFlyerTracker sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];
        } else {
            url = userActivity.webpageURL;
        }
    }
    shouldContinue = [[Branch getInstance] continueUserActivity:userActivity];
    if (shouldContinue == NO && url) {
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
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, 0) forBarMetrics:UIBarMetricsDefault];
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

- (UIViewController *)rootViewControllerForCoordinator:(ReactNavigationCoordinator *)coordinator {
    return _window.rootViewController;
}

@end
