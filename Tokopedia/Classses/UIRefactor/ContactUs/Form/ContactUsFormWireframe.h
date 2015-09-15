//
//  ContactUsWireframe.h
//  Tokopedia
//
//  Created by Tokopedia on 9/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPRootWireframe;
@class ContactUsFormPresenter;
@class ContactUsFormViewController;
@class TicketCategory;

@interface ContactUsFormWireframe : NSObject

@property (nonatomic, strong) TPRootWireframe *rootWireframe;
@property (nonatomic, strong) ContactUsFormPresenter *presenter;

- (void)pushToContactFormWithMainCategory:(TicketCategory *)mainCategory
                            subCategories:(NSArray *)subCategories
                           fromNavigation:(UINavigationController *)navigation;

- (void)presentPhotoPickerFromNavigation:(UINavigationController *)navigation;

- (void)pushToInboxDetailFromNavigation:(UINavigationController *)navigation;

@end
