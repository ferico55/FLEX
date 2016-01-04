//
//  HelloPhoneVerificationViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 11/26/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface HelloPhoneVerificationViewController : UIViewController
@property (weak, nonatomic) id<LoginViewDelegate> delegate;
@property (weak, nonatomic) id redirectViewController;
@property BOOL isSkipButtonHidden;
@end
