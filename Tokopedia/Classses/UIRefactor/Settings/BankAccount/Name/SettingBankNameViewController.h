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


@property (nonatomic, weak) IBOutlet id<SettingBankNameViewControllerDelegate> delegate;
@property (nonatomic, strong)NSDictionary *data;

@end
