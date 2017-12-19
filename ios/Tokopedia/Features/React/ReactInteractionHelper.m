//
//  ReactInteractionHelper.m
//  Tokopedia
//
//  Created by Ferico Samuel on 7/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactInteractionHelper.h"
#import "UIApplication+React.h"
#import "UIColor+Theme.h"
#import <CFAlertViewController/CFAlertViewController-Swift.h>
#import "Tokopedia-Swift.h"
#import <React/RCTView.h>
#import "string_more.h"
#import <React/RCTUIManager.h>
#import <Photos/PHAsset.h>
@import NativeNavigation;
@import SwiftOverlays;

@implementation ReactInteractionHelper

RCT_EXPORT_MODULE();

static UIView *lastNotificationView;

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(share:(NSString *)urlString deeplink:(NSString*)deeplink caption:(NSString*) caption anchor:(nonnull NSNumber*) anchorTag) {
    RCTSharingReferable * object = [RCTSharingReferable new];
    object.desktopUrl = urlString;
    object.deeplinkPath = deeplink;
    object.title = caption;
    object.feature = @"Promo";
    object.utm_campaign = @"promo";
    RCTView* view = anchorTag == 0 ? nil : (RCTView*)[_bridge.uiManager viewForReactTag: anchorTag];
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    ReferralManager *referralManager = [[ReferralManager alloc] init];
    [referralManager shareWithObject:object from:viewController anchor:view];
}

RCT_EXPORT_METHOD(showStickyAlert:(NSString*) message) {
    [self destroyLastNotificationView];
    lastNotificationView = [UIViewController showNotificationWithMessage:message
                                                                    type:NotificationTypeSuccess
                                                                duration:4.0
                                                             buttonTitle:nil
                                                             dismissable:YES
                                                                  action:nil];
}

RCT_EXPORT_METHOD(showErrorStickyAlert:(NSString*) message) {
    [self destroyLastNotificationView];
    lastNotificationView = [UIViewController showNotificationWithMessage:message
                                                                    type:NotificationTypeError
                                                                duration:4.0
                                                             buttonTitle:@"Coba Lagi"
                                                             dismissable:YES
                                                                  action:nil];
}

-(void)destroyLastNotificationView {
    if(lastNotificationView) {
        [lastNotificationView setHidden:YES];
        lastNotificationView = nil;
        [NSObject cancelPreviousPerformRequestsWithTarget:SwiftOverlays.class];
    }
}

RCT_EXPORT_METHOD(showDangerAlert:(NSString*) message){
    UIViewController *topMostViewController = [self topMostViewController];
    StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:@[message] delegate:topMostViewController];
    [alertView show];
}

RCT_EXPORT_METHOD(showSuccessAlert:(NSString*) message){
    UIViewController *topMostViewController = [self topMostViewController];
    StickyAlertView *alertView = [[StickyAlertView alloc] initWithSuccessMessages:@[message] delegate:topMostViewController];
    [alertView show];
}

RCT_EXPORT_METHOD(showPopover:(NSArray<NSString*>*) options anchor:(nonnull NSNumber*) anchorTag callback: (RCTResponseSenderBlock)callback) {
    RCTView* view = (RCTView*)[_bridge.uiManager viewForReactTag: anchorTag];
    UIViewController *rootViewController =[UIApplication sharedApplication].keyWindow.rootViewController;
    
    ReactPopoverOptionViewController *vc = [[ReactPopoverOptionViewController alloc] initWithOptions:options anchorView:view presentingViewController:rootViewController callback:^(NSInteger selectedIndex){
        callback(@[@(selectedIndex)]);
    }];
    [vc showPopover];
}

RCT_EXPORT_METHOD(hideNavigationBar) {
    UIViewController *topMostViewController = [self topMostViewController];
    [topMostViewController.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

RCT_EXPORT_METHOD(dismiss: (RCTResponseSenderBlock)callback) {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    NSArray<UIViewController*> *firstChildren = [rootViewController childViewControllers];
    for (UIViewController *firstChild in firstChildren) {
        NSArray<UIViewController*>* secondChildren = [firstChild childViewControllers];
        for (UIViewController *viewController in secondChildren) {
            if ([viewController isKindOfClass:[ReactSplitViewController class]]) {
                [viewController.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
    callback(@[[NSNull null]]);
}

RCT_EXPORT_METHOD(ensureLogin: (RCTResponseSenderBlock)callback) {
    UIViewController *topMostViewController = [self topMostViewController];
    [AuthenticationService.shared ensureLoggedInFromViewController:topMostViewController onSuccess:^{
        UserAuthentificationManager* auth = [UserAuthentificationManager new];
        callback(@[auth.getUserId, auth.getShopId]);
    }];
}

RCT_EXPORT_METHOD(showImagePicker: (nonnull NSNumber*) maxSelected callback: (RCTResponseSenderBlock)callback) {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topMostViewController = [rootViewController topMostViewController];
    
    [[TKPImagePickerController class] showImagePicker:topMostViewController assetType:DKImagePickerControllerAssetTypeAllPhotos allowMultipleSelect:YES showCancel:YES showCamera:YES maxSelected:maxSelected.intValue selectedAssets:nil completion:^(NSArray<DKAsset*>* result){
        NSMutableArray<NSString*>* resultUri = [NSMutableArray new];
        __block int count = (int) result.count;
        for(DKAsset* asset in result) {
            PHAsset *originalAsset = asset.originalAsset;
            if (originalAsset.pixelWidth < 300 || originalAsset.pixelHeight < 300) {
                [resultUri addObject:@"small"];
                continue;
            }
            NSURL *url = [originalAsset getPublicUrl];
            [resultUri addObject:url.absoluteString];
        }
        if (count > 0) {
            callback(@[resultUri]);
        }
    }];
}

- (UIViewController*) topMostViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [rootViewController topMostViewController];
}

@end
