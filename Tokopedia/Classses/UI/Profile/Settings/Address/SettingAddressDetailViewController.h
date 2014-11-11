//
//  SettingAddressDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Setting Address Detail View Controller Delegate
@protocol SettingAddressDetailViewControllerDelegate <NSObject>
@required
-(void)DidTapButton:(UIButton*)button withdata:(NSDictionary*)data;
@end

@interface SettingAddressDetailViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingAddressDetailViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingAddressDetailViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong) NSDictionary *data;

@end
