//
//  CreatePasswordViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Login.h"
#import <FacebookSDK/FacebookSDK.h>

@protocol CreatePasswordDelegate <NSObject>

- (void)createPasswordSuccess;

@end

@interface CreatePasswordViewController : UIViewController

@property (strong, nonatomic) Login *login;
@property (weak, nonatomic) id<CreatePasswordDelegate> delegate;
@property (strong, nonatomic) id<FBGraphUser> facebookUser;

@end
