//
//  MainViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDMAIN_PRESENTATIONDELAY 1
#define kTKPDMAIN_AUTHENTICATIONDIDBECOMEINVALIDNOTIFICATION @"tokopedia.kTKPDMAIN_AUTHENTICATIONDIDBECOMEINVALIDNOTIFICATION"

#define kTKPD_HOMETITLEISAUTHARRAY @[@"Hot List",@"Produk Feed", @"Terakhir dilihat", @"Toko Favorite"]
#define kTKPD_HOMETITLEARRAY @[@"Hot List"]

#define kTKPDNAVIGATION_TABBARTITLEARRAY @[@"Home", @"Hot List", @"Cari", @"Keranjang", @"More", @"Login"]
#define kTKPDNAVIGATION_TABBARACTIVETITLECOLOR [UIColor blackColor]
#define kTKPDNAVIGATION_TABBARTITLECOLOR [UIColor blackColor]

#pragma mark -
#pragma mark MainViewController

typedef NS_ENUM(NSInteger, MainViewControllerPage) {
    MainViewControllerPageSearch,
    MainViewControllerPageLogin,
    MainViewControllerPageRegister,
    MainViewControllerPageDefault
};

@interface MainViewController : UIViewController

- (instancetype)initWithPage:(MainViewControllerPage)page;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSMutableDictionary *auth;

@end
