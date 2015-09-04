//
//  ContactUsWireframe.h
//  Tokopedia
//
//  Created by Tokopedia on 9/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPRootWireframe;
@class ContactUsPresenter;
@class ContactUsViewController;

@interface ContactUsWireframe : NSObject

@property (nonatomic, strong) TPRootWireframe *rootWireframe;
@property (nonatomic, strong) ContactUsPresenter *presenter;

- (void)pushContactUsViewControllerFromNavigation:(UINavigationController *)navigation;
- (void)pushContactUsProblemChoices:(NSArray *)choices
                    selectedProblem:(NSString *)problem
                     fromNavigation:(UINavigationController *)navigation;
- (void)pushContactUsProblemDetailChoicesFromNavigation:(UINavigationController *)navigation;
- (void)pushContactUsFormViewFromNavigation:(UINavigationController *)navigation;

@end
