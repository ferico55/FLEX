//
//  LoginViewController.h
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleSignIn/GoogleSignIn.h>

@class GPPSignInButton;

@protocol LoginViewDelegate <NSObject>

- (void)redirectViewController:(id)viewController;

@optional
- (void)cancelLoginView;

@end

@interface LoginViewController : GAITrackedViewController <UITextFieldDelegate, GPPSignInDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (strong,nonatomic) NSDictionary *data;
@property BOOL isPresentedViewController;
@property (weak, nonatomic) id<LoginViewDelegate> delegate;
@property (weak, nonatomic) id redirectViewController;
@property BOOL isFromTabBar;

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;

- (void)navigateToRegister;

@end
