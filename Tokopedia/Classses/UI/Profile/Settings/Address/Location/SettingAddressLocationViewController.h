//
//  SettingAddressLocationViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - SettingAddress Location View Delegate
@protocol SettingAddressLocationViewDelegate <NSObject>
@required
-(void)SettingAddressLocationView:(UIViewController*)vc withData:(NSDictionary*)data;

@end

@interface SettingAddressLocationViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingAddressLocationViewDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingAddressLocationViewDelegate> delegate;
#endif

@property (nonatomic, strong)NSDictionary *data;

@end
