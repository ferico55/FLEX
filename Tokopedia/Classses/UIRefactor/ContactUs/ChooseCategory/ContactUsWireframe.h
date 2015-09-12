//
//  ContactUsWireframe.h
//  Tokopedia
//
//  Created by Tokopedia on 9/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicketCategory.h"
#import "ContactUsFormWireframe.h"

@class TPRootWireframe;
@class ContactUsPresenter;
@class ContactUsViewController;

@interface ContactUsWireframe : NSObject

@property (nonatomic, strong) ContactUsPresenter *presenter;
@property (nonatomic, strong) TPRootWireframe *rootWireframe;
@property (nonatomic, strong) ContactUsFormWireframe *formWireframe;

- (void)pushContactUsViewControllerFromNavigation:(UINavigationController *)navigation;
- (void)pushCategoryFromNavigation:(UINavigationController *)navigation;
- (void)pushSubCategoryFromNavigation:(UINavigationController *)navigation;
- (void)pushContactUsFormViewFromNavigation:(UINavigationController *)navigation;

@end
