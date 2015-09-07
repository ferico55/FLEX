//
//  ContactUsWireframe.m
//  Tokopedia
//
//  Created by Tokopedia on 9/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TPRootWireframe.h"
#import "ContactUsWireframe.h"
#import "ContactUsViewController.h"
#import "ContactUsPresenter.h"
#import "GeneralTableViewController.h"
#import "ContactUsFormViewController.h"

@implementation ContactUsWireframe

- (void)pushContactUsViewControllerFromNavigation:(UINavigationController *)navigation {
    [navigation pushViewController:self.presenter.userInterface animated:YES];
}

- (void)pushContactUsProblemFromNavigation:(UINavigationController *)navigation {
    NSArray *object = [self.presenter.dataCollector selectedProblemTitles];
    NSString *selectedObject = self.presenter.dataCollector.selectedProblem.ticket_category_name;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.title = @"Pilih Masalah";
    controller.objects = object;
    controller.selectedObject = selectedObject;
    controller.delegate = self.presenter;
    controller.senderIndexPath = indexPath;
    [navigation pushViewController:controller animated:YES];
}

- (void)pushContactUsProblemDetailFromNavigation:(UINavigationController *)navigation {
    NSArray *object = [self.presenter.dataCollector selectedProblemDetailTitles];
    NSString *selectedObject = self.presenter.dataCollector.selectedDetailProblem.ticket_category_name;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.title = @"Pilih Detail Masalah";
    controller.objects = object;
    controller.selectedObject = selectedObject;
    controller.delegate = self.presenter;
    controller.senderIndexPath = indexPath;
    [navigation pushViewController:controller animated:YES];
}

- (void)pushContactUsProblemDetailChoicesFromNavigation:(UINavigationController *)navigation {
    
}

- (void)pushContactUsFormViewFromNavigation:(UINavigationController *)navigation {
    ContactUsFormViewController *controller = [ContactUsFormViewController new];
    controller.contactUsType = self.presenter.dataCollector.selectedType;
    controller.problem = self.presenter.dataCollector.selectedProblem;
    controller.detailProblem = self.presenter.dataCollector.selectedDetailProblem;
    [navigation pushViewController:controller animated:YES];
}

@end
