//
//  SettingAddressViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SettingAddressViewController;

#pragma mark - Setting Address View Controller Delegate
@protocol SettingAddressViewControllerDelegate <NSObject>
@required
-(void)SettingAddressViewController:(SettingAddressViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

@interface SettingAddressViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingAddressViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingAddressViewControllerDelegate> delegate;
#endif

@property(strong, nonatomic) NSDictionary *data;

@end
