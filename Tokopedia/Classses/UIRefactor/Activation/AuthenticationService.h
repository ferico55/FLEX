//
//  AuthenticationService.h
//  Tokopedia
//
//  Created by Samuel Edwin on 6/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Login;

@interface AuthenticationService : NSObject

@property (weak) UIViewController *viewController;
+ (instancetype)sharedService;

- (void)verifyPhoneNumber:(Login *)login onPhoneNumberVerified:(void (^)())verifiedCallback;
@end
