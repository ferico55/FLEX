//
//  SettingBankAccountViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BankAccountFormList;

#pragma mark - Setting Bank Account Delegate
@protocol SettingBankAccountViewControllerDelegate <NSObject>
@optional
- (void)selectedObject:(id)object;

@end

@interface SettingBankAccountViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<SettingBankAccountViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *data;
@property BankAccountFormList *selectedObject;

@end
