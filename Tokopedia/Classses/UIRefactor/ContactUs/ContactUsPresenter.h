//
//  ContactUsPresenter.h
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsViewInterface.h"
#import "ContactUsInteractor.h"
#import "ContactUsModuleInterface.h"
#import "ContactUsWireframe.h"

@protocol ContactUsViewInterface;

@interface ContactUsPresenter : NSObject <ContactUsInteractorOutput, ContactUsModuleInterface>

@property (nonatomic, strong) id<ContactUsInteractorInput> interactor;
@property (nonatomic, strong) UIViewController<ContactUsViewInterface> *userInterface;
@property (nonatomic, strong) ContactUsWireframe *wireframe;

@end
