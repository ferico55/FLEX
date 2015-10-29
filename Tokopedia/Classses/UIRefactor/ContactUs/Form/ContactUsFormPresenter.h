//
//  ContactUsFormPresenter.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContactUsFormViewInterface.h"
#import "ContactUsFormModuleInterface.h"
#import "ContactUsFormInteractor.h"
#import "ContactUsFormWireframe.h"
#import "ContactUsFormDataCollector.h"

#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"

@protocol ContactUsFormViewInterface;

@interface ContactUsFormPresenter : NSObject
<
    ContactUsFormInteractorOutput,
    ContactUsFormModuleInterface,
    CameraAlbumListDelegate,
    CameraCollectionViewControllerDelegate
>

@property (nonatomic, strong) id<ContactUsFormInteractorInput> interactor;
@property (nonatomic, strong) UIViewController<ContactUsFormViewInterface> *userInterface;
@property (nonatomic, strong) ContactUsFormWireframe *wireframe;
@property (nonatomic, strong) ContactUsFormDataCollector *dataCollector;

@end
