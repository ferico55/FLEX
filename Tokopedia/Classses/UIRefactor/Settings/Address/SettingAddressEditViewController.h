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


@property (nonatomic, weak) IBOutlet id<SettingAddressEditViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *data;
@property UIImage *imageMap;
@property NSString *longitude;
@property NSString *latitude;

@end
