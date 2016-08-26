//
//  RegisterViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface RegisterViewController : GAITrackedViewController <GIDSignInDelegate, GIDSignInUIDelegate>
@property (nonatomic) NSString *emailFromForgotPassword;

@end