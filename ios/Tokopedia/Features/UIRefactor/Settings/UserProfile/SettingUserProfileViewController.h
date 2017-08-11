//
//  SettingUserProfileViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingUserProfileDelegate <NSObject>

- (void)successEditUserProfile;

@end

@interface SettingUserProfileViewController : UIViewController

@property (strong, nonatomic) NSDictionary *data;
@property (weak, nonatomic) id<SettingUserProfileDelegate> delegate;

@end
