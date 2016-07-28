//
//  ContactUsFormWireframe.m
//  Tokopedia
//
//  Created by Tokopedia on 9/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsFormWireframe.h"
#import "ContactUsFormPresenter.h"
#import "ContactUsFormViewController.h"

#import "camera.h"
#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"

#import "TKPDTabViewController.h"
#import "InboxTicketViewController.h"
#import "InboxTicketDetailViewController.h"
#import "InboxTicketSplitViewController.h"

@implementation ContactUsFormWireframe

- (void)pushToContactFormWithMainCategory:(TicketCategory *)mainCategory
                            subCategories:(NSArray *)subCategories
                           fromNavigation:(UINavigationController *)navigation {
    ContactUsFormViewController *controller = [ContactUsFormViewController new];
    controller.mainCategory = mainCategory;
    controller.subCategories = subCategories;
    controller.eventHandler = self.presenter;
    self.presenter.userInterface = controller;
    [navigation pushViewController:controller animated:YES];
}

- (void)presentPhotoPickerFromNavigation:(UINavigationController *)navigation {
    CameraAlbumListViewController *albumVC = [CameraAlbumListViewController new];
    albumVC.title = @"Album";
    albumVC.delegate = self.presenter;
    
    CameraCollectionViewController *photoVC = [CameraCollectionViewController new];
    photoVC.title = @"All Picture";
    photoVC.delegate = self.presenter;
    photoVC.maxSelected = 1;
    
    UINavigationController *nav = [[UINavigationController alloc]init];
    UIColor *backgroundColor = [UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1];
    nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:backgroundColor.CGColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [nav setViewControllers:@[albumVC,photoVC]];
    
    [navigation presentViewController:nav animated:YES completion:nil];
}

- (void)pushToInboxDetailFromNavigation:(UINavigationController *)navigation {
    InboxTicketDetailViewController *controller = [InboxTicketDetailViewController new];
    controller.inboxTicketId = self.presenter.dataCollector.inboxTicketId;
    [navigation popViewControllerAnimated:NO];
    [navigation pushViewController:controller animated:YES];
}

- (void)pushToInboxTicketFromNavigation:(UINavigationController *)navigation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        InboxTicketSplitViewController *controller = [InboxTicketSplitViewController new];
        
        [navigation pushViewController:controller animated:YES];
    } else {
        TKPDTabViewController *controller = [TKPDTabViewController new];
        controller.hidesBottomBarWhenPushed = YES;
        
        InboxTicketViewController *allInbox = [InboxTicketViewController new];
        allInbox.inboxCustomerServiceType = InboxCustomerServiceTypeAll;
        allInbox.delegate = controller;
        
        InboxTicketViewController *unreadInbox = [InboxTicketViewController new];
        unreadInbox.inboxCustomerServiceType = InboxCustomerServiceTypeInProcess;
        unreadInbox.delegate = controller;
        
        InboxTicketViewController *closedInbox = [InboxTicketViewController new];
        closedInbox.inboxCustomerServiceType = InboxCustomerServiceTypeClosed;
        closedInbox.delegate = controller;
        
        controller.viewControllers = @[allInbox, unreadInbox, closedInbox];
        controller.tabTitles = @[@"Semua", @"Dalam Proses", @"Ditutup"];
        controller.menuTitles = @[@"Semua Layanan Pengguna", @"Belum Dibaca"];
        
        [navigation pushViewController:controller animated:YES];
    }
    
}

@end
