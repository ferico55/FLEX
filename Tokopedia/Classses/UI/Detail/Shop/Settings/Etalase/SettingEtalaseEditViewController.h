//
//  SettingEtalaseEditViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SettingEtalaseEditViewController;

#pragma mark - Product Edit Wholesale Cell Delegate
@protocol SettingEtalaseEditViewControllerDelegate <NSObject>
@optional
-(void)SettingEtalaseEditViewController:(SettingEtalaseEditViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

@interface SettingEtalaseEditViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingEtalaseEditViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingEtalaseEditViewControllerDelegate> delegate;
#endif

@property (nonatomic,strong)NSDictionary *data;

@end
