//
//  SettingPrivacyListViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingPrivacyListViewControllerDelegate <NSObject>
@required
-(void)SettingPrivacyListType:(NSInteger)type withIndex:(NSInteger)index;

@end

@interface SettingPrivacyListViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingPrivacyListViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingPrivacyListViewControllerDelegate> delegate;
#endif


@property (nonatomic, strong) NSDictionary *data;

@end
