//
//  TKPDTabInboxCustomerServiceNavigationController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDTabInboxCustomerServiceNavigationController.h"
#import "InboxTicketViewController.h"

@interface TKPDTabInboxCustomerServiceNavigationController () {
    InboxTicketViewController *_allInboxController;
    InboxTicketViewController *_processInboxController;
    InboxTicketViewController *_closedInboxController;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation TKPDTabInboxCustomerServiceNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    _allInboxController = [InboxTicketViewController new];
    _processInboxController = [InboxTicketViewController new];
    _closedInboxController = [InboxTicketViewController new];

    _segmentedControl.selectedSegmentIndex = 0;
    [self valueChangedSegmentedControl:_segmentedControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)valueChangedSegmentedControl:(UISegmentedControl *)sender {
    UIViewController *controller;
    if (sender.selectedSegmentIndex == 0) {
        controller = _allInboxController;
    } else if (sender.selectedSegmentIndex == 1) {
        controller = _processInboxController;
    } else if (sender.selectedSegmentIndex == 2) {
        controller = _closedInboxController;
    }
    controller.view.frame = _containerView.bounds;
    [_containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

@end
