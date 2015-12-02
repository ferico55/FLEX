//
//  PhoneVerificationViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 11/25/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface PhoneVerificationViewController : UIViewController
@property (weak, nonatomic) id<LoginViewDelegate> delegate;
@property (weak, nonatomic) id redirectViewController;
@property (strong, nonatomic) NSString *phone;
@property BOOL isSkipButtonHidden;
@end
