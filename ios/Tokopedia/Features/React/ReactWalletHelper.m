//
//  ReactWalletHelper.m
//  Tokopedia
//
//  Created by Ferico Samuel on 18/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import "ReactWalletHelper.h"
#import <RxCocoa/RxCocoa.h>
#import "Tokopedia-Swift.h"
#import "UserAuthentificationManager.h"
@import NativeNavigation;

@implementation ReactWalletHelper

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(requestTokocash:(RCTPromiseResolveBlock)resolve reject:(__unused RCTPromiseRejectBlock)reject) {
    [TokoCashUseCase requestBalanceWithCompletionHandler:^(WalletStore * wallet) {
        resolve(@{
                       @"text": wallet.data.balance,
                       @"applinks": wallet.data.applinks,
                       @"pendingCashback": @(NO)
                       });
    } andErrorHandler:^(NSError * error) {
        if (error.code == 402) {
            // aktivasi
            NSString* phoneNumber = [[UserAuthentificationManager new] getUserPhoneNumber];
            [WalletService getPendingCashbackWithPhoneNumber:phoneNumber completionHandler:^(WalletCashBackResponse * _Nullable response) {
                resolve(@{
                          @"text": (response && ![response.data.amount isEqualToString:@"0"]) ? response.data.amountText : @"Aktivasi",
                          @"applinks": @"tokopedia://wallet/activation",
                          @"pendingCashback": (response && ![response.data.amount isEqualToString:@"0"]) ? @(YES) : @(NO)
                          });
                
            } andErrorHandler:^(NSError * _Nonnull error) {
                resolve(@{
                          @"text": @"Aktivasi",
                          @"applinks": @"tokopedia://wallet/activation",
                          @"pendingCashback": @(NO)
                          });
            }];
        }else {
            reject(@(error.code).stringValue, error.localizedDescription, error);
        }
    }];
}

RCT_EXPORT_METHOD(showPendingCashbackPopup: (NSString*) applink balance: (NSString*) balance) {
    CFAlertAction *closeButton = [CFAlertAction actionWithTitle:@"Tutup" style:CFAlertActionStyleCancel alignment:CFAlertActionAlignmentJustified backgroundColor:UIColor.lightGrayColor textColor:UIColor.lightGrayColor handler:nil];
    CFAlertAction *cashbackButton = [CFAlertAction actionWithTitle:@"Dapatkan Cashback Sekarang" style:CFAlertActionStyleDefault alignment:CFAlertActionAlignmentJustified backgroundColor:UIColor.tpGreen textColor:UIColor.whiteColor handler:^(CFAlertAction * _Nonnull action) {
        [TPRoutes routeURL: [NSURL URLWithString:@"tokopedia://wallet/activation"]];
    }];
    
    
    CFAlertViewController *alertViewController = [TooltipAlert createAlertWithTitle:@"Bonus Cashback" subtitle:[NSString stringWithFormat:@"Anda mendapatkan cashback TokoCash sebesar %@", balance] image:[UIImage imageNamed:@"icon_cashback"] buttons:@[cashbackButton, closeButton] isAlternative:YES];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topMostViewController = [rootViewController topMostViewController];
    [topMostViewController presentViewController:alertViewController animated: YES completion:nil];
}

RCT_EXPORT_METHOD(showTokopointNotification: (NSDictionary *) options) {
    PointsAlertViewButton *button = [PointsAlertViewButton new];
    [button initializeWithTitle:[options objectForKey:@"buttonText"] titleColor:UIColor.tpGreen image:nil alignment:NSTextAlignmentCenter callback:^{
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        WebViewController* vc = [WebViewController new];
        vc.strURL = [auth webViewUrlFromUrl: [options objectForKey:@"url"]];
        vc.shouldAuthorizeRequest = YES;
        vc.hidesBottomBarWhenPushed = YES;
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *topMostViewController = [rootViewController topMostViewController];
        [topMostViewController.navigationController pushViewController:vc animated:YES];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PointsAlertView *alert = [[PointsAlertView alloc] initWithTitle:[options objectForKey:@"title"] image:nil imageUrl:[options objectForKey:@"imageUrl"] message:[options objectForKey:@"message"] buttons:@[button]];
        [alert showSelfWithAnimated: YES];
    });
}

@end
