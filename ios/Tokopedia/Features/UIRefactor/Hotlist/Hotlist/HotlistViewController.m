//
//  HotlistViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "HotlistViewController.h"
#import "NotificationManager.h"
#import "Tokopedia-Swift.h"
#import "UIApplication+React.h"
#import "ReactEventManager.h"
#import "CategoryResultViewController.h"
#import <React/RCTRootView.h>

@interface HotlistViewController ()<NotificationManagerDelegate> {
    NotificationManager *_notifManager;
}

@end

@implementation HotlistViewController

#pragma mark - View Lifecylce
- (void) viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo]; 
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[UIApplication sharedApplication].reactBridge
                                                     moduleName:@"Tokopedia"
                                              initialProperties:@{@"name" : @"Hotlist", @"params" : @{} }];
    
    self.view = rootView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Hot List Page"];
    
    [self initNotificationManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initNotificationManager) name:@"reloadNotification" object:nil];
    
    [self checkForPhoneVerification];
}

-(void)checkForPhoneVerification{
    if([self shouldShowPhoneVerif]){
        [OTPRequest
         checkPhoneVerifiedStatusOnSuccess:^(NSString * _Nonnull isVerified) {
             if (![isVerified isEqualToString:@"1"]) {
                 PhoneVerificationViewController *controller = [[PhoneVerificationViewController alloc]
                                                                initWithPhoneNumber: @""
                                                                isFirstTimeVisit: NO
                                                                didVerifiedPhoneNumber:nil];
                 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                 navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                 [self.navigationController presentViewController:navigationController animated:YES completion:nil];
             }
         }
         onFailure:^{
             
         }];
    }
}


/*
 
 apps should ask for phone verif if:
 1. is login
 2. msisdn_is_verified in secure storage is 0 ("msisdn_is_verified" is updated when: login or verifying phone number profile setting)
 3. if last appear timestamp in cache is nil, go to step 6(first login)
 4. check if phone verif last appear timestamp is already past time interval tolerance
 5. check WS, maybe user is already do phone verif in another media(other apps, website, etc)
 6. if not, do ask for verif
 
 */
- (BOOL)shouldShowPhoneVerif{
    NSString *phoneVerifLastAppear = [[NSUserDefaults standardUserDefaults] stringForKey:@"phone_verif_last_appear"];
    UserAuthentificationManager *userAuth = [UserAuthentificationManager new];
    
    if([userAuth isLogin]){
        if(![userAuth isUserPhoneVerified]){
            NSDate* lastAppearDate = [self NSDatefromString:phoneVerifLastAppear];
            if(lastAppearDate){
                NSTimeInterval timeIntervalSinceLastAppear = [[NSDate date]timeIntervalSinceDate:lastAppearDate];
                NSTimeInterval allowedTimeInterval = [self allowedTimeInterval];
                return timeIntervalSinceLastAppear > allowedTimeInterval;
            }else{
                return YES;
            }
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

- (NSTimeInterval)allowedTimeInterval{
    return FBTweakValue(@"Others", @"Phone Verification", @"Notice Interval(Minutes)", 60*24*1)*60;
}

- (NSDate*)NSDatefromString:(NSString*)date{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"WIB"]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    }
    return [dateFormatter dateFromString:date];
}


#pragma mark - Memory Management
- (void)dealloc {
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification Manager
- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    _notifManager.delegate = self;
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}

- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController {
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)scrollToTop {
    ReactEventManager *tabManager = [[UIApplication sharedApplication].reactBridge moduleForClass:[ReactEventManager class]];
    [tabManager sendScrollToTopEvent];
}


@end
