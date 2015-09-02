//
//  ContactUsPresenter.h
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsView.h"
#import "ContactUsInteractor.h"

@interface ContactUsPresenter : NSObject

@property (nonatomic, strong) id<ContactUsView> view;
@property (nonatomic, strong) ContactUsInteractor *interactor;

- (void)showContactUsForm;

@end
