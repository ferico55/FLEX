//
//  ContactUsWireframe.m
//  Tokopedia
//
//  Created by Tokopedia on 9/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TPRootWireframe.h"

#import "GeneralTableViewController.h"

#import "ContactUsWireframe.h"
#import "ContactUsPresenter.h"
#import "ContactUsViewController.h"

@implementation ContactUsWireframe

- (void)pushContactUsViewControllerFromNavigation:(UINavigationController *)navigation {
    [navigation pushViewController:self.presenter.userInterface animated:YES];
}

- (void)pushCategoryFromNavigation:(UINavigationController *)navigation {
    NSArray *object = [self.presenter.dataCollector categoryTitles];
    NSString *selectedObject = self.presenter.dataCollector.selectedCategory.ticket_category_name;
    NSIndexPath *senderIndexPath = self.presenter.dataCollector.senderIndexPath;
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.title = @"Pilih Masalah";
    controller.objects = object;
    controller.selectedObject = selectedObject;
    controller.delegate = self.presenter;
    controller.senderIndexPath = senderIndexPath;
    [navigation pushViewController:controller animated:YES];
}

- (void)pushContactUsFormViewFromNavigation:(UINavigationController *)navigation {
    ContactUsDataCollector *data = self.presenter.dataCollector;
    [self.formWireframe pushToContactFormWithMainCategory:data.mainCategory
                                            subCategories:data.subCategories
                                           fromNavigation:navigation];
}

@end
