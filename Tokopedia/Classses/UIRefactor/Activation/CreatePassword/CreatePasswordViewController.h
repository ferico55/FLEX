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
#import <GoogleSignIn/GoogleSignIn.h>

@class CreatePasswordUserProfile;

@interface CreatePasswordViewController : UIViewController

@property (strong, nonatomic) NSDictionary *facebookUserData;
@property GIDGoogleUser *gidGoogleUser;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) CreatePasswordUserProfile *userProfile;

@property (copy) void(^onPasswordCreated)();

@end
