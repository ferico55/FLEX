//
//  SettingEtalaseDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Setting Etalase Detail View Controller Delegate
@protocol SettingEtalaseDetailViewControllerDelegate <NSObject>
@required
-(void)DidTapButton:(UIButton*)button withdata:(NSDictionary*)data;
@end

@interface SettingEtalaseDetailViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingEtalaseDetailViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingEtalaseDetailViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong)NSDictionary *data;

@end
