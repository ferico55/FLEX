//
//  CreatePasswordViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Login.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GoogleSignIn/GoogleSignIn.h>

@protocol CreatePasswordDelegate <NSObject>

- (void)createPasswordSuccess;

@end

@interface CreatePasswordViewController : UIViewController

@property (strong, nonatomic) Login *login;
@property (weak, nonatomic) id<CreatePasswordDelegate> delegate;
@property (strong, nonatomic) NSDictionary *facebookUserData;
@property GTLPlusPerson *googleUser;
@property GIDGoogleUser *gidGoogleUser;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *fullName;

@end
