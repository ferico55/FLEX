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
#define kTKPD_REACHABILITYURL @"https://"
#endif
#define kTKPD_REACHABILITYDELAY 3.0

#define kJYAPI_REGISTERDEVICETOKEN @"regtoken"
#define kJYAPI_REGISTERDEVICETOKENKEY @"token"

#define kTKPD_APSKEY @"aps"
#define kTKPD_BADGEKEY @"badge"
#define kTKPD_INTERRUPTNOTIFICATIONKEY @"interrupt"

#define kTKPDWINDOW_TINTLCOLOR [UIColor blackColor]

#define kTKPD_HOMETITLEARRAY @[@"Hotlist",@"Produk Feed", @"Terakhir dilihat", @"Toko Favorite"]

#define kTKPDNAVIGATION_TABBARTITLEARRAY @[@"Home", @"Category", @"Search", @"Cart", @"More"]

#define kTKPDNAVIGATION_BACKGROUNDINSET UIEdgeInsetsZero
#define kTKPDNAVIGATION_TITLEFONT [UIFont fontWithName:@"Lato-Bold" size:16.0f]
#define kTKPDNAVIGATION_TITLECOLOR [UIColor whiteColor]
#define kTKPDNAVIGATION_TITLESHADOWCOLOR [UIColor clearColor]
#define kTKPDNAVIGATION_BUTTONINSET UIEdgeInsetsZero
#define kTKPDNAVIGATION_BACKBUTTONINSET UIEdgeInsetsZero

#define kTKPDNAVIGATION_NAVIGATIONBGCOLOR [UIColor colorWithRed:(66/255.0) green:(189/255.0) blue:(65/255.0) alpha:1]
#define kTKPDNAVIGATION_TABBARACTIVETITLECOLOR [UIColor blackColor]
#define kTKPDNAVIGATION_TABBARTITLECOLOR [UIColor blackColor]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
