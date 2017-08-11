//
//  LoginViewController.h
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "Login.h"

@interface LoginViewController : GAITrackedViewController <UITextFieldDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (strong,nonatomic) NSDictionary *data;
@property BOOL isPresentedViewController;
@property (copy) void(^onLoginFinished)(LoginResult * loginResult);

- (void)navigateToRegister;


@end
