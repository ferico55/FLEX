//
//  LoginViewController.h
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewDelegate <NSObject>

- (void)redirectViewController:(id)viewController;

@optional
- (void)cancelLoginView;

@end

@interface LoginViewController : GAITrackedViewController <UITextFieldDelegate>

@property (strong,nonatomic) NSDictionary *data;
@property BOOL isPresentedViewController;
@property (weak, nonatomic) id<LoginViewDelegate> delegate;
@property (weak, nonatomic) id redirectViewController;

@end
