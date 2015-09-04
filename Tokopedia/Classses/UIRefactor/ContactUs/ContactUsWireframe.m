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

@implementation ContactUsWireframe

- (void)pushContactUsViewControllerFromNavigation:(UINavigationController *)navigation {
    [navigation pushViewController:self.presenter.userInterface animated:YES];
}

- (void)pushContactUsProblemChoices:(NSArray *)choices
                    selectedProblem:(NSString *)problem
                     fromNavigation:(UINavigationController *)navigation {
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.title = @"Pilih Masalah";
    controller.objects = choices;
    controller.selectedObject = problem;
    controller.delegate = self.presenter;
    [navigation pushViewController:controller animated:YES];
}

- (void)pushContactUsProblemDetailChoicesFromNavigation:(UINavigationController *)navigation {
    
}

- (void)pushContactUsFormViewFromNavigation:(UINavigationController *)navigation {
    
}

@end
