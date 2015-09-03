//
//  TPContactUsDependencies.m
//  Tokopedia
//
//  Created by Tokopedia on 9/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TPContactUsDependencies.h"

#import "TPRootWireframe.h"

#import "ContactUsWireframe.h"
#import "ContactUsViewController.h"
#import "ContactUsPresenter.h"
#import "ContactUsInteractor.h"

@interface TPContactUsDependencies ()

@property (nonatomic, strong) ContactUsWireframe *contactUsWireframe;

@end

@implementation TPContactUsDependencies

- (id)init {
    self = [super init];
    if (self) {
        [self configureDependencies];
    }
    return self;
}

- (void)configureDependencies {
    TPRootWireframe *rootWireframe = [TPRootWireframe new];
    
    ContactUsViewController *controller = [ContactUsViewController new];
    ContactUsPresenter *presenter = [ContactUsPresenter new];
    ContactUsInteractor *interactor = [ContactUsInteractor new];
    interactor.output = presenter;
    presenter.userInterface = controller;
    presenter.interactor = interactor;
    controller.eventHandler = presenter;
}

@end
