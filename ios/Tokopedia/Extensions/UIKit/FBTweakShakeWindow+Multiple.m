//
//  FBTweakShakeWindow+Multiple.m
//  Tokopedia
//
//  Created by Vishun Dayal on 21/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import "FBTweakShakeWindow+Multiple.h"
#import "Tokopedia-Swift.h"
@implementation FBTweakShakeWindow(Multiple)
- (void)_presentTweaks
{
    UIViewController *visibleViewController = [UIApplication topViewController];
    // Prevent double-presenting the tweaks view controller.
    if (![visibleViewController isKindOfClass:[FBTweakViewController class]]) {
        [self showTweakControllerFrom:visibleViewController];
    }
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionBegan:motion withEvent:event];
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self setValue:@(YES) forKey:@"_shaking"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[ACRemoteConfig new] isShakeEnabledOnCompletion:^(BOOL isShakeEnabled) {
                if ([self _shouldPresentTweaks] && isShakeEnabled) {
                    [self showActionSheet];
                } else if (isShakeEnabled) {
                    [self doAudioCampaign];
                } else if ([self _shouldPresentTweaks]) {
                    [self _presentTweaks];
                }
            }];
        });
    }
    [super motionEnded:motion withEvent:event];
}
- (void)showActionSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
    popPresenter.sourceView = self;
    popPresenter.sourceRect = CGRectMake(self.bounds.size.width/2, self.bounds.size.height, 1, 1);
    UIAlertAction *tweak = [UIAlertAction actionWithTitle:@"Tweaks" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _presentTweaks];
    }];
    UIAlertAction *audio = [UIAlertAction actionWithTitle:@"Shake - Shake" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doAudioCampaign];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:tweak];
    [alertController addAction:audio];
    [alertController addAction:cancel];
    UIViewController *visibleViewController = [UIApplication topViewController];
    [visibleViewController presentViewController:alertController animated:YES completion:nil];
}
- (void)showTweakControllerFrom:(UIViewController *)visibleViewController {
    FBTweakStore *store = [FBTweakStore sharedInstance];
    FBTweakViewController *viewController = [[FBTweakViewController alloc] initWithStore:store];
    viewController.tweaksDelegate = self;
    [visibleViewController presentViewController:viewController animated:YES completion:NULL];
}
- (void)doAudioCampaign {
    [[ACRemoteConfig new] isAudioOnCompletion:^(BOOL isAudio) {
        if (isAudio) {
            UIViewController *visibleViewController = [UIApplication topViewController];
            // Prevent double-presenting the tweaks view controller.
            if ([visibleViewController isKindOfClass:[AudioRecorderViewController class]]) {
                return;
            }
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AudioRecorder" bundle: nil];
            UINavigationController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AudioRecorderNavigationController"];
            UIViewController * topViewController = [UIApplication topViewController];
            [topViewController presentViewController:viewController animated:YES completion:nil];
        } else {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Memuat..." message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
            popPresenter.sourceView = self;
            popPresenter.sourceRect = CGRectMake(self.bounds.size.width/2, self.bounds.size.height, 1, 1);
            UIViewController *visibleViewController = [UIApplication topViewController];                [visibleViewController presentViewController:alertController animated:YES completion:nil];
            [[AudioCampaignService new] verifyShakeWithUrl:nil isAudio:NO onCompletion:^{
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }];
}
@end
