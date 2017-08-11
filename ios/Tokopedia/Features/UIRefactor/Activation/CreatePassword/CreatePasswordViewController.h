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
@class OAuthToken;
@class AccountInfo;

@interface CreatePasswordViewController : UIViewController

@property (strong, nonatomic) CreatePasswordUserProfile *userProfile;

@property (copy) void(^onPasswordCreated)();

@property(nonatomic, strong) OAuthToken *oAuthToken;
@property(nonatomic, strong) AccountInfo *accountInfo;
@end
