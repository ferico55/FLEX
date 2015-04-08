//
//  AppDelegate.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#define kTKPD_REACHABILITYURL @"http://www.google.com"
#else
#define kTKPD_REACHABILITYURL @"http://www.google.com"
#endif
#define kTKPD_REACHABILITYDELAY 3.0

#define kTKPD_APSKEY @"aps"
#define kTKPD_BADGEKEY @"badge"

#define kTKPDWINDOW_TINTLCOLOR [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]

#define kTKPDNAVIGATION_TABBARACTIVETITLECOLOR [UIColor blackColor]
#define kTKPDNAVIGATION_TABBARTITLECOLOR [UIColor blackColor]

#define kTKPDNAVIGATION_BACKGROUNDINSET UIEdgeInsetsZero
#define kTKPDNAVIGATION_TITLEFONT [UIFont fontWithName:@"Lato-Bold" size:16.0f]
#define kTKPDNAVIGATION_TITLECOLOR [UIColor whiteColor]
#define kTKPDNAVIGATION_TITLESHADOWCOLOR [UIColor clearColor]
#define kTKPDNAVIGATION_BUTTONINSET UIEdgeInsetsZero
#define kTKPDNAVIGATION_BACKBUTTONINSET UIEdgeInsetsMake(0.0f, 35.0f, 0.0f, 0.0f)
#define kTKPD_SETUSERSTICKYMESSAGEKEY @"stickymessage"

#define kTKPDNAVIGATION_NAVIGATIONBGCOLOR [UIColor colorWithRed:(66/255.0) green:(189/255.0) blue:(65/255.0) alpha:1]
#define kTKPDNAVIGATION_NAVIGATIONITEMCOLOR [UIColor whiteColor]

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"UA-XXXXX-Y";
static NSString *const kAllowTracking = @"allowTracking";

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) BOOL isNetworkAvailable;
@property (assign, nonatomic) BOOL isNetworkWiFi;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UIViewController *navigationController;
@property (assign, nonatomic) BOOL isPushNotificationRegistered;

@end
