//
//  AppDelegate.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "AppDelegate.h"
#import "MainViewController.h"
#import "TKPDSecureStorage.h"
#import "AppsFlyerTracker.h"


@implementation AppDelegate

@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    _viewController = [MainViewController new];
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _window.backgroundColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
    _window.rootViewController = _viewController;
    [_window makeKeyAndVisible];
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
        
        //appsflyer init
        [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"SdSopxGtYr9yK8QEjFVHXL";
        [AppsFlyerTracker sharedTracker].appleAppID = @"1001394201";
        [AppsFlyerTracker sharedTracker].currencyCode = @"IDR";
        
        //fabric init
        [Fabric with:@[CrashlyticsKit]];
        
        //push notification init
        if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            // iOS 8 Notifications
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [application registerForRemoteNotifications];
        }
        else {
            // iOS < 8 Notifications
            [application registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
        }
        
        //Google Analytics init
        [GAI sharedInstance].trackUncaughtExceptions = YES;
//        [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
        [GAI sharedInstance].dispatchInterval = 60;
        [[GAI sharedInstance] trackerWithTrackingId:GATrackingId];
        [[[GAI sharedInstance] trackerWithTrackingId:GATrackingId] setAllowIDFACollection:YES];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        [self preparePersistData];
    });
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppEvents activateApp];
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
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if([sourceApplication isEqualToString:@"com.facebook.Facebook"]) {
        return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    } else if ([self.tagManager previewWithUrl:url]) {
        return YES;
    }
    
    return NO;
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


#pragma mark - Method
+ (void)setIconResponseSpeed:(NSString *)strResponse withImage:(id)imgSpeed largeImage:(BOOL)isLarge {
    UIImage *image = nil;
    if([strResponse isEqualToString:CBadgeSpeedGood]) {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_speed_fast_large":@"icon_speed_fast" ofType:@"png"]];
    }
    else if([strResponse isEqualToString:CBadgeSpeedBad]) {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_speed_bad_large":@"icon_speed_bad" ofType:@"png"]];
    }
    else if([strResponse isEqualToString:CBadgeSpeedNeutral]) {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_speed_neutral_large":@"icon_speed_neutral" ofType:@"png"]];
    }
    else {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_speed_grey_large":@"icon_speed_grey" ofType:@"png"]];
    }
    
    
    
    if([imgSpeed isMemberOfClass:[UIImageView class]]) {
        ((UIImageView *) imgSpeed).image = image;
    }
    else if([imgSpeed isMemberOfClass:[UIButton class]]){
        [((UIButton *) imgSpeed) setImage:image forState:UIControlStateNormal];
    }
}

+ (UIImage *)generateImage:(UIImage *)image withCount:(int)count {
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width*count, image.size.height)];
    
    for(int i=0;i<count;i++) {
        [tempView addSubview:[[[UIImageView alloc] initWithFrame:CGRectMake(i*image.size.width, 0, image.size.width, image.size.height)] initWithImage:image]];
    }
    
    UIGraphicsBeginImageContextWithOptions(tempView.bounds.size, 0, 0.0);
    [tempView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}


+ (void)generateMedal:(NSString *)value withImage:(id)image isLarge:(BOOL)isLarge {
    value = [value stringByReplacingOccurrencesOfString:@"." withString:@""];
    UIImage *tempImage = nil;
    int valueStar = value==nil||[value isEqualToString:@""]?0:[value intValue];
    valueStar = valueStar>0?valueStar:0;
    int n = 0;
    BOOL isArrayObject = ([image isKindOfClass:[NSArray class]] || [image isKindOfClass:[NSMutableArray class]]);
    
    if(valueStar == 0) {
        n = 1;
        tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal":@"icon_medal14" ofType:@"png"]] : [AppDelegate generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal":@"icon_medal14" ofType:@"png"]] withCount:1];
    }
    else {
        ///Set medal image
        if(valueStar<=10 || (valueStar>250 && valueStar<=500) || (valueStar>10000 && valueStar<=20000) || (valueStar>500000 && valueStar<=1000000)) {
            n = 1;
        }
        else if((valueStar>10 && valueStar<=40) || (valueStar>500 && valueStar<=1000) || (valueStar>20000 && valueStar<=50000) || (valueStar>1000000 && valueStar<=2000000)) {
            n = 2;
        }
        else if((valueStar>40 && valueStar<=90) || (valueStar>1000 && valueStar<=2000) || (valueStar>50000 && valueStar<=100000) || (valueStar>2000000 && valueStar<=5000000)) {
            n = 3;
        }
        else if((valueStar>90 && valueStar<=150) || (valueStar>2000 && valueStar<=5000) || (valueStar>100000 && valueStar<=200000) || (valueStar>5000000 && valueStar<=10000000)) {
            n = 4;
        }
        else if((valueStar>150 && valueStar<=250) || (valueStar>5000 && valueStar<=10000) || (valueStar>200000 && valueStar<=500000) || valueStar>10000000) {
            n = 5;
        }
        
        
        
        //Check image medal
        if(valueStar <= 250) {
            tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_bronze":@"icon_medal_bronze14" ofType:@"png"]] : [AppDelegate generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_bronze":@"icon_medal_bronze14" ofType:@"png"]] withCount:n];
        }
        else if(valueStar <= 10000) {
            tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_silver":@"icon_medal_silver14" ofType:@"png"]] : [AppDelegate generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_silver":@"icon_medal_silver14" ofType:@"png"]] withCount:n];
        }
        else if(valueStar <= 500000) {
            tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_gold":@"icon_medal_gold14" ofType:@"png"]] : [AppDelegate generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_gold":@"icon_medal_gold14" ofType:@"png"]] withCount:n];
        }
        else {
            tempImage = isArrayObject? [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_diamond_one":@"icon_medal_diamond_one14" ofType:@"png"]] : [AppDelegate generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isLarge? @"icon_medal_diamond_one":@"icon_medal_diamond_one14" ofType:@"png"]] withCount:n];
        }
    }
    
    
    
    
    if([image isMemberOfClass:[UIButton class]]) {
        [((UIButton *) image) setImage:tempImage forState:UIControlStateNormal];
    }
    else if(isArrayObject) {
        for(int i=0;i<((NSArray *) image).count;i++) {
            UIImageView *temporaryImage = ((NSArray *) image)[i];
            if(i < n) {
                temporaryImage.image = tempImage;
            }
            else
                temporaryImage.image = nil;
        }
    }
    else if([image isMemberOfClass:[UIImageView class]]){
        ((UIImageView *) image).image = tempImage;
    }
}

- (id)initButtonContentPopUp:(NSString *)strTitle withImage:(UIImage *)image withFrame:(CGRect)rectFrame withTextColor:(UIColor *)textColor
{
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.frame = rectFrame;
    [tempBtn setImage:image forState:UIControlStateNormal];
    [tempBtn setTitle:strTitle forState:UIControlStateNormal];
    [tempBtn setTitleColor:textColor forState:UIControlStateNormal];
    tempBtn.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    
    //    CGSize imageSize = tempBtn.imageView.bounds.size;
    //    CGSize titleSize = tempBtn.titleLabel.bounds.size;
    //    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    //    tempBtn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    tempBtn.titleEdgeInsets = UIEdgeInsetsMake(15.0, 0.0, 0.0, 0.0);
    
    return (id)tempBtn;
}

- (void)showPopUpSmiley:(UIView *)viewContentPopUp andPadding:(int)paddingRightLeftContent withReputationNetral:(NSString *)strNetral withRepSmile:(NSString *)strGood withRepSad:(NSString *)strSad withDelegate:(id<SmileyDelegate>)delegate{
    viewContentPopUp.backgroundColor = [UIColor clearColor];
    
    UIButton *btnMerah = (UIButton *)[self initButtonContentPopUp:strSad withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]] withFrame:CGRectMake(paddingRightLeftContent/2.0f, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:244/255.0f green:67/255.0f blue:54/255.0f alpha:1.0f]];
    UIButton *btnKuning = (UIButton *)[self initButtonContentPopUp:strNetral withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]] withFrame:CGRectMake(btnMerah.frame.origin.x+btnMerah.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:255/255.0f green:193/255.0f blue:7/255.0f alpha:1.0f]];
    UIButton *btnHijau = (UIButton *)[self initButtonContentPopUp:strGood withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] withFrame:CGRectMake(btnKuning.frame.origin.x+btnKuning.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:0 green:128/255.0f blue:0 alpha:1.0f]];
    
    btnMerah.tag = CTagMerah;
    btnKuning.tag = CTagKuning;
    btnHijau.tag = CTagHijau;
    
    [btnMerah addTarget:delegate action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnKuning addTarget:delegate action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnHijau addTarget:delegate action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    
    [viewContentPopUp addSubview:btnMerah];
    [viewContentPopUp addSubview:btnKuning];
    [viewContentPopUp addSubview:btnHijau];
}
@end
