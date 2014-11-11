//
//  SettingBankNameViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Setting Bank Name View Delegate
@protocol SettingBankNameViewControllerDelegate <NSObject>
@required
-(void)SettingBankNameViewController:(UIViewController*)vc withData:(NSDictionary*)data;

@end

@interface SettingBankNameViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingBankNameViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingBankNameViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong)NSDictionary *data;

@end
