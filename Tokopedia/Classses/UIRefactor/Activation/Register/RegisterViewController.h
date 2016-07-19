//
//  RegisterViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleSignIn/GoogleSignIn.h>

@class GPPSignInButton;

@interface RegisterViewController : GAITrackedViewController <GPPSignInDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

//@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property (nonatomic) NSString *emailFromForgotPassword;

@end