//
//  SettingBankAccountViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BankAccountForm.h"


#pragma mark - Setting Bank Account Delegate
@protocol SettingBankAccountViewControllerDelegate <NSObject>
@optional
- (void)selectedObject:(id)object;

@end

@interface SettingBankAccountViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingBankAccountViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingBankAccountViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong) NSDictionary *data;
@property BankAccountFormList *selectedObject;

@end
