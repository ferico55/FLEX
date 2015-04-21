//
//  SettingAddressEditViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressFormList.h"

@class SettingAddressEditViewController;

#pragma mark - Address Add Edit View Controller Delegate
@protocol SettingAddressEditViewControllerDelegate <NSObject>
@optional
- (void)SettingAddressEditViewController:(SettingAddressEditViewController *)viewController withUserInfo:(NSDictionary*)userInfo;
- (void)successEditAddress:(AddressFormList *)address;
- (void)successAddAddress;

@end

@interface SettingAddressEditViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingAddressEditViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingAddressEditViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong) NSDictionary *data;

@end
