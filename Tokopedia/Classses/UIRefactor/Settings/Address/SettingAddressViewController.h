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


@property (nonatomic, weak) IBOutlet id<SettingAddressViewControllerDelegate> delegate;
@property(strong, nonatomic) NSDictionary *data;
@property (nonatomic, strong) NSMutableArray *list;

@end
