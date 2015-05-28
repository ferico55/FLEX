//
//  SettingBankDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Setting Bank Detail View Controller Delegate
@protocol SettingBankDetailViewControllerDelegate <NSObject>
@required
-(void)DidTapButton:(UIButton*)button withdata:(NSDictionary*)data;
@end

@interface SettingBankDetailViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<SettingBankDetailViewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableDictionary *data;

@end
